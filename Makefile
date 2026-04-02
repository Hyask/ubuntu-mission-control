PROXY_PORT  ?= 8765
HTTP_PORT   ?= 3000
PROXY_PID_FILE := .proxy.pid
HTTP_PID_FILE  := .http.pid

.PHONY: help start stop proxy serve open status clean

help:
	@echo "Usage:"
	@echo "  make start   — start proxy + HTTP server, open browser"
	@echo "  make stop    — stop both background servers"
	@echo "  make status  — show which servers are running"
	@echo "  make proxy   — start only the CORS proxy (port $(PROXY_PORT))"
	@echo "  make serve   — start only the HTTP server (port $(HTTP_PORT))"
	@echo "  make open    — open the UI in the browser"
	@echo "  make clean   — remove PID files"

start: proxy serve open

proxy:
	@if [ -f $(PROXY_PID_FILE) ] && kill -0 $$(cat $(PROXY_PID_FILE)) 2>/dev/null; then \
		echo "Proxy already running (PID $$(cat $(PROXY_PID_FILE)))"; \
	else \
		python3 proxy.py $(PROXY_PORT) & echo $$! > $(PROXY_PID_FILE); \
		echo "Proxy started on http://localhost:$(PROXY_PORT) (PID $$(cat $(PROXY_PID_FILE)))"; \
	fi

serve:
	@if [ -f $(HTTP_PID_FILE) ] && kill -0 $$(cat $(HTTP_PID_FILE)) 2>/dev/null; then \
		echo "HTTP server already running (port $(HTTP_PORT), PID $$(cat $(HTTP_PID_FILE)))"; \
	else \
		python3 -m http.server $(HTTP_PORT) --bind 127.0.0.1 >/dev/null 2>&1 & echo $$! > $(HTTP_PID_FILE); \
		echo "HTTP server started on http://localhost:$(HTTP_PORT) (PID $$(cat $(HTTP_PID_FILE)))"; \
	fi

open:
	@sleep 0.5
	@xdg-open http://localhost:$(HTTP_PORT) 2>/dev/null || \
	 open     http://localhost:$(HTTP_PORT) 2>/dev/null || \
	 echo "Open http://localhost:$(HTTP_PORT) in your browser"

stop:
	@if [ -f $(PROXY_PID_FILE) ]; then \
		PID=$$(cat $(PROXY_PID_FILE)); \
		kill $$PID 2>/dev/null && echo "Proxy stopped (PID $$PID)" || echo "Proxy was not running"; \
		rm -f $(PROXY_PID_FILE); \
	else \
		echo "Proxy PID file not found"; \
	fi
	@if [ -f $(HTTP_PID_FILE) ]; then \
		PID=$$(cat $(HTTP_PID_FILE)); \
		kill $$PID 2>/dev/null && echo "HTTP server stopped (PID $$PID)" || echo "HTTP server was not running"; \
		rm -f $(HTTP_PID_FILE); \
	else \
		echo "HTTP server PID file not found"; \
	fi

status:
	@if [ -f $(PROXY_PID_FILE) ] && kill -0 $$(cat $(PROXY_PID_FILE)) 2>/dev/null; then \
		echo "Proxy      : running on http://localhost:$(PROXY_PORT) (PID $$(cat $(PROXY_PID_FILE)))"; \
	else \
		echo "Proxy      : stopped"; \
	fi
	@if [ -f $(HTTP_PID_FILE) ] && kill -0 $$(cat $(HTTP_PID_FILE)) 2>/dev/null; then \
		echo "HTTP server: running on http://localhost:$(HTTP_PORT) (PID $$(cat $(HTTP_PID_FILE)))"; \
	else \
		echo "HTTP server: stopped"; \
	fi

clean:
	@rm -f $(PROXY_PID_FILE) $(HTTP_PID_FILE)
	@echo "PID files removed"
