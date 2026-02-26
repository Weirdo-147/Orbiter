# Orbiter
ORBITER  Master Summary
Everything You Need to Know in One Place
What You're Building
Orbiter: A lightweight container orchestration platform Kubernetes alternative for small teams).
2 4 5
Why It Matters:
Solves real problem K8s complexity).
4 5 2
Shows distributed systems mastery Raft, scheduling, networking).
Gets 5K GitHub stars (realistic if executed well).
Gets you hired at top companies for 2540 LPA.
Potential to become a company.
Timeline: 8 12 weeks to impressive MVP.
The Vision
Week 1–2: Infrastructure + RPC communication
Week 3–4: Basic container deployment (MVP)
Week 5–6: Service discovery + load balancing
Week 7–8: Health checks + auto-recovery
Week 9:   Multi-master (Raft consensus)
Week 10:  UI dashboard
Week 11:  Documentation
Week 12:  LAUNCH + marketing
6 7 1
Result: 5K+ stars, inbound recruiter messages, 25–40 LPA offers
Infrastructure Decision
Recommended: Cloud VMs DigitalOcean-style droplets)
Typical “basic” VMs today: 1 vCPU, 1 2 GiB RAM, small SSD, around 512 USD/month.
Best Setup for Testing:
Your Laptop (dev) → 3 Cloud VMs
VM 1: Master node      
VM 2: Worker node 1    
VM 3: Worker node 2    
(1 GB RAM, 1 vCPU)
(1 GB RAM, 1 vCPU)
(1 GB RAM, 1 vCPU)
3 8 9
Total: 3 vCPUs, 3 GB RAM
Cost: ≈ 15 USD/month (for 3× small VMs)
Why this is perfect:
Enough to test a real distributed system.
Mirrors how small teams would actually deploy it.
Easy remote demo (send them the dashboard URL.
No noise from home power/cooling issues.
Why not Dell OptiPlex right now:
Upfront ₹2025K vs roughly 45 USD over 3 months for cloud.
Less flexible (tied to home power/network).
Harder to demo to remote interviewers.
You can still build a homelab later; for this project, cloud first is better.
Architecture at a Glance
5 10 2 4
Control-plane vs data-plane mirrors Kubernetes: API server, scheduler, state store, worker
agents.
┌─────────────────────────────────────────┐
│             
ORBITER CLUSTER            
│
├─────────────────────────────────────────┤
│ CONTROL PLANE (Master)                 
│  ├─ API Server      
│  ├─ Scheduler       
│  ├─ State Store     
(REST/gRPC)        
(where to run)     
(cluster state)    
│  └─ Health Manager  (nodes + tasks)    
│                                         
│ WORKERS (Agents)                        
│  ├─ Docker runtime                      
│
│
│
│
│
│
│
│
│  ├─ Executor (run/stop containers)     
│
│  └─ Metrics + health reporter          
│                                         
│ NETWORKING                              
│  ├─ Service Registry                    
│  ├─ DNS-based Service Discovery         
│  └─ Load Balancer (simple RR)          
│
│
│
│
│
│
└─────────────────────────────────────────┘
Core inspiration: Kubernetes control plane plus a Raft-backed consistent state (like etcd).
10 6 2 4 5
Control Plane Core Ideas
7 13 1 6 11
11 12
State Store: A replicated state machine using a Raft-like log: cluster nodes, deployments,
tasks, health status.
Scheduler: Simple bin-packing or score-based placement by CPU/RAM and spread.
API Server: FastAPI (or similar) with endpoints for deployments, scaling, status.
Health Loop: Periodic checks of node heartbeats and task health, triggering reschedules.
Raft gives:
10 4
Leader election on master failure.
Log replication for consistent cluster state.
Quorum guarantees: majority needed to commit updates.
Worker Agents
Each worker node runs:
A lightweight agent process that:
Registers with master.
Pulls assigned tasks.
Uses Docker API to start/stop containers.
Reports metrics CPU, RAM, running containers).
Minimal local state; truth is in the control plane.
14 15 16
13 1 6 7 11
Docker networking and bridge networks allow you to simulate multi-container communication on
single hosts and across hosts.
Networking & Service Discovery
You want basic service discovery:
Service registry in master: service name 
→
 list of endpoints IP:port).
Simple DNS responder so containers can call 
http://service-name:port
.
Load balancing: round-robin or iptables/NAT-based rules.
This is conceptually similar to how Kubernetes uses DNS + services to expose pods.
Health Checks & Auto-Recovery
Agents expose or collect health signals per container.
Master:
Marks tasks as unhealthy if checks fail repeatedly.
Restarts tasks or reschedules them on other nodes.
2 4 5 10
Detects node death via missing heartbeats and moves all its tasks elsewhere.
Matching the “desired state vs current state” pattern from Kubernetes controllers.
High Availability Optional Raft Step)
Two options for HA
Option A (simpler): Use an external etcd cluster as your state store.
1 6 7 11 13
17 18 19
4 5 10 2
Option B (more impressive): Integrate a Raft implementation and maintain your own
replicated log.
You can implement Option A first, then upgrade when core features are done.
