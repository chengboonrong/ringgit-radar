package nintendo

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"slices"
	"strconv"
	"strings"
	"sync/atomic"
	"testing"
	"time"
)

func newClient(srv *httptest.Server) *Client {
	return &Client{
		SearchURL: srv.URL + "/search",
		PriceURL:  srv.URL + "/price",
		HTTP:      srv.Client(),
		UserAgent: "test-agent/1",
		Backoff:   time.Millisecond,
	}
}

// catalogueServer serves n items (nsuid = 1000+i) honouring page and limit, and
// reports total as given. It counts the requests it receives.
func catalogueServer(n, total int, requests *atomic.Int32) *httptest.Server {
	return httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		requests.Add(1)
		q := r.URL.Query()
		limit, _ := strconv.Atoi(q.Get("limit"))
		page, _ := strconv.Atoi(q.Get("page"))
		if !q.Has("q") || q.Get("q") != "" || limit != 400 || page < 1 {
			http.Error(w, "bad query "+r.URL.RawQuery, http.StatusBadRequest)
			return
		}
		var items []string
		for i := (page - 1) * limit; i < min(page*limit, n); i++ {
			items = append(items, fmt.Sprintf(`{"nsuid":"%d","title":"T%d","maker":"M","hard":"1_HAC","sform":"HAC_DL","ssitu":"onsale","extra":{"k":%d}}`, 1000+i, i, i))
		}
		fmt.Fprintf(w, `{"result":{"total":%d,"items":[%s]}}`, total, strings.Join(items, ","))
	}))
}

func TestCatalogueStopsAtTheEnd(t *testing.T) {
	var requests atomic.Int32
	srv := catalogueServer(850, 850, &requests)
	defer srv.Close()

	var pages []int
	var first Item
	total, collected, err := newClient(srv).Catalogue(context.Background(), func(items []Item) error {
		if len(pages) == 0 {
			first = items[0]
		}
		pages = append(pages, len(items))
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
	if total != 850 || collected != 850 || !slices.Equal(pages, []int{400, 400, 50}) {
		t.Fatalf("total=%d collected=%d pages=%v", total, collected, pages)
	}
	if requests.Load() != 3 {
		t.Fatalf("requests = %d, want 3 (no request past the last page)", requests.Load())
	}
	if first.NSUID == nil || *first.NSUID != "1000" || first.Title != "T0" || first.Maker != "M" ||
		first.Hard != "1_HAC" || first.Sform != "HAC_DL" || first.Ssitu != "onsale" {
		t.Fatalf("first item decoded wrong: %+v", first)
	}
	if !strings.Contains(string(first.Raw), `"extra":{"k":0}`) {
		t.Fatalf("raw not kept whole: %s", first.Raw)
	}
}

func TestCatalogueEmptyPageEndsShortOfTotal(t *testing.T) {
	var requests atomic.Int32
	srv := catalogueServer(450, 900, &requests)
	defer srv.Close()

	total, collected, err := newClient(srv).Catalogue(context.Background(), func([]Item) error { return nil })
	if err != nil {
		t.Fatal(err)
	}
	if total != 900 || collected != 450 || requests.Load() != 3 {
		t.Fatalf("total=%d collected=%d requests=%d", total, collected, requests.Load())
	}
}

func TestPricesMapsTitleIDAndBatches(t *testing.T) {
	var gotIDs string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		q := r.URL.Query()
		if q.Get("country") != "MY" || q.Get("lang") != "en" {
			http.Error(w, "bad query", http.StatusBadRequest)
			return
		}
		gotIDs = q.Get("ids")
		// reversed order, title_id as a JSON number, one discounted, one unpriced
		fmt.Fprint(w, `{"prices":[
			{"title_id":70010000000003,"sales_status":"not_found"},
			{"title_id":70010000000002,"sales_status":"onsale","regular_price":{"amount":"RM72.00","currency":"MYR","raw_value":"72"},
			 "discount_price":{"amount":"RM64.80","currency":"MYR","raw_value":"64.80","start_datetime":"2026-10-28T16:00:00Z","end_datetime":"2026-12-16T15:59:59Z"}},
			{"title_id":70010000000001,"sales_status":"onsale","regular_price":{"amount":"RM12.50","currency":"MYR","raw_value":"12.5"}}]}`)
	}))
	defer srv.Close()
	c := newClient(srv)

	ids := []string{"70010000000001", "70010000000002", "70010000000003"}
	prices, err := c.Prices(context.Background(), ids)
	if err != nil {
		t.Fatal(err)
	}
	if gotIDs != strings.Join(ids, ",") {
		t.Fatalf("ids = %q", gotIDs)
	}
	byID := map[string]Price{}
	for _, p := range prices {
		byID[p.NSUID] = p
	}
	if len(byID) != 3 {
		t.Fatalf("prices = %+v", prices)
	}
	if p := byID["70010000000001"]; p.Regular == nil || p.Regular.RawValue != "12.5" || p.Discount != nil {
		t.Errorf("price 1: %+v", p)
	}
	p2 := byID["70010000000002"]
	if p2.Regular == nil || p2.Regular.RawValue != "72" || p2.Discount == nil || p2.Discount.RawValue != "64.80" ||
		p2.Discount.Currency != "MYR" || p2.Discount.Start != "2026-10-28T16:00:00Z" || p2.Discount.End != "2026-12-16T15:59:59Z" {
		t.Errorf("price 2: %+v", p2)
	}
	if p := byID["70010000000003"]; p.Regular != nil || p.SalesStatus != "not_found" {
		t.Errorf("price 3: %+v", p)
	}

	// 50 ids is the batch size; one more is the caller's bug.
	if _, err := c.Prices(context.Background(), make([]string, PriceBatch+1)); err == nil {
		t.Fatal("expected error for more than PriceBatch ids")
	}
}

