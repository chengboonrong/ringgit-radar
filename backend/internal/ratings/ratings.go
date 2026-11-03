// Package ratings matches Malaysian catalogue titles to age ratings from the public titledb dataset
// (github.com/blawar/titledb, MIT, metadata only). The dataset's nsuIds are per region and do not
// join to ours, so matching is by normalised title.
package ratings

import (
	"encoding/json"
	"fmt"
	"io"
	"slices"
	"strings"
	"unicode"

	"golang.org/x/text/unicode/norm"
)

// Entry is one rated title from the dataset. Age is -1 when the dataset has no rating for it.
type Entry struct {
	Name        string
	Age         int
	Descriptors []string
}

// Normalise folds a title so spelling variants of the same game compare equal: trademark marks go,
// width variants fold (NFKC), case folds, and anything that is not a letter or digit is a space.
func Normalise(s string) string {
	s = strings.Map(func(r rune) rune {
		switch r {
		case '™', '®', '©', '℠':
			return -1
		}
		return r
	}, s)
	s = strings.ToLower(norm.NFKC.String(s))
	var b strings.Builder
	space := true
	for _, r := range s {
		if unicode.IsLetter(r) || unicode.IsDigit(r) {
			b.WriteRune(r)
			space = false
		} else if !space {
			b.WriteByte(' ')
			space = true
		}
	}
	return strings.TrimSpace(b.String())
}

// phrases that may stand between a title and a trailing "edition", longest first.
var editionWords = [][]string{
	{"game", "of", "the", "year"}, {"director", "s", "cut"}, {"collector", "s"}, {"nintendo", "switch", "2"},
	{"nintendo", "switch"}, {"switch", "2"}, {"switch"}, {"goty"}, {"deluxe"}, {"complete"}, {"definitive"},
	{"standard"}, {"ultimate"}, {"gold"}, {"special"}, {"premium"}, {"digital"}, {"anniversary"},
	{"enhanced"}, {"legendary"}, {"royal"}, {"launch"},
}

// StripEdition removes trailing edition wording from an already normalised title: "x deluxe edition"
// and "x nintendo switch 2 edition" become "x". A title is never stripped down to nothing.
// ponytail: a fixed word list, so an unusual edition name simply does not strip and stays unmatched.
func StripEdition(n string) string {
	words := strings.Fields(n)
	for {
		if len(words) < 2 || words[len(words)-1] != "edition" {
			break
		}
		words = words[:len(words)-1]
		for popped := true; popped && len(words) > 1; {
			popped = false
			for _, p := range editionWords {
				if len(words) > len(p) && slices.Equal(words[len(words)-len(p):], p) {
					words = words[:len(words)-len(p)]
					popped = true
					break
				}
			}
		}
	}
	for _, w := range words {
		if !editionVocab(w) {
			return strings.Join(words, " ")
		}
	}
	return n // nothing but edition wording would be left
}

// only words that can be nothing else than edition wording; "game" and "year" can be part of a title
var editionOnly = []string{"edition", "nintendo", "switch", "2", "deluxe", "complete", "definitive", "standard", "ultimate", "gold", "special", "premium", "digital", "anniversary", "enhanced", "legendary", "royal", "launch", "goty"}

func editionVocab(w string) bool { return slices.Contains(editionOnly, w) }

type Status int

const (
	Unmatched Status = iota
	Matched
	Conflict
)

// Match is the outcome of looking one title up. Key is the normalised name the lookup landed on.
type Match struct {
	Status      Status
	Age         int
	Descriptors []string
	MatchedName string
	Key         string
}

// Index holds the dataset by exact normalised name and by name with edition wording stripped.
type Index struct {
	exact, loose map[string][]Entry
}

// Add indexes an entry. Entries without an age are ignored.
func (ix *Index) Add(e Entry) {
	if e.Age < 0 || e.Name == "" {
		return
	}
	if ix.exact == nil {
		ix.exact, ix.loose = map[string][]Entry{}, map[string][]Entry{}
	}
	n := Normalise(e.Name)
	if n == "" {
		return
	}
	ix.exact[n] = append(ix.exact[n], e)
	l := StripEdition(n)
	ix.loose[l] = append(ix.loose[l], e)
}

// Lookup matches a title: exact name first, then with edition wording stripped from both sides.
// Entries that share a name but disagree on age are a Conflict: nothing is stored for them.
func (ix *Index) Lookup(title string) Match {
	n := Normalise(title)
	if n == "" {
		return Match{}
	}
	if es := ix.exact[n]; len(es) > 0 {
		return merge(n, es)
	}
	l := StripEdition(n)
	if es := ix.loose[l]; len(es) > 0 {
		return merge(l, es)
	}
	return Match{}
}

func merge(key string, es []Entry) Match {
	r := Match{Status: Matched, Age: es[0].Age, MatchedName: es[0].Name, Key: key, Descriptors: []string{}}
	for _, e := range es {
		if e.Age != r.Age {
			return Match{Status: Conflict, Key: key}
		}
		for _, d := range e.Descriptors {
			if !slices.Contains(r.Descriptors, d) {
				r.Descriptors = append(r.Descriptors, d)
			}
		}
	}
	slices.Sort(r.Descriptors)
	return r
}

// ReadTitleDB streams the dataset (one big JSON object keyed by nsuId) without holding it in memory,
// calling fn for each named entry.
func ReadTitleDB(r io.Reader, fn func(Entry)) error {
	dec := json.NewDecoder(r)
	if t, err := dec.Token(); err != nil || t != json.Delim('{') {
		return fmt.Errorf("titledb: expected a JSON object at the start (%v)", err)
	}
	for dec.More() {
		if _, err := dec.Token(); err != nil { // the nsuId key
			return fmt.Errorf("titledb: %w", err)
		}
		var v struct {
			Name          string   `json:"name"`
			Rating        *int     `json:"rating"`
			RatingContent []string `json:"ratingContent"`
		}
		if err := dec.Decode(&v); err != nil {
			return fmt.Errorf("titledb: %w", err)
		}
		if v.Name == "" {
			continue
		}
		age := -1
		if v.Rating != nil {
			age = *v.Rating
		}
		fn(Entry{Name: v.Name, Age: age, Descriptors: v.RatingContent})
	}
	return nil
}
