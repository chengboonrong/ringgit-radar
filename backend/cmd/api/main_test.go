package main

import (
	"strings"
	"testing"
)

// The real entry point refuses to start on a public address without a password, before it touches
// the database or opens a socket.
func TestRunRefusesPublicAddressWithoutPassword(t *testing.T) {
	for _, host := range []string{"0.0.0.0", "::", "192.168.1.5", "example.com"} {
		t.Setenv("HOST", host)
		t.Setenv("SITE_PASSWORD", "")
		t.Setenv("PUBLIC", "")
		t.Setenv("DATABASE_URL", "postgres://nobody@127.0.0.1:1/none") // would fail slowly if it were reached
		t.Setenv("PORT", "0")
		err := run()
		if err == nil || !strings.Contains(err.Error(), "SITE_PASSWORD or PUBLIC=true") {
			t.Errorf("HOST=%q: run() = %v, want a refusal that names SITE_PASSWORD and PUBLIC=true", host, err)
		}
	}
}

func TestRunRefusesPasswordAndPublicTogether(t *testing.T) {
	t.Setenv("HOST", "0.0.0.0")
	t.Setenv("SITE_PASSWORD", "x")
	t.Setenv("PUBLIC", "true")
	if err := run(); err == nil || !strings.Contains(err.Error(), "both set") {
		t.Errorf("run() = %v, want a refusal for PUBLIC=true together with SITE_PASSWORD", err)
	}
}

func TestRunRejectsABadLimit(t *testing.T) {
	t.Setenv("HOST", "127.0.0.1")
	t.Setenv("RATE_LIMIT_PER_MIN", "lots")
	if err := run(); err == nil || !strings.Contains(err.Error(), "RATE_LIMIT_PER_MIN") {
		t.Errorf("run() = %v", err)
	}
}
