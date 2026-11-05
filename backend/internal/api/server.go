// Package api is the read-only JSON API over the catalog view, plus the image proxy.
// Money is always integer sen. Clients never talk to Nintendo; only the proxy does.
package api

import (
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/db"
)

type Server struct {
	q   *db.Queries
	img *ImageProxy
	log *slog.Logger
}

// New builds the router. img may be nil in tests that do not touch images.
func New(pool *pgxpool.Pool, img *ImageProxy, log *slog.Logger) http.Handler {
	s := &Server{q: db.New(pool), img: img, log: log}
	r := chi.NewRouter()
	r.Use(cors)
	r.NotFound(func(w http.ResponseWriter, r *http.Request) { writeErr(w, http.StatusNotFound, "not found") })
	r.MethodNotAllowed(func(w http.ResponseWriter, r *http.Request) {
		writeErr(w, http.StatusMethodNotAllowed, "method not allowed")
	})
	// Prices change once a day, so a CDN may serve a JSON answer for ten minutes and refresh it in the
	// background for half an hour more. Only a 200 is cached; the URL, query included, is the cache key, so a
	// Wish List request (?ids=...) is cached per list of ids and one visitor's answer is never another's.
	r.Group(func(r chi.Router) {
		r.Use(cdnCache("public, max-age=60, s-maxage=600, stale-while-revalidate=1800"))
		r.Get("/v1/games", s.games)
		r.Get("/v1/games/{nsuid}", s.game)
		r.Get("/v1/highlights", s.highlights)
		r.Get("/v1/ranking", s.ranking)
		r.Get("/v1/genres", s.genres)
	})
	r.With(cdnCache("public, max-age=30, s-maxage=60")).Get("/v1/status/prices", s.status)
	r.Get("/v1/img/{hash}", s.image) // sets its own, much longer, caching
	return r
}

