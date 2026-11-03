package api

import (
	"context"
	"os"
	"strings"
	"sync"
	"testing"

	"github.com/jackc/pgx/v5"
)

func TestServerlessPoolDefaultsAndOverrides(t *testing.T) {
	ctx := context.Background()
	// nothing is connected to: the pool is built lazily
	p, err := NewServerlessPool(ctx, "postgres://u:p@127.0.0.1:1/db")
	if err != nil {
		t.Fatal(err)
	}
	defer p.Close()
	c := p.Config()
	if c.MaxConns != 2 || c.MinConns != 0 || c.ConnConfig.DefaultQueryExecMode != pgx.QueryExecModeSimpleProtocol {
		t.Errorf("defaults: max=%d min=%d mode=%v", c.MaxConns, c.MinConns, c.ConnConfig.DefaultQueryExecMode)
	}
	p2, err := NewServerlessPool(ctx, "postgres://u:p@127.0.0.1:1/db?pool_max_conns=5&default_query_exec_mode=cache_describe")
	if err != nil {
		t.Fatal(err)
	}
	defer p2.Close()
	if c := p2.Config(); c.MaxConns != 5 || c.ConnConfig.DefaultQueryExecMode != pgx.QueryExecModeCacheDescribe {
		t.Errorf("the URL must win: max=%d mode=%v", c.MaxConns, c.ConnConfig.DefaultQueryExecMode)
	}
	if _, err := NewServerlessPool(ctx, "not a url"); err == nil {
		t.Error("a bad URL must be an error")
	}
}

func TestColdStartBurstNeverOpensMoreThanTwoConnections(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Fatal("TEST_DATABASE_URL is not set")
	}
	ctx := context.Background()
	p, err := NewServerlessPool(ctx, url)
	if err != nil {
		t.Fatal(err)
	}
	defer p.Close()
	var wg sync.WaitGroup
	for i := 0; i < 30; i++ { // thirty requests land on a cold instance at once
		wg.Add(1)
		go func() {
			defer wg.Done()
			var n int
			if err := p.QueryRow(ctx, `SELECT 1`).Scan(&n); err != nil {
				t.Error(err)
			}
		}()
	}
	wg.Wait()
	// two unless the URL asks for another number (the whole suite also runs with pool_max_conns=3)
	want := int32(2)
	if strings.Contains(url, "pool_max_conns") {
		want = p.Config().MaxConns
	}
	if total := p.Stat().TotalConns(); total > want || p.Config().MaxConns != want {
		t.Errorf("the pool holds %d connections (max %d), want at most %d", total, p.Config().MaxConns, want)
	}
	var live int
	if err := p.QueryRow(ctx, `SELECT count(*) FROM pg_stat_activity WHERE pid = pg_backend_pid()`).Scan(&live); err != nil || live != 1 {
		t.Fatalf("sanity: %d, %v", live, err)
	}
}
