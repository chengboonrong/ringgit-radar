// Command importratings loads age ratings from the public titledb dataset (github.com/blawar/titledb,
// MIT, metadata only) and matches them to our games by title. One shot, not scheduled. The only host
// it contacts is GitHub; set TITLEDB_PATH to read a local copy instead.
package main

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/nintendo"
	"eshop-radar/backend/internal/ratings"
)

const (
	titledbURL = "https://raw.githubusercontent.com/blawar/titledb/master/GB.en.json"
	source     = "titledb GB.en (PEGI)"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "importratings:", err)
		os.Exit(1)
	}
}

func run() error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	var src io.ReadCloser
	if path := os.Getenv("TITLEDB_PATH"); path != "" {
		f, err := os.Open(path)
		if err != nil {
			return err
		}
		src = f
	} else {
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, titledbURL, nil)
		if err != nil {
			return err
		}
		req.Header.Set("User-Agent", getenv("USER_AGENT", nintendo.DefaultUserAgent))
		resp, err := (&http.Client{Timeout: 10 * time.Minute}).Do(req)
		if err != nil {
			return fmt.Errorf("download titledb: %w", err)
		}
		if resp.StatusCode != http.StatusOK {
			resp.Body.Close()
			return fmt.Errorf("download titledb: GitHub answered %d", resp.StatusCode)
		}
		src = resp.Body
	}
	defer src.Close()

	var ix ratings.Index
	n := 0
	if err := ratings.ReadTitleDB(src, func(e ratings.Entry) { ix.Add(e); n++ }); err != nil {
		return err
	}

	pool, err := pgxpool.New(ctx, getenv("DATABASE_URL", "postgres:///eshop_radar"))
	if err != nil {
		return fmt.Errorf("connect: %w", err)
	}
	defer pool.Close()
	res, err := ratings.Import(ctx, pool, &ix, source)
	if err != nil {
		return err
	}
	fmt.Printf("titledb entries=%d games=%d matched=%d unmatched=%d conflicts=%d (conflicting names=%d)\n",
		n, res.Games, res.Matched, res.Unmatched, res.Conflicts, res.ConflictNames)
	return nil
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
