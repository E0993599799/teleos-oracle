Type: grilling
Status: open

## Question

`control_fleet` (ticket 12) diverged 1 ahead / 3 behind its own production branch `control-fleet-mvp` (origin's HEAD branch — no separate main). ~29 modified files sit unstaged, dated back to 2026-08-25 (~11 days), **including an uncommitted deletion of a whole module** (`src/zeus/*.ts`, 8 files) — real work (or a real intentional removal) at risk if this working tree were ever discarded, reset, or cleaned. Plus 24 untracked files, some dated back to 2026-08-04 (~1 month).

Decide: is the `src/zeus/*` deletion intentional (module being removed) or accidental/in-progress (should be restored)? How should the 3-behind divergence and the month of untracked accumulation be reconciled — commit what's wanted, discard what isn't, pull the missing 3 commits? This is a LINE/webhook bot (per earlier findings) — confirm whether it's currently live/serving traffic before deciding how aggressively to touch it.

See [CONTEXT.md](../CONTEXT.md), ticket 12.
