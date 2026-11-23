package site

import (
	"encoding/json"
	"html/template"
	"regexp"
	"strings"
)

// loadText reads text/<code>.json, a flat key → string map. {name} marks a placeholder.
func loadText(code string) (map[string]string, error) {
	b, err := files.ReadFile("text/" + code + ".json")
	if err != nil {
		return nil, err
	}
	var m map[string]string
	return m, json.Unmarshal(b, &m)
}

var placeholder = regexp.MustCompile(`\{[a-zA-Z]+\}`)

// render escapes s, then puts each {name} back as args[name], which is already safe HTML.
func render(s string, args map[string]template.HTML) template.HTML {
	esc := template.HTMLEscapeString(s)
	return template.HTML(placeholder.ReplaceAllStringFunc(esc, func(p string) string {
		if v, ok := args[p[1:len(p)-1]]; ok {
			return string(v)
		}
		return p
	}))
}

// The honesty rules: nothing official, popular, best-selling, coming soon, authorised or a partner.
// The allowed phrases are removed before the check, so "unofficial" and its translations pass.
var (
	allowed = map[string][]string{
		"en": {"unofficial"},
		"zh": {"非官方"},
		"ms": {"tidak rasmi", "tidak diiktiraf"},
	}
	forbidden = map[string][]string{
		"en": {"official", "popular", "best-selling", "bestseller", "best seller", "top-selling", "trending", "coming soon", "authorised", "authorized", "partner"},
		"zh": {"官方", "热门", "最受欢迎", "畅销", "人气", "即将", "敬请期待", "授权", "合作伙伴"},
		"ms": {"rasmi", "popular", "terlaris", "paling laris", "trending", "akan datang", "tidak lama lagi", "bertauliah", "rakan kongsi", "diiktiraf"},
	}
)

// banned returns the first forbidden word s uses in language code, or "".
func banned(code, s string) string {
	s = strings.ToLower(s)
	for _, a := range allowed[code] {
		s = strings.ReplaceAll(s, a, " ")
	}
	for _, w := range forbidden[code] {
		if strings.Contains(s, w) {
			return w
		}
	}
	return ""
}
