package collector

import (
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/nintendo"
)

// fakeNintendo serves a mutable catalogue and price list. Tests change it between sweeps.
type fakeNintendo struct {
	mu          sync.Mutex
	items       []map[string]any          // catalogue rows
	totalExtra  int                       // added to the reported total
	prices      map[string]map[string]any // nsuid -> price entry without title_id
	priceCalls  int
	failOnCall  int // 1-based price call that answers failStatus; 0 = never
	failStatus  int
	onPriceCall func() // runs inside every price call, before answering
}

func (f *fakeNintendo) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()
	q := r.URL.Query()
	if strings.HasSuffix(r.URL.Path, "/search") {
		limit, _ := strconv.Atoi(q.Get("limit"))
		page, _ := strconv.Atoi(q.Get("page"))
		lo := min((page-1)*limit, len(f.items))
		hi := min(page*limit, len(f.items))
		json.NewEncoder(w).Encode(map[string]any{"result": map[string]any{"total": len(f.items) + f.totalExtra, "items": f.items[lo:hi]}})
		return
	}
	f.priceCalls++
	if f.onPriceCall != nil {
		f.onPriceCall()
	}
	if f.failOnCall == f.priceCalls {
		w.WriteHeader(f.failStatus)
		return
	}
	var out []map[string]any
	for _, id := range strings.Split(q.Get("ids"), ",") {
		if p, ok := f.prices[id]; ok {
			e := map[string]any{"title_id": json.Number(id)}
			for k, v := range p {
				e[k] = v
			}
			out = append(out, e)
		}
	}
	json.NewEncoder(w).Encode(map[string]any{"prices": out})
}

func (f *fakeNintendo) update(fn func()) {
	f.mu.Lock()
	defer f.mu.Unlock()
	fn()
}

func item(nsuid any, title string) map[string]any {
	return map[string]any{"nsuid": nsuid, "title": title, "maker": "Maker", "hard": "1_HAC", "sform": "HAC_DL", "ssitu": "onsale", "pprice": 999.0}
}

func regular(raw string) map[string]any {
	return map[string]any{"sales_status": "onsale", "regular_price": map[string]any{"amount": "RM" + raw, "currency": "MYR", "raw_value": raw}}
}

func discounted(regRaw, discRaw, start, end string) map[string]any {
	p := regular(regRaw)
	d := map[string]any{"amount": "RM" + discRaw, "currency": "MYR", "raw_value": discRaw}
	if start != "" {
		d["start_datetime"] = start
	}
	if end != "" {
		d["end_datetime"] = end
	}
	p["discount_price"] = d
	return p
}

func testPool(t *testing.T) *pgxpool.Pool {
	t.Helper()
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Fatal("TEST_DATABASE_URL is not set (e.g. postgres:///eshop_radar_test)")
	}
	pool, err := pgxpool.New(context.Background(), url)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	if _, err := pool.Exec(context.Background(), `TRUNCATE price_history, prices, products, collection_runs RESTART IDENTITY CASCADE`); err != nil {
		t.Fatal(err)
	}
	return pool
}

type env struct {
	t    *testing.T
	pool *pgxpool.Pool
	fake *fakeNintendo
	sw   *Sweep
}

func newEnv(t *testing.T) *env {
	t.Helper()
	pool := testPool(t)
	fake := &fakeNintendo{prices: map[string]map[string]any{}}
	srv := httptest.NewServer(fake)
	t.Cleanup(srv.Close)
	client := &nintendo.Client{SearchURL: srv.URL + "/search", PriceURL: srv.URL + "/price", HTTP: srv.Client(), UserAgent: "test", Backoff: time.Millisecond}
	return &env{t, pool, fake, &Sweep{Pool: pool, Client: client, Log: slog.New(slog.NewTextHandler(io.Discard, nil))}}
}

func (e *env) run() (Counts, error) {
	_, c, err := e.sw.Run(context.Background())
	return c, err
}

func (e *env) mustRun() Counts {
	e.t.Helper()
	c, err := e.run()
	if err != nil {
		e.t.Fatalf("sweep: %v", err)
	}
	return c
}

func (e *env) count(table string) int {
	e.t.Helper()
	var n int
	if err := e.pool.QueryRow(context.Background(), `SELECT count(*) FROM `+table).Scan(&n); err != nil {
		e.t.Fatal(err)
	}
	return n
}

