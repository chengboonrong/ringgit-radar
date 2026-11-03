package api

import (
	"context"
	"crypto/md5"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/testdb"
)

// testEnv runs the API against a private schema in the test database, built from the real
// migration files, so these tests never collide with the collector tests in the same database.
type testEnv struct {
	t    *testing.T
	pool *pgxpool.Pool
	h    http.Handler
	run  int64
}

func newEnv(t *testing.T) *testEnv {
	t.Helper()
	pool := testdb.Pool(t)
	e := &testEnv{t: t, pool: pool, h: New(pool, nil, slog.New(slog.NewTextHandler(io.Discard, nil)))}
	if err := pool.QueryRow(context.Background(), `INSERT INTO collection_runs (provider, status, finished_at) VALUES ('t', 'succeeded', now()) RETURNING id`).Scan(&e.run); err != nil {
		t.Fatal(err)
	}
	return e
}

type game struct {
	nsuid, title, publisher string
	hard                    string // 05_BEE or 1_HAC
	sctg                    string // dl_soft, bundle, aoc
	ssitu                   string
	raw                     map[string]any // extra raw fields
	// price; regular 0 means no price row
	regular  int64
	discount *int64
	start    time.Time
	end      time.Time
}

func sen(v int64) *int64 { return &v }

func (e *testEnv) add(g game) {
	e.t.Helper()
	if g.hard == "" {
		g.hard = "05_BEE"
	}
	if g.sctg == "" {
		g.sctg = "dl_soft"
	}
	if g.ssitu == "" {
		g.ssitu = "onsale"
	}
	sum := sha256.Sum256([]byte(g.nsuid))
	raw := map[string]any{"sctg": g.sctg, "hard": g.hard, "ssitu": g.ssitu, "iurl": hex.EncodeToString(sum[:]), "text": "About " + g.title}
	for k, v := range g.raw {
		raw[k] = v
	}
	b, _ := json.Marshal(raw)
	ctx := context.Background()
	if _, err := e.pool.Exec(ctx, `INSERT INTO products (nsuid, title, publisher, platform, kind, source_status, raw) VALUES ($1,$2,$3,$4,'',$5,$6)`,
		g.nsuid, g.title, g.publisher, g.hard, g.ssitu, json.RawMessage(b)); err != nil {
		e.t.Fatal(err)
	}
	if g.regular == 0 {
		return
	}
	var start, end any
	if g.discount != nil {
		start, end = g.start, g.end
	}
	if _, err := e.pool.Exec(ctx, `INSERT INTO prices (nsuid, region, currency, regular_minor, discount_minor, discount_start, discount_end, sales_status)
		VALUES ($1,'MY','MYR',$2,$3,$4,$5,'onsale')`, g.nsuid, g.regular, g.discount, start, end); err != nil {
		e.t.Fatal(err)
	}
}

func (e *testEnv) history(nsuid string, at time.Time, regular int64, discount *int64) {
	e.t.Helper()
	var start, end any
	if discount != nil {
		start, end = at.Add(-time.Hour), at.Add(24*time.Hour)
	}
	if _, err := e.pool.Exec(context.Background(), `INSERT INTO price_history (nsuid, region, currency, regular_minor, discount_minor, discount_start, discount_end, observed_at, run_id)
		VALUES ($1,'MY','MYR',$2,$3,$4,$5,$6,$7)`, nsuid, regular, discount, start, end, at, e.run); err != nil {
		e.t.Fatal(err)
	}
}

func (e *testEnv) get(path string, into any) int {
	e.t.Helper()
	rec := httptest.NewRecorder()
	e.h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))
	if into != nil && rec.Code == http.StatusOK {
		if err := json.Unmarshal(rec.Body.Bytes(), into); err != nil {
			e.t.Fatalf("%s: bad json: %v\n%s", path, err, rec.Body.String())
		}
	}
	return rec.Code
}

type listResp struct {
	Items []struct {
		Nsuid       string   `json:"nsuid"`
		Title       string   `json:"title"`
		Publisher   string   `json:"publisher"`
		Rank        *int     `json:"rank"`
		Age         *int     `json:"age"`
		AgeDesc     []string `json:"age_descriptors"`
		ReleaseDate *string  `json:"release_date"`
		ReleaseText string   `json:"release_text"`
		Price       *struct {
			RegularMinor  int64      `json:"regular_minor"`
			CurrentMinor  int64      `json:"current_minor"`
			DiscountMinor *int64     `json:"discount_minor"`
			PercentOff    int        `json:"percent_off"`
			SavedMinor    int64      `json:"saved_minor"`
			OnSale        bool       `json:"on_sale"`
			DiscountEnd   *time.Time `json:"discount_end"`
		} `json:"price"`
	} `json:"items"`
	Total int `json:"total"`
	Page  int `json:"page"`
}

