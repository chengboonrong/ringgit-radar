package ratings

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/testdb"
)

func TestNormalise(t *testing.T) {
	for in, want := range map[string]string{
		"LEGO® Star Wars™: The Skywalker Saga": "lego star wars the skywalker saga",
		"Ｆｉｎａｌ　Ｆａｎｔａｓｙ ＶＩＩ":                    "final fantasy vii",
		"  Hello,   World!  ":                  "hello world",
		"Mizuchi - 白蛇心傳":                       "mizuchi 白蛇心傳",
		"Pokémon Legends: Z-A":                 "pokémon legends z a",
		"Dirty Little Puzzle©℠":                "dirty little puzzle",
		"":                                     "",
	} {
		if got := Normalise(in); got != want {
			t.Errorf("Normalise(%q) = %q, want %q", in, got, want)
		}
	}
}

func TestStripEdition(t *testing.T) {
	for in, want := range map[string]string{
		"Pokémon Legends: Z-A – Nintendo Switch 2 Edition": "pokémon legends z a",
		"Hogwarts Legacy Deluxe Edition":                   "hogwarts legacy",
		"Cyberpunk 2077: Ultimate Edition":                 "cyberpunk 2077",
		"Mario Kart World Switch 2 Edition":                "mario kart world",
		"Hogwarts Legacy":                                  "hogwarts legacy",
		"Game Deluxe Edition Nintendo Switch 2 Edition":    "game",           // both suffixes, repeatedly
		"Deluxe Edition":                                   "deluxe edition", // never strips a title down to nothing
		"Edition Zero":                                     "edition zero",   // only a trailing suffix
		"Super Mario Party Jamboree + Jamboree TV":         "super mario party jamboree jamboree tv",
	} {
		if got := StripEdition(Normalise(in)); got != want {
			t.Errorf("StripEdition(Normalise(%q)) = %q, want %q", in, got, want)
		}
	}
}

func entry(name string, age int, d ...string) Entry {
	return Entry{Name: name, Age: age, Descriptors: d}
}

func TestLookup(t *testing.T) {
	var ix Index
	ix.Add(entry("Hogwarts Legacy", 12, "Violence", "Bad Language"))
	ix.Add(entry("Pokémon Legends: Z-A", 7))
	ix.Add(entry("Cyberpunk 2077: Ultimate Edition", 18, "Strong Violence"))
	ix.Add(entry("Dirty Little Puzzle", 12, "Sexual Innuendo"))
	ix.Add(entry("Twin Name", 7, "Fear"))
	ix.Add(entry("Twin  Name!", 12, "Violence")) // normalises to the same name, different age
	ix.Add(entry("Same Name", 3, "Online"))
	ix.Add(entry("Same Name", 3, "In-game purchases", "Online")) // same age: merged
	ix.Add(Entry{Name: "No Rating Game", Age: -1})               // no age in the source: ignored

	cases := []struct {
		title  string
		status Status
		age    int
		desc   string
		name   string
	}{
		{"Hogwarts Legacy", Matched, 12, "Bad Language,Violence", "Hogwarts Legacy"},
		{"HOGWARTS LEGACY™", Matched, 12, "Bad Language,Violence", "Hogwarts Legacy"},
		{"Hogwarts Legacy Deluxe Edition", Matched, 12, "Bad Language,Violence", "Hogwarts Legacy"}, // ours has the suffix
		{"Pokémon Legends: Z-A – Nintendo Switch 2 Edition", Matched, 7, "", "Pokémon Legends: Z-A"},
		{"Cyberpunk 2077", Matched, 18, "Strong Violence", "Cyberpunk 2077: Ultimate Edition"}, // theirs has the suffix
		{"Dirty Little Puzzle", Matched, 12, "Sexual Innuendo", "Dirty Little Puzzle"},
		{"Catgirls Hentai Puzzle", Unmatched, 0, "", ""},
		{"Twin Name", Conflict, 0, "", ""},
		{"Same Name", Matched, 3, "In-game purchases,Online", "Same Name"},
		{"No Rating Game", Unmatched, 0, "", ""},
	}
	for _, c := range cases {
		r := ix.Lookup(c.title)
		if r.Status != c.status || r.Age != c.age || strings.Join(r.Descriptors, ",") != c.desc || r.MatchedName != c.name {
			t.Errorf("Lookup(%q) = %+v, want status %v age %d %q %q", c.title, r, c.status, c.age, c.desc, c.name)
		}
	}
}