func (e *env) checkedAt(nsuid string) time.Time {
	e.t.Helper()
	var ts time.Time
	if err := e.pool.QueryRow(context.Background(), `SELECT checked_at FROM prices WHERE nsuid=$1 AND region='MY'`, nsuid).Scan(&ts); err != nil {
		e.t.Fatal(err)
	}
	return ts
}

func TestFirstSweepWritesHistory(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha"), item("1002", "Beta"), item(nil, "No id"), item("1001", "Alpha again")}
	e.fake.prices["1001"] = regular("12.5")
	e.fake.prices["1002"] = discounted("72", "64.80", "2026-10-28T16:00:00Z", "2026-12-16T15:59:59Z")

	c := e.mustRun()
	want := Counts{ProductsSeen: 2, ProductsSkipped: 1, PricesSeen: 2, PriceChanges: 2}
	if c != want {
		t.Fatalf("counts = %+v, want %+v", c, want)
	}
	if e.count("products") != 2 || e.count("prices") != 2 || e.count("price_history") != 2 {
		t.Fatalf("rows: products=%d prices=%d history=%d", e.count("products"), e.count("prices"), e.count("price_history"))
	}

	var title, publisher, platform, kind, status, rawTitle string
	if err := e.pool.QueryRow(context.Background(),
		`SELECT title, publisher, platform, kind, source_status, raw->>'title' FROM products WHERE nsuid='1001'`).
		Scan(&title, &publisher, &platform, &kind, &status, &rawTitle); err != nil {
		t.Fatal(err)
	}
	if title != "Alpha" || publisher != "Maker" || platform != "1_HAC" || kind != "HAC_DL" || status != "onsale" || rawTitle != "Alpha" {
		t.Fatalf("product row wrong: %q %q %q %q %q %q", title, publisher, platform, kind, status, rawTitle)
	}

	var reg, disc int64
	var start, end time.Time
	var cur string
	if err := e.pool.QueryRow(context.Background(),
		`SELECT currency, regular_minor, discount_minor, discount_start, discount_end FROM prices WHERE nsuid='1002' AND region='MY'`).
		Scan(&cur, &reg, &disc, &start, &end); err != nil {
		t.Fatal(err)
	}
	if cur != "MYR" || reg != 7200 || disc != 6480 ||
		!start.Equal(time.Date(2026, 10, 28, 16, 0, 0, 0, time.UTC)) || !end.Equal(time.Date(2026, 12, 16, 15, 59, 59, 0, time.UTC)) {
		t.Fatalf("price row wrong: %s %d %d %v %v", cur, reg, disc, start, end)
	}

	var status2 string
	var finished *time.Time
	var seen, changes int64
	if err := e.pool.QueryRow(context.Background(),
		`SELECT status, finished_at, products_seen, price_changes FROM collection_runs`).Scan(&status2, &finished, &seen, &changes); err != nil {
		t.Fatal(err)
	}
	if status2 != "succeeded" || finished == nil || seen != 2 || changes != 2 {
		t.Fatalf("run row: %s %v %d %d", status2, finished, seen, changes)
	}
}

func TestIdenticalSecondSweepAddsNoHistoryButAdvancesCheckedAt(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha"), item("1002", "Beta")}
	e.fake.prices["1001"] = regular("12.5")
	e.fake.prices["1002"] = discounted("72", "64.80", "2026-10-28T16:00:00Z", "2026-12-16T15:59:59Z")

	e.mustRun()
	first := e.checkedAt("1001")
	c := e.mustRun()

	if c.PriceChanges != 0 || c.PricesSeen != 2 {
		t.Fatalf("counts = %+v", c)
	}
	if e.count("price_history") != 2 {
		t.Fatalf("history = %d, want 2", e.count("price_history"))
	}
	if second := e.checkedAt("1001"); !second.After(first) {
		t.Fatalf("checked_at did not advance: %v then %v", first, second)
	}
	if e.count("collection_runs") != 2 {
		t.Fatalf("runs = %d", e.count("collection_runs"))
	}
}

