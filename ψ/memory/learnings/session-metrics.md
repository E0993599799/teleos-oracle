# Oracle Session Metrics

Rule (parent CLAUDE.md §"Self-Evaluation Loop"): same friction 3 sessions → fix root cause, not another workaround.

| when | session | done | stuck | win | friction | error |
|---|---|---|---|---|---|---|
| 2026-08-27 09:06 | b056ea61 | committed+pushed stale Supabase skills install (43 files, db06acd) | none | closed a 3-week-old uncommitted install found via recap | python3→MS-Store-stub on Windows; /c/... path not readable by native python | repeated failed python3 call after it already failed once earlier same session |
| 2026-08-27 10:18 | b056ea61 | fleet supabase-skills check (clean), Vercel mission-control root-cause traced + reported to khun, maw fixed for native-Windows (wrapper+serve+plugin) | none | maw now reachable fleet-wide from this host, doctor 3->1 issues | maw doctor's plugin-install hint needs an arg it doesn't show; maw plugin ls -v disagrees with doctor on plugin count | shipped a wrapper verified only on trivial single-arg calls before the printf-recycling bug surfaced on a multi-arg test |
| 2026-09-05 01:48 | 466e53ee | mattpocock/skills install (37, committed); wayfinder-charted+worked Agentic AI workspace map (11 tickets resolved: mission-control root synced, 4 worktrees removed, PROJECT_REGISTRY.md+narrative doc written, live-Vercel-project finding on curated2) | ticket 11 (new standalone repo for salary-certificate) blocked on user's interactive gh auth login | caught a stuck production-adjacent repo (merge conflict) and a colleague Oracle's live approved project (Omega) before either got mishandled | skills installer ignored --skill flag; nested-subagent delegation (ticket 05) silently skipped its persistence step, only reported in chat | copied a subagent's specific path-mismatch diagnosis into a ticket without re-verifying at execution time — attributed to the wrong pair of worktrees, caught only when the real command failed |

## 🔁 Fleet-Wide Pattern Note (2026-09-03, via khun-oracle)

The 2026-08-27 09:06 row above ("closed a 3-week-old uncommitted install found via recap")
is one instance of a pattern found recurring across the fleet: acting/reasoning without
first checking current repo state (uncommitted files, branch identity, remote existence).
Confirmed independently in khun-oracle (3/7 sessions), luxi-oracle (self-escalated 6/8
sessions on 2026-08-02/08-28), codex-oracle, and serra-oracle.

**Resolved fleet-wide 2026-09-03**: `~/.claude/RTK.md` now carries a mandatory "Session
Start Protocol" — `git status --short` + `git branch --show-current` as the unconditional
first action of every session. Loaded via `~/.claude/CLAUDE.md`'s `@RTK.md` import, so it
applies here without any change to this repo's own CLAUDE.md. A 3-week-stale uncommitted
install like the 08-27 case should surface immediately at session start going forward,
not get found later via `/recap`.
