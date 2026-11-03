package api

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
)

// ParseTrust reads TRUST_PROXY: "true" (X-Forwarded-For, as set by Vercel), "cloudflare", or off.
func ParseTrust(v string) (string, error) {
	switch v {
	case "", "false":
		return TrustNone, nil
	case "true":
		return TrustForwarded, nil
	case "cloudflare":
		return TrustCloudflare, nil
	}
	return "", fmt.Errorf("TRUST_PROXY must be true, cloudflare or false, not %q", v)
}

// EnvInt reads a whole number from the environment; 0 usually turns a limit off.
func EnvInt(key string, def int) (int, error) {
	v := os.Getenv(key)
	if v == "" {
		return def, nil
	}
	n, err := strconv.Atoi(v)
	if err != nil || n < 0 {
		return 0, fmt.Errorf("%s must be a whole number, not %q", key, v)
	}
	return n, nil
}

// RestorePath undoes the Vercel rewrite that sends every API path to one function. The rewrite
// "/v1/:path*" to "/api/index?p=/v1/:path*" hides the real path in the p query parameter (a plain
// ":path" parameter, if the platform adds one, is understood too). The path is put back and the helper
// parameters are removed, so the router sees the request the visitor made.
func RestorePath(r *http.Request) {
	q := r.URL.Query()
	switch {
	case q.Get("p") != "":
		r.URL.Path = q.Get("p")
	case q.Has("path") && strings.HasPrefix(r.URL.Path, "/api/"):
		r.URL.Path = "/v1/" + strings.TrimPrefix(q.Get("path"), "/")
	default:
		return
	}
	q.Del("p")
	q.Del("path")
	r.URL.RawPath = ""
	r.URL.RawQuery = q.Encode()
	r.RequestURI = r.URL.RequestURI()
}
