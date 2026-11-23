// Package site builds the landing pages and the Android download pages of ringgitradar.snitco.com from one
// set of templates and one text file per language. It writes them into the Vercel output directory, next
// to the Flutter web build in app/, and never deletes anything there.
package site

import (
	"bytes"
	"embed"
	"fmt"
	"html/template"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

//go:embed templates text static
var files embed.FS

// Origin is the address the pages are published at.
const Origin = "https://ringgitradar.snitco.com"

// Lang is one language of the site. Prefix is "" for English, which lives at the root.
type Lang struct{ Code, HTMLLang, Prefix string }

// ponytail: Chinese and Malay join in the next step, once their text files exist.
var Langs = []Lang{{"en", "en", ""}}

var switchLabels = map[string]string{"en": "EN", "zh": "中文", "ms": "BM"}

// Options says where to write and what to write it with.
type Options struct {
	Out     string // the Vercel output directory; the Flutter build must already be in Out/app
	APKPath string // the release APK, copied to Out/ringgit-radar.apk
	Status  Status // the live numbers
}

// kinds are the two page kinds, and where each lives under a language's prefix.
var kinds = []struct{ name, dir, title, description string }{
	{"landing", "/", "metaTitle", "metaDescription"},
}

type switchLink struct {
	Label, Href, Code, HTMLLang string
	Current                     bool
}

type page struct {
	Lang        Lang
	Path        string
	Title       string
	Description string
	Switch      []switchLink
	text        map[string]string
	args        map[string]template.HTML
}

// T is a page text with its placeholders filled in.
func (p page) T(key string) template.HTML {
	s, ok := p.text[key]
	if !ok {
		panic("site: no text " + key + " in " + p.Lang.Code)
	}
	return render(s, p.args)
}

func a(href string, label template.HTML) template.HTML {
	return template.HTML(`<a href="`+template.HTMLEscapeString(href)+`">`) + label + "</a>"
}

// Build writes every page, the static files and the APK into o.Out.
func Build(o Options) error {
	appIndex := filepath.Join(o.Out, "app", "index.html")
	b, err := os.ReadFile(appIndex)
	if err != nil {
		return fmt.Errorf("the Flutter web build must be in %s first: %w", appIndex, err)
	}
	if !bytes.Contains(b, []byte(`<base href="/app/">`)) {
		return fmt.Errorf("%s was not built with --base-href /app/", appIndex)
	}
	st, err := os.Stat(o.APKPath)
	if err != nil {
		return fmt.Errorf("the APK: %w", err)
	}
	if err := copyFile(o.APKPath, filepath.Join(o.Out, "ringgit-radar.apk")); err != nil {
		return err
	}
	for _, k := range kinds {
		tmpl, err := template.ParseFS(files, "templates/base.html.tmpl", "templates/"+k.name+".html.tmpl")
		if err != nil {
			return err
		}
		for _, l := range Langs {
			text, err := loadText(l.Code)
			if err != nil {
				return fmt.Errorf("text for %s: %w", l.Code, err)
			}
			p := page{Lang: l, Path: l.Prefix + k.dir, text: text}
			for _, s := range Langs {
				p.Switch = append(p.Switch, switchLink{switchLabels[s.Code], s.Prefix + k.dir, s.Code, s.HTMLLang, s == l})
			}
			p.args = map[string]template.HTML{
				"count":    template.HTML(`<span data-count>` + formatCount(o.Status.ProductCount) + `</span>`),
				"date":     template.HTML(formatDate(o.Status.HistorySince, l.Code)),
				"size":     template.HTML(fmt.Sprint(apkMB(st.Size()))),
				"email":    a("mailto:ringgitradar@snitco.com", "ringgitradar@snitco.com"),
				"dataPage": a("/app/data-sources", render(text["dataPageLink"], nil)),
			}
			p.Title, p.Description = text[k.title], text[k.description]
			var buf bytes.Buffer
			if err := tmpl.ExecuteTemplate(&buf, "base", p); err != nil {
				return fmt.Errorf("%s %s: %w", k.name, l.Code, err)
			}
			if err := write(filepath.Join(o.Out, filepath.FromSlash(p.Path), "index.html"), buf.Bytes()); err != nil {
				return err
			}
		}
	}
	return fs.WalkDir(files, "static", func(name string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return err
		}
		b, err := files.ReadFile(name)
		if err != nil {
			return err
		}
		return write(filepath.Join(o.Out, "site", filepath.FromSlash(strings.TrimPrefix(name, "static/"))), b)
	})
}

func write(name string, b []byte) error {
	if err := os.MkdirAll(filepath.Dir(name), 0o755); err != nil {
		return err
	}
	return os.WriteFile(name, b, 0o644)
}

func copyFile(from, to string) error {
	in, err := os.Open(from)
	if err != nil {
		return err
	}
	defer in.Close()
	if err := os.MkdirAll(filepath.Dir(to), 0o755); err != nil {
		return err
	}
	out, err := os.Create(to)
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		return err
	}
	return out.Close()
}
