# Development Guide

## Prerequisites

Orbiter currently targets a Go-based toolchain.

Required:

- Go **1.22+**
- GNU Make **4.x+**
- Git **2.40+**

Recommended:

- `golangci-lint` (for `make lint`)

Run this at any time to verify your environment:

```bash
make bootstrap
```

## First-run setup

1. Clone the repository.
2. From repo root, run:

   ```bash
   make bootstrap
   ```

3. (Optional) Install lint tooling if missing, then verify:

   ```bash
   go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
   make lint
   ```

4. Run formatting and tests:

   ```bash
   make fmt
   make test
   ```

## Command reference

- `make bootstrap` — verify local prerequisites and print install hints if missing.
- `make fmt` — format code (Go sources via `gofmt`).
- `make lint` — run lint checks (`golangci-lint run ./...`).
- `make test` — run test suite (`go test ./...`).
- `make run-controlplane` — run the control-plane process (`cmd/orbiter`).
- `make run-agent` — run a worker agent (`cmd/orbiter-agent`).

## Quick start: one manager + one worker (local)

> This section assumes `cmd/orbiter` and `cmd/orbiter-agent` entrypoints are present.

Terminal 1 (manager):

```bash
make run-controlplane
```

Terminal 2 (worker):

```bash
make run-agent
```

If you are testing the planned CLI flow directly, the equivalent commands are:

```bash
orbiter cluster init
orbiter-agent --manager http://127.0.0.1:8080 --node local-worker-1
```
