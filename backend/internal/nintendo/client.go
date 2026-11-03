// Package nintendo reads the Malaysian eShop catalogue and prices. It is used by choice,
// at a low rate, and never works around a block: 401/403/other 4xx stop everything.
package nintendo

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/rand/v2"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

const (
	DefaultSearchURL = "https://search.nintendo.jp/nintendo_soft_my/search.json"
	DefaultPriceURL  = "https://api.ec.nintendo.com/v1/price"
	DefaultUserAgent = "RinggitRadar/0.2 (public Malaysian game price tracker)"

	PageSize   = 400 // effective maximum the catalogue serves
	PriceBatch = 50  // ids per price request
	maxAttempt = 3
	maxBody    = 64 << 20
)

// Client talks to the two Nintendo endpoints. Tests point SearchURL and PriceURL at httptest.
// ponytail: requests are paced by a plain timestamp, so a Client is for one goroutine only.
type Client struct {
	SearchURL string
	PriceURL  string
	HTTP      *http.Client
	UserAgent string
	Interval  time.Duration // minimum gap between requests; tests set 0
	Backoff   time.Duration // first retry delay, doubled each attempt, plus jitter

	last time.Time
}

// New returns a Client with the real endpoints and a 1 second gap between requests.
func New(userAgent string) *Client {
	return &Client{
		SearchURL: DefaultSearchURL,
		PriceURL:  DefaultPriceURL,
		HTTP:      &http.Client{Timeout: 30 * time.Second},
		UserAgent: userAgent,
		Interval:  time.Second,
		Backoff:   time.Second,
	}
}

// Item is one catalogue row. Raw is the whole source object, kept so later fields need no recollection.
// NSUID is nil for rows without one. Price fields in search results are deliberately not read.
type Item struct {
	NSUID *string         `json:"nsuid"`
	Title string          `json:"title"`
	Maker string          `json:"maker"`
	Hard  string          `json:"hard"`
	Sform string          `json:"sform"`
	Ssitu string          `json:"ssitu"`
	Raw   json.RawMessage `json:"-"`
}

// Amount is a price as the API reports it. Start and End are only set on discounts.
type Amount struct {
	Currency string `json:"currency"`
	RawValue string `json:"raw_value"`
	Start    string `json:"start_datetime"`
	End      string `json:"end_datetime"`
}

// Price is one entry of the price API, with title_id mapped back to the nsuid string.
type Price struct {
	NSUID       string
	SalesStatus string
	Regular     *Amount
	Discount    *Amount
}

// Catalogue pages through the whole catalogue, calling each with every page of rows. It returns
// the total the source claims and how many rows it actually delivered; the caller compares them.
func (c *Client) Catalogue(ctx context.Context, each func([]Item) error) (total, collected int, err error) {
	for page := 1; ; page++ {
		body, err := c.get(ctx, fmt.Sprintf("%s?limit=%d&page=%d&q=", c.SearchURL, PageSize, page))
		if err != nil {
			return total, collected, err
		}
		var resp struct {
			Result struct {
				Total int               `json:"total"`
				Items []json.RawMessage `json:"items"`
			} `json:"result"`
		}
		if err := json.Unmarshal(body, &resp); err != nil {
			return total, collected, fmt.Errorf("nintendo: decode search page %d: %w", page, err)
		}
		total = resp.Result.Total
		if len(resp.Result.Items) == 0 {
			return total, collected, nil
		}
		items := make([]Item, len(resp.Result.Items))
		for i, raw := range resp.Result.Items {
			if err := json.Unmarshal(raw, &items[i]); err != nil {
				return total, collected, fmt.Errorf("nintendo: decode search page %d item %d: %w", page, i, err)
			}
			items[i].Raw = raw
		}
		collected += len(items)
		if err := each(items); err != nil {
			return total, collected, err
		}
		if collected >= total {
			return total, collected, nil
		}
	}
}