func (l listResp) ids() []string {
	var out []string
	for _, it := range l.Items {
		out = append(out, it.Nsuid)
	}
	return out
}

func has(ids []string, want ...string) bool {
	for _, w := range want {
		found := false
		for _, id := range ids {
			if id == w {
				found = true
			}
		}
		if !found {
			return false
		}
	}
	return true
}

func onSale(reg, disc int64, daysLeft float64) game {
	return game{regular: reg, discount: sen(disc), start: time.Now().Add(-24 * time.Hour), end: time.Now().Add(time.Duration(daysLeft * 24 * float64(time.Hour)))}
}

func TestFlaggedExcludedUnlessAskedFor(t *testing.T) {
	e := newEnv(t)
	e.add(game{nsuid: "1", title: "Quiet Garden", publisher: "A", regular: 5000})
	e.add(game{nsuid: "2", title: "Naughty Waifu Strip Club", publisher: "B", regular: 1000})
	e.add(game{nsuid: "3", title: "Dirty Rally Cars", publisher: "C", regular: 3000})
	e.add(game{nsuid: "4", title: "Hand Strippers' Tale", publisher: "D", regular: 3000}) // not a whole word: stays

	var l listResp
	e.get("/v1/games", &l)
	if got := l.ids(); !has(got, "1", "4") || has(got, "2", "3") || l.Total != 2 {
		t.Fatalf("default list = %v total %d", got, l.Total)
	}
	for _, path := range []string{"/v1/games?q=waifu", "/v1/games?ids=2,3", "/v1/games?all=1"} {
		var r listResp
		e.get(path, &r)
		if !has(r.ids(), "2") {
			t.Errorf("%s = %v, want the flagged title", path, r.ids())
		}
	}
	var h struct {
		TopSavings []struct{ Nsuid string } `json:"top_savings"`
	}
	e.add(func() game {
		g := onSale(10000, 1000, 5)
		g.nsuid, g.title, g.publisher = "5", "Sexy Panty Hunt", "E"
		return g
	}())
	e.get("/v1/highlights", &h)
	for _, it := range h.TopSavings {
		if it.Nsuid == "5" {
			t.Fatal("flagged title leaked into highlights")
		}
	}
}

func TestDefaultTypeAndExcludedStatuses(t *testing.T) {
	e := newEnv(t)
	e.add(game{nsuid: "1", title: "Game", publisher: "A", regular: 5000})
	e.add(game{nsuid: "2", title: "Bundle", publisher: "A", sctg: "bundle", regular: 5000})
	e.add(game{nsuid: "3", title: "DLC", publisher: "A", sctg: "aoc", regular: 500})
	e.add(game{nsuid: "4", title: "Gone", publisher: "A", ssitu: "sales_termination", regular: 500})
	e.add(game{nsuid: "5", title: "Missing", publisher: "A", ssitu: "not_found"})

	var l listResp
	e.get("/v1/games", &l)
	if !has(l.ids(), "1") || l.Total != 1 {
		t.Fatalf("default = %v", l.ids())
	}
	e.get("/v1/games?type=bundle,addon", &l)
	if got := l.ids(); !has(got, "2", "3") || has(got, "1") {
		t.Fatalf("type=bundle,addon = %v", got)
	}
	e.get("/v1/games?ids=3,4,5", &l) // ids bypass type and the status exclusion
	if !has(l.ids(), "3", "4", "5") {
		t.Fatalf("ids = %v", l.ids())
	}
	for _, bad := range []string{"/v1/games?type=dlc", "/v1/games?sort=popular", "/v1/games?platform=ps5", "/v1/games?max_price=-1", "/v1/games?limit=0", "/v1/games?release=soon"} {
		if code := e.get(bad, nil); code != http.StatusBadRequest {
			t.Errorf("%s = %d, want 400", bad, code)
		}
	}
}