func TestPriceChangeAddsOneRow(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha"), item("1002", "Beta")}
	e.fake.prices["1001"] = regular("12.5")
	e.fake.prices["1002"] = regular("8.5")
	e.mustRun()

	e.fake.update(func() { e.fake.prices["1001"] = regular("10") })
	c := e.mustRun()

	if c.PriceChanges != 1 || e.count("price_history") != 3 {
		t.Fatalf("changes=%d history=%d", c.PriceChanges, e.count("price_history"))
	}
	var reg int64
	if err := e.pool.QueryRow(context.Background(), `SELECT regular_minor FROM prices WHERE nsuid='1001'`).Scan(&reg); err != nil || reg != 1000 {
		t.Fatalf("current price = %d, %v", reg, err)
	}
}

func TestDiscountStartAndEndEachAddARow(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha")}
	set := func(start, end string) {
		e.fake.update(func() { e.fake.prices["1001"] = discounted("72", "64.80", start, end) })
	}
	step := func(wantHistory int, wantChanges int64) {
		t.Helper()
		if c := e.mustRun(); c.PriceChanges != wantChanges || e.count("price_history") != wantHistory {
			t.Fatalf("changes=%d history=%d, want %d and %d", c.PriceChanges, e.count("price_history"), wantChanges, wantHistory)
		}
	}

	e.fake.prices["1001"] = regular("72")
	step(1, 1)
	set("2026-10-28T16:00:00Z", "2026-12-16T15:59:59Z") // discount appears
	step(2, 1)
	set("2026-10-28T16:00:00Z", "2026-12-16T15:59:59Z") // same again
	step(2, 0)
	set("2026-10-28T16:00:00Z", "2026-12-20T15:59:59Z") // only the end moves
	step(3, 1)
	set("2026-10-29T16:00:00Z", "2026-12-20T15:59:59Z") // only the start moves
	step(4, 1)
	e.fake.update(func() { e.fake.prices["1001"] = regular("72") }) // discount ends
	step(5, 1)
	e.fake.update(func() { e.fake.prices["1001"] = regular("72") })
	step(5, 0)
}

func TestInvalidAndUnpricedWriteNothing(t *testing.T) {
	e := newEnv(t)
	const start, end = "2026-10-28T16:00:00Z", "2026-12-16T15:59:59Z"
	e.fake.items = []map[string]any{
		item("1", "good"), item("2", "usd"), item("3", "too many decimals"), item("4", "discount above regular"),
		item("5", "discount without timestamps"), item("6", "unpriced"), item("7", "bad discount currency"),
		item("8", "exponent"), item("9", "discount ends before it starts"), item("10", "discount missing end"),
	}
	usd := regular("10")
	usd["regular_price"].(map[string]any)["currency"] = "USD"
	badCur := discounted("72", "60", start, end)
	badCur["discount_price"].(map[string]any)["currency"] = "SGD"
	e.fake.prices = map[string]map[string]any{
		"1":  regular("12.5"),
		"2":  usd,
		"3":  regular("12.345"),
		"4":  discounted("50", "50.01", start, end),
		"5":  discounted("50", "40", "", ""),
		"6":  {"sales_status": "not_found"},
		"7":  badCur,
		"8":  regular("1e3"),
		"9":  discounted("50", "40", end, start),
		"10": discounted("50", "40", start, ""),
	}

	c := e.mustRun()
	want := Counts{ProductsSeen: 10, PricesSeen: 10, Unpriced: 1, InvalidPrices: 8, PriceChanges: 1}
	if c != want {
		t.Fatalf("counts = %+v, want %+v", c, want)
	}
	if e.count("prices") != 1 || e.count("price_history") != 1 || e.count("products") != 10 {
		t.Fatalf("rows: prices=%d history=%d products=%d", e.count("prices"), e.count("price_history"), e.count("products"))
	}
}