func TestReadTitleDBStreamsEntries(t *testing.T) {
	const doc = `{
	  "1": {"name": "A Game", "rating": 12, "ratingContent": ["Violence"], "description": "long text", "nsuId": 1},
	  "2": {"name": "No Rating", "rating": null, "ratingContent": null},
	  "3": {"name": "Plain", "rating": 3, "ratingContent": []},
	  "4": {"rating": 7}
	}`
	var got []Entry
	if err := ReadTitleDB(strings.NewReader(doc), func(e Entry) { got = append(got, e) }); err != nil {
		t.Fatal(err)
	}
	b, _ := json.Marshal(got)
	want := `[{"Name":"A Game","Age":12,"Descriptors":["Violence"]},{"Name":"No Rating","Age":-1,"Descriptors":null},{"Name":"Plain","Age":3,"Descriptors":[]}]`
	if string(b) != want {
		t.Fatalf("got  %s\nwant %s", b, want)
	}
	if err := ReadTitleDB(strings.NewReader(`[1,2]`), func(Entry) {}); err == nil {
		t.Fatal("an array is not a titledb file")
	}
}

func seed(t *testing.T, pool *pgxpool.Pool, nsuid, title, sctg string) {
	t.Helper()
	raw, _ := json.Marshal(map[string]any{"sctg": sctg})
	if _, err := pool.Exec(context.Background(), `INSERT INTO products (nsuid, title, publisher, platform, kind, source_status, raw) VALUES ($1,$2,'P','05_BEE','','onsale',$3)`, nsuid, title, json.RawMessage(raw)); err != nil {
		t.Fatal(err)
	}
}

func TestImportStoresMatchesOnlyForGamesAndNothingOnConflict(t *testing.T) {
	pool := testdb.Pool(t)
	seed(t, pool, "1", "Hogwarts Legacy", "dl_soft")
	seed(t, pool, "2", "Hogwarts Legacy", "aoc") // an add-on with the game's name is not rated
	seed(t, pool, "3", "Catgirls Hentai Puzzle", "dl_soft")
	seed(t, pool, "4", "Twin Name", "dl_soft")
	seed(t, pool, "5", "Dirty Little Puzzle", "dl_soft")
	seed(t, pool, "6", "Bundle Pack", "bundle")

	var ix Index
	ix.Add(entry("Hogwarts Legacy", 12, "Violence", "Bad Language", "In-game purchases"))
	ix.Add(entry("Twin Name", 7))
	ix.Add(entry("Twin Name", 16))
	ix.Add(entry("Dirty Little Puzzle", 12, "Sexual Innuendo"))
	ix.Add(entry("Bundle Pack", 3))

	// a stale row for the conflicting title must go: the import leaves nothing for it
	if _, err := pool.Exec(context.Background(), `INSERT INTO title_ratings (nsuid, age, source, matched_name) VALUES ('4', 3, 'old', 'Twin Name')`); err != nil {
		t.Fatal(err)
	}

	res, err := Import(context.Background(), pool, &ix, "test")
	if err != nil {
		t.Fatal(err)
	}
	want := Result{Games: 4, Matched: 2, Unmatched: 1, Conflicts: 1, ConflictNames: 1}
	if res != want {
		t.Fatalf("result = %+v, want %+v", res, want)
	}
	rows := map[string]string{}
	r, err := pool.Query(context.Background(), `SELECT nsuid, age::text || ' ' || array_to_string(descriptors, ',') || ' ' || source || ' ' || matched_name FROM title_ratings ORDER BY nsuid`)
	if err != nil {
		t.Fatal(err)
	}
	defer r.Close()
	for r.Next() {
		var k, v string
		if err := r.Scan(&k, &v); err != nil {
			t.Fatal(err)
		}
		rows[k] = v
	}
	if len(rows) != 2 || rows["1"] != "12 Bad Language,In-game purchases,Violence test Hogwarts Legacy" || rows["5"] != "12 Sexual Innuendo test Dirty Little Puzzle" {
		t.Fatalf("title_ratings = %v", rows)
	}

	// running it again changes nothing
	if again, err := Import(context.Background(), pool, &ix, "test"); err != nil || again != want {
		t.Fatalf("second import = %+v, %v", again, err)
	}
}
