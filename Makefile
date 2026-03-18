.PHONY: bootstrap fmt lint test run-controlplane run-agent

bootstrap:
	bash scripts/bootstrap.sh

fmt:
	@echo "Formatting not wired yet (Phase 0 scaffold)."

lint:
	@echo "Linting not wired yet (Phase 0 scaffold)."

test:
	@echo "Test suite not wired yet (Phase 0 scaffold)."

run-controlplane:
	go run ./cmd/orbiter

run-agent:
	go run ./cmd/orbiter-agent
