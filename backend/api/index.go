// Package handler is the Vercel function behind /v1/* and /healthz.
// Vercel compiles this file as a module named after the package, which may not import internal/ directly.
package handler

import (
	"net/http"

	"eshop-radar/backend/serverless"
)

// Handler is the entry point Vercel calls.
func Handler(w http.ResponseWriter, r *http.Request) { serverless.Handler(w, r) }
