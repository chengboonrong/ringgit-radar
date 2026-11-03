package api

import (
	"context"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// NewServerlessPool opens the database for a serverless function that talks to a transaction pooler
// (Supabase port 6543). Such a pooler has no prepared statements, so unless the URL already says how
// to run queries, the simple protocol is used, and the pool is kept to two connections because every
// cold instance opens its own. pool_max_conns and default_query_exec_mode in the URL win over these defaults.
// No connection is made until the first query.
func NewServerlessPool(ctx context.Context, url string) (*pgxpool.Pool, error) {
	cfg, err := pgxpool.ParseConfig(url)
	if err != nil {
		return nil, err
	}
	if !strings.Contains(url, "default_query_exec_mode") {
		cfg.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol
	}
	if !strings.Contains(url, "pool_max_conns") {
		cfg.MaxConns = 2
	}
	cfg.MinConns = 0
	cfg.MaxConnIdleTime = 30 * time.Second // an idle instance gives its connections back to the pooler
	return pgxpool.NewWithConfig(ctx, cfg)
}
