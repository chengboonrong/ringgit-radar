package site

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"time"
)

var since = time.Date(2026, 11, 1, 15, 29, 5, 0, time.UTC)

func TestFetchStatus(t *testing.T) {
	reply := func(code int, body string) string {
		s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.URL.Path != "/v1/status/prices" {
				http.NotFound(w, r)
				return
			}
			w.WriteHeader(code)
			w.Write([]byte(body))
		}))
		t.Cleanup(s.Close)
		return s.URL
	}
	ctx := context.Background()
	got, err := FetchStatus(ctx, reply(200, `{"product_count":8141,"history_since":"2026-11-01T15:29:05Z","last_run_at":"2026-11-22T17:24:42Z"}`))
	if err != nil || got.ProductCount != 8141 || !got.HistorySince.Equal(since) {
		t.Fatalf("FetchStatus = %+v, %v", got, err)
	}
	for name, base := range map[string]string{
		"500":        reply(500, `oops`),
		"zero count": reply(200, `{"product_count":0,"history_since":"2026-11-01T15:29:05Z"}`),
		"no history": reply(200, `{"product_count":8141,"history_since":null}`),
		"not json":   reply(200, `<html>`),
	} {
		if _, err := FetchStatus(ctx, base); err == nil {
			t.Errorf("%s: want an error", name)
		}
	}
	closed := httptest.NewServer(http.NotFoundHandler())
	closed.Close()
	if _, err := FetchStatus(ctx, closed.URL); err == nil {
		t.Error("closed server: want an error")
	}
}

func TestFormatCount(t *testing.T) {
	for n, want := range map[int64]string{999: "999", 8141: "8,141", 1234567: "1,234,567"} {
		if got := formatCount(n); got != want {
			t.Errorf("formatCount(%d) = %q, want %q", n, got, want)
		}
	}
}

func TestFormatDate(t *testing.T) {
	cases := []struct {
		t    time.Time
		lang string
		want string
	}{
		{since, "en", "1 Nov 2026"},
		{time.Date(2026, 10, 31, 16, 30, 0, 0, time.UTC), "en", "1 Nov 2026"}, // 00:30 in Malaysia
		{time.Date(2026, 8, 5, 0, 0, 0, 0, time.UTC), "ms", "5 Ogo 2026"},
		{since, "zh", "2026年11月1日"},
	}
	for _, c := range cases {
		if got := formatDate(c.t, c.lang); got != c.want {
			t.Errorf("formatDate(%v, %s) = %q, want %q", c.t, c.lang, got, c.want)
		}
	}
}

func TestApkMB(t *testing.T) {
	for size, want := range map[int64]int64{54_600_000: 55, 54_400_000: 54, 2_600_000: 3} {
		if got := apkMB(size); got != want {
			t.Errorf("apkMB(%d) = %d, want %d", size, got, want)
		}
	}
}

// fixture makes an output dir holding a Flutter build at /app/ and an APK, as the deploy steps leave them.
func fixture(t *testing.T, baseHref string) Options {
	t.Helper()
	out := t.TempDir()
	if baseHref != "" {
		os.MkdirAll(filepath.Join(out, "app"), 0o755)
		os.WriteFile(filepath.Join(out, "app", "index.html"), []byte(`<html><head><base href="`+baseHref+`"></head></html>`), 0o644)
	}
	apk := filepath.Join(t.TempDir(), "app-release.apk")
	f, err := os.Create(apk)
	if err != nil {
		t.Fatal(err)
	}
	f.Truncate(2_600_000)
	f.Close()
	return Options{Out: out, APKPath: apk, Status: Status{ProductCount: 8141, HistorySince: since}}
}

func built(t *testing.T) Options {
	t.Helper()
	o := fixture(t, "/app/")
	if err := Build(o); err != nil {
		t.Fatal(err)
	}
	return o
}

func read(t *testing.T, path string) string {
	t.Helper()
	b, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	return string(b)
}

func TestBuildRefusesWithoutApp(t *testing.T) {
	if err := Build(fixture(t, "")); err == nil || !strings.Contains(err.Error(), "app/index.html") {
		t.Errorf("no app build: err = %v", err)
	}
	if err := Build(fixture(t, "/")); err == nil || !strings.Contains(err.Error(), "/app/") {
		t.Errorf("app built for /: err = %v", err)
	}
}

func TestBuildRefusesWithoutAPK(t *testing.T) {
	o := fixture(t, "/app/")
	o.APKPath = filepath.Join(t.TempDir(), "missing.apk")
	if err := Build(o); err == nil {
		t.Error("want an error")
	}
}

func TestBuildLanding(t *testing.T) {
	o := built(t)
	en, _ := loadText("en")
	page := read(t, filepath.Join(o.Out, "index.html"))
	for _, want := range []string{
		`<html lang="en">`, en["headline"], `<span data-count>8,141</span>`, "1 Nov 2026",
		`href="/app/"`, `href="/android/"`, "APK, 3 MB",
	} {
		if !strings.Contains(page, want) {
			t.Errorf("landing page lacks %q", want)
		}
	}
	if n := strings.Count(page, en["unofficial"]); n < 2 {
		t.Errorf("unofficial line appears %d times, want at least 2", n)
	}
	if m := regexp.MustCompile(`src="https?://`).FindString(page); m != "" {
		t.Errorf("page loads from another site: %s", m)
	}
	if st, err := os.Stat(filepath.Join(o.Out, "ringgit-radar.apk")); err != nil || st.Size() != 2_600_000 {
		t.Errorf("apk not copied: %v", err)
	}
	if _, err := os.Stat(filepath.Join(o.Out, "site", "fonts", "MPLUSRounded1c-Regular.woff2")); err != nil {
		t.Error(err)
	}
}

