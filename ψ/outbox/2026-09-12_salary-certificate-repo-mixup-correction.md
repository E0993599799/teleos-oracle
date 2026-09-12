# Correction: `salary-certificate` repo was a wayfinder misunderstanding

**Date**: 2026-09-12
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-12_arigeo-hr-attendance-cancelled-decision]] (same day, same pattern — a routed task diverging from owner intent)

## What happened

During the 2026-09-04/05 `/wayfinder` "map the Agentic AI workspace" effort
(retro: `ψ/memory/retrospectives/2026-09/05/01.48_wayfinder-agentic-ai-workspace-map.md`),
ticket 10 found the local `salary-certificate-request/` working copy was "a diverged
Marcuzx-Forge snapshot" and ticket 11 planned to give it "a real standalone repo,"
blocked on `gh auth login`.

At some point after that session, a **second** GitHub repo, `E0993599799/salary-certificate`
(no `-request` suffix), was created (2026-09-04T19:04:35Z, single push 5s later, `.vercel/`
committed, no branch history) — separate from the real, long-lived
`E0993599799/salary-certificate-request` (created 2026-06-13, dozens of feature/fix
branches, last pushed 2026-09-03).

Eak clarified 2026-09-12: `salary-certificate` (no `-request`) exists because wayfinder
misunderstood the goal. The actual intent was never "give salary-certificate its own repo" —
it's meant to go **into `arigeo-hr` (hr-arigeo.com)** as a module inside that codebase,
**not as a separate repo**.

## Decision

- `E0993599799/salary-certificate` (no `-request`) was created by mistake — it should not
  exist as a standalone repo going forward.
- The correct target: integrate the salary-certificate feature as a **module inside
  `E0993599799/arigeo-hr`** — not its own repo, not a duplicate of `salary-certificate-request`.
- `E0993599799/salary-certificate-request` (the original, real, long-history repo) is
  untouched by this decision — it's the existing standalone product, separate concern.
- No deletion or repo changes made yet as of this note — Eak was only clarifying intent;
  next concrete steps (archive/delete the mistaken repo? start scoping the arigeo-hr module?)
  are still open, not yet authorized.

## Why this is being written down

Same failure shape as the attendance-module mixup same day: a routing/planning pass
(wayfinder, in this case, not another oracle) produced an artifact — a whole GitHub repo —
that doesn't match what the owner actually wants, and if left unrecorded, a future session
could treat the mistaken `salary-certificate` repo as legitimate and keep building on it,
or waste time re-deriving this correction from scratch.
