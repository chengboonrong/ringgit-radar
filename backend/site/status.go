package site

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"
)

// Status is the part of /v1/status/prices the pages show.
type Status struct {
	ProductCount int64     `json:"product_count"`
	HistorySince time.Time `json:"history_since"`
}

// FetchStatus reads the live numbers. Anything short of a real count and start date is an error, so a
// build never writes a made-up number.
func FetchStatus(ctx context.Context, apiBase string) (Status, error) {
	ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, apiBase+"/v1/status/prices", nil)
	if err != nil {
		return Status{}, err
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return Status{}, fmt.Errorf("read the live numbers: %w", err)
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return Status{}, fmt.Errorf("read the live numbers: %s answered %s", req.URL, res.Status)
	}
	var s struct {
		ProductCount int64      `json:"product_count"`
		HistorySince *time.Time `json:"history_since"`
	}
	if err := json.NewDecoder(res.Body).Decode(&s); err != nil {
		return Status{}, fmt.Errorf("read the live numbers: %w", err)
	}
	if s.ProductCount <= 0 || s.HistorySince == nil || s.HistorySince.IsZero() {
		return Status{}, fmt.Errorf("read the live numbers: %s gave no count or start date", req.URL)
	}
	return Status{ProductCount: s.ProductCount, HistorySince: *s.HistorySince}, nil
}

// formatCount groups thousands with commas, as Malaysian text does in all three languages.
func formatCount(n int64) string {
	s := strconv.FormatInt(n, 10)
	for i := len(s) - 3; i > 0; i -= 3 {
		s = s[:i] + "," + s[i:]
	}
	return s
}

var myt = time.FixedZone("MYT", 8*3600)

var months = map[string][]string{
	"en": {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"},
	"ms": {"Jan", "Feb", "Mac", "Apr", "Mei", "Jun", "Jul", "Ogo", "Sep", "Okt", "Nov", "Dis"},
}

// formatDate writes a day in Malaysia time: "1 Nov 2026", "1 Nov 2026" (ms names), "2026年11月1日".
func formatDate(t time.Time, lang string) string {
	t = t.In(myt)
	if lang == "zh" {
		return fmt.Sprintf("%d年%d月%d日", t.Year(), t.Month(), t.Day())
	}
	return fmt.Sprintf("%d %s %d", t.Day(), months[lang][t.Month()-1], t.Year())
}

// apkMB is the APK's size in decimal megabytes, rounded to the nearest.
func apkMB(size int64) int64 { return (size + 500_000) / 1_000_000 }
