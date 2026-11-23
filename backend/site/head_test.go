package site

import (
	"html"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

// pages lists every built page as (lang, path).
func pages() (out [][2]string) {
	for _, l := range Langs {
		for _, dir := range []string{"/", "/android/"} {
			out = append(out, [2]string{l.Code, l.Prefix + dir})
		}
	}
	return out
}

func meta(page, attr, name string) []string {
	var out []string
	re := regexp.MustCompile(`<meta ` + attr + `="` + regexp.QuoteMeta(name) + `" content="([^"]*)">`)
	for _, m := range re.FindAllStringSubmatch(page, -1) {
		out = append(out, html.UnescapeString(m[1]))
	}
	return out
}

func TestHead(t *testing.T) {
	o := built(t)
	locale := map[string]string{"en": "en_MY", "zh": "zh_CN", "ms": "ms_MY"}
	unofficial := map[string]string{"en": "unofficial", "zh": "非官方", "ms": "tidak rasmi"}
	for _, pg := range pages() {
		code, path := pg[0], pg[1]
		page := read(t, filepath.Join(o.Out, filepath.FromSlash(path), "index.html"))
		head := page[:strings.Index(page, "</head>")]
		canon := `<link rel="canonical" href="` + Origin + path + `">`
		if strings.Count(head, `rel="canonical"`) != 1 || !strings.Contains(head, canon) {
			t.Errorf("%s: want exactly %s", path, canon)
		}
		kind := strings.TrimPrefix(path, "/"+code)
		if code == "en" {
			kind = path
		}
		for _, l := range Langs {
			alt := `<link rel="alternate" hreflang="` + l.HTMLLang + `" href="` + Origin + l.Prefix + kind + `">`
			if !strings.Contains(head, alt) {
				t.Errorf("%s lacks %s", path, alt)
			}
		}
		if xd := `<link rel="alternate" hreflang="x-default" href="` + Origin + kind + `">`; !strings.Contains(head, xd) {
			t.Errorf("%s lacks %s", path, xd)
		}
		title := html.UnescapeString(regexp.MustCompile(`<title>([^<]*)</title>`).FindStringSubmatch(head)[1])
		if og := meta(head, "property", "og:title"); len(og) != 1 || og[0] != title {
			t.Errorf("%s og:title = %v, want %q", path, og, title)
		}
		img := Origin + "/site/og-" + code + ".png"
		if og := meta(head, "property", "og:image"); len(og) != 1 || og[0] != img {
			t.Errorf("%s og:image = %v, want %s", path, og, img)
		}
		if _, err := os.Stat(filepath.Join(o.Out, "site", "og-"+code+".png")); err != nil {
			t.Error(err)
		}
		for name, want := range map[string]string{"og:url": Origin + path, "og:locale": locale[code], "og:type": "website"} {
			if got := meta(head, "property", name); len(got) != 1 || got[0] != want {
				t.Errorf("%s %s = %v, want %s", path, name, got, want)
			}
		}
		if got := meta(head, "name", "twitter:card"); len(got) != 1 || got[0] != "summary_large_image" {
			t.Errorf("%s twitter:card = %v", path, got)
		}
		if len(meta(head, "property", "og:description")) != 1 {
			t.Errorf("%s has no og:description", path)
		}
		// Nintendo's name never travels without the disclaimer.
		texts := []string{title}
		for _, n := range []string{"description", "twitter:title", "twitter:description"} {
			texts = append(texts, meta(head, "name", n)...)
		}
		for _, n := range []string{"og:title", "og:description", "og:image:alt"} {
			texts = append(texts, meta(head, "property", n)...)
		}
		for _, s := range texts {
			if (strings.Contains(s, "Nintendo") || strings.Contains(s, "任天堂")) && !strings.Contains(strings.ToLower(s), unofficial[code]) {
				t.Errorf("%s: head text names Nintendo without %q: %q", path, unofficial[code], s)
			}
			if w := banned(code, s); w != "" {
				t.Errorf("%s: head text says %q: %q", path, w, s)
			}
		}
	}
}

func TestSitemap(t *testing.T) {
	o := built(t)
	sm := read(t, filepath.Join(o.Out, "sitemap.xml"))
	locs := regexp.MustCompile(`<loc>([^<]*)</loc>`).FindAllStringSubmatch(sm, -1)
	if len(locs) != 6 {
		t.Errorf("sitemap has %d entries, want 6", len(locs))
	}
	for _, pg := range pages() {
		if !strings.Contains(sm, "<loc>"+Origin+pg[1]+"</loc>") {
			t.Errorf("sitemap lacks %s", pg[1])
		}
	}
	if r := read(t, filepath.Join(o.Out, "robots.txt")); !strings.Contains(r, "Sitemap: https://ringgitradar.snitco.com/sitemap.xml") {
		t.Errorf("robots.txt = %q", r)
	}
}

// TestPageWeight keeps the first load small on a phone: the page plus every file it loads at once.
func TestPageWeight(t *testing.T) {
	o := built(t)
	budget := map[string]int64{"en": 250_000, "zh": 400_000, "ms": 250_000}
	ref := regexp.MustCompile(`(?:src|href)="(/site/[^"]+)"|url\((/site/[^)]+)\)`)
	for _, l := range Langs {
		name := filepath.Join(o.Out, filepath.FromSlash(l.Prefix+"/"), "index.html")
		page := read(t, name)
		total := int64(len(page))
		seen := map[string]bool{}
		for _, m := range ref.FindAllStringSubmatch(page, -1) {
			f := m[1] + m[2]
			if seen[f] || strings.Contains(f, "/og-") || strings.HasSuffix(f, "favicon.png") ||
				(strings.Contains(f, "RinggitZh") && l.Code != "zh") {
				continue // previews load only when shared; the Chinese font only where Chinese is shown
			}
			seen[f] = true
			st, err := os.Stat(filepath.Join(o.Out, filepath.FromSlash(f)))
			if err != nil {
				t.Fatal(err)
			}
			total += st.Size()
		}
		t.Logf("%s: %d bytes over %d files", l.Code, total, len(seen)+1)
		if total > budget[l.Code] {
			t.Errorf("%s page weighs %d bytes, budget %d", l.Code, total, budget[l.Code])
		}
	}
}