func placeholders(s string) map[string]bool {
	m := map[string]bool{}
	for _, p := range regexp.MustCompile(`\{[a-zA-Z]+\}`).FindAllString(s, -1) {
		m[p] = true
	}
	return m
}

func TestTextRules(t *testing.T) {
	en, err := loadText("en")
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(en["unofficial"], "unofficial") {
		t.Errorf("en unofficial line = %q", en["unofficial"])
	}
	files, _ := filepath.Glob("text/*.json")
	for _, f := range files {
		code := strings.TrimSuffix(filepath.Base(f), ".json")
		tx, err := loadText(code)
		if err != nil {
			t.Fatal(err)
		}
		if len(tx) != len(en) {
			t.Errorf("%s has %d keys, en has %d", code, len(tx), len(en))
		}
		for k, v := range en {
			w, ok := tx[k]
			if !ok {
				t.Errorf("%s lacks %s", code, k)
				continue
			}
			a, b := placeholders(v), placeholders(w)
			if len(a) != len(b) {
				t.Errorf("%s.%s placeholders %v, en has %v", code, k, b, a)
			}
			for p := range a {
				if !b[p] {
					t.Errorf("%s.%s lacks %s", code, k, p)
				}
			}
		}
		for k, v := range tx {
			if w := banned(code, v); w != "" {
				t.Errorf("%s.%s says %q: %q", code, k, w, v)
			}
		}
	}
}

// chars reads a char list written by tool/subset_fonts.sh.
func chars(t *testing.T, name string) map[rune]bool {
	t.Helper()
	m := map[rune]bool{}
	for _, r := range strings.TrimRight(read(t, filepath.Join("static", "fonts", name)), "\n") {
		m[r] = true
	}
	return m
}

func TestFontsCoverText(t *testing.T) {
	latin := chars(t, "latin_chars.txt")
	files, _ := filepath.Glob("text/*.json")
	for _, f := range files {
		code := strings.TrimSuffix(filepath.Base(f), ".json")
		var tx map[string]string
		json.Unmarshal([]byte(read(t, f)), &tx)
		for k, v := range tx {
			for _, r := range v {
				if (code != "zh" || r <= 0x7E) && !latin[r] {
					t.Errorf("%s.%s: %q is not in the latin font subset", code, k, r)
				}
			}
		}
	}
}

func TestBuildAndroid(t *testing.T) {
	o := built(t)
	en, _ := loadText("en")
	page := read(t, filepath.Join(o.Out, "android", "index.html"))
	for _, want := range []string{
		`<html lang="en">`, `href="/ringgit-radar.apk" download`, "APK file, 3 MB",
		`href="/app/"`, `href="/app/privacy"`, en["unofficial"],
	} {
		if !strings.Contains(page, want) {
			t.Errorf("android page lacks %q", want)
		}
	}
	if strings.Contains(page, `href="/privacy"`) {
		t.Error("android page links the old /privacy")
	}
	for _, l := range Langs {
		if !strings.Contains(page, `href="`+l.Prefix+`/android/"`) {
			t.Errorf("android page has no switch link to %s/android/", l.Prefix)
		}
	}
}

func TestBuildAllLanguages(t *testing.T) {
	o := built(t)
	for _, l := range []struct{ code, html, prefix string }{{"zh", "zh-Hans", "/zh"}, {"ms", "ms", "/ms"}} {
		tx, err := loadText(l.code)
		if err != nil {
			t.Fatal(err)
		}
		page := read(t, filepath.Join(o.Out, l.code, "index.html"))
		for _, want := range []string{`<html lang="` + l.html + `">`, string(render(tx["headline"], nil)), `href="` + l.prefix + `/android/"`, `href="/app/"`} {
			if !strings.Contains(page, want) {
				t.Errorf("%s landing page lacks %q", l.code, want)
			}
		}
	}
	for _, l := range Langs {
		for dir, kind := range map[string]string{"/": "landing", "/android/": "android"} {
			page := read(t, filepath.Join(o.Out, filepath.FromSlash(l.Prefix+dir), "index.html"))
			for _, m := range Langs {
				if !strings.Contains(page, `href="`+m.Prefix+dir+`" hreflang="`+m.HTMLLang+`"`) {
					t.Errorf("%s %s page has no switch link to %s%s", l.Code, kind, m.Prefix, dir)
				}
			}
		}
	}
}

func TestZhFontCoversText(t *testing.T) {
	zh := chars(t, "zh_chars.txt")
	tx, err := loadText("zh")
	if err != nil {
		t.Fatal(err)
	}
	for k, v := range tx {
		for _, r := range v {
			if r > 0x7E && !zh[r] {
				t.Errorf("zh.%s: %q is not in the Chinese font subset", k, r)
			}
		}
	}
}