func TestUnreleasedWithoutPriceStillWorks(t *testing.T) {
	e := newEnv(t)
	e.add(game{nsuid: "1", title: "Soon Dated", publisher: "A", ssitu: "unreleased", raw: map[string]any{"dsdate": "2027-03-08 00:00:00", "sdate": "2027.3.8"}})
	e.add(game{nsuid: "2", title: "Soon Vague", publisher: "B", ssitu: "unreleased", raw: map[string]any{"sdate": "2027"}})

	var l listResp
	for _, sort := range []string{"savings", "discount", "price", "newest", "soonest", "ending", "title"} {
		if code := e.get("/v1/games?sort="+sort, &l); code != 200 || l.Total != 2 {
			t.Fatalf("sort=%s code=%d total=%d", sort, code, l.Total)
		}
	}
	e.get("/v1/games?release=upcoming", &l)
	if !has(l.ids(), "1", "2") || l.Items[0].Nsuid != "1" {
		t.Fatalf("upcoming = %v", l.ids())
	}
	byID := map[string]int{}
	for i, it := range l.Items {
		byID[it.Nsuid] = i
	}
	if it := l.Items[byID["1"]]; it.Price != nil || it.ReleaseDate == nil || *it.ReleaseDate != "2027-03-08" {
		t.Errorf("dated: %+v", it)
	}
	if it := l.Items[byID["2"]]; it.Price != nil || it.ReleaseDate != nil || it.ReleaseText != "2027" {
		t.Errorf("vague: %+v", it)
	}
	var d detailResp
	if code := e.get("/v1/games/1", &d); code != 200 || d.Price != nil || len(d.History) != 0 || d.Lowest != nil || d.FirstObservedAt != nil {
		t.Fatalf("detail code=%d %+v", code, d)
	}
}

func TestPercentOffFloorsAndSavedIsSen(t *testing.T) {
	e := newEnv(t)
	a := onSale(7200, 6480, 5)
	a.nsuid, a.title, a.publisher = "1", "Ten Percent", "A"
	b := onSale(43900, 12800, 5) // 70.8% saved
	b.nsuid, b.title, b.publisher = "2", "Seventy", "B"
	c := onSale(10000, 9999, 5) // 0.01% saved: must not round up to 1
	c.nsuid, c.title, c.publisher = "3", "Hair", "C"
	for _, g := range []game{a, b, c} {
		e.add(g)
	}
	var l listResp
	e.get("/v1/games?sale=1", &l)
	got := map[string][3]int64{}
	for _, it := range l.Items {
		if !it.Price.OnSale || it.Price.DiscountMinor == nil {
			t.Fatalf("%s not on sale: %+v", it.Nsuid, it.Price)
		}
		got[it.Nsuid] = [3]int64{int64(it.Price.PercentOff), it.Price.SavedMinor, it.Price.CurrentMinor}
	}
	want := map[string][3]int64{"1": {10, 720, 6480}, "2": {70, 31100, 12800}, "3": {0, 1, 9999}}
	for k, w := range want {
		if got[k] != w {
			t.Errorf("%s: percent,saved,current = %v, want %v", k, got[k], w)
		}
	}
	if l.Items[0].Nsuid != "2" { // default sort is biggest savings in sen
		t.Errorf("first = %s, want 2", l.Items[0].Nsuid)
	}
	e.get("/v1/games?sale=1&sort=discount", &l)
	if l.Items[0].Nsuid != "2" || l.Items[2].Nsuid != "3" {
		t.Errorf("discount order = %v", l.ids())
	}
}

func TestPublisherCapOnHighlightsAndRanking(t *testing.T) {
	e := newEnv(t)
	for i := 1; i <= 5; i++ { // publisher A has five big sales, B two small ones
		g := onSale(100000, int64(100000-i*10000), 5)
		g.nsuid, g.title, g.publisher = fmt.Sprint(i), fmt.Sprintf("A game %d", i), "A"
		e.add(g)
	}
	for i := 6; i <= 7; i++ {
		g := onSale(2000, 1000, 5)
		g.nsuid, g.title, g.publisher = fmt.Sprint(i), fmt.Sprintf("B game %d", i), "B"
		e.add(g)
	}
	var r listResp
	e.get("/v1/ranking", &r)
	if len(r.Items) != 5 {
		t.Fatalf("ranking has %d items %v, want 3 from A plus 2 from B", len(r.Items), r.ids())
	}
	perPub := map[string]int{}
	for i, it := range r.Items {
		perPub[it.Publisher]++
		if it.Rank == nil || *it.Rank != i+1 {
			t.Errorf("item %d rank = %v", i, it.Rank)
		}
		if i > 0 && it.Price.SavedMinor > r.Items[i-1].Price.SavedMinor {
			t.Errorf("ranking not ordered by saved_minor at %d", i)
		}
	}
	if perPub["A"] != 3 || perPub["B"] != 2 {
		t.Errorf("per publisher = %v", perPub)
	}
	if r.Items[0].Nsuid != "5" { // 50 000 sen saved is the biggest
		t.Errorf("first = %s", r.Items[0].Nsuid)
	}

	var h struct {
		TopSavings []struct{ Nsuid, Publisher string } `json:"top_savings"`
	}
	e.get("/v1/highlights", &h)
	n := 0
	for _, it := range h.TopSavings {
		if it.Publisher == "A" {
			n++
		}
	}
	if n != 3 || len(h.TopSavings) != 5 {
		t.Errorf("top_savings: %d from A of %d", n, len(h.TopSavings))
	}

	// platform tab
	e.add(func() game {
		g := onSale(9000, 1000, 5)
		g.nsuid, g.title, g.publisher, g.hard = "8", "Old Console", "C", "1_HAC"
		return g
	}())
	e.get("/v1/ranking?platform=switch", &r)
	if len(r.Items) != 1 || r.Items[0].Nsuid != "8" {
		t.Errorf("switch ranking = %v", r.ids())
	}
}

