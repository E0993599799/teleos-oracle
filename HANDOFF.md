# HANDOFF.md — teleos-oracle

Living handoff doc for `AGENT_MEMORY_BOOTSTRAP_V1`. Created 2026-10-13 — this file
did not exist before (fleet-wide gap, not specific to this repo; see `serra-oracle`
and `khun-oracle` for the same gap). Update it on any multi-session task per
`~/.claude/RTK.md`'s Pre-Interruption Handoff Protocol, rather than relying on
chat history or `ψ/outbox/` alone to carry state forward.

## Current state (as of 2026-10-13)

- Branch: `main`, working tree clean at session start.
- Most recent work (from `git log`): backlog catch-up and lab-archival commits —
  `3dcab81` (ED Project production closure retrospective, PR #344/#348/#368),
  `854013d`/`c8d61ef` (worktree archival/removal), `0f568f0` (popup-terminal-windows
  closure + disk-space status + ED-project/KPI-dedupe pivot), `f23dced` (PowerShell
  cleanup-script permission config).
- This session's own work (not yet written to `ψ/`): cleaned up a `cms-arigeo`
  duplicate clone and legacy Next.js scaffold under
  `mission-control/cms-arigeo` (separate repo, not this one) — deleted stale
  `node_modules` in several places, discovered and repaired local git object
  corruption there via a fresh clone + swap, committed and pushed
  (`33853b0` on `fix/admin-nav-wiring-and-perf`). Also deleted a stray
  `node_modules` in an unrelated `pharmacy-expiry-system` hermes worktree.
  None of this touches teleos-oracle's own repo.
- This session's trigger for creating `AGENTS.md`/`PROJECT.md`/`HANDOFF.md`:
  invoking `/learn https://github.com/morluto/rea` hit the mandatory bootstrap
  gate (`MEMORY_BOOTSTRAP_BLOCKED` — these three files were missing). User chose
  to have the missing governance files created rather than skip or bypass the gate.

## Next safe action

- Resume the pending `/learn https://github.com/morluto/rea` request now that the
  bootstrap gate is satisfied.
- No other pending thread is known; treat any prior in-flight task as closed
  unless `ψ/outbox/` or recent commits say otherwise.

## How to update this file

Replace "Current state" and "Next safe action" above whenever you're about to
lose session context (interruption, `/clear`, handoff to a peer) with: what was
found, why the chosen route was picked, what failed, evidence (commit/file
refs), and the concrete next step. Keep it short — this is a pointer, not a diary;
full detail belongs in `ψ/memory/retrospectives/` or `ψ/outbox/`.
