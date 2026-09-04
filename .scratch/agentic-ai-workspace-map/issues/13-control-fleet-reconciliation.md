Type: grilling
Status: resolved

## Question

`control_fleet` (ticket 12) diverged 1 ahead / 3 behind its own production branch `control-fleet-mvp` (origin's HEAD branch — no separate main). ~29 modified files sit unstaged, dated back to 2026-08-25 (~11 days), **including an uncommitted deletion of a whole module** (`src/zeus/*.ts`, 8 files) — real work (or a real intentional removal) at risk if this working tree were ever discarded, reset, or cleaned. Plus 24 untracked files, some dated back to 2026-08-04 (~1 month).

Decide: is the `src/zeus/*` deletion intentional (module being removed) or accidental/in-progress (should be restored)? How should the 3-behind divergence and the month of untracked accumulation be reconciled — commit what's wanted, discard what isn't, pull the missing 3 commits? This is a LINE/webhook bot (per earlier findings) — confirm whether it's currently live/serving traffic before deciding how aggressively to touch it.

See [CONTEXT.md](../CONTEXT.md), ticket 12.

## Answer

Investigation before deciding: the `src/zeus/*` deletion was intentional — confirmed by `ZEUS_CLI_QUICK_START.md` (documenting an already-set-up replacement `scripts/zeus-cli.mjs`) and the local-only commit `996e0e9 feat: Zeus CLI tool for direct oracle communication`. The uncommitted working tree turned out to be the completion of a **fleet-wide Zeus→Khun rename** (matching a rename already seen elsewhere in `mission-control` root's reflog this session) — 77 files, including a genuine `src/zeus → src/khun-oracle` directory rename (git-detected) plus substantial new subsystems with their own tests (`notification-outbox`, `notification-worker`, `supervisor`, `process-cleanup`, `routing/`).

**Decided (พี่เอก, this session):** ready, commit it.

**Executed 2026-09-05:**
1. Secret-scanned all changed/new files first (clean — `.env.example`'s diff was just var renames, all placeholder values).
2. Committed all 77 files (`fd96485`).
3. Merged with `origin/control-fleet-mvp`'s 3 unique commits — 1 real conflict in `scripts/line-github-inbox.mjs` (5 hunks). Investigated before resolving: HEAD's generalized `agentTargets`/`requestedAgent()` routing was a verified-correct superset of origin's simpler inline version — confirmed `luxi`'s real tmux session is `44-luxi` (per this session's own `ListAgents` output), matching HEAD, not origin's stale `02-luxi`. Kept HEAD for 4 hunks; **unioned** the 5th (origin had added a `"khun report status"` short-phrase variant HEAD didn't have — kept both instead of picking a side). Confirmed with พี่เอก before applying.
4. Completed the merge (`01de5d9`), verified 0 remaining divergence, syntax-checked the resolved file.
5. Pushed to `origin/control-fleet-mvp` (`4e1191d..01de5d9`), พี่เอก's go-ahead (live webhook bot).

`control_fleet` is now fully reconciled — no uncommitted work, no divergence from origin.
