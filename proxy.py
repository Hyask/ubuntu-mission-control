#!/usr/bin/env python3
"""
Simple CORS proxy for Test Observer API local development.

Usage:
    python3 proxy.py [port]   (default port: 8765)

Then open index.html and it will talk to http://localhost:8765
which forwards all requests to https://tests-api.ubuntu.com.
"""

import sys
import urllib.request
import urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler

API_BASE = "https://tests-api.ubuntu.com"
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8765

CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PATCH, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-CSRF-Token, Authorization",
}


class ProxyHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(204)
        for k, v in CORS_HEADERS.items():
            self.send_header(k, v)
        self.end_headers()

    def do_GET(self):
        self._proxy("GET")

    def do_POST(self):
        self._proxy("POST")

    def do_PATCH(self):
        self._proxy("PATCH")

    def do_PUT(self):
        self._proxy("PUT")

    def do_DELETE(self):
        self._proxy("DELETE")

    def _proxy(self, method):
        url = API_BASE + self.path
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else None

        forward_headers = {}
        for key in ("Content-Type", "Cookie", "X-CSRF-Token", "Authorization"):
            val = self.headers.get(key)
            if val:
                forward_headers[key] = val

        req = urllib.request.Request(url, data=body, headers=forward_headers, method=method)
        try:
            with urllib.request.urlopen(req) as resp:
                data = resp.read()
                self.send_response(resp.status)
                ct = resp.headers.get("Content-Type", "application/json")
                self.send_header("Content-Type", ct)
                for k, v in CORS_HEADERS.items():
                    self.send_header(k, v)
                self.end_headers()
                self.wfile.write(data)
        except urllib.error.HTTPError as e:
            data = e.read()
            self.send_response(e.code)
            self.send_header("Content-Type", "application/json")
            for k, v in CORS_HEADERS.items():
                self.send_header(k, v)
            self.end_headers()
            self.wfile.write(data)
        except Exception as e:
            self.send_response(502)
            for k, v in CORS_HEADERS.items():
                self.send_header(k, v)
            self.end_headers()
            self.wfile.write(f'{{"error": "{e}"}}'.encode())

    def log_message(self, fmt, *args):
        print(f"[proxy] {fmt % args}")


if __name__ == "__main__":
    server = HTTPServer(("localhost", PORT), ProxyHandler)
    print(f"Proxy listening on http://localhost:{PORT}")
    print(f"Forwarding requests to {API_BASE}")
    print("Press Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nProxy stopped.")
