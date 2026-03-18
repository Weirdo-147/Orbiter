# Orbiter

Orbiter is an open-source, lightweight Kubernetes alternative: simple enough for small teams, powerful enough for real workloads.

It is built for teams that need clean, minimal orchestration without the operational overhead and steep learning curve of full Kubernetes.

## Why Orbiter

Kubernetes is excellent, but it can be too complex for many teams and projects.

Orbiter focuses on the **80/20**:
- Deploy containers across a small cluster.
- Keep services alive with health checks and restart logic.
- Discover and route traffic between services.
- Scale workloads up/down with straightforward commands.

No giant control plane. No sprawling ecosystem required to get started.

## Target Users

Orbiter is designed for:

1. **Startups (10–100 engineers)**
   - Need multi-node deployments.
   - Don’t want full Kubernetes operational complexity.

2. **Product/dev teams**
   - Need easy “run this container across 2–5 machines” workflows.
   - Want simple APIs and predictable behavior.

3. **Self-hosters and homelab operators**
   - Want clustering and service failover.
   - Prefer a smaller, understandable system.

## Project Goals

### Core goals
- Lightweight cluster orchestration for small-to-medium deployments.
- Simple control-plane architecture.
- Reliable scheduling and reconciliation.
- Fast local and cloud setup.

### Non-goals (initially)
- Full Kubernetes API compatibility.
- Complex CRD/operator ecosystem.
- Massive multi-tenant enterprise features.

## High-Level Architecture

Orbiter has two main parts:

### 1) Control Plane
- **API Server**: accepts deploy/scale/status operations.
- **Scheduler**: places workloads based on resources and simple spread rules.
- **State Store**: tracks desired and actual state.
- **Health/Reconciler Loop**: heals unhealthy tasks and reschedules failed nodes.

### 2) Worker Agent (per node)
- Registers node with control plane.
- Pulls assigned tasks.
- Starts/stops containers via container runtime.
- Reports heartbeat + runtime metrics.

### Networking & Service Discovery
- Service registry (`service -> endpoint list`).
- Internal DNS naming (`http://service-name`).
- Simple built-in load balancing (round-robin first).

## MVP Scope

The first usable release should include:
- Cluster bootstrap (1 control node + N worker nodes).
- Deploy a containerized app with replicas.
- Scale replicas up/down.
- Service-to-service discovery.
- Health checks + automatic restart/reschedule.
- CLI for common operations.

## Planned CLI (draft)

```bash
orbiter cluster init
orbiter node join --token <token> --manager <ip:port>
orbiter deploy apply ./app.yaml
orbiter deploy scale web=3
orbiter deploy status web
orbiter service list
orbiter logs web --follow
```

## Example Deployment Spec (draft)

```yaml
apiVersion: orbiter/v1
kind: Deployment
metadata:
  name: web
spec:
  image: ghcr.io/example/web:latest
  replicas: 3
  resources:
    cpu: "250m"
    memory: "256Mi"
  ports:
    - containerPort: 8080
  healthCheck:
    httpGet:
      path: /health
      port: 8080
    intervalSeconds: 10
```

## Development Roadmap

### Phase 0 — Foundation
- [ ] Repository scaffolding and coding standards.
- [ ] Local dev environment and test harness.
- [ ] Basic node identity + secure join tokens.

### Phase 1 — MVP Control Plane
- [ ] API server with deployment CRUD.
- [ ] In-memory (then persistent) state store.
- [ ] Naive scheduler + reconciliation loop.

### Phase 2 — Worker Runtime
- [ ] Worker agent daemon.
- [ ] Container lifecycle operations.
- [ ] Heartbeats and task status reporting.

### Phase 3 — Networking & Reliability
- [ ] Service registry and DNS.
- [ ] Round-robin service routing.
- [ ] Health checks and rescheduling.

### Phase 4 — Production Hardening
- [ ] Persistent state + backup/restore.
- [ ] Optional HA control plane (Raft).
- [ ] Security baseline (TLS, authn/authz).

## Current Status

🚧 **Early project stage** — README and product direction are being actively defined.

Immediate next steps:
1. Define initial codebase layout (`cmd/`, `internal/`, `pkg/`, etc.).
2. Implement a minimal API server skeleton.
3. Implement a worker heartbeat protocol.
4. Add first end-to-end deploy/health integration test.

## Repository Layout

- `cmd/orbiter/` — CLI entrypoint and command wiring.
- `cmd/orbiter-agent/` — worker daemon entrypoint.
- `internal/controlplane/` — scheduler, reconciler, and API server internals.
- `internal/worker/` — agent runtime internals.
- `pkg/api/` — shared API types and contracts used across components.
- `configs/` — local and development cluster configuration files.
- `deploy/` — manifests and scripts for running local multi-node setups.
- `scripts/` — helper scripts (bootstrap, lint, test wrappers).
- `docs/architecture/` — architecture and design documentation.

## Contributing

Contributions are welcome from day one.

If you want to help, open an issue with one of:
- bug report,
- design proposal,
- or implementation plan for a roadmap item.

## License

Orbiter is licensed under the **MIT License**. See [`LICENSE`](./LICENSE) for full text.
