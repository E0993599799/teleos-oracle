# Oracle Session Metrics

Rule (parent CLAUDE.md §"Self-Evaluation Loop"): same friction 3 sessions → fix root cause, not another workaround.

| when | session | done | stuck | win | friction | error |
|---|---|---|---|---|---|---|
| 2026-08-27 09:06 | b056ea61 | committed+pushed stale Supabase skills install (43 files, db06acd) | none | closed a 3-week-old uncommitted install found via recap | python3→MS-Store-stub on Windows; /c/... path not readable by native python | repeated failed python3 call after it already failed once earlier same session |
| 2026-08-27 10:18 | b056ea61 | fleet supabase-skills check (clean), Vercel mission-control root-cause traced + reported to khun, maw fixed for native-Windows (wrapper+serve+plugin) | none | maw now reachable fleet-wide from this host, doctor 3->1 issues | maw doctor's plugin-install hint needs an arg it doesn't show; maw plugin ls -v disagrees with doctor on plugin count | shipped a wrapper verified only on trivial single-arg calls before the printf-recycling bug surfaced on a multi-arg test |