func TestForbiddenMidSweepFailsRunAndKeepsSavedRows(t *testing.T) {
	e := newEnv(t)
	for i := range 120 { // 3 price batches: 50, 50, 20
		id := strconv.Itoa(1000 + i)
		e.fake.items = append(e.fake.items, item(id, "T"+id))
		e.fake.prices[id] = regular("5")
	}
	e.fake.failOnCall, e.fake.failStatus = 2, http.StatusForbidden

	c, err := e.run()
	if err == nil || !strings.Contains(err.Error(), "403") {
		t.Fatalf("err = %v, want a 403 error", err)
	}
	if e.fake.priceCalls != 2 {
		t.Fatalf("price calls = %d, want 2 (no retry, sweep stopped)", e.fake.priceCalls)
	}
	if c.ProductsSeen != 120 || c.PricesSeen != 50 || c.PriceChanges != 50 {
		t.Fatalf("counts = %+v", c)
	}
	if e.count("products") != 120 || e.count("prices") != 50 || e.count("price_history") != 50 {
		t.Fatalf("rows: products=%d prices=%d history=%d", e.count("products"), e.count("prices"), e.count("price_history"))
	}

	var status, msg string
	var finished *time.Time
	var seen, priceChanges int64
	if err := e.pool.QueryRow(context.Background(),
		`SELECT status, finished_at, coalesce(error, ''), products_seen, price_changes FROM collection_runs`).
		Scan(&status, &finished, &msg, &seen, &priceChanges); err != nil {
		t.Fatal(err)
	}
	if status != "failed" || finished == nil || !strings.Contains(msg, "403") || seen != 120 || priceChanges != 50 {
		t.Fatalf("run row: %s %v %q %d %d", status, finished, msg, seen, priceChanges)
	}
}

func TestCancelledSweepStillRecordsFailedRun(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha")}
	e.fake.prices["1001"] = regular("12.5")
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	e.fake.onPriceCall = cancel

	_, _, err := e.sw.Run(ctx)
	if err == nil {
		t.Fatal("expected an error")
	}
	var status string
	if err := e.pool.QueryRow(context.Background(), `SELECT status FROM collection_runs`).Scan(&status); err != nil || status != "failed" {
		t.Fatalf("status = %q, %v", status, err)
	}
}

func TestIncompleteCatalogueFailsRunBeforePrices(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha")}
	e.fake.totalExtra = 5
	e.fake.prices["1001"] = regular("12.5")

	_, err := e.run()
	if err == nil || !strings.Contains(err.Error(), "1 of 6") {
		t.Fatalf("err = %v", err)
	}
	if e.fake.priceCalls != 0 || e.count("products") != 1 || e.count("prices") != 0 {
		t.Fatalf("priceCalls=%d products=%d prices=%d", e.fake.priceCalls, e.count("products"), e.count("prices"))
	}
	var status, msg string
	if err := e.pool.QueryRow(context.Background(), `SELECT status, error FROM collection_runs`).Scan(&status, &msg); err != nil ||
		status != "failed" || !strings.Contains(msg, "1 of 6") {
		t.Fatalf("run: %q %q %v", status, msg, err)
	}
}

func TestEmptyCatalogueFailsRun(t *testing.T) {
	e := newEnv(t) // the fake serves total 0 and no rows

	_, err := e.run()
	if err == nil || !strings.Contains(err.Error(), "no rows") {
		t.Fatalf("err = %v, want a no-rows error", err)
	}
	var status, msg string
	if err := e.pool.QueryRow(context.Background(), `SELECT status, coalesce(error, '') FROM collection_runs`).Scan(&status, &msg); err != nil ||
		status != "failed" || !strings.Contains(msg, "no rows") {
		t.Fatalf("run: %q %q %v", status, msg, err)
	}
}

func TestEmptyPriceResponseFailsRunAndKeepsProducts(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha"), item("1002", "Beta")}
	// no prices at all: the API answers 200 with an empty prices array

	_, err := e.run()
	if err == nil || !strings.Contains(err.Error(), "no entries") {
		t.Fatalf("err = %v, want a no-entries error", err)
	}
	if e.fake.priceCalls != 1 {
		t.Fatalf("price calls = %d, want 1 (sweep stopped)", e.fake.priceCalls)
	}
	if e.count("products") != 2 || e.count("prices") != 0 {
		t.Fatalf("rows: products=%d prices=%d", e.count("products"), e.count("prices"))
	}
	var status, msg string
	if err := e.pool.QueryRow(context.Background(), `SELECT status, coalesce(error, '') FROM collection_runs`).Scan(&status, &msg); err != nil ||
		status != "failed" || !strings.Contains(msg, "no entries") {
		t.Fatalf("run: %q %q %v", status, msg, err)
	}
}

func TestPartialPriceResponseIsNotFatal(t *testing.T) {
	e := newEnv(t)
	e.fake.items = []map[string]any{item("1001", "Alpha"), item("1002", "Beta")}
	e.fake.prices["1001"] = regular("12.5") // 1002 does not come back

	if c := e.mustRun(); c.PricesSeen != 1 || e.count("prices") != 1 {
		t.Fatalf("counts = %+v prices=%d", c, e.count("prices"))
	}
}
