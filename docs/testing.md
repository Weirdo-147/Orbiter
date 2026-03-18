# Testing Strategy

Orbiter uses a layered test strategy:

- `tests/unit`: fast, deterministic tests for small components.
- `tests/integration`: cross-package behavior with local dependencies.
- `tests/e2e`: multi-process behavior and cluster workflows.

## CI policy (initial)
- Run lint + unit tests on every PR.
- Run integration tests when available.
- Add e2e jobs once control-plane/worker protocol is stable.
