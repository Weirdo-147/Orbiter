# Testing strategy

Orbiter follows a test pyramid so contributors get fast feedback locally while CI still verifies important system behavior.

## Test pyramid expectations

### Unit tests (`tests/unit/`)
- **Purpose:** validate individual packages/functions in isolation.
- **Runtime target:** seconds to a couple minutes.
- **Run frequency:** every local change and every CI pull request build.

### Integration tests (`tests/integration/`)
- **Purpose:** validate interactions between Orbiter components or with required dependencies.
- **Runtime target:** slower than unit tests; may require setup fixtures.
- **Run frequency:** optional locally; separate CI job so failures are isolated from unit-test feedback.

### End-to-end tests (`tests/e2e/`)
- **Purpose:** validate full user-facing workflows in realistic environments.
- **Runtime target:** slowest tests.
- **Run frequency:** on-demand locally and in dedicated CI workflows (nightly/release), not mandatory for each pull request.

## Local commands

Use Makefile targets so local and CI commands stay aligned:

- `make fmt` – apply formatting.
- `make fmt-check` – verify formatting without changing files.
- `make lint` – run linters.
- `make test-unit` – run unit test suite.
- `make test-integration` – run integration tests (currently optional).

## CI behavior

The default CI workflow runs:
1. formatting check (`make fmt-check`),
2. lint (`make lint`),
3. unit tests (`make test-unit`).

Integration tests run in a dedicated optional job (`integration-tests`) and are gated behind an input flag for manual runs. This keeps PR feedback fast while preserving a standard path for deeper validation.
