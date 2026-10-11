---
pattern: "The file-based ψ/ vault and the live mission-memory MCP can diverge silently — memory records stay current during multi-session work, but the matching ψ/ retrospective only gets written if a session is explicitly invoked to write one."
date: 2026-10-11
source: "rrr-style catch-up: teleos-oracle (/recap)"
concepts: ["memory", "retrospectives", "staleness", "worktrees", "verification-before-completion"]
---

# A frozen worktree is not evidence that work stopped

While recapping, the ψ/ vault's newest retrospective was dated 2026-10-08, but
mission-memory had live, VERIFIED records through 2026-10-11 — a full ED
Project production-closure arc (PR #344 → #348 → #368, deploy approved and
live) had happened with zero matching ψ/ file-based retro. The gap was only
caught because `/recap` cross-checked mission-memory against the ψ/ files
instead of trusting the newest ψ/ file as "current state."

A related pattern inside that same arc: teleos-oracle had been polling a
specific worktree (`ed-retrospective-gmail-reconcile-20261010`) that never
advanced past one commit. The real completion happened via a sibling path
(direct work landing as PR #344/#348 on master) that the frozen worktree gave
no visibility into. The fix was to verify against production/GitHub directly
rather than treat "my monitored worktree hasn't moved" as "no progress has
been made" — a stalled branch is a signal to look for work elsewhere, not a
status report on the whole effort.

**Takeaway**: (1) a session doing multi-day cross-session work should write a
ψ/ retro before the vault goes stale relative to mission-memory, not rely on
the next `/recap`/`/rrr` to notice and backfill; (2) treat a non-advancing
worktree/branch as grounds to check sibling paths and live production state,
not as proof the underlying effort is stalled.
