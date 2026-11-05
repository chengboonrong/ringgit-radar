// Package serverless is the code behind the Vercel function for /v1/* and /healthz. It wraps the same router as cmd/api.
// The web app itself is static files in public/, served by Vercel's CDN; see vercel.json and the README.
package serverless

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"sync"

	"eshop-radar/backend/internal/api"
)

var (
	once    sync.Once
	handler http.Handler
	initErr error
)

// Handler builds the router on the first request of an instance and keeps it for the instance's life.
func Handler(w http.ResponseWriter, r *http.Request) {
	once.Do(func() { handler, initErr = build(r.Context()) })
	if initErr != nil {
		slog.Error("startup", "err", initErr)
		w.Header().Set("Cache-Control", "no-store")
		http.Error(w, "service unavailable", http.StatusServiceUnavailable)
		return
	}
	api.RestorePath(r)
	handler.ServeHTTP(w, r)
}

func build(ctx context.Context) (http.Handler, error) {
	log := slog.Default()
	// context.WithoutCancel: the pool outlives the request that happened to start it
	pool, err := api.NewServerlessPool(context.WithoutCancel(ctx), os.Getenv("DATABASE_URL"))
	if err != nil {
		return nil, err
	}
	rate, err := api.EnvInt("RATE_LIMIT_PER_MIN", 600)
	if err != nil {
		return nil, err
	}
	trust := os.Getenv("TRUST_PROXY")
	if trust == "" {
		trust = "true" // behind Vercel, whose X-Forwarded-For is the visitor's address
	}
	mode, err := api.ParseTrust(trust)
	if err != nil {
		return nil, err
	}
	return api.NewHandler(api.Config{Pool: pool, Log: log, RatePerMin: rate, TrustProxy: mode})
}
