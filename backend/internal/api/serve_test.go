package api

import (
	"context"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5"

	"eshop-radar/backend/internal/db"
	"eshop-radar/backend/internal/testdb"
)

const sitePassword = "correct horse"

// site builds the whole handler over a real database and a web directory with a few files in it.
func site(t *testing.T, password string) (http.Handler, string) {
	t.Helper()
	pool := testdb.Pool(t)
	dir := t.TempDir()
	web := filepath.Join(dir, "web")
	for name, body := range map[string]string{
		"index.html":               "<!doctype html><title>app</title>",
		"main.dart.wasm":           "\x00asm\x01\x00\x00\x00",
		"flutter_bootstrap.js":     "console.log(1)",
		"assets/note.txt":          "a note",
		"canvaskit/canvaskit.wasm": "\x00asm",
		"assets/nested/index.html": "should not list or serve as a directory index",
	} {
		p := filepath.Join(web, name)
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, []byte(body), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	secret := filepath.Join(dir, "secret.txt")
	if err := os.WriteFile(secret, []byte("TOP SECRET"), 0o644); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(secret, filepath.Join(web, "leak.txt")); err != nil { // a link out of the web dir
		t.Fatal(err)
	}
	h, err := NewHandler(Config{Pool: pool, Log: slog.New(slog.NewTextHandler(io.Discard, nil)), WebDir: web, Password: password})
	if err != nil {
		t.Fatal(err)
	}
	return h, dir
}

func do(h http.Handler, method, target, user, pass string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(method, target, nil)
	if pass != "" || user != "" {
		req.SetBasicAuth(user, pass)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func TestEverythingNeedsThePasswordExceptHealthz(t *testing.T) {
	h, _ := site(t, sitePassword)
	for _, path := range []string{"/", "/games/1", "/main.dart.wasm", "/v1/genres", "/v1/games", "/v1/img/" + strings.Repeat("a", 64) + "?w=320", "/v1/nothing"} {
		rec := do(h, http.MethodGet, path, "", "")
		if rec.Code != http.StatusUnauthorized {
			t.Errorf("%s without credentials = %d, want 401", path, rec.Code)
		}
		if got := rec.Header().Get("WWW-Authenticate"); !strings.HasPrefix(got, `Basic realm="Ringgit Radar"`) {
			t.Errorf("%s challenge = %q", path, got)
		}
		if strings.Contains(rec.Body.String(), "<title>app</title>") {
			t.Errorf("%s leaked the app to an unauthenticated request", path)
		}
	}
	// the OPTIONS preflight is behind the gate too
	if rec := do(h, http.MethodOptions, "/v1/genres", "", ""); rec.Code != http.StatusUnauthorized {
		t.Errorf("OPTIONS = %d", rec.Code)
	}
}

func TestRightPasswordGetsInWithAnyUsername(t *testing.T) {
	h, _ := site(t, sitePassword)
	for _, user := range []string{"", "owner", "a friend"} {
		if rec := do(h, http.MethodGet, "/v1/genres", user, sitePassword); rec.Code != http.StatusOK {
			t.Errorf("user %q: /v1/genres = %d", user, rec.Code)
		}
	}
	if rec := do(h, http.MethodGet, "/", "friend", sitePassword); rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), "<title>app</title>") {
		t.Errorf("/ = %d %q", rec.Code, rec.Body.String())
	}
}

func TestWrongPasswordIsRefused(t *testing.T) {
	h, _ := site(t, sitePassword)
	for _, pass := range []string{"wrong", sitePassword + " ", strings.ToUpper(sitePassword), "correct", sitePassword + sitePassword} {
		if rec := do(h, http.MethodGet, "/v1/genres", "friend", pass); rec.Code != http.StatusUnauthorized {
			t.Errorf("password %q = %d, want 401", pass, rec.Code)
		}
	}
	// not Basic, and not valid base64
	for _, auth := range []string{"Bearer " + sitePassword, "Basic !!!not-base64!!!", "Basic", sitePassword} {
		req := httptest.NewRequest(http.MethodGet, "/v1/genres", nil)
		req.Header.Set("Authorization", auth)
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		if rec.Code != http.StatusUnauthorized {
			t.Errorf("Authorization %q = %d, want 401", auth, rec.Code)
		}
	}
}

func TestHealthzIsOpenAndChecksTheDatabase(t *testing.T) {
	h, _ := site(t, sitePassword)
	if rec := do(h, http.MethodGet, "/healthz", "", ""); rec.Code != http.StatusOK || strings.TrimSpace(rec.Body.String()) != "ok" {
		t.Fatalf("/healthz = %d %q", rec.Code, rec.Body.String())
	}
	if rec := do(h, http.MethodHead, "/healthz", "", ""); rec.Code != http.StatusOK {
		t.Errorf("HEAD /healthz = %d", rec.Code)
	}

	pool := testdb.Pool(t)
	down, err := NewHandler(Config{Pool: pool, Log: slog.New(slog.NewTextHandler(io.Discard, nil)), Password: sitePassword})
	if err != nil {
		t.Fatal(err)
	}
	pool.Close() // the database is gone
	if rec := do(down, http.MethodGet, "/healthz", "", ""); rec.Code != http.StatusServiceUnavailable {
		t.Errorf("/healthz with no database = %d, want 503", rec.Code)
	}
}

func TestNoPasswordMeansNoGate(t *testing.T) {
	h, _ := site(t, "")
	if rec := do(h, http.MethodGet, "/v1/genres", "", ""); rec.Code != http.StatusOK {
		t.Errorf("open site /v1/genres = %d", rec.Code)
	}
}

func TestExposureNeedsAPasswordOrAnExplicitPublicSite(t *testing.T) {
	for _, host := range []string{"0.0.0.0", "::", "[::]", "192.168.1.5", "10.0.0.1", "example.com", "0.0.0.0:80"} {
		if err := CheckExposure(host, "", false); err == nil || !strings.Contains(err.Error(), "PUBLIC=true") {
			t.Errorf("CheckExposure(%q, no password, not public) = %v, want a refusal naming PUBLIC=true", host, err)
		}
		if err := CheckExposure(host, "pw", false); err != nil {
			t.Errorf("CheckExposure(%q, password) = %v, want nil", host, err)
		}
		if err := CheckExposure(host, "", true); err != nil {
			t.Errorf("CheckExposure(%q, public) = %v, want nil", host, err)
		}
		// a site is public or it has a password, not both
		if err := CheckExposure(host, "pw", true); err == nil {
			t.Errorf("CheckExposure(%q, password and public) = nil, want a refusal", host)
		}
	}
	for _, host := range []string{"127.0.0.1", "::1", "[::1]", "localhost", "127.1.2.3"} {
		if err := CheckExposure(host, "", false); err != nil {
			t.Errorf("CheckExposure(%q, no password) = %v, want nil for loopback", host, err)
		}
	}
}

func TestPublicSiteHasNoGate(t *testing.T) {
	h, _ := site(t, "") // PUBLIC=true reaches the handler as an empty password
	for _, path := range []string{"/", "/v1/genres", "/healthz"} {
		if rec := do(h, http.MethodGet, path, "", ""); rec.Code != http.StatusOK {
			t.Errorf("public %s = %d, want 200 with no credentials", path, rec.Code)
		}
	}
}

func TestWebServesTheAppWithTheRightHeaders(t *testing.T) {
	h, _ := site(t, "")

	rec := do(h, http.MethodGet, "/", "", "")
	if rec.Code != 200 || !strings.Contains(rec.Body.String(), "<title>app</title>") {
		t.Fatalf("/ = %d", rec.Code)
	}
	if cc := rec.Header().Get("Cache-Control"); cc != "no-cache" {
		t.Errorf("index Cache-Control = %q, want no-cache", cc)
	}
	if rec.Header().Get("Cross-Origin-Opener-Policy") != "same-origin" || rec.Header().Get("Cross-Origin-Embedder-Policy") != "credentialless" {
		t.Errorf("isolation headers: %v", rec.Header())
	}

	wasm := do(h, http.MethodGet, "/main.dart.wasm", "", "")
	if ct := wasm.Header().Get("Content-Type"); ct != "application/wasm" {
		t.Errorf("main.dart.wasm Content-Type = %q", ct)
	}
	if ct := do(h, http.MethodGet, "/canvaskit/canvaskit.wasm", "", "").Header().Get("Content-Type"); ct != "application/wasm" {
		t.Errorf("canvaskit.wasm Content-Type = %q", ct)
	}
	if cc := do(h, http.MethodGet, "/canvaskit/canvaskit.wasm", "", "").Header().Get("Cache-Control"); !strings.Contains(cc, "max-age") {
		t.Errorf("canvaskit Cache-Control = %q", cc)
	}
	if ct := do(h, http.MethodGet, "/flutter_bootstrap.js", "", "").Header().Get("Content-Type"); !strings.Contains(ct, "javascript") {
		t.Errorf("js Content-Type = %q", ct)
	}
	if rec := do(h, http.MethodGet, "/assets/note.txt", "", ""); rec.Body.String() != "a note" {
		t.Errorf("a real file = %q", rec.Body.String())
	}
}

func TestUnknownPathsFallBackToTheAppButV1StaysTheAPI(t *testing.T) {
	h, _ := site(t, "")
	for _, path := range []string{"/games/70010000118902", "/sale", "/ranking", "/wish-list", "/assets/", "/assets", "/nothing/here.png"} {
		if rec := do(h, http.MethodGet, path, "", ""); rec.Code != 200 || !strings.Contains(rec.Body.String(), "<title>app</title>") {
			t.Errorf("%s = %d %q, want the app", path, rec.Code, rec.Body.String())
		}
	}
	// the API keeps its own answers, JSON 404s included, and never falls back to the app
	rec := do(h, http.MethodGet, "/v1/does-not-exist", "", "")
	if rec.Code != http.StatusNotFound || !strings.Contains(rec.Header().Get("Content-Type"), "json") || strings.Contains(rec.Body.String(), "<title>") {
		t.Errorf("/v1/does-not-exist = %d %q %q", rec.Code, rec.Header().Get("Content-Type"), rec.Body.String())
	}
	if rec := do(h, http.MethodGet, "/v1/games/424242", "", ""); rec.Code != http.StatusNotFound || !strings.Contains(rec.Body.String(), "no such game") {
		t.Errorf("/v1/games/424242 = %d %q", rec.Code, rec.Body.String())
	}
	if rec := do(h, http.MethodGet, "/v1/genres", "", ""); rec.Code != 200 || !strings.Contains(rec.Header().Get("Content-Type"), "json") {
		t.Errorf("/v1/genres = %d", rec.Code)
	}
	if rec := do(h, http.MethodPost, "/", "", ""); rec.Code != http.StatusMethodNotAllowed {
		t.Errorf("POST / = %d", rec.Code)
	}
}

func TestWebCannotReadOutsideItsDirectory(t *testing.T) {
	h, dir := site(t, "")
	secret := "TOP SECRET"
	for _, target := range []string{
		"/leak.txt", // a symlink inside the web dir that points out of it
		"/../secret.txt", "/..%2fsecret.txt", "/%2e%2e/secret.txt", "/assets/../../secret.txt",
		"/assets/%2e%2e/%2e%2e/secret.txt", "//secret.txt", "/.." + dir + "/secret.txt", "/assets/..%5c..%5csecret.txt",
	} {
		req := httptest.NewRequest(http.MethodGet, "http://example.test"+target, nil)
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, req)
		if strings.Contains(rec.Body.String(), secret) {
			t.Errorf("%s leaked a file from outside the web directory", target)
		}
	}
	// an absolute path in the URL is just a path under the web dir
	if rec := do(h, http.MethodGet, dir+"/secret.txt", "", ""); strings.Contains(rec.Body.String(), secret) {
		t.Errorf("absolute path leaked")
	}
}

