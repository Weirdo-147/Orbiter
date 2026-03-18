# Integration tests

Put cross-component or external dependency tests in this folder.

These tests should use the `integration` build tag and only run when explicitly requested:

```bash
go test -tags=integration ./tests/integration/...
```
