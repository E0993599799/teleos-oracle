Type: grilling
Status: resolved

## Question

`mission-control/Omega/` holds a new, uncommitted dashboard feature (`OMEGA_BUILD_PLAN.md`, `PHASE1_PROGRESS.md`, a Next.js app under `dashboard/`), staged since 2026-08-31, never committed. It's part of what's making mission-control root's `git status` stuck (see the root-reconciliation ticket), but it's a separate decision: is this feature wanted?

Decide: commit it (as part of, or after, the root reconciliation), discard it, or move it out to its own repo. If wanted, does it block or follow the root-reconciliation ticket?

See [CONTEXT.md](../CONTEXT.md), "Omega — corrected, not a real anomaly".

## Answer

The premise was wrong: this is not abandoned/unclear-fate work. `OMEGA_BUILD_PLAN.md` identifies it as **"OMEGA — Fencing Competition Control"**, an entirely separate product from ARIGEO HR (a tournament-management + live-scoring + broadcast + AI-analytics platform for fencing), prepared by Serra (Researcher Oracle) for Eak, plan approved 2026-08-31, dispatched to codex. Phase 0→1 gate approval confirmed live via closed GitHub issues [#322](https://github.com/E0993599799/mission-control/issues/322) and [#323](https://github.com/E0993599799/mission-control/issues/323) — พี่เอก (`E0993599799`) personally acknowledged Serra's Phase 1 kickoff on 2026-08-31. `PHASE1_PROGRESS.md` shows real, working Phase 1 output (a dependency-free Rust tournament engine + HTTP/JSON API, not mock UI).

**Decided (พี่เอก, this session):**
1. **Leave Omega entirely untouched** — not Teleos's project to commit, discard, or move. It's Serra/codex's active, Eak-approved work-in-progress; no sign of abandonment (the progress note describes a deliberate mid-phase checkpoint, not a stall).
2. **Ticket 01's execution must explicitly carve out "don't touch Omega/" as a constraint**, rather than relying on a plain `git pull` being naturally safe — this whole map exists because "should be safe in theory" already broke once on this repo.

This also means: Omega is a second, unrelated product living inside the `mission-control` repo by directory-nesting accident, not a mission-control/ARIGEO feature. Worth a "not yet specified" note on whether it eventually deserves its own repo — not this session's call, and explicitly not urgent since Serra owns it.