func TestSaleWindowsDriveHighlights(t *testing.T) {
	e := newEnv(t)
	now := time.Now()
	mk := func(id string, pub string, start, end time.Time) {
		g := game{nsuid: id, title: "G" + id, publisher: pub, regular: 5000, discount: sen(2500), start: start, end: end}
		e.add(g)
	}
	mk("1", "P1", now.Add(-48*time.Hour), now.Add(2*24*time.Hour))        // ends in 2 days, started 2 days ago
	mk("2", "P2", now.Add(-10*24*time.Hour), now.Add(10*24*time.Hour))    // old, long sale
	mk("3", "P3", now.Add(-3*24*time.Hour), now.Add(-time.Hour))          // already ended
	mk("4", "P4", now.Add(2*24*time.Hour), now.Add(9*24*time.Hour))       // not started
	mk("5", "P5", now.Add(-time.Hour), now.Add(3*24*time.Hour+time.Hour)) // ends just past 3 days

	var h struct {
		EndingSoon []struct{ Nsuid string } `json:"ending_soon"`
		NewSales   []struct{ Nsuid string } `json:"new_sales"`
		Top        []struct{ Nsuid string } `json:"top_savings"`
	}
	e.get("/v1/highlights", &h)
	pick := func(xs []struct{ Nsuid string }) []string {
		var o []string
		for _, x := range xs {
			o = append(o, x.Nsuid)
		}
		return o
	}
	if got := pick(h.EndingSoon); len(got) != 1 || got[0] != "1" {
		t.Errorf("ending_soon = %v, want [1]", got)
	}
	if got := pick(h.NewSales); !has(got, "1", "5") || has(got, "2", "3", "4") {
		t.Errorf("new_sales = %v, want 1 and 5 only", got)
	}
	if got := pick(h.Top); !has(got, "1", "2", "5") || has(got, "3", "4") {
		t.Errorf("top_savings = %v, want live sales only", got)
	}

	// an ended or future discount shows the regular price, not a sale
	for _, id := range []string{"3", "4"} {
		var d detailResp
		e.get("/v1/games/"+id, &d)
		if d.Price == nil || d.Price.OnSale || d.Price.CurrentMinor != 5000 || d.Price.DiscountMinor != nil || d.Price.PercentOff != 0 {
			t.Errorf("game %s price = %+v", id, d.Price)
		}
	}
	var d detailResp
	e.get("/v1/games/1", &d)
	if d.Price.DiscountEnd == nil || d.Price.DiscountEnd.Sub(now.Add(48*time.Hour)).Abs() > 5*time.Second {
		t.Errorf("discount_end = %v", d.Price.DiscountEnd)
	}
	var l listResp
	e.get("/v1/games?sort=ending&sale=1", &l)
	if got := l.ids(); len(got) != 3 || got[0] != "1" {
		t.Errorf("ending order = %v, want 1 first", got)
	}
}

func TestRecentReleases(t *testing.T) {
	e := newEnv(t)
	day := func(n int) string {
		return time.Now().In(time.FixedZone("MYT", 8*3600)).AddDate(0, 0, n).Format("2006-01-02") + " 00:00:00"
	}
	e.add(game{nsuid: "1", title: "Fresh", publisher: "A", regular: 5000, raw: map[string]any{"dsdate": day(-3)}})
	e.add(game{nsuid: "2", title: "Stale", publisher: "B", regular: 5000, raw: map[string]any{"dsdate": day(-45)}})
	e.add(game{nsuid: "3", title: "Later", publisher: "C", regular: 5000, ssitu: "preorder", raw: map[string]any{"dsdate": day(20)}})
	var h struct {
		Recent []struct{ Nsuid string } `json:"recent"`
	}
	e.get("/v1/highlights", &h)
	if len(h.Recent) != 1 || h.Recent[0].Nsuid != "1" {
		t.Errorf("recent = %v", h.Recent)
	}
	var l listResp
	e.get("/v1/games?release=recent", &l)
	if got := l.ids(); len(got) != 1 || got[0] != "1" {
		t.Errorf("release=recent = %v", got)
	}
	e.get("/v1/games?release=upcoming", &l)
	if got := l.ids(); len(got) != 1 || got[0] != "3" {
		t.Errorf("release=upcoming = %v", got)
	}
}

