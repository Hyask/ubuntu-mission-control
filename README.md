# Ubuntu Mission Control

Real-time dashboard for Ubuntu image release tracking.

It reads from the public Test Observer API and shows:
- Current artifact status (approved/failed/undecided)
- Build freshness (today vs stale)
- Manual testing progress and pass rate
- Launchpad bugs referenced in test results

## Features

- **Release selector** — switch between tracked Ubuntu releases; automatically becomes a dropdown when more than one is configured.
- **Color-coded artifact cards** — green (approved), amber (undecided, built today), red (failed), grey (stale / not built today).
- **Three-phase progressive loading** — artifact cards appear immediately, then test execution chips are added, then individual test result counts and bug references fill in as data arrives.
- **Launchpad bug extraction** — LP bug numbers are parsed from structured issues and freeform text in test result comments.
- **KPI summary row** — live aggregate counts of approved, failed, in-progress, and untested artifacts across the whole dashboard.
- **Auto-refresh** — configurable polling interval with a live countdown timer and a manual refresh button.
- **Incremental state diffing** — background refreshes only re-render cards whose status, test data, or bugs actually changed, avoiding full-page flicker.

## Tech Stack

- Svelte 5
- Vite 6
- Vanilla CSS
- Vitest for unit tests

See [DESIGN.md](DESIGN.md) for full architecture, data pipeline details, and release configuration.

## Quick Start

```bash
make install
make dev
```

The app runs on http://localhost:3000 by default.

## Commands

```bash
make dev      # start Vite dev server
make test     # run unit tests
make build    # production build to dist/
make serve    # preview production build
```

Equivalent npm scripts:

```bash
npm run dev
npm run test
npm run test:watch
npm run build
npm run preview
```

## API

The frontend always calls `/api/v1/...`. In development and preview, Vite proxies `/api/*` to `https://tests-api.ubuntu.com`.

## Project Layout

```text
src/
  api/client.js            # API wrappers
  lib/utils.js             # date/format helpers
  lib/processor.js         # core data pipeline + KPI + diff logic
  components/              # Svelte UI components
  App.svelte               # app state + loading/refresh orchestration
```

## Tests

Current test coverage focuses on stable core logic:
- `src/lib/utils.test.js`
- `src/lib/processor.test.js`

These tests protect:
- Date/version parsing behavior
- Artifact-to-product transformation
- Test execution/result enrichment logic
- Bug extraction from structured issues and comments
- KPI calculations
- Incremental diff behavior preserving unchanged references

## Release Checklist

- Run `make test`
- Run `make build`
- Verify local app with `make dev`
- Confirm API access in your deployment environment

## Notes

- Reference docs are in `DESIGN.md` and `TEST_OBSERVER_API.md`.
- This repository currently tracks the `image` artifact family.
