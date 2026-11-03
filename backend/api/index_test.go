package handler

import (
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

// The function, called the way Vercel calls it after the rewrite in vercel.json.
func TestFunctionServesTheAPIAndHealthz(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Fatal("TEST_DATABASE_URL is not set")
	}
	t.Setenv("DATABASE_URL", url)
	for target, want := range map[string]string{
		"/api/index?p=/v1/genres":        `"items"`,
		"/api/index?p=/v1/status/prices": `"product_count"`,
		"/api/index?p=/healthz":          "ok",
		"/api/index?path=genres":         `"items"`,
		"/v1/genres":                     `"items"`, // a platform that keeps the original path works too
		"/api/index?p=/v1/games/nope":    `"error"`,
		"/api/index?p=/v1/img/zzz?w=320": `"error"`, // bad hash, never reaches upstream
		"/api/index?p=/v1/no/such/thing": `"error"`,
	} {
		rec := httptest.NewRecorder()
		Handler(rec, httptest.NewRequest(http.MethodGet, target, nil))
		if !strings.Contains(rec.Body.String(), want) {
			t.Errorf("%s = %d %q, want it to contain %q", target, rec.Code, rec.Body.String(), want)
		}
	}
	rec := httptest.NewRecorder()
	Handler(rec, httptest.NewRequest(http.MethodGet, "/api/index?p=/v1/genres", nil))
	if rec.Code != 200 || !strings.Contains(rec.Header().Get("Cache-Control"), "s-maxage=600") {
		t.Errorf("genres: %d %q", rec.Code, rec.Header().Get("Cache-Control"))
	}
}