// cors lets the web app talk to the API from localhost during development.
// ponytail: any localhost origin is allowed; a deployed web app needs an explicit origin list.
func cors(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if o := r.Header.Get("Origin"); o != "" {
			if u, err := url.Parse(o); err == nil && (u.Hostname() == "localhost" || u.Hostname() == "127.0.0.1") {
				w.Header().Set("Access-Control-Allow-Origin", o)
				w.Header().Set("Vary", "Origin")
				w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
				w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
			}
		}
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

// ---- JSON shapes ----

type priceJSON struct {
	Currency      string     `json:"currency"`
	RegularMinor  int64      `json:"regular_minor"`
	CurrentMinor  int64      `json:"current_minor"`
	OnSale        bool       `json:"on_sale"`
	DiscountMinor *int64     `json:"discount_minor,omitempty"`
	PercentOff    int        `json:"percent_off"`
	SavedMinor    int64      `json:"saved_minor"`
	DiscountStart *time.Time `json:"discount_start,omitempty"`
	DiscountEnd   *time.Time `json:"discount_end,omitempty"`
	CheckedAt     *time.Time `json:"checked_at,omitempty"`
}

type gameJSON struct {
	Nsuid        string     `json:"nsuid"`
	Title        string     `json:"title"`
	Publisher    string     `json:"publisher"`
	Platform     string     `json:"platform"`
	Category     string     `json:"category"`
	ReleaseDate  *string    `json:"release_date"`
	ReleaseText  string     `json:"release_text,omitempty"`
	Image        string     `json:"image,omitempty"`
	SourceStatus string     `json:"source_status"`
	SalesStatus  string     `json:"sales_status,omitempty"`
	Price        *priceJSON `json:"price"`
	Rank         *int       `json:"rank,omitempty"`
	// UK PEGI age and content descriptors from the titledb match; null when no rating was found
	Age            *int     `json:"age"`
	AgeDescriptors []string `json:"age_descriptors"`
}

type historyJSON struct {
	ObservedAt    time.Time  `json:"observed_at"`
	RegularMinor  int64      `json:"regular_minor"`
	DiscountMinor *int64     `json:"discount_minor,omitempty"`
	DiscountStart *time.Time `json:"discount_start,omitempty"`
	DiscountEnd   *time.Time `json:"discount_end,omitempty"`
	PriceMinor    int64      `json:"price_minor"`
}

type lowestJSON struct {
	PriceMinor int64     `json:"price_minor"`
	Since      time.Time `json:"since"`
	IsSale     bool      `json:"is_sale"`
}

type detailJSON struct {
	gameJSON
	Screenshots     []string      `json:"screenshots"`
	Dcolors         []string      `json:"dcolors"`
	Genres          []string      `json:"genres"`
	Description     string        `json:"description"`
	Tagline         string        `json:"tagline,omitempty"`
	Players         string        `json:"players,omitempty"`
	History         []historyJSON `json:"history"`
	FirstObservedAt *time.Time    `json:"first_observed_at"`
	Lowest          *lowestJSON   `json:"lowest"`
	Addons          []gameJSON    `json:"addons"`
}

func ts(t pgtype.Timestamptz) *time.Time {
	if !t.Valid {
		return nil
	}
	u := t.Time.UTC()
	return &u
}

func i64(v pgtype.Int8) *int64 {
	if !v.Valid {
		return nil
	}
	return &v.Int64
}

func toGame(c db.Catalog) gameJSON {
	g := gameJSON{
		Nsuid: c.Nsuid, Title: c.Title, Publisher: c.Publisher, Platform: c.Platform, Category: c.Category,
		Image: c.Image, SourceStatus: c.SourceStatus, SalesStatus: c.SalesStatus.String,
	}
	if c.Age.Valid {
		a := int(c.Age.Int32)
		g.Age = &a
		g.AgeDescriptors = append([]string{}, c.AgeDescriptors...)
	}
	if c.ReleaseDate.Valid {
		d := c.ReleaseDate.Time.Format(time.DateOnly)
		g.ReleaseDate = &d
	} else {
		g.ReleaseText = c.Sdate
	}
	if c.RegularMinor.Valid {
		p := &priceJSON{
			Currency: c.Currency.String, RegularMinor: c.RegularMinor.Int64, CurrentMinor: c.PriceMinor.Int64,
			OnSale: c.OnSale, PercentOff: int(c.PercentOff), SavedMinor: c.SavedMinor, CheckedAt: ts(c.CheckedAt),
		}
		if c.OnSale {
			p.DiscountMinor = i64(c.DiscountMinor)
			p.DiscountStart = ts(c.DiscountStart)
			p.DiscountEnd = ts(c.DiscountEnd)
		}
		g.Price = p
	}
	return g
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

// writeErr never lets an error be cached: a CDN keeps 404s by default, and a 429 or 503 must be retried.
func writeErr(w http.ResponseWriter, status int, msg string) {
	w.Header().Set("Cache-Control", "no-store")
	writeJSON(w, status, map[string]string{"error": msg})
}

// cdnCache sets cacheControl on a 200 answer and no-store on anything else.
func cdnCache(cacheControl string) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			next.ServeHTTP(&cacheWriter{ResponseWriter: w, ok: cacheControl}, r)
		})
	}
}

type cacheWriter struct {
	http.ResponseWriter
	ok          string
	wroteHeader bool
}

func (c *cacheWriter) WriteHeader(status int) {
	if !c.wroteHeader {
		c.wroteHeader = true
		if status == http.StatusOK {
			c.Header().Set("Cache-Control", c.ok)
		} else {
			c.Header().Set("Cache-Control", "no-store")
		}
	}
	c.ResponseWriter.WriteHeader(status)
}

func (c *cacheWriter) Write(b []byte) (int, error) {
	if !c.wroteHeader {
		c.WriteHeader(http.StatusOK)
	}
	return c.ResponseWriter.Write(b)
}

