// Command collector runs one price sweep of the Malaysian Nintendo eShop and exits.
package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"

	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/collector"
	"eshop-radar/backend/internal/nintendo"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "collector:", err)
		os.Exit(1)
	}
}

func run() error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	dsn := getenv("DATABASE_URL", "postgres:///eshop_radar")
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return fmt.Errorf("connect: %w", err)
	}
	defer pool.Close()

	sw := &collector.Sweep{
		Pool:   pool,
		Client: nintendo.New(getenv("USER_AGENT", nintendo.DefaultUserAgent)),
		Log:    slog.Default(),
	}
	id, c, err := sw.Run(ctx)
	status := "succeeded"
	if err != nil {
		status = "failed"
	}
	fmt.Printf("run %d %s: products=%d skipped=%d prices=%d unpriced=%d invalid=%d changes=%d\n",
		id, status, c.ProductsSeen, c.ProductsSkipped, c.PricesSeen, c.Unpriced, c.InvalidPrices, c.PriceChanges)
	return err
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
