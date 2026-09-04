Type: research
Status: resolved

## Question

`mission-control` root (ticket 01/08) was found stuck: an unresolved merge conflict plus staged-but-uncommitted work, discovered only because it happened to be the repo already under investigation. No other repo in the Workspace has been checked for the same class of issue. Audit for: unresolved merge conflicts, staged-but-never-committed work sitting for an extended period, broken/orphaned git worktrees, and significant divergence from `origin` (ahead/behind counts worth flagging).

Scope — repos not yet individually audited by this effort:
- `mission-control/captain-maid`, `mission-control/control_fleet`, `mission-control/arigeo-auth`, `mission-control/cms-arigeo` (the arigeo family + captain-maid, only shallow-inventoried in the Registry so far)
- `royal-master-oracle/{aris,codex,dheva,khun,lens,luxi,serra,stratum,verity,warden}-oracle` (10 fleet Oracle repos)
- `royal-master-oracle/all-oracle`, `royal-master-oracle/agent-brain` (purpose still unclear — note what they even are while checking)

Out of scope: `teleos-oracle` itself (this repo, already known-healthy), the 4 `royal-master-oracle/_archived-*` repos (archived, not active), anything already covered by tickets 01–11.

Produce a per-repo verdict (clean / needs-attention, with specifics) — not fixes. Any repo found stuck or with real recoverable work at risk graduates its own ticket, same pattern as ticket 01/02/04 did for mission-control. Resolve by calling the Skill tool with "research" (or dispatch parallel subagents per repo group, given the size).

See [CONTEXT.md](../CONTEXT.md), map.md "Not yet specified".

## Answer

14 repos audited via 3 parallel read-only subagents (2026-09-05). **11 clean, 3 needs-attention, none as severe as mission-control root was.**

**Clean (11)**: `captain-maid`, `aris-oracle`, `codex-oracle`, `dheva-oracle`, `khun-oracle` (actively-in-use, same-day commit, in sync), `lens-oracle`, `luxi-oracle` (actively-in-use, 1 clean unpulled commit, no divergence), `serra-oracle`, `stratum-oracle`, `verity-oracle`, `warden-oracle`. No merge conflicts, no stale staged work, no broken worktrees in any of these.

**Purpose identified while auditing** (previously unclear): `all-oracle` — "Fleet Scribe + Memory Coordinator," budded from `tham`, reports to Zeus. `agent-brain` — a private memory-hygiene store deliberately kept outside `mission-control` so no repo can accidentally sweep it up via `git add` (references incident `INCIDENT_2026-07-18_fleet-repo-memory-hygiene.md`). Both clean, both real repos.

**Needs-attention (3), none with unresolved conflicts**:
1. **`control_fleet`** — the closest analog to mission-control root's pattern, though not mid-conflict. Diverged 1 ahead / 3 behind its own production branch (`control-fleet-mvp`, which is origin's HEAD branch — no separate main). ~29 modified files unstaged, dated back to 2026-08-25 (~11 days), **including uncommitted deletion of a whole module** (`src/zeus/*.ts`, 8 files) — real recoverable work at risk if this working tree were ever discarded. Plus 24 untracked files, some dated back to 2026-08-04 (~1 month). **Graduated into ticket 13.**
2. **`arigeo-auth`** — minor. On its feature branch (`feat/portal-app-handoff`, expected — active work), 2 ahead/1 behind `origin/main` (normal feature drift, not alarming), ~1 week of unstaged docs/proof-artifact changes. Not graduated — no risk pattern here, just an active feature branch mid-work.
3. **`cms-arigeo`** — worth a glance, not urgent. On its feature branch (`feat/portal-handoff-login`), 1 ahead but **50 behind `origin/main`** — meaningful drift if `main` is what's actually deployed. No uncommitted work at risk (working tree only ~2 days of unstaged changes). Not graduated as its own ticket — this is a positioning question for whoever owns that branch, not an urgent-recovery situation like `control_fleet`. Noted in map fog for now.

Bottom line: the mission-control root incident (tickets 01/08) was a one-off, not a fleet-wide pattern — no other repo was found mid-conflict. `control_fleet` is the one repo with genuinely at-risk uncommitted work.
