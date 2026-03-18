# Development Guide

## Prerequisites
- Go 1.22+
- Bash
- GNU Make

## First-time setup
```bash
make bootstrap
```

## Day-to-day commands
```bash
make fmt
make lint
make test
```

## Running local binaries
```bash
make run-controlplane
make run-agent
```

## Notes
Current commands are Phase 0 scaffolding and will be wired to real tooling in upcoming phases.