type detailResp struct {
	Title           string   `json:"title"`
	Screenshots     []string `json:"screenshots"`
	Dcolors         []string `json:"dcolors"`
	Genres          []string `json:"genres"`
	Description     string   `json:"description"`
	FirstObservedAt *string  `json:"first_observed_at"`
	Price           *struct {
		CurrentMinor  int64      `json:"current_minor"`
		DiscountMinor *int64     `json:"discount_minor"`
		PercentOff    int        `json:"percent_off"`
		OnSale        bool       `json:"on_sale"`
		DiscountEnd   *time.Time `json:"discount_end"`
	} `json:"price"`
	History []struct {
		RegularMinor  int64  `json:"regular_minor"`
		DiscountMinor *int64 `json:"discount_minor"`
		PriceMinor    int64  `json:"price_minor"`
	} `json:"history"`
	Lowest *struct {
		PriceMinor int64     `json:"price_minor"`
		Since      time.Time `json:"since"`
		IsSale     bool      `json:"is_sale"`
	} `json:"lowest"`
	Addons []struct{ Nsuid, Title string } `json:"addons"`
}

func TestDetailHistoryLowestAndAddons(t *testing.T) {
	e := newEnv(t)
	base := onSale(7200, 6480, 5)
	base.nsuid, base.title, base.publisher = "1", "Main Game", "A"
	base.raw = map[string]any{
		"sslurl": []string{"aa", "bb"}, "dcolors": []string{"112233"}, "genre": []string{"Action", "RPG"},
		"cnsuid": []string{"2", "999"}, // 999 is not in products
	}
	e.add(base)
	e.add(game{nsuid: "2", title: "Main Game Pass", publisher: "A", sctg: "aoc", regular: 1500})

	t0 := time.Date(2026, 11, 1, 3, 0, 0, 0, time.UTC)
	e.history("1", t0, 7200, nil)
	e.history("1", t0.Add(24*time.Hour), 7200, sen(5000))
	e.history("1", t0.Add(48*time.Hour), 7200, sen(5000)) // same price seen again: lowest "since" must stay at day 2
	e.history("1", t0.Add(72*time.Hour), 7200, sen(6480))

	var d detailResp
	if code := e.get("/v1/games/1", &d); code != 200 {
		t.Fatalf("code %d", code)
	}
	if len(d.History) != 4 || d.History[0].PriceMinor != 7200 || d.History[1].PriceMinor != 5000 || d.History[1].DiscountMinor == nil {
		t.Errorf("history = %+v", d.History)
	}
	if d.FirstObservedAt == nil || !strings.HasPrefix(*d.FirstObservedAt, "2026-11-01T03:00:00") {
		t.Errorf("first_observed_at = %v", d.FirstObservedAt)
	}
	if d.Lowest == nil || d.Lowest.PriceMinor != 5000 || !d.Lowest.IsSale || !d.Lowest.Since.Equal(t0.Add(24*time.Hour)) {
		t.Errorf("lowest = %+v", d.Lowest)
	}
	if len(d.Screenshots) != 2 || len(d.Genres) != 2 || d.Dcolors[0] != "112233" || d.Description != "About Main Game" {
		t.Errorf("detail fields: %+v", d)
	}
	if len(d.Addons) != 1 || d.Addons[0].Nsuid != "2" {
		t.Errorf("addons = %+v", d.Addons)
	}
	if d.Price.PercentOff != 10 || d.Price.CurrentMinor != 6480 {
		t.Errorf("price = %+v", d.Price)
	}
	if code := e.get("/v1/games/424242", nil); code != http.StatusNotFound {
		t.Errorf("unknown game = %d", code)
	}
}

