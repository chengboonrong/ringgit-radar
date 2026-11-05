package api

import (
	"context"
	"crypto/sha256"
	"crypto/subtle"
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"mime"
	"net"
	"net/http"
	"os"
	"path"
	"strings"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Config is everything the deployed server is made of.
type Config struct {
	Pool *pgxpool.Pool
	Log  *slog.Logger
	// WebDir, when set, is a Flutter web build served at / with a fallback to index.html.
	WebDir string
	// Password, when set, puts HTTP Basic Auth in front of everything except /healthz. With no password
	// the site is public.
	// ponytail: one shared password, any username. Per-person accounts (and the per-person wish lists
	// that need them) are the next step.
	Password string
	// RatePerMin limits each client to this many /v1 requests a minute (0 turns the limit off).
	RatePerMin int
	// TrustProxy says which proxy's forwarded-address header can be believed: TrustForwarded, TrustCloudflare or none.
	TrustProxy string
}

const maxLimiterKeys = 10000

// NewHandler is the whole site: /healthz open, then (behind the password, if one is set) the API
// under /v1 and, if WebDir is set, the web app everywhere else.
func NewHandler(c Config) (http.Handler, error) {
	apiHandler := New(c.Pool, c.Log)
	var web http.Handler
	if c.WebDir != "" {
		w, err := newWeb(c.WebDir)
		if err != nil {
			return nil, err
		}
		web = w
	}
	if c.RatePerMin > 0 {
		apiHandler = rateLimit(NewLimiter(c.RatePerMin, time.Minute, maxLimiterKeys), c.TrustProxy, apiHandler)
	}
	site := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if web != nil && r.URL.Path != "/v1" && !strings.HasPrefix(r.URL.Path, "/v1/") {
			web.ServeHTTP(w, r)
			return
		}
		apiHandler.ServeHTTP(w, r)
	})
	var gated http.Handler = site
	if c.Password != "" {
		gated = requirePassword(c.Password, site)
	}
	mux := http.NewServeMux()
	mux.Handle("GET /healthz", healthz(c.Pool))
	mux.Handle("/", gated)
	return mux, nil
}

// CheckExposure is the fail-closed rule: listening beyond loopback needs a decision, either a
// password (SITE_PASSWORD) or an explicit public site (PUBLIC=true). Both at once is a contradiction.
func CheckExposure(host, password string, public bool) error {
	if public && password != "" {
		return fmt.Errorf("PUBLIC=true and SITE_PASSWORD are both set: a site is either public or behind a password")
	}
	if password != "" || public || isLoopback(host) {
		return nil
	}
	return fmt.Errorf("refusing to listen on %q without SITE_PASSWORD or PUBLIC=true: set one, or HOST=127.0.0.1", host)
}

func isLoopback(host string) bool {
	if host == "localhost" {
		return true
	}
	ip := net.ParseIP(strings.Trim(host, "[]"))
	return ip != nil && ip.IsLoopback()
}

// requirePassword answers 401 with a Basic challenge unless the request carries the password.
// The username is ignored. Both sides are hashed first so the comparison takes the same time
// whatever the length of the guess.
func requirePassword(password string, next http.Handler) http.Handler {
	want := sha256.Sum256([]byte(password))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if _, got, ok := r.BasicAuth(); ok {
			sum := sha256.Sum256([]byte(got))
			if subtle.ConstantTimeCompare(sum[:], want[:]) == 1 {
				next.ServeHTTP(w, r)
				return
			}
		}
		w.Header().Set("WWW-Authenticate", `Basic realm="Ringgit Radar", charset="UTF-8"`)
		w.Header().Set("Cache-Control", "no-store")
		http.Error(w, "password required", http.StatusUnauthorized)
	})
}

// healthz is Railway's health check: 200 only if the database answers.
func healthz(pool *pgxpool.Pool) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), 3*time.Second)
		defer cancel()
		w.Header().Set("Cache-Control", "no-store")
		if err := pool.Ping(ctx); err != nil {
			http.Error(w, "database unavailable", http.StatusServiceUnavailable)
			return
		}
		w.Write([]byte("ok\n"))
	})
}

// web serves a Flutter web build from a directory.
type web struct{ files fs.FS }

func newWeb(dir string) (*web, error) {
	// os.Root keeps every lookup inside dir: ".." and symlinks that leave it fail instead of resolving
	root, err := os.OpenRoot(dir)
	if err != nil {
		return nil, fmt.Errorf("WEB_DIR: %w", err)
	}
	files := root.FS()
	if _, err := fs.Stat(files, "index.html"); err != nil {
		return nil, fmt.Errorf("WEB_DIR %s has no index.html: %w", dir, err)
	}
	// the wasm build must be served as application/wasm to be compiled while streaming
	if err := errors.Join(mime.AddExtensionType(".wasm", "application/wasm"), mime.AddExtensionType(".mjs", "text/javascript")); err != nil {
		return nil, err
	}
	return &web{files: files}, nil
}

func (wb *web) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet && r.Method != http.MethodHead {
		w.Header().Set("Allow", "GET, HEAD")
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	name := strings.TrimPrefix(path.Clean("/"+r.URL.Path), "/")
	if st, err := fs.Stat(wb.files, name); name == "" || err != nil || st.IsDir() {
		name = "index.html" // a route of the app, or a path that is not a file: the app decides
	}
	// the wasm build wants a cross-origin isolated page to use threads; everything here is same-origin
	h := w.Header()
	h.Set("Cross-Origin-Opener-Policy", "same-origin")
	h.Set("Cross-Origin-Embedder-Policy", "credentialless")
	if strings.HasPrefix(name, "canvaskit/") {
		h.Set("Cache-Control", "public, max-age=86400") // versioned with the Flutter engine
	} else {
		h.Set("Cache-Control", "no-cache") // revalidate: index.html, the bootstrap, the wasm and the service worker change per build
	}
	// serve under the cleaned path, so ServeFileFS never sees the original ".." segments
	r2 := r.Clone(r.Context())
	r2.URL.Path = "/" + name
	if name == "index.html" {
		r2.URL.Path = "/" // ServeFileFS would redirect a path ending in /index.html
	}
	http.ServeFileFS(w, r2, wb.files, name)
}
