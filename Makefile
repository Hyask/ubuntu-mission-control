DEV_PORT  ?= 3000

.PHONY: help install dev build serve start stop status clean

help:
	@echo "Usage:"
	@echo "  make install  — install npm dependencies (run once)"
	@echo "  make dev      — start Vite dev server with hot reload (port $(DEV_PORT))"
	@echo "  make build    — build optimised production bundle into dist/"
	@echo "  make serve    — build + preview production bundle (port $(DEV_PORT))"
	@echo "  make start    — alias for 'make dev'"
	@echo ""
	@echo "Legacy (production deployment without Node):"
	@echo "  make proxy    — start only the CORS proxy (port 8765)"
	@echo "  make stop     — stop background proxy server"
	@echo "  make status   — show proxy server status"
	@echo "  make clean    — remove PID files and dist/"

# ── Primary workflow ──────────────────────────────────────────

install:
	npm install

dev:
	npm run dev

build:
	npm run build

serve: build
	npm run preview

start: dev

# ── Legacy: bare proxy for charm/production deployments ───────
# proxy.py strips the /api prefix that the built app emits.

PROXY_PORT    ?= 8765
PROXY_PID_FILE := .proxy.pid

proxy:
	@if [ -f $(PROXY_PID_FILE) ] && kill -0 $$(cat $(PROXY_PID_FILE)) 2>/dev/null; then \
		echo "Proxy already running (PID $$(cat $(PROXY_PID_FILE)))"; \
	else \
		python3 proxy.py $(PROXY_PORT) & echo $$! > $(PROXY_PID_FILE); \
		echo "Proxy started on http://localhost:$(PROXY_PORT) (PID $$(cat $(PROXY_PID_FILE)))"; \
	fi

stop:
	@if [ -f $(PROXY_PID_FILE) ]; then \
		PID=$$(cat $(PROXY_PID_FILE)); \
		kill $$PID 2>/dev/null && echo "Proxy stopped (PID $$PID)" || echo "Proxy was not running"; \
		rm -f $(PROXY_PID_FILE); \
	else \
		echo "Proxy PID file not found"; \
	fi

status:
	@if [ -f $(PROXY_PID_FILE) ] && kill -0 $$(cat $(PROXY_PID_FILE)) 2>/dev/null; then \
		echo "Proxy: running on http://localhost:$(PROXY_PORT) (PID $$(cat $(PROXY_PID_FILE)))"; \
	else \
		echo "Proxy: stopped"; \
	fi

clean:
	@rm -f $(PROXY_PID_FILE)
	@rm -rf dist/
	@echo "Cleaned PID files and dist/"
