# Node Identity and Join Semantics (Phase 0)

## Purpose

This document defines the Phase 0 contract for node identity, node join, and auditing. It is intentionally minimal so implementation can begin without introducing long-term coupling to a full PKI or attestation system.

## Node identity model

### Stable `node_id`

- `node_id` is the canonical, manager-assigned identifier for a node.
- `node_id` is immutable for the lifetime of that node record.
- `node_id` MUST be globally unique within a manager control plane.
- `node_id` MUST NOT be derived from mutable host properties (hostname, IP, cloud instance name).
- Recommended format for Phase 0: UUIDv4 string.

### Display name / hostname behavior

- Nodes may submit a `hostname` (or equivalent display name) during join.
- `hostname` is non-authoritative metadata and may change over time.
- Manager stores both:
  - `last_reported_hostname`: latest value seen from the node.
  - `display_name`: optional operator-assigned alias; defaults to `last_reported_hostname` at first join.
- Collisions in hostname/display names are allowed and do not affect identity resolution.
- All API references and internal authorization decisions MUST use `node_id`, not hostname.

### Metadata fields (labels/capacity placeholders)

Phase 0 stores metadata as opaque, optional fields for future scheduling and placement logic:

- `labels`: key/value string map, e.g. `{"region":"us-east-1","disk":"ssd"}`.
- `capacity`: structured placeholder object, e.g. `{"cpu_millis":0,"memory_bytes":0,"storage_bytes":0}`.

Rules:

- Metadata supplied at join is accepted on a best-effort basis.
- Manager may sanitize/normalize keys and values.
- Metadata does not grant privileges and is not trusted for security-sensitive decisions in Phase 0.

## Join flow

### Manager-generated short-lived join token

1. Operator (or manager API) requests a join token from the manager.
2. Manager issues a signed/random opaque token with embedded or server-side metadata:
   - `token_id`
   - `expires_at`
   - `scope` (minimum: `node:join`)
   - `usage_limit` (one-time or reusable)
3. Node presents token to `POST /v1/nodes/join` to bootstrap identity.
4. On success, manager creates or binds a node record and returns bootstrap credentials/session material.

### One-time vs reusable token semantics

- **One-time token** (`usage_limit = 1`):
  - First successful join consumes token.
  - Any subsequent use fails with `token_reused`.
- **Reusable token** (`usage_limit > 1` or policy-based reusable):
  - Can be used until expiration/revocation and usage limit is reached.
  - Manager tracks `used_count` and enforces upper bound.
- Default recommendation for Phase 0: one-time tokens for production; reusable only for controlled lab/automation scenarios.

### Token TTL and revocation model

- Token TTL is set at issuance time, with a strict max configured by manager policy.
- Recommended Phase 0 defaults:
  - default TTL: 15 minutes
  - max TTL: 24 hours
- Expired tokens are rejected without grace period.
- Revocation:
  - Manager supports explicit revocation by `token_id`.
  - Revocation takes effect immediately in manager validation path.
  - Revoked tokens return `token_revoked` (or `invalid_token` where code granularity is limited).

## Security baseline

### Token transport requirements

- Join API MUST be served only over TLS (HTTPS).
- Token MUST be sent in one of:
  - `Authorization: Bearer <join_token>` header (preferred), or
  - request body field `join_token` for constrained clients.
- Tokens MUST NOT be placed in URL path or query string.
- Redact token values in logs, traces, and error messages.

### Replay protection approach

- For one-time tokens: server-side consumed-state is primary replay defense.
- For reusable tokens: enforce `usage_limit` and optional join rate limits per token.
- Manager records join attempt nonce/attempt ID for observability and anomaly detection.
- Expired/revoked/consumed token checks occur before node record mutation.

### Bootstrap trust assumptions for Phase 0

Phase 0 explicitly assumes:

- Possession of a valid join token is sufficient proof to create initial node identity.
- No hardware attestation or external workload identity proof is required.
- First-join channel is trusted only to the extent provided by TLS and token secrecy.

This means stolen tokens can be abused until expiry/revocation; therefore short TTL and strict handling are required.

## API contract draft

Equivalent RPCs are acceptable, but HTTP contract is normative for Phase 0.

### `POST /v1/nodes/join`

#### Request JSON

```json
{
  "join_token": "string",
  "hostname": "string",
  "labels": {
    "key": "value"
  },
  "capacity": {
    "cpu_millis": 0,
    "memory_bytes": 0,
    "storage_bytes": 0
  },
  "node_version": "string",
  "nonce": "string"
}
```

Field notes:

- `join_token` required unless provided via `Authorization` header.
- `hostname`, `labels`, `capacity`, `node_version`, and `nonce` are optional in Phase 0.
- Unknown fields may be ignored or rejected per strictness mode; default behavior should be ignore with audit warning.

#### Success response (`200 OK`)

```json
{
  "node_id": "uuid",
  "display_name": "string",
  "issued_at": "2026-03-18T12:00:00Z",
  "credentials": {
    "type": "bootstrap_bearer",
    "token": "redacted-or-once-delivered-secret",
    "expires_at": "2026-03-18T13:00:00Z"
  }
}
```

#### Failure/error codes

- `400 Bad Request`
  - malformed payload
  - missing token
- `401 Unauthorized`
  - `invalid_token` (unknown/failed validation)
  - `token_expired`
  - `token_revoked`
  - `token_reused` (for one-time token already consumed)
- `403 Forbidden`
  - `token_scope_denied` (token valid but lacks `node:join` scope)
- `409 Conflict`
  - `node_conflict` (optional, if server detects conflicting bootstrap semantics)
- `429 Too Many Requests`
  - join rate limit exceeded

Error body draft:

```json
{
  "error": {
    "code": "token_expired",
    "message": "Join token is expired",
    "retryable": false
  }
}
```

## Auditing

### Join events to log

Manager audit log MUST record:

- token issuance (`token_id`, issuer, ttl, usage policy)
- token revocation (`token_id`, actor, timestamp, reason)
- join attempts (success and failure), including:
  - timestamp
  - `token_id` when derivable (never raw token)
  - source IP / network context
  - submitted hostname
  - outcome (`joined`, `token_expired`, `token_reused`, etc.)
  - resulting `node_id` on success

### Log destination

- Primary destination: manager audit log stream (append-only where possible).
- Secondary destination: centralized log/siem pipeline, if configured.
- Retention and access control follow manager security policy; Phase 0 minimum is sufficient retention for incident review and token abuse investigation.

## Phase 0 scope

Phase 0 includes only:

- manager-assigned stable `node_id`
- token-based join bootstrap
- TTL + revocation + consumed-state checks
- basic join API contract and audit events

No guarantees beyond baseline token possession + TLS are implied.

## Defer to Phase 1+

The following are explicitly out of scope for Phase 0 and deferred:

- mutual TLS with per-node certificates and automated rotation
- hardware-backed identity (TPM/TEE) and remote attestation
- signed node claims with trust chain validation
- full node lifecycle workflows (rejoin transfer, secure decommission attestations)
- fine-grained policy engine for label/capacity trust and admission control
- cross-cluster/global uniqueness guarantees for `node_id`
