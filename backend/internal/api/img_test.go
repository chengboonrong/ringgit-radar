package api

import (
	"bytes"
	"errors"
	"fmt"
	"image"
	"image/color"
	"image/jpeg"
	"io"
	"log/slog"
	"math/rand"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

const hashA = "97c37e800cf3069eeba29725f46d2b54632752e19a016ee8f48eed26d82c2a64"

func testJPEG(w, h int) []byte {
	img := image.NewRGBA(image.Rect(0, 0, w, h))
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			img.Set(x, y, color.RGBA{uint8(x % 256), uint8(y % 256), 90, 255})
		}
	}
	var b bytes.Buffer
	jpeg.Encode(&b, img, nil)
	return b.Bytes()
}

type upstream struct {
	*httptest.Server
	calls   atomic.Int32
	paths   []string
	agents  []string
	queries []string
	mu      sync.Mutex
	status  int // 0 = 200
	delay   time.Duration
	live    atomic.Int32
	maxLive atomic.Int32
}

func newUpstream(t *testing.T) *upstream {
	u := &upstream{}
	u.Server = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		u.calls.Add(1)
		n := u.live.Add(1)
		defer u.live.Add(-1)
		for {
			m := u.maxLive.Load()
			if n <= m || u.maxLive.CompareAndSwap(m, n) {
				break
			}
		}
		u.mu.Lock()
		u.paths = append(u.paths, r.URL.Path)
		u.agents = append(u.agents, r.Header.Get("User-Agent"))
		u.queries = append(u.queries, r.URL.RawQuery)
		status := u.status
		u.mu.Unlock()
		time.Sleep(u.delay)
		if status != 0 {
			w.WriteHeader(status)
			return
		}
		w.Header().Set("Content-Type", "image/jpeg")
		w.Write(testJPEG(1000, 562))
	}))
	t.Cleanup(u.Close)
	return u
}

func newProxy(t *testing.T, u *upstream) (*ImageProxy, http.Handler) {
	t.Helper()
	p := NewImageProxy(t.TempDir(), "RinggitRadar/test", slog.New(slog.NewTextHandler(io.Discard, nil)))
	p.Upstream = u.URL + "/i/"
	// the image route needs no database
	return p, New(nil, p, slog.New(slog.NewTextHandler(io.Discard, nil)))
}

func fetch(h http.Handler, path string) *httptest.ResponseRecorder {
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))
	return rec
}

func TestImageProxyResizesCachesAndMakesOneUpstreamCall(t *testing.T) {
	u := newUpstream(t)
	_, h := newProxy(t, u)

	rec := fetch(h, "/v1/img/"+hashA+"?w=320")
	if rec.Code != 200 || rec.Header().Get("Content-Type") != "image/jpeg" ||
		rec.Header().Get("Cache-Control") != "public, max-age=31536000, s-maxage=31536000, immutable" {
		t.Fatalf("code=%d headers=%v", rec.Code, rec.Header())
	}
	cfg, err := jpeg.DecodeConfig(rec.Body)
	if err != nil || cfg.Width != 320 || cfg.Height != 180 {
		t.Fatalf("size = %dx%d, %v", cfg.Width, cfg.Height, err)
	}
	if u.calls.Load() != 1 || u.paths[0] != "/i/"+hashA+".jpg" || u.queries[0] != "" || u.agents[0] != "RinggitRadar/test" {
		t.Fatalf("upstream: calls=%d paths=%v queries=%q agents=%v", u.calls.Load(), u.paths, u.queries, u.agents)
	}

	// same image and width again, and the same image at another width: no second upstream call
	if rec := fetch(h, "/v1/img/"+hashA+"?w=320"); rec.Code != 200 {
		t.Fatalf("second fetch = %d", rec.Code)
	}
	rec = fetch(h, "/v1/img/"+hashA+"?w=640")
	if cfg, _ := jpeg.DecodeConfig(rec.Body); rec.Code != 200 || cfg.Width != 640 {
		t.Fatalf("640 fetch: code=%d width=%d", rec.Code, cfg.Width)
	}
	if n := u.calls.Load(); n != 1 {
		t.Fatalf("upstream calls = %d, want 1", n)
	}

	// never upscaled: the 1000 px original is served as is for 1280
	rec = fetch(h, "/v1/img/"+hashA+"?w=1280")
	if cfg, _ := jpeg.DecodeConfig(rec.Body); cfg.Width != 1000 {
		t.Fatalf("1280 width = %d, want the 1000 px original", cfg.Width)
	}
	if rec := fetch(h, "/v1/img/"+hashA); rec.Code != 200 { // default width
		t.Fatalf("default width = %d", rec.Code)
	}
}