func TestFiltersSortsPagingGenresStatus(t *testing.T) {
	e := newEnv(t)
	e.add(game{nsuid: "1", title: "Cheap Switch Two", publisher: "A", regular: 1000, raw: map[string]any{"genre": []string{"Action"}}})
	e.add(game{nsuid: "2", title: "Dear Switch Two", publisher: "B", regular: 9000, raw: map[string]any{"genre": []string{"Action", "RPG"}}})
	e.add(game{nsuid: "3", title: "Old Console", publisher: "C", hard: "1_HAC", regular: 500, raw: map[string]any{"genre": []string{"RPG"}}})
	var l listResp
	e.get("/v1/games?sort=price", &l)
	if got := l.ids(); got[0] != "3" || got[2] != "2" {
		t.Errorf("price order = %v", got)
	}
	e.get("/v1/games?platform=switch2&max_price=1000", &l)
	if got := l.ids(); len(got) != 1 || got[0] != "1" {
		t.Errorf("platform+cap = %v", got)
	}
	e.get("/v1/games?genre=RPG&sort=title", &l)
	if got := l.ids(); len(got) != 2 || got[0] != "2" {
		t.Errorf("genre = %v", got)
	}
	e.get("/v1/games?q=switch%20two&limit=1&page=2&sort=title", &l)
	if len(l.Items) != 1 || l.Total != 2 || l.Page != 2 {
		t.Errorf("paging = %+v", l)
	}
	e.get("/v1/games?q=%25", &l) // a literal percent matches nothing, it is not a wildcard
	if l.Total != 0 {
		t.Errorf("q=%%25 total = %d", l.Total)
	}
	e.get("/v1/games?q=nothing&page=3", &l)
	if len(l.Items) != 0 || l.Total != 0 {
		t.Errorf("empty page = %+v", l)
	}

	var g struct {
		Items []struct {
			Name  string
			Count int
		}
	}
	e.get("/v1/genres", &g)
	if len(g.Items) != 2 || g.Items[0].Count != 2 {
		t.Errorf("genres = %+v", g)
	}
	var st struct {
		LastRunAt    *time.Time `json:"last_run_at"`
		ProductCount int        `json:"product_count"`
		HistorySince *time.Time `json:"history_since"`
	}
	e.get("/v1/status/prices", &st)
	if st.LastRunAt == nil || st.ProductCount != 3 || st.HistorySince != nil {
		t.Errorf("status = %+v", st)
	}
	e.history("1", time.Date(2026, 11, 1, 0, 0, 0, 0, time.UTC), 1000, nil)
	e.get("/v1/status/prices", &st)
	if st.HistorySince == nil || st.HistorySince.Day() != 1 {
		t.Errorf("history_since = %v", st.HistorySince)
	}
}

func TestCORSOnlyForLocalhost(t *testing.T) {
	e := newEnv(t)
	for origin, want := range map[string]string{
		"http://localhost:5173": "http://localhost:5173", "http://127.0.0.1:8080": "http://127.0.0.1:8080", "https://example.com": "",
	} {
		req := httptest.NewRequest(http.MethodGet, "/v1/genres", nil)
		req.Header.Set("Origin", origin)
		rec := httptest.NewRecorder()
		e.h.ServeHTTP(rec, req)
		if got := rec.Header().Get("Access-Control-Allow-Origin"); got != want {
			t.Errorf("origin %s: allow-origin = %q, want %q", origin, got, want)
		}
	}
}

func TestNewestListsReleasedBeforeUpcoming(t *testing.T) {
	e := newEnv(t)
	day := func(n int) string {
		return time.Now().In(time.FixedZone("MYT", 8*3600)).AddDate(0, 0, n).Format("2006-01-02") + " 00:00:00"
	}
	e.add(game{nsuid: "1", title: "Old", publisher: "A", regular: 100, raw: map[string]any{"dsdate": day(-100)}})
	e.add(game{nsuid: "2", title: "Fresh", publisher: "B", regular: 100, raw: map[string]any{"dsdate": day(-2)}})
	e.add(game{nsuid: "3", title: "Future", publisher: "C", regular: 100, ssitu: "preorder", raw: map[string]any{"dsdate": day(90)}})
	var l listResp
	e.get("/v1/games?sort=newest", &l)
	if got := l.ids(); fmt.Sprint(got) != "[2 1 3]" {
		t.Fatalf("newest = %v, want [2 1 3]", got)
	}
}

func (e *testEnv) rate(nsuid string, age int, descriptors ...string) {
	e.t.Helper()
	if descriptors == nil {
		descriptors = []string{}
	}
	if _, err := e.pool.Exec(context.Background(), `INSERT INTO title_ratings (nsuid, age, descriptors, source, matched_name) VALUES ($1,$2,$3,'test','x')`, nsuid, age, descriptors); err != nil {
		e.t.Fatal(err)
	}
}