func TestRetries503ThenOK(t *testing.T) {
	var n atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if n.Add(1) < 3 {
			w.WriteHeader(http.StatusServiceUnavailable)
			return
		}
		fmt.Fprint(w, `{"prices":[]}`)
	}))
	defer srv.Close()

	if _, err := newClient(srv).Prices(context.Background(), []string{"1"}); err != nil {
		t.Fatal(err)
	}
	if n.Load() != 3 {
		t.Fatalf("requests = %d, want 3", n.Load())
	}
}

func TestGivesUpAfterThreeAttempts(t *testing.T) {
	var n atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		n.Add(1)
		w.WriteHeader(http.StatusServiceUnavailable)
	}))
	defer srv.Close()

	_, err := newClient(srv).Prices(context.Background(), []string{"1"})
	if err == nil || !strings.Contains(err.Error(), "503") {
		t.Fatalf("err = %v", err)
	}
	if n.Load() != 3 {
		t.Fatalf("requests = %d, want 3", n.Load())
	}
}

func TestRetriesNetworkError(t *testing.T) {
	var n atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if n.Add(1) == 1 {
			panic(http.ErrAbortHandler) // drops the connection mid-request
		}
		fmt.Fprint(w, `{"prices":[]}`)
	}))
	defer srv.Close()

	if _, err := newClient(srv).Prices(context.Background(), []string{"1"}); err != nil {
		t.Fatal(err)
	}
	if n.Load() != 2 {
		t.Fatalf("requests = %d, want 2", n.Load())
	}
}

func TestHonoursRetryAfter(t *testing.T) {
	var n atomic.Int32
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if n.Add(1) == 1 {
			w.Header().Set("Retry-After", "1")
			w.WriteHeader(http.StatusTooManyRequests)
			return
		}
		fmt.Fprint(w, `{"prices":[]}`)
	}))
	defer srv.Close()

	start := time.Now()
	if _, err := newClient(srv).Prices(context.Background(), []string{"1"}); err != nil {
		t.Fatal(err)
	}
	if n.Load() != 2 || time.Since(start) < time.Second {
		t.Fatalf("requests=%d elapsed=%v, want a 1s wait before the retry", n.Load(), time.Since(start))
	}
}

func TestClientErrorsAreNotRetried(t *testing.T) {
	for _, code := range []int{http.StatusUnauthorized, http.StatusForbidden, http.StatusNotFound} {
		var n atomic.Int32
		srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			n.Add(1)
			w.WriteHeader(code)
		}))
		_, err := newClient(srv).Prices(context.Background(), []string{"1"})
		srv.Close()
		if err == nil || !strings.Contains(err.Error(), strconv.Itoa(code)) {
			t.Errorf("%d: err = %v", code, err)
		}
		if n.Load() != 1 {
			t.Errorf("%d: requests = %d, want 1 (no retry)", code, n.Load())
		}
	}
}

func TestSendsUserAgentOnBothEndpoints(t *testing.T) {
	var agents []string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		agents = append(agents, r.Header.Get("User-Agent"))
		if strings.HasSuffix(r.URL.Path, "/search") {
			fmt.Fprint(w, `{"result":{"total":0,"items":[]}}`)
			return
		}
		fmt.Fprint(w, `{"prices":[]}`)
	}))
	defer srv.Close()
	c := newClient(srv)

	if _, _, err := c.Catalogue(context.Background(), func([]Item) error { return nil }); err != nil {
		t.Fatal(err)
	}
	if _, err := c.Prices(context.Background(), []string{"1"}); err != nil {
		t.Fatal(err)
	}
	if !slices.Equal(agents, []string{"test-agent/1", "test-agent/1"}) {
		t.Fatalf("user agents = %q", agents)
	}
}

func TestPacesRequests(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, `{"prices":[]}`)
	}))
	defer srv.Close()
	c := newClient(srv)
	c.Interval = 100 * time.Millisecond

	start := time.Now()
	for range 3 {
		if _, err := c.Prices(context.Background(), []string{"1"}); err != nil {
			t.Fatal(err)
		}
	}
	if d := time.Since(start); d < 200*time.Millisecond {
		t.Fatalf("3 requests took %v, want at least 2 intervals", d)
	}
}

func TestDefaultUserAgentSaysWhatThisIs(t *testing.T) {
	if DefaultUserAgent != "RinggitRadar/0.2 (public Malaysian game price tracker)" {
		t.Fatalf("DefaultUserAgent = %q", DefaultUserAgent)
	}
	if got := New(DefaultUserAgent).UserAgent; got != DefaultUserAgent {
		t.Fatalf("New sets %q", got)
	}
}