func TestImageProxyRejectsBadHashAndWidthBeforeUpstream(t *testing.T) {
	u := newUpstream(t)
	_, h := newProxy(t, u)
	bad := []string{
		"/v1/img/" + strings.ToUpper(hashA) + "?w=320",
		"/v1/img/" + hashA[:63] + "?w=320",
		"/v1/img/" + hashA + "0?w=320",
		"/v1/img/..%2F..%2Fetc%2Fpasswd?w=320",
		"/v1/img/" + hashA[:60] + "zzzz?w=320",
		"/v1/img/" + hashA + "?w=100",
		"/v1/img/" + hashA + "?w=641",
		"/v1/img/" + hashA + "?w=abc",
		"/v1/img/" + hashA + "?w=-320",
	}
	for _, path := range bad {
		if rec := fetch(h, path); rec.Code != http.StatusBadRequest && rec.Code != http.StatusNotFound {
			t.Errorf("%s = %d, want 400 or 404", path, rec.Code)
		}
	}
	if n := u.calls.Load(); n != 0 {
		t.Fatalf("upstream was called %d times for rejected requests", n)
	}
}

func TestImageProxyStopsAfter403(t *testing.T) {
	u := newUpstream(t)
	u.status = http.StatusForbidden
	p, h := newProxy(t, u)
	other := strings.Repeat("ab", 32)

	if rec := fetch(h, "/v1/img/"+hashA+"?w=320"); rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("first = %d", rec.Code)
	}
	if rec := fetch(h, "/v1/img/"+other+"?w=320"); rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("second = %d", rec.Code)
	}
	if n := u.calls.Load(); n != 1 {
		t.Fatalf("upstream calls = %d, want 1: after a 403 nothing more is asked", n)
	}
	if !p.blocked.Load() {
		t.Fatal("proxy should be marked blocked")
	}
	if entries, _ := os.ReadDir(p.Dir); len(entries) != 0 {
		t.Fatalf("cache dir has %d files after a refusal", len(entries))
	}
}

func TestImageProxyUnknownImageIs404AndNotCached(t *testing.T) {
	u := newUpstream(t)
	u.status = http.StatusNotFound
	p, h := newProxy(t, u)
	if rec := fetch(h, "/v1/img/"+hashA+"?w=320"); rec.Code != http.StatusNotFound {
		t.Fatalf("code = %d", rec.Code)
	}
	if m, _ := filepath.Glob(filepath.Join(p.Dir, hashA+"*")); len(m) != 0 {
		t.Fatalf("cached a 404: %v", m)
	}
	if rec := fetch(h, "/v1/img/"+hashA+"?w=320"); rec.Code != http.StatusNotFound || u.calls.Load() != 2 {
		t.Fatalf("a missing image may be asked for again; calls = %d", u.calls.Load())
	}
}

func TestImageProxyAtMostFourUpstreamFetchesAtOnce(t *testing.T) {
	u := newUpstream(t)
	u.delay = 80 * time.Millisecond
	_, h := newProxy(t, u)

	var wg sync.WaitGroup
	for i := 0; i < 12; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			hash := fmt.Sprintf("%064x", i+1)
			if rec := fetch(h, "/v1/img/"+hash+"?w=320"); rec.Code != 200 {
				t.Errorf("%s = %d", hash, rec.Code)
			}
		}()
	}
	wg.Wait()
	if m := u.maxLive.Load(); m > 4 || m < 2 {
		t.Fatalf("max concurrent upstream fetches = %d, want 2 to 4", m)
	}
	if n := u.calls.Load(); n != 12 {
		t.Fatalf("calls = %d", n)
	}
}

