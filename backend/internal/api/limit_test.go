package api

import (
	"fmt"
	"io"
	"log/slog"
	"math/rand"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"
	"time"

	"eshop-radar/backend/internal/testdb"
)

func limited(t *testing.T, perMin int, trust string) http.Handler {
	t.Helper()
	h, err := NewHandler(Config{Pool: testdb.Pool(t), Log: slog.New(slog.NewTextHandler(io.Discard, nil)), RatePerMin: perMin, TrustProxy: trust})
	if err != nil {
		t.Fatal(err)
	}
	return h
}

func from(h http.Handler, remote string, headers map[string]string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodGet, "/v1/genres", nil)
	req.RemoteAddr = remote
	for k, v := range headers {
		req.Header.Set(k, v)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestTooManyRequestsGetA429WithRetryAfter(t *testing.T) {
	h := limited(t, 3, TrustNone)
	for i := 1; i <= 3; i++ {
		if rec := from(h, "203.0.113.5:4000", nil); rec.Code != http.StatusOK {
			t.Fatalf("request %d = %d", i, rec.Code)
		}
	}
	rec := from(h, "203.0.113.5:4001", nil) // same address, another port: same client
	if rec.Code != http.StatusTooManyRequests {
		t.Fatalf("4th request = %d, want 429", rec.Code)
	}
	secs, err := strconv.Atoi(rec.Header().Get("Retry-After"))
	if err != nil || secs < 1 || secs > 60 {
		t.Errorf("Retry-After = %q, want a whole number of seconds from 1 to 60", rec.Header().Get("Retry-After"))
	}
	if ct := rec.Header().Get("Content-Type"); ct != "application/json" {
		t.Errorf("429 Content-Type = %q", ct)
	}
	// somebody else is not held back, and /healthz and the app are never limited
	if rec := from(h, "203.0.113.6:4000", nil); rec.Code != http.StatusOK {
		t.Errorf("another client = %d", rec.Code)
	}
	for i := 0; i < 10; i++ {
		req := httptest.NewRequest(http.MethodGet, "/healthz", nil)
		req.RemoteAddr = "203.0.113.5:4000"
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		if rec.Code != http.StatusOK {
			t.Fatalf("/healthz was limited: %d", rec.Code)
		}
	}
}

func TestLimitIsOffAtZero(t *testing.T) {
	h := limited(t, 0, TrustNone)
	for i := 0; i < 50; i++ {
		if rec := from(h, "203.0.113.5:4000", nil); rec.Code != http.StatusOK {
			t.Fatalf("request %d = %d with the limit off", i, rec.Code)
		}
	}
}

func TestLimiterWindowResetsAndTheMapStaysBounded(t *testing.T) {
	now := time.Date(2026, 11, 2, 12, 0, 0, 0, time.UTC)
	l := NewLimiter(2, time.Minute, 100)
	l.now = func() time.Time { return now }

	l.Allow("a")
	l.Allow("a")
	if ok, wait := l.Allow("a"); ok || wait != time.Minute {
		t.Fatalf("third request: ok=%v wait=%v, want refused for the full minute", ok, wait)
	}
	now = now.Add(30 * time.Second)
	if ok, wait := l.Allow("a"); ok || wait != 30*time.Second {
		t.Fatalf("after 30s: ok=%v wait=%v, want 30s left", ok, wait)
	}
	now = now.Add(31 * time.Second)
	if ok, _ := l.Allow("a"); !ok {
		t.Fatal("a new window should let the client in again")
	}

	// a flood of distinct addresses inside one window cannot grow the map past its bound
	for i := 0; i < 10000; i++ {
		l.Allow(fmt.Sprintf("10.%d.%d.%d", i>>16, (i>>8)&255, i&255))
		if l.Len() > 100 {
			t.Fatalf("limiter holds %d keys after %d distinct clients, bound is 100", l.Len(), i+1)
		}
	}
	// and once their windows are over, they are swept out
	now = now.Add(2 * time.Minute)
	l.Allow("fresh")
	if l.Len() > 100 {
		t.Errorf("limiter holds %d keys", l.Len())
	}
}

func TestForwardedAddressIsOnlyBelievedWhenTold(t *testing.T) {
	spoof := func(i int) map[string]string {
		return map[string]string{"X-Forwarded-For": fmt.Sprintf("198.51.100.%d", i), "Cf-Connecting-Ip": fmt.Sprintf("198.51.100.%d", i)}
	}
	run := func(h http.Handler, n int, headers func(int) map[string]string) string {
		codes := []int{}
		for i := 0; i < n; i++ {
			codes = append(codes, from(h, "127.0.0.1:5000", headers(i)).Code)
		}
		return fmt.Sprint(codes)
	}

	// not behind a proxy we trust: a client choosing its own headers gains nothing
	if got := run(limited(t, 2, TrustNone), 4, spoof); got != "[200 200 429 429]" {
		t.Errorf("TRUST_PROXY off, spoofed headers: %s, want [200 200 429 429]", got)
	}

	// Vercel: X-Forwarded-For holds the visitor and is believed; a Cf-Connecting-Ip the client invents is not
	h := limited(t, 2, TrustForwarded)
	for i := 0; i < 4; i++ {
		if rec := from(h, "127.0.0.1:5000", map[string]string{"X-Forwarded-For": fmt.Sprintf("198.51.100.%d", i)}); rec.Code != http.StatusOK {
			t.Errorf("trusted X-Forwarded-For, visitor %d = %d", i, rec.Code)
		}
	}
	same := func(int) map[string]string {
		return map[string]string{"X-Forwarded-For": "198.51.100.77", "Cf-Connecting-Ip": fmt.Sprintf("203.0.113.%d", rand.Intn(250))}
	}
	if got := run(limited(t, 2, TrustForwarded), 4, same); got != "[200 200 429 429]" {
		t.Errorf("TRUST_PROXY=true must ignore Cf-Connecting-Ip, got %s", got)
	}
	// only the entry the proxy appended counts, not one the client put in front of it
	fixed := func(int) map[string]string { return map[string]string{"X-Forwarded-For": "9.9.9.9, 198.51.100.77"} }
	h = limited(t, 2, TrustForwarded)
	if got := run(h, 3, fixed); got != "[200 200 429]" {
		t.Errorf("client-added first XFF entry: %s", got)
	}
	// no header at all: the socket address
	if rec := from(limited(t, 2, TrustForwarded), "127.0.0.1:5000", nil); rec.Code != http.StatusOK {
		t.Errorf("trusted proxy but no header = %d", rec.Code)
	}

	// behind a Cloudflare tunnel: Cf-Connecting-Ip first
	h = limited(t, 2, TrustCloudflare)
	for i := 0; i < 4; i++ {
		if rec := from(h, "127.0.0.1:5000", map[string]string{"Cf-Connecting-Ip": fmt.Sprintf("198.51.100.%d", i)}); rec.Code != http.StatusOK {
			t.Errorf("cloudflare mode, visitor %d = %d", i, rec.Code)
		}
	}
}

func TestRestorePathPutsTheVisitorsPathBack(t *testing.T) {
	for _, c := range []struct{ in, wantPath, wantQuery string }{
		{"/api/index?p=/v1/games/123", "/v1/games/123", ""},
		{"/api/index?p=/v1/games&sort=price&limit=5", "/v1/games", "limit=5&sort=price"},
		{"/api/index?p=/healthz", "/healthz", ""},
		{"/api/index?path=genres", "/v1/genres", ""},
		{"/api/index?path=games/7&ids=1,2", "/v1/games/7", "ids=1%2C2"},
		{"/v1/genres?sort=x", "/v1/genres", "sort=x"}, // already the real path: untouched
	} {
		r := httptest.NewRequest(http.MethodGet, c.in, nil)
		RestorePath(r)
		if r.URL.Path != c.wantPath || r.URL.RawQuery != c.wantQuery {
			t.Errorf("%s -> path %q query %q, want %q %q", c.in, r.URL.Path, r.URL.RawQuery, c.wantPath, c.wantQuery)
		}
	}
}