func TestAgeFilterKeepsUnratedGamesListed(t *testing.T) {
	e := newEnv(t)
	e.add(game{nsuid: "1", title: "Twelve", publisher: "A", regular: 1000})
	e.add(game{nsuid: "2", title: "Sixteen", publisher: "B", regular: 1000})
	e.add(game{nsuid: "3", title: "Unrated", publisher: "C", regular: 1000})
	e.add(game{nsuid: "4", title: "Plain Three", publisher: "D", regular: 1000})
	e.rate("1", 12, "Violence", "Bad Language")
	e.rate("2", 16, "Strong Violence")
	e.rate("4", 3)

	var l listResp
	e.get("/v1/games?sort=title", &l)
	if got := l.ids(); len(got) != 4 {
		t.Fatalf("without a filter every game is listed, got %v", got)
	}
	byID := map[string]int{}
	for i, it := range l.Items {
		byID[it.Nsuid] = i
	}
	if it := l.Items[byID["1"]]; it.Age == nil || *it.Age != 12 || strings.Join(it.AgeDesc, ",") != "Violence,Bad Language" {
		t.Errorf("rated card: %+v", it)
	}
	if it := l.Items[byID["3"]]; it.Age != nil || it.AgeDesc != nil {
		t.Errorf("an unrated card must have null age and descriptors: %+v", it)
	}
	if it := l.Items[byID["4"]]; it.Age == nil || *it.Age != 3 || it.AgeDesc == nil || len(it.AgeDesc) != 0 {
		t.Errorf("a rated game with no descriptors has an empty list, not null: %+v", it)
	}

	for path, want := range map[string]string{
		"/v1/games?age=12&sort=title":    "[1]",
		"/v1/games?age=12,16&sort=title": "[2 1]",
		"/v1/games?age=3&sort=title":     "[4]",
		"/v1/games?age=18&sort=title":    "[]", // unrated games are not "18"; with a filter set they drop out
	} {
		e.get(path, &l)
		if got := fmt.Sprint(l.ids()); got != want {
			t.Errorf("%s = %s, want %s", path, got, want)
		}
	}
	if code := e.get("/v1/games?age=old", nil); code != http.StatusBadRequest {
		t.Errorf("bad age = %d", code)
	}

	var d struct {
		Age     *int     `json:"age"`
		AgeDesc []string `json:"age_descriptors"`
	}
	e.get("/v1/games/1", &d)
	if d.Age == nil || *d.Age != 12 || len(d.AgeDesc) != 2 {
		t.Errorf("detail rating = %+v", d)
	}
	d = struct {
		Age     *int     `json:"age"`
		AgeDesc []string `json:"age_descriptors"`
	}{}
	e.get("/v1/games/3", &d)
	if d.Age != nil || d.AgeDesc != nil {
		t.Errorf("unrated detail = %+v", d)
	}
}

func TestSexualDescriptorsDoNotFlagAGame(t *testing.T) {
	// the rating-filter test (docs/research/rating-filter-test.md) found every descriptor rule hides real games
	e := newEnv(t)
	e.add(game{nsuid: "1", title: "Octopath Traveler Like", publisher: "A", regular: 1000})
	e.rate("1", 12, "Bad Language", "Sex")
	var l listResp
	e.get("/v1/games", &l)
	if !has(l.ids(), "1") {
		t.Fatalf("a rated 12 with Sex is still listed, got %v", l.ids())
	}
}

func hashOf(nsuid string) string {
	sum := sha256.Sum256([]byte(nsuid))
	return hex.EncodeToString(sum[:])
}