func TestImageProxyConcurrentSameImageIsOneFetch(t *testing.T) {
	u := newUpstream(t)
	u.delay = 80 * time.Millisecond
	_, h := newProxy(t, u)
	var wg sync.WaitGroup
	for i := 0; i < 6; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			if rec := fetch(h, "/v1/img/"+hashA+"?w=640"); rec.Code != 200 {
				t.Errorf("code %d", rec.Code)
			}
		}()
	}
	wg.Wait()
	if n := u.calls.Load(); n != 1 {
		t.Fatalf("calls = %d, want 1", n)
	}
}

func TestImageProxyHourlyCapStopsUpstreamFetchesAndNeverRetries(t *testing.T) {
	u := newUpstream(t)
	p, h := newProxy(t, u)
	p.UpstreamPerHour = 2
	clock := time.Date(2026, 11, 2, 12, 0, 0, 0, time.UTC)
	p.now = func() time.Time { return clock }
	hash := func(i int) string { return fmt.Sprintf("%064x", i) }

	for i := 1; i <= 2; i++ {
		if rec := fetch(h, "/v1/img/"+hash(i)+"?w=320"); rec.Code != 200 {
			t.Fatalf("image %d = %d", i, rec.Code)
		}
	}
	// the third distinct image is over the cap: 503, a Retry-After, and no request to the source
	rec := fetch(h, "/v1/img/"+hash(3)+"?w=320")
	if rec.Code != http.StatusServiceUnavailable {
		t.Fatalf("over the cap = %d, want 503", rec.Code)
	}
	if secs, err := strconv.Atoi(rec.Header().Get("Retry-After")); err != nil || secs < 1 || secs > 3600 {
		t.Errorf("Retry-After = %q", rec.Header().Get("Retry-After"))
	}
	for i := 0; i < 5; i++ { // asking again never reaches the source
		if rec := fetch(h, "/v1/img/"+hash(3)+"?w=320"); rec.Code != http.StatusServiceUnavailable {
			t.Fatalf("retry %d = %d", i, rec.Code)
		}
	}
	if n := u.calls.Load(); n != 2 {
		t.Fatalf("upstream calls = %d, want 2", n)
	}
	// cached images do not count and keep working, at any width
	if rec := fetch(h, "/v1/img/"+hash(1)+"?w=320"); rec.Code != 200 {
		t.Errorf("cached image = %d", rec.Code)
	}
	if rec := fetch(h, "/v1/img/"+hash(1)+"?w=640"); rec.Code != 200 {
		t.Errorf("cached original at another width = %d", rec.Code)
	}
	if n := u.calls.Load(); n != 2 {
		t.Fatalf("cached requests reached the source: calls = %d", n)
	}

	// the next hour has a fresh budget
	clock = clock.Add(61 * time.Minute)
	if rec := fetch(h, "/v1/img/"+hash(3)+"?w=320"); rec.Code != 200 {
		t.Errorf("after the hour = %d", rec.Code)
	}
	if n := u.calls.Load(); n != 3 {
		t.Errorf("calls = %d, want 3", n)
	}
}

func TestImageProxyCapZeroMeansNoCap(t *testing.T) {
	u := newUpstream(t)
	p, h := newProxy(t, u)
	p.UpstreamPerHour = 0
	for i := 1; i <= 5; i++ {
		if rec := fetch(h, "/v1/img/"+fmt.Sprintf("%064x", i)+"?w=320"); rec.Code != 200 {
			t.Fatalf("image %d = %d", i, rec.Code)
		}
	}
}

