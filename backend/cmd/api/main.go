// Command api serves the read-only Ringgit Radar API, and the web app when WEB_DIR is set.
// HOST (default 127.0.0.1) and PORT choose the address; a HOST other than loopback needs SITE_PASSWORD or
// PUBLIC=true. TRUST_PROXY=true believes X-Forwarded-For (Vercel); TRUST_PROXY=cloudflare also Cf-Connecting-Ip. RATE_LIMIT_PER_MIN
// tunes the rate limit (0 turns it off).
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/api"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "api:", err)
		os.Exit(1)
	}
}

func run() error {
	host := getenv("HOST", "127.0.0.1")
	password := os.Getenv("SITE_PASSWORD")
	public := os.Getenv("PUBLIC") == "true"
	// fail closed before anything else happens: beyond this machine needs a password or PUBLIC=true
	if err := api.CheckExposure(host, password, public); err != nil {
		return err
	}
	ratePerMin, err := api.EnvInt("RATE_LIMIT_PER_MIN", 600)
	if err != nil {
		return err
	}
	trust, err := api.ParseTrust(os.Getenv("TRUST_PROXY"))
	if err != nil {
		return err
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	log := slog.Default()

	pool, err := pgxpool.New(ctx, getenv("DATABASE_URL", "postgres:///eshop_radar"))
	if err != nil {
		return fmt.Errorf("connect: %w", err)
	}
	defer pool.Close()

	handler, err := api.NewHandler(api.Config{
		Pool: pool, Log: log, WebDir: os.Getenv("WEB_DIR"), Password: password,
		RatePerMin: ratePerMin, TrustProxy: trust,
	})
	if err != nil {
		return err
	}
	srv := &http.Server{Handler: handler, ReadHeaderTimeout: 10 * time.Second}

	ln, err := net.Listen("tcp", net.JoinHostPort(host, getenv("PORT", "8088")))
	if err != nil {
		return err
	}
	log.Info("listening", "addr", ln.Addr().String(), "web_dir", os.Getenv("WEB_DIR"), "password", password != "", "public", public, "rate_per_min", ratePerMin, "pid", os.Getpid())

	errc := make(chan error, 1)
	go func() { errc <- srv.Serve(ln) }()
	select {
	case err := <-errc:
		return err
	case <-ctx.Done():
	}
	shutdown, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdown); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