func TestStartingWithABadWebDirFails(t *testing.T) {
	pool := testdb.Pool(t)
	log := slog.New(slog.NewTextHandler(io.Discard, nil))
	if _, err := NewHandler(Config{Pool: pool, Log: log, WebDir: filepath.Join(t.TempDir(), "missing")}); err == nil {
		t.Error("a missing WEB_DIR must fail at start")
	}
	if _, err := NewHandler(Config{Pool: pool, Log: log, WebDir: t.TempDir()}); err == nil {
		t.Error("a WEB_DIR without index.html must fail at start")
	}
}

// Supabase's transaction pooler cannot run prepared statements, so the whole suite also runs with
// default_query_exec_mode=simple_protocol in TEST_DATABASE_URL. This proves the mode is really in force.
func TestSimpleProtocolPreparesNothingAndExtendedDoes(t *testing.T) {
	pool := testdb.Pool(t)
	ctx := context.Background()
	conn, err := pool.Acquire(ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer conn.Release()
	if _, err := db.New(conn).ListGenres(ctx); err != nil {
		t.Fatal(err)
	}
	var prepared int
	if err := conn.QueryRow(ctx, `SELECT count(*) FROM pg_prepared_statements`).Scan(&prepared); err != nil {
		t.Fatal(err)
	}
	simple := pool.Config().ConnConfig.DefaultQueryExecMode == pgx.QueryExecModeSimpleProtocol
	if simple && prepared != 0 {
		t.Errorf("simple protocol is on but %d statements are prepared on the connection", prepared)
	}
	if !simple && prepared == 0 {
		t.Errorf("extended protocol is expected to prepare statements, found none")
	}
	t.Logf("simple protocol: %v, prepared statements: %d", simple, prepared)
}
