# Node Identity and Secure Join Tokens (Phase 0 Draft)

## Goals
- Give each worker a stable `node_id`.
- Authenticate node joins with short-lived tokens.
- Establish baseline auditability for join events.

## Identity model
- `node_id`: generated UUID, immutable once issued.
- `node_name`: human-readable name (hostname by default).
- `labels`: key/value metadata for future scheduling.
- `capacity`: CPU/memory fields reserved for scheduler use.

## Join flow (draft)
1. Operator requests a join token from control plane.
2. Control plane issues signed token with TTL (e.g., 15 minutes).
3. Worker calls join endpoint with token + node metadata.
4. Control plane validates token signature, expiry, and revocation status.
5. Control plane returns assigned `node_id` and session credentials.

## Security baseline
- Tokens must be single-purpose (join only).
- Token TTL should be short and configurable.
- Reused/revoked/expired tokens are rejected.
- Join events are logged with timestamp, source IP, and node_name.

## API draft
`POST /v1/nodes/join`

Request fields:
- `token`
- `node_name`
- `labels`
- `capacity`

Response fields:
- `node_id`
- `accepted`
- `message`

## Deferred to later phases
- Mutual TLS certificate bootstrapping.
- Fine-grained RBAC for node operations.
- Multi-manager token issuing policy.
