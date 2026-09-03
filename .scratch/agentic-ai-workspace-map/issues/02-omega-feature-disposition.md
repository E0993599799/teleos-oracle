Type: grilling
Status: open

## Question

`mission-control/Omega/` holds a new, uncommitted dashboard feature (`OMEGA_BUILD_PLAN.md`, `PHASE1_PROGRESS.md`, a Next.js app under `dashboard/`), staged since 2026-08-31, never committed. It's part of what's making mission-control root's `git status` stuck (see the root-reconciliation ticket), but it's a separate decision: is this feature wanted?

Decide: commit it (as part of, or after, the root reconciliation), discard it, or move it out to its own repo. If wanted, does it block or follow the root-reconciliation ticket?

See [CONTEXT.md](../CONTEXT.md), "Omega — corrected, not a real anomaly".
