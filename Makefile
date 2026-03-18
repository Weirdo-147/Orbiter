SHELL := /usr/bin/env bash

GO ?= go
GOFMT ?= gofmt
GOLANGCI_LINT ?= golangci-lint

.PHONY: bootstrap fmt lint test run-controlplane run-agent

bootstrap:
	./scripts/bootstrap.sh

fmt:
	@set -euo pipefail; \
	if [ -f go.mod ]; then \
		$(GOFMT) -w $$(find . -type f -name '*.go' -not -path './vendor/*'); \
		echo 'Formatted Go sources with gofmt.'; \
	else \
		echo 'No go.mod found yet; skipping Go formatting.'; \
	fi

lint:
	@set -euo pipefail; \
	if [ -f go.mod ]; then \
		if command -v $(GOLANGCI_LINT) >/dev/null 2>&1; then \
			$(GOLANGCI_LINT) run ./...; \
		else \
			echo 'golangci-lint not found. Run make bootstrap to see install guidance.'; \
			exit 1; \
		fi; \
	else \
		echo 'No go.mod found yet; lint target is ready for when modules are added.'; \
	fi

test:
	@set -euo pipefail; \
	if [ -f go.mod ]; then \
		$(GO) test ./...; \
	else \
		echo 'No go.mod found yet; test target is ready for when packages are added.'; \
	fi

run-controlplane:
	@set -euo pipefail; \
	if [ -d ./cmd/orbiter ]; then \
		$(GO) run ./cmd/orbiter controlplane --config ./configs/local-manager.yaml; \
	else \
		echo 'Missing ./cmd/orbiter. Add the CLI skeleton first.'; \
		exit 1; \
	fi

run-agent:
	@set -euo pipefail; \
	if [ -d ./cmd/orbiter-agent ]; then \
		$(GO) run ./cmd/orbiter-agent --manager http://127.0.0.1:8080 --node local-worker-1; \
	else \
		echo 'Missing ./cmd/orbiter-agent. Add the agent skeleton first.'; \
		exit 1; \
	fi
