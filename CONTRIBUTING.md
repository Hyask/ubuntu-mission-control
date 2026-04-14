# Contributing to Ubuntu Mission Control

Thank you for your interest in contributing! This document explains how to get involved, what is expected, and how to get your changes merged.

## Before you start

For anything beyond a typo fix or a small bug, please open an issue first. Describe what you want to change and why. This avoids wasted effort on both sides and gives us a chance to discuss the best approach before any code is written.

For small, obvious fixes (typos, broken links, trivial bugs), you can go straight to a pull request.

## Development setup

```bash
git clone https://github.com/<your-fork>/ubuntu-mission-control.git
cd ubuntu-mission-control
make install   # install dependencies
make dev       # start dev server on http://localhost:3000
```

## Workflow

1. Fork the repository and create a branch from `main`:
   ```bash
   git checkout -b my-feature
   ```

2. Write tests first. Bug fixes should include a failing test that reproduces the issue before the fix. New features should have tests that cover the expected behaviour.

3. Make your changes, keeping commits small and focused. Each commit should represent one logical change and be independently understandable.

4. Verify everything passes before pushing:
   ```bash
   make test    # run Vitest suite
   make build   # verify production build succeeds
   ```

5. Open a pull request against `main`. Fill in the PR description with:
   - What the change does and why
   - How you tested it
   - Any tradeoffs or alternatives you considered

## Code standards

- Follow the Svelte style conventions; existing code provides examples.
- Keep components focused and compose them together for complex UIs.
- Avoid tight coupling between components and data pipeline logic.
- Add unit tests to `src/lib/*.test.js` for core data transformations.
- Keep line length reasonable (aim for ~100 characters).
- Use meaningful variable and function names; avoid abbreviations where clarity matters.
- Comment non-obvious logic, especially in data processing and KPI calculations.

Run tests locally:

```bash
make test      # run Vitest suite once
make test:watch  # watch mode for development
```

## AI-assisted contributions

AI-assisted code is welcome. If you used an AI tool (GitHub Copilot, Claude, ChatGPT, etc.) to write or substantially revise code in your PR, please mention it in the PR description. You are still responsible for reviewing, understanding, and testing everything you submit — the same quality bar applies regardless of how the code was written.

## Commit messages

Write commit messages in the imperative mood, describing what the change does and why (not just what the diff shows):

```
Add release selector dropdown for multi-release tracking

Previously only a single release was displayed. This adds a release
selector that automatically becomes a dropdown when multiple releases
are configured in the environment.

Fixes #42
```

## What makes a good PR

- It solves one problem clearly.
- It includes tests (unit tests in `src/lib/*.test.js` for core logic).
- `make test` passes with no failures.
- The description explains the motivation, not just the mechanics.
- It has been reviewed by the author before submission (no debug code, no leftover TODOs, no accidental file inclusions).

## Questions?

Open an issue and tag it `question`. We're happy to help.

## Additional resources

- [Project README](README.md)
- [Architecture and Design](DESIGN.md)
- [Feature Guide](docs/FEATURES.md)
- [Test Observer API Notes](TEST_OBSERVER_API.md)