func (s *Server) fail(w http.ResponseWriter, what string, err error) {
	s.log.Error(what, "err", err)
	writeErr(w, http.StatusInternalServerError, "could not "+what)
}

// ---- list ----

var (
	validTypes     = map[string]bool{"game": true, "bundle": true, "addon": true}
	validPlatforms = map[string]bool{"switch2": true, "switch": true}
	validSorts     = map[string]bool{"savings": true, "discount": true, "price": true, "newest": true, "soonest": true, "ending": true, "title": true}
)

func splitList(s string) []string {
	var out []string
	for _, p := range strings.Split(s, ",") {
		if p = strings.TrimSpace(p); p != "" {
			out = append(out, p)
		}
	}
	return out
}

func checkAll(list []string, ok map[string]bool) (string, bool) {
	for _, v := range list {
		if !ok[v] {
			return v, false
		}
	}
	return "", true
}

// likePattern turns user text into a contains-pattern, escaping LIKE wildcards.
func likePattern(q string) string {
	r := strings.NewReplacer(`\`, `\\`, `%`, `\%`, `_`, `\_`)
	return "%" + r.Replace(q) + "%"
}

func intParam(w http.ResponseWriter, v url.Values, name string, def, lo, hi int) (int, bool) {
	raw := v.Get(name)
	if raw == "" {
		return def, true
	}
	n, err := strconv.Atoi(raw)
	if err != nil || n < lo || n > hi {
		writeErr(w, http.StatusBadRequest, name+" must be a whole number from "+strconv.Itoa(lo)+" to "+strconv.Itoa(hi))
		return 0, false
	}
	return n, true
}

func (s *Server) games(w http.ResponseWriter, r *http.Request) {
	v := r.URL.Query()
	p := db.ListGamesParams{Sort: v.Get("sort")}

	ids := splitList(v.Get("ids"))
	if len(ids) > 200 {
		writeErr(w, http.StatusBadRequest, "ids takes at most 200 values")
		return
	}
	if len(ids) > 0 {
		p.Ids = ids
	}
	types := splitList(v.Get("type"))
	if bad, ok := checkAll(types, validTypes); !ok {
		writeErr(w, http.StatusBadRequest, "type must be game, bundle or addon, not "+bad)
		return
	}
	switch {
	case len(types) > 0:
		p.Types = types
	case len(ids) > 0: // a wish list can hold bundles and add-ons
		p.Types = []string{"game", "bundle", "addon"}
	default:
		p.Types = []string{"game"}
	}
	if pl := splitList(v.Get("platform")); len(pl) > 0 {
		if bad, ok := checkAll(pl, validPlatforms); !ok {
			writeErr(w, http.StatusBadRequest, "platform must be switch2 or switch, not "+bad)
			return
		}
		p.Platforms = pl
	}
	if g := splitList(v.Get("genre")); len(g) > 0 {
		p.Genres = g
	}
	if raw := splitList(v.Get("age")); len(raw) > 0 {
		for _, a := range raw {
			n, err := strconv.Atoi(a)
			if err != nil || n < 0 || n > 21 {
				writeErr(w, http.StatusBadRequest, "age must be whole PEGI ages such as 3,7,12,16,18")
				return
			}
			p.Ages = append(p.Ages, int32(n))
		}
	}
	q := strings.TrimSpace(v.Get("q"))
	if q != "" {
		p.Q = pgtype.Text{String: likePattern(q), Valid: true}
	}
	p.OnSale = v.Get("sale") == "1"
	if raw := v.Get("max_price"); raw != "" {
		n, err := strconv.ParseInt(raw, 10, 64)
		if err != nil || n < 0 {
			writeErr(w, http.StatusBadRequest, "max_price must be a whole number of sen")
			return
		}
		p.MaxPrice = pgtype.Int8{Int64: n, Valid: true}
	}
	switch rel := v.Get("release"); rel {
	case "":
	case "recent", "upcoming":
		p.Release = pgtype.Text{String: rel, Valid: true}
	default:
		writeErr(w, http.StatusBadRequest, "release must be recent or upcoming")
		return
	}
	if p.Sort == "" {
		p.Sort = "savings"
		if p.Release.String == "upcoming" {
			p.Sort = "soonest"
		}
	}
	if !validSorts[p.Sort] {
		writeErr(w, http.StatusBadRequest, "unknown sort "+p.Sort)
		return
	}
	p.IncludeFlagged = q != "" || len(ids) > 0 || v.Get("all") == "1"

	page, ok := intParam(w, v, "page", 1, 1, 100000)
	if !ok {
		return
	}
	limit, ok := intParam(w, v, "limit", 24, 1, 100)
	if !ok {
		return
	}
	p.Lim, p.Off = int32(limit), int32((page-1)*limit)

	rows, err := s.q.ListGames(r.Context(), p)
	if err != nil {
		s.fail(w, "list games", err)
		return
	}
	items := make([]gameJSON, len(rows))
	var total int64
	for i, row := range rows {
		items[i] = toGame(row.Catalog)
		total = row.Total
	}
	if len(rows) == 0 && page > 1 { // total is only known from a row; ask again for page 1's count
		p.Lim, p.Off = 1, 0
		if first, err := s.q.ListGames(r.Context(), p); err == nil && len(first) > 0 {
			total = first[0].Total
		}
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items, "total": total, "page": page, "limit": limit})
}

// ---- detail ----

func (s *Server) game(w http.ResponseWriter, r *http.Request) {
	nsuid := chi.URLParam(r, "nsuid")
	c, err := s.q.GetGame(r.Context(), nsuid)
	if errors.Is(err, pgx.ErrNoRows) {
		writeErr(w, http.StatusNotFound, "no such game")
		return
	}
	if err != nil {
		s.fail(w, "load game", err)
		return
	}
	hist, err := s.q.ListPriceHistory(r.Context(), nsuid)
	if err != nil {
		s.fail(w, "load price history", err)
		return
	}
	d := detailJSON{
		gameJSON: toGame(c), Screenshots: c.Screenshots, Dcolors: c.Dcolors, Genres: c.Genres,
		Description: excerpt(c.Description), Tagline: c.Tagline, Players: c.Players,
		History: make([]historyJSON, 0, len(hist)), Addons: []gameJSON{},
	}
	for _, h := range hist {
		cur := h.RegularMinor
		if h.DiscountMinor.Valid {
			cur = h.DiscountMinor.Int64
		}
		at := h.ObservedAt.Time.UTC()
		d.History = append(d.History, historyJSON{
			ObservedAt: at, RegularMinor: h.RegularMinor, DiscountMinor: i64(h.DiscountMinor),
			DiscountStart: ts(h.DiscountStart), DiscountEnd: ts(h.DiscountEnd), PriceMinor: cur,
		})
		if d.FirstObservedAt == nil {
			d.FirstObservedAt = &at
		}
		// the earliest observation of the lowest price wins, so "since" stays put
		if d.Lowest == nil || cur < d.Lowest.PriceMinor {
			d.Lowest = &lowestJSON{PriceMinor: cur, Since: at, IsSale: h.DiscountMinor.Valid}
		}
	}
	if len(c.Addons) > 0 {
		rows, err := s.q.ListGames(r.Context(), db.ListGamesParams{
			Types: []string{"game", "bundle", "addon"}, Ids: c.Addons, IncludeFlagged: true, Sort: "title", Lim: 60,
		})
		if err != nil {
			s.fail(w, "load add-ons", err)
			return
		}
		for _, row := range rows {
			d.Addons = append(d.Addons, toGame(row.Catalog))
		}
	}
	writeJSON(w, http.StatusOK, d)
}

// ---- highlights, ranking, genres, status ----

func games(cs []db.Catalog) []gameJSON {
	out := make([]gameJSON, len(cs))
	for i, c := range cs {
		out[i] = toGame(c)
	}
	return out
}

func (s *Server) highlights(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	// Switch 2 leads the shelf; the full cross-platform list is /v1/ranking without a platform
	top, err := s.q.TopSavings(ctx, db.TopSavingsParams{Platform: pgtype.Text{String: "switch2", Valid: true}, Lim: 10})
	if err != nil {
		s.fail(w, "load top savings", err)
		return
	}
	ending, err := s.q.EndingSoon(ctx, 10)
	if err != nil {
		s.fail(w, "load ending soon", err)
		return
	}
	newSales, err := s.q.NewSales(ctx, 10)
	if err != nil {
		s.fail(w, "load new sales", err)
		return
	}
	recent, err := s.q.RecentReleases(ctx, 10)
	if err != nil {
		s.fail(w, "load recent releases", err)
		return
	}
	var a, b, c, d []db.Catalog
	for _, x := range top {
		a = append(a, x.Catalog)
	}
	for _, x := range ending {
		b = append(b, x.Catalog)
	}
	for _, x := range newSales {
		c = append(c, x.Catalog)
	}
	for _, x := range recent {
		d = append(d, x.Catalog)
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"top_savings": games(a), "ending_soon": games(b), "new_sales": games(c), "recent": games(d),
	})
}

func (s *Server) ranking(w http.ResponseWriter, r *http.Request) {
	p := db.TopSavingsParams{Lim: 50}
	if pl := r.URL.Query().Get("platform"); pl != "" {
		if !validPlatforms[pl] {
			writeErr(w, http.StatusBadRequest, "platform must be switch2 or switch")
			return
		}
		p.Platform = pgtype.Text{String: pl, Valid: true}
	}
	rows, err := s.q.TopSavings(r.Context(), p)
	if err != nil {
		s.fail(w, "load ranking", err)
		return
	}
	items := make([]gameJSON, len(rows))
	for i, row := range rows {
		items[i] = toGame(row.Catalog)
		rank := i + 1
		items[i].Rank = &rank
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items, "total": len(items)})
}

func (s *Server) genres(w http.ResponseWriter, r *http.Request) {
	rows, err := s.q.ListGenres(r.Context())
	if err != nil {
		s.fail(w, "load genres", err)
		return
	}
	type g struct {
		Name  string `json:"name"`
		Count int64  `json:"count"`
		Cover string `json:"cover,omitempty"`
	}
	out := make([]g, len(rows))
	for i, row := range rows {
		out[i] = g{row.Name, row.Count, row.Cover}
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": out})
}

func (s *Server) status(w http.ResponseWriter, r *http.Request) {
	st, err := s.q.StatusPrices(r.Context())
	if err != nil {
		s.fail(w, "load status", err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"last_run_at": ts(st.LastRunAt), "product_count": st.ProductCount, "history_since": ts(st.HistorySince),
	})
}

func (s *Server) image(w http.ResponseWriter, r *http.Request) {
	if s.img == nil {
		writeErr(w, http.StatusNotFound, "images are not enabled")
		return
	}
	s.img.ServeHTTP(w, r)
}

// excerpt keeps the first paragraph of a publisher's description, cut to about 280 characters at a
// sentence end (or a word, with an ellipsis), so the API quotes the store text instead of republishing it.
func excerpt(s string) string {
	s = strings.TrimSpace(s)
	if i := strings.Index(s, "\n"); i >= 0 {
		s = strings.TrimSpace(s[:i])
	}
	const limit = 280
	r := []rune(s)
	if len(r) <= limit {
		return s
	}
	cut := string(r[:limit])
	end := -1
	for _, p := range []string{". ", "! ", "? "} {
		end = max(end, strings.LastIndex(cut, p))
	}
	if end > len(cut)/3 {
		return cut[:end+1]
	}
	if i := strings.LastIndex(cut, " "); i > 0 {
		return cut[:i] + "…"
	}
	return cut + "…"
}