// Prices fetches MYR prices for up to PriceBatch nsuids. Order of the result is not guaranteed.
// ponytail: country and language are fixed to MY/en; a second region means a new parameter here.
func (c *Client) Prices(ctx context.Context, ids []string) ([]Price, error) {
	if len(ids) > PriceBatch {
		return nil, fmt.Errorf("nintendo: %d ids in one price request, max %d", len(ids), PriceBatch)
	}
	esc := make([]string, len(ids))
	for i, id := range ids {
		esc[i] = url.QueryEscape(id)
	}
	body, err := c.get(ctx, fmt.Sprintf("%s?country=MY&lang=en&ids=%s", c.PriceURL, strings.Join(esc, ",")))
	if err != nil {
		return nil, err
	}
	var resp struct {
		Prices []struct {
			TitleID     json.Number `json:"title_id"`
			SalesStatus string      `json:"sales_status"`
			Regular     *Amount     `json:"regular_price"`
			Discount    *Amount     `json:"discount_price"`
		} `json:"prices"`
	}
	if err := json.Unmarshal(body, &resp); err != nil {
		return nil, fmt.Errorf("nintendo: decode prices: %w", err)
	}
	out := make([]Price, len(resp.Prices))
	for i, p := range resp.Prices {
		out[i] = Price{NSUID: p.TitleID.String(), SalesStatus: p.SalesStatus, Regular: p.Regular, Discount: p.Discount}
	}
	return out, nil
}

// get does one paced GET, retrying only network errors, 429 and 5xx (3 attempts in total).
func (c *Client) get(ctx context.Context, u string) ([]byte, error) {
	var lastErr error
	for attempt := 1; attempt <= maxAttempt; attempt++ {
		if err := c.pace(ctx); err != nil {
			return nil, err
		}
		body, retryAfter, err := c.once(ctx, u)
		if err == nil {
			return body, nil
		}
		if ctx.Err() != nil {
			return nil, ctx.Err()
		}
		var fatal *fatalError
		if errors.As(err, &fatal) {
			return nil, err
		}
		lastErr = err
		if attempt == maxAttempt {
			break
		}
		wait := c.Backoff << (attempt - 1)
		wait += rand.N(wait/2 + 1)
		if retryAfter >= 0 {
			wait = retryAfter
		}
		if err := sleep(ctx, wait); err != nil {
			return nil, err
		}
	}
	return nil, fmt.Errorf("nintendo: giving up after %d attempts: %w", maxAttempt, lastErr)
}

// fatalError marks a response we must not retry or work around.
type fatalError struct{ error }

// once makes a single request. retryAfter is -1 unless the server sent a Retry-After in seconds.
// ponytail: only the delta-seconds form of Retry-After is read, not the HTTP-date form.
func (c *Client) once(ctx context.Context, u string) (body []byte, retryAfter time.Duration, err error) {
	retryAfter = -1
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return nil, retryAfter, &fatalError{err}
	}
	req.Header.Set("User-Agent", c.UserAgent)
	resp, err := c.HTTP.Do(req)
	if err != nil {
		return nil, retryAfter, err
	}
	defer resp.Body.Close()

	switch {
	case resp.StatusCode == http.StatusOK:
		body, err = io.ReadAll(io.LimitReader(resp.Body, maxBody))
		return body, retryAfter, err
	case resp.StatusCode == http.StatusTooManyRequests || resp.StatusCode >= 500:
		if s, perr := strconv.Atoi(resp.Header.Get("Retry-After")); perr == nil && s >= 0 {
			retryAfter = time.Duration(s) * time.Second
		}
		return nil, retryAfter, fmt.Errorf("status %d", resp.StatusCode)
	default:
		return nil, retryAfter, &fatalError{fmt.Errorf("nintendo: %s answered %d, not retrying and not working around it", resp.Request.URL.Host, resp.StatusCode)}
	}
}

// pace waits until at least Interval has passed since the previous request.
func (c *Client) pace(ctx context.Context) error {
	if d := c.Interval - time.Since(c.last); d > 0 {
		if err := sleep(ctx, d); err != nil {
			return err
		}
	}
	c.last = time.Now()
	return nil
}

func sleep(ctx context.Context, d time.Duration) error {
	if d <= 0 {
		return ctx.Err()
	}
	t := time.NewTimer(d)
	defer t.Stop()
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-t.C:
		return nil
	}
}