func TestImageProxyWithoutADiskFetchesAndResizesPerRequest(t *testing.T) {
	u := newUpstream(t)
	p, h := newProxy(t, u)
	dir := p.Dir
	p.Dir = "" // IMG_CACHE=none
	const long = "public, max-age=31536000, s-maxage=31536000, immutable"

	rec := fetch(h, "/v1/img/"+hashA+"?w=320")
	if rec.Code != 200 || rec.Header().Get("Cache-Control") != long || rec.Header().Get("Content-Type") != "image/jpeg" {
		t.Fatalf("code=%d headers=%v", rec.Code, rec.Header())
	}
	cfg, err := jpeg.DecodeConfig(bytes.NewReader(rec.Body.Bytes()))
	if err != nil || cfg.Width != 320 {
		t.Fatalf("width = %d, %v", cfg.Width, err)
	}
	if rec.Header().Get("Content-Length") != strconv.Itoa(rec.Body.Len()) || rec.Body.Len() > 4_000_000 {
		t.Errorf("content length %q for %d bytes", rec.Header().Get("Content-Length"), rec.Body.Len())
	}
	// nothing is kept: a second request goes upstream again
	if rec := fetch(h, "/v1/img/"+hashA+"?w=320"); rec.Code != 200 {
		t.Fatalf("second = %d", rec.Code)
	}
	if n := u.calls.Load(); n != 2 {
		t.Errorf("upstream calls = %d, want 2 (no disk, no cache)", n)
	}
	if entries, _ := os.ReadDir(dir); len(entries) != 0 {
		t.Errorf("wrote %d files with the disk off", len(entries))
	}
	// the whitelist and the hash check still hold
	for _, path := range []string{"/v1/img/" + hashA + "?w=100", "/v1/img/" + strings.ToUpper(hashA) + "?w=320"} {
		if rec := fetch(h, path); rec.Code != http.StatusBadRequest || rec.Header().Get("Cache-Control") != "no-store" {
			t.Errorf("%s = %d cache-control %q", path, rec.Code, rec.Header().Get("Cache-Control"))
		}
	}
	if n := u.calls.Load(); n != 2 {
		t.Errorf("rejected requests reached the source: %d", n)
	}
}

func TestImageProxyFailuresAreNeverCached(t *testing.T) {
	u := newUpstream(t)
	p, h := newProxy(t, u)
	p.Dir = ""
	p.UpstreamPerHour = 1

	u.status = http.StatusNotFound
	rec := fetch(h, "/v1/img/"+hashA+"?w=320")
	if rec.Code != http.StatusNotFound || rec.Header().Get("Cache-Control") != "no-store" {
		t.Errorf("404: %d %q", rec.Code, rec.Header().Get("Cache-Control"))
	}
	// the budget (1) is spent by that attempt, so the next image is a 503 with no-store and a Retry-After
	rec = fetch(h, "/v1/img/"+strings.Repeat("ab", 32)+"?w=320")
	if rec.Code != http.StatusServiceUnavailable || rec.Header().Get("Cache-Control") != "no-store" || rec.Header().Get("Retry-After") == "" {
		t.Errorf("503: %d cache-control %q retry-after %q", rec.Code, rec.Header().Get("Cache-Control"), rec.Header().Get("Retry-After"))
	}
	if strings.Contains(rec.Header().Get("Cache-Control"), "max-age=31536000") {
		t.Error("an error carried the long cache header")
	}
}

func TestHugeOriginalsNeverExceedTheResponseLimit(t *testing.T) {
	// an incompressible original bigger than the limit is squeezed once, or refused, never sent as it is
	noise := image.NewRGBA(image.Rect(0, 0, 3000, 2000))
	rnd := rand.New(rand.NewSource(1))
	for i := range noise.Pix {
		noise.Pix[i] = uint8(rnd.Intn(256))
	}
	var big bytes.Buffer
	jpeg.Encode(&big, noise, &jpeg.Options{Quality: 100})
	if big.Len() < maxResponseBytes {
		t.Fatalf("test image is only %d bytes, it must be over the limit", big.Len())
	}
	out, err := resize(big.Bytes(), 5000, "x") // asked for more than the source has: no upscale, but too big
	if err != nil && !errors.Is(err, errTooLarge) {
		t.Fatal(err)
	}
	if err == nil && len(out) > maxResponseBytes {
		t.Fatalf("resize returned %d bytes, over the limit", len(out))
	}
}
