"""Serves a built backend/public the way backend/vercel.json does, for tool/check.js before a deploy.

usage: python3 tool/serve.py <dir> <port> <api base URL>

Static files (a directory serves its index.html), /app/* falling back to /app/index.html, the trailing-slash
redirects, /v1/* and /healthz proxied to the API, and the security headers on every response.
"""
import http.server
import os
import sys
import urllib.error
import urllib.request

root, port, api = sys.argv[1], int(sys.argv[2]), sys.argv[3].rstrip("/")
SLASHLESS = {"/zh", "/ms", "/app", "/android", "/zh/android", "/ms/android"}
HEADERS = {
    "Cross-Origin-Opener-Policy": "same-origin",
    "Cross-Origin-Embedder-Policy": "credentialless",
    "X-Content-Type-Options": "nosniff",
    "Content-Security-Policy": "frame-ancestors 'none'",
    "X-Frame-Options": "DENY",
}


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=root, **k)

    def end_headers(self):
        for k, v in HEADERS.items():
            self.send_header(k, v)
        super().end_headers()

    def do_GET(self):
        path = self.path.split("?")[0]
        if path in SLASHLESS:
            self.send_response(308)
            self.send_header("Location", path + "/")
            self.end_headers()
            return
        if path.startswith("/v1/") or path == "/healthz":
            return self.proxy()
        local = os.path.join(root, path.lstrip("/"))
        if os.path.isdir(local):
            local = os.path.join(local, "index.html")
        if not os.path.exists(local):
            if path.startswith("/app/"):
                self.path = "/app/index.html"
            else:
                self.send_error(404)
                return
        elif os.path.isdir(os.path.join(root, path.lstrip("/"))) and not path.endswith("/"):
            self.send_error(404)  # Vercel has no automatic slash redirect beyond the ones in SLASHLESS
            return
        return super().do_GET()

    def proxy(self):
        try:
            with urllib.request.urlopen(api + self.path, timeout=30) as r:
                body, status, ctype = r.read(), r.status, r.headers.get("Content-Type", "")
        except urllib.error.HTTPError as e:
            body, status, ctype = e.read(), e.code, e.headers.get("Content-Type", "")
        self.send_response(status)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *a):
        pass


http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