func TestGenreCoverIsDeterministicAndSkipsFlaggedAndArtless(t *testing.T) {
	e := newEnv(t)
	// Action: a flagged game with lots of art, a Switch game with lots of art, then Switch 2 games
	e.add(game{nsuid: "1", title: "Sexy Strip Show", publisher: "A", regular: 100, raw: map[string]any{"genre": []string{"Action"}, "sslurl": []string{"a", "b", "c"}}})
	e.add(game{nsuid: "2", title: "Old Console Action", publisher: "B", hard: "1_HAC", regular: 100, raw: map[string]any{"genre": []string{"Action"}, "sslurl": []string{"a", "b", "c", "d"}}})
	e.add(game{nsuid: "9", title: "Thin Switch 2 Action", publisher: "C", regular: 100, raw: map[string]any{"genre": []string{"Action"}, "sslurl": []string{"a"}}})
	e.add(game{nsuid: "3", title: "Rich Switch 2 Action", publisher: "D", regular: 100, raw: map[string]any{"genre": []string{"Action"}, "sslurl": []string{"a", "b", "c"}}})
	// Strategy: two Switch 2 games that tie on everything, so the md5(genre || nsuid) order decides
	e.add(game{nsuid: "6", title: "Strategy Six", publisher: "G", regular: 100, raw: map[string]any{"genre": []string{"Strategy"}}})
	e.add(game{nsuid: "7", title: "Strategy Seven", publisher: "H", regular: 100, raw: map[string]any{"genre": []string{"Strategy"}}})
	// Puzzle: a Switch game with no art at all
	e.add(game{nsuid: "4", title: "Artless Puzzle", publisher: "E", hard: "1_HAC", regular: 100, raw: map[string]any{"genre": []string{"Puzzle"}, "iurl": ""}})
	// Racing: no art anywhere
	e.add(game{nsuid: "5", title: "Artless Racing", publisher: "F", regular: 100, raw: map[string]any{"iurl": "", "genre": []string{"Racing"}}})

	type genre struct {
		Name  string
		Count int
		Cover string
	}
	var first, second struct{ Items []genre }
	e.get("/v1/genres", &first)
	e.get("/v1/genres", &second)
	if fmt.Sprint(first) != fmt.Sprint(second) {
		t.Fatalf("two calls differ:\n%v\n%v", first, second)
	}
	got := map[string]genre{}
	for _, g := range first.Items {
		got[g.Name] = g
	}
	if g := got["Action"]; g.Count != 3 || g.Cover != hashOf("3") {
		t.Errorf("Action = %+v, want 3 games (the flagged one left out) and the Switch 2 game with 3 screenshots", g)
	}
	sum := func(nsuid string) string { h := md5.Sum([]byte("Strategy" + nsuid)); return hex.EncodeToString(h[:]) }
	want := hashOf("6")
	if sum("7") < sum("6") {
		want = hashOf("7")
	}
	if g := got["Strategy"]; g.Count != 2 || g.Cover != want {
		t.Errorf("Strategy = %+v, want the cover of the lower md5 (%s)", g, want)
	}
	if g := got["Puzzle"]; g.Count != 1 || g.Cover != "" {
		t.Errorf("Puzzle = %+v, want a count and no cover", g)
	}
	if g := got["Racing"]; g.Count != 1 || g.Cover != "" {
		t.Errorf("Racing = %+v", g)
	}
}

func TestHighlightsTopSavingsLeadWithSwitch2(t *testing.T) {
	e := newEnv(t)
	big := onSale(90000, 10000, 5) // a Switch game that saves far more
	big.nsuid, big.title, big.publisher, big.hard = "1", "Bigger Saving On Switch", "A", "1_HAC"
	e.add(big)
	small := onSale(20000, 15000, 5)
	small.nsuid, small.title, small.publisher = "2", "Smaller Saving On Switch 2", "B"
	e.add(small)

	var h struct {
		TopSavings []struct{ Nsuid, Platform string } `json:"top_savings"`
	}
	e.get("/v1/highlights", &h)
	if len(h.TopSavings) != 1 || h.TopSavings[0].Nsuid != "2" || h.TopSavings[0].Platform != "switch2" {
		t.Fatalf("top_savings = %+v, want only the Switch 2 game", h.TopSavings)
	}
	// the cross-platform ranking still sees the bigger saving first
	var r listResp
	e.get("/v1/ranking", &r)
	if got := r.ids(); len(got) != 2 || got[0] != "1" {
		t.Fatalf("ranking = %v", got)
	}
}

func TestOnlyGoodAnswersAreCachedByACDN(t *testing.T) {
	e := newEnv(t)
	e.add(game{nsuid: "1", title: "Cached", publisher: "A", regular: 1000})
	cc := func(path string) (int, string) {
		rec := httptest.NewRecorder()
		e.h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, path, nil))
		return rec.Code, rec.Header().Get("Cache-Control")
	}
	const long = "public, max-age=60, s-maxage=600, stale-while-revalidate=1800"
	for _, path := range []string{"/v1/games", "/v1/games/1", "/v1/highlights", "/v1/ranking", "/v1/genres", "/v1/games?ids=1"} {
		if code, got := cc(path); code != 200 || got != long {
			t.Errorf("%s = %d %q, want 200 and %q", path, code, got, long)
		}
	}
	if code, got := cc("/v1/status/prices"); code != 200 || got != "public, max-age=30, s-maxage=60" {
		t.Errorf("status = %d %q, want a one minute CDN life", code, got)
	}
	// anything that is not a 200 says no-store, so a CDN never keeps a 404, a 400 or a 500
	for _, path := range []string{"/v1/games/424242", "/v1/games?sort=popular", "/v1/games?limit=0", "/v1/nope", "/v1/ranking?platform=ps5"} {
		if code, got := cc(path); code < 400 || got != "no-store" {
			t.Errorf("%s = %d %q, want an error with no-store", path, code, got)
		}
	}
	// the Wish List request is keyed by its ids, which are in the URL: different lists, different answers
	var a, b listResp
	e.get("/v1/games?ids=1", &a)
	e.get("/v1/games?ids=999", &b)
	if a.Total == b.Total {
		t.Errorf("ids=1 and ids=999 gave the same total %d: the ids must decide the answer", a.Total)
	}
}
