# Agentic AI workspace map — findings & recommendations

**Date**: 2026-09-04
**Effort**: wayfinder map "Agentic AI workspace map & improvement plan" — `.scratch/agentic-ai-workspace-map/` in this repo
**Companion artifact**: `/mnt/d/01 Main Work/Boots/Agentic AI/PROJECT_REGISTRY.md`

Started from พี่เอก's request to scan the whole `Agentic AI` folder, map it, and suggest improvements. What followed instead was mostly *discovering the map didn't match reality* — the workspace turned out to be bigger, messier, and structured differently than any existing doc claimed. This is the write-up of what we actually found and fixed, plus what's still open.

## Headline finding

The top-level `CLAUDE.md` claims 3 projects. There are **80+**. The `PROJECT_REGISTRY.md` that was supposed to track this had **5 stale, fragmented copies** (all frozen 2026-08-04) and **no generator script anywhere** — "regenerate the registry" wasn't a script re-run, it had to be built from nothing. That's now done as a first manual pass (see the companion Registry); the automation to keep it fresh is still a gap.

## What got fixed this session (production-adjacent, done with your sign-off)

- **`mission-control` root was stuck**, not just stale — an unresolved merge conflict from a failed autostash pop, sitting on the repo that's actually live on Vercel (`prj_hfdIL1BYKitpZTxpH5EixAputdzQ`). Turned out root had zero commits of its own beyond `origin/main` — no real work at risk. Synced clean. *(ticket 01, 08)*
- **Worktree cleanup**: 2 registered-but-broken worktrees removed (`git worktree remove --force` actually failed on a Windows-path/WSL-path mismatch in their metadata — fixed via `git worktree prune` instead), 2 stale orphan directories deleted outright. One (`mission-control-hermes-watcher`) deliberately held back — it has an installer script and a team config not found anywhere else in the fleet, worth your own look before it's touched. *(ticket 04, 09)*

## What got clarified (no action needed)

- **"Omega" isn't stray debris.** It's `mission-control/Omega/` holding **"OMEGA — Fencing Competition Control"** — Serra-oracle's separate, Eak-approved fencing-tournament product (confirmed via closed GitHub issues #322/#323, where you personally acknowledged Serra's Phase 1 kickoff). Entirely unrelated to ARIGEO HR, just living in the same directory tree by accident. Left untouched. *(ticket 02)*
- **The arigeo family is deliberate**, not duplication — `arigeo-hr`, `arigeo-auth`, `cms-arigeo`, `arigeo-project` are separate microservices by design (you confirmed this directly). No consolidation needed.
- **The whole `Agentic AI` folder is itself one git repo** (remote `Marcuzx-Forge`), not a plain folder of independent projects. Its last commit message ("remove stale mission-control submodule gitlink") implies `mission-control` was once a proper git submodule and got deliberately detached — why is still unknown (see Open items).

## Priority findings still open

1. **`mission-control-vercel-curated2`** — its `.git` is dead (an interrupted-copy leftover, safe to remove), but its working tree is a real "salary-certificate" feature wired to a **third, distinct Vercel project** (`prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq`, a different team than mission-control's own). Whether that project is even still live is unchecked — ticket 07 on the map, not yet pulled.
2. **Cruft**: ~2.63 GB across 8 backup/archive items, none git-tracked (no repo-bloat risk). 5 are safe-to-delete now; 3 need a quick glance first — notably `_archive-bundles` (855M) contains a deliberate `captain-maid` git-history backup bundle, worth confirming the real repo still has that history before it goes. Full verdicts: ticket 05.
3. **The nested `mission-control/arigeo-hr` duplicate** and the dead git-init artifacts (`captain-maid/app/*`, a nested `arra-oracle-v3/arra-oracle-v3`) are all zero-risk, low-priority removal candidates — nobody's blocked on them.
4. **Fleet-wide git health is unaudited.** Only `mission-control` got the deep "is anything stuck" treatment this session. The other 10 active fleet Oracles, `captain-maid`, `control_fleet`, `arigeo-auth`, `cms-arigeo` haven't been checked for the same class of issue (stuck merges, dangling worktrees, uncommitted staged work).
5. **The outer Workspace repo has its own unrelated uncommitted changes** (modified/deleted files under `ai-orchestrator/`, `auth-portal/`, others), surfaced incidentally by the cruft audit — not scoped or investigated at all yet.

## Process recommendation

Build the Registry generator (referenced by Khun-Oracle's original message as if it already existed — it didn't). Without it, this manual snapshot will be exactly as stale as its predecessors within weeks. Worth a dedicated ticket/session of its own rather than folding into this map.

## Where to pick this up

Full ticket detail, decisions, and evidence: `.scratch/agentic-ai-workspace-map/map.md` and its `issues/` in this repo. Open frontier as of this writing: ticket 07 (third Vercel project), plus everything in the map's "Not yet specified" section.
