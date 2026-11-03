package api

import (
	"net"
	"net/http"
	"strconv"
	"strings"
	"sync"
	"time"
)

// Limiter is a per-key fixed-window request limiter.
// ponytail: it lives in one process's memory, so a restart forgets everyone and two server processes
// would each allow the full limit. One process is all this runs as; a shared store (Redis) is the next step.
type Limiter struct {
	mu      sync.Mutex
	limit   int
	window  time.Duration
	maxKeys int
	now     func() time.Time
	hits    map[string]*window
}

type window struct {
	start time.Time
	n     int
}

// NewLimiter allows limit requests per window for each key and remembers at most maxKeys keys.
func NewLimiter(limit int, per time.Duration, maxKeys int) *Limiter {
	return &Limiter{limit: limit, window: per, maxKeys: maxKeys, now: time.Now, hits: map[string]*window{}}
}

// Allow counts one request for key. When it is over the limit it says how long until the window ends.
func (l *Limiter) Allow(key string) (ok bool, retryAfter time.Duration) {
	l.mu.Lock()
	defer l.mu.Unlock()
	now := l.now()
	w := l.hits[key]
	if w == nil || now.Sub(w.start) >= l.window {
		if w == nil {
			l.makeRoom(now)
			w = &window{}
			l.hits[key] = w
		}
		w.start, w.n = now, 0
	}
	w.n++
	if w.n > l.limit {
		return false, w.start.Add(l.window).Sub(now)
	}
	return true, 0
}

// makeRoom keeps the map bounded: first drop every key whose window is over, and if the map is still
// full (a flood of distinct keys inside one window) drop an arbitrary one.
func (l *Limiter) makeRoom(now time.Time) {
	if len(l.hits) < l.maxKeys {
		return
	}
	for k, w := range l.hits {
		if now.Sub(w.start) >= l.window {
			delete(l.hits, k)
		}
	}
	for k := range l.hits {
		if len(l.hits) < l.maxKeys {
			break
		}
		delete(l.hits, k)
	}
}

// Len is how many keys are remembered.
func (l *Limiter) Len() int {
	l.mu.Lock()
	defer l.mu.Unlock()
	return len(l.hits)
}

// How far forwarded-address headers are believed.
const (
	TrustNone       = ""           // the socket address only
	TrustForwarded  = "forwarded"  // X-Forwarded-For, the entry the proxy appended (Vercel overwrites the header)
	TrustCloudflare = "cloudflare" // Cf-Connecting-Ip, else X-Forwarded-For, behind a Cloudflare tunnel
)

// clientIP is the address a request is counted under. The socket address is the only thing a client
// cannot choose, so forwarded headers are believed only when the server is told it sits behind a proxy
// that sets them. Each mode reads just the header that proxy owns: Vercel overwrites X-Forwarded-For with
// the visitor's address and does not touch Cf-Connecting-Ip, so there a client could send its own
// Cf-Connecting-Ip and pick its own bucket; that header is read only in cloudflare mode.
func clientIP(r *http.Request, trust string) string {
	if trust == TrustCloudflare {
		if ip := strings.TrimSpace(r.Header.Get("Cf-Connecting-Ip")); ip != "" {
			return ip
		}
	}
	if trust == TrustForwarded || trust == TrustCloudflare {
		if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
			parts := strings.Split(xff, ",")
			if ip := strings.TrimSpace(parts[len(parts)-1]); ip != "" {
				return ip
			}
		}
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}

// rateLimit answers 429 with Retry-After once a client is over the limit.
func rateLimit(l *Limiter, trust string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if ok, wait := l.Allow(clientIP(r, trust)); !ok {
			secs := int((wait + time.Second - 1) / time.Second)
			if secs < 1 {
				secs = 1
			}
			w.Header().Set("Retry-After", strconv.Itoa(secs))
			writeErr(w, http.StatusTooManyRequests, "too many requests, try again shortly")
			return
		}
		next.ServeHTTP(w, r)
	})
}
