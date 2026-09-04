Type: research
Status: open

## Question

`mission-control` root (ticket 01/08) was found stuck: an unresolved merge conflict plus staged-but-uncommitted work, discovered only because it happened to be the repo already under investigation. No other repo in the Workspace has been checked for the same class of issue. Audit for: unresolved merge conflicts, staged-but-never-committed work sitting for an extended period, broken/orphaned git worktrees, and significant divergence from `origin` (ahead/behind counts worth flagging).

Scope — repos not yet individually audited by this effort:
- `mission-control/captain-maid`, `mission-control/control_fleet`, `mission-control/arigeo-auth`, `mission-control/cms-arigeo` (the arigeo family + captain-maid, only shallow-inventoried in the Registry so far)
- `royal-master-oracle/{aris,codex,dheva,khun,lens,luxi,serra,stratum,verity,warden}-oracle` (10 fleet Oracle repos)
- `royal-master-oracle/all-oracle`, `royal-master-oracle/agent-brain` (purpose still unclear — note what they even are while checking)

Out of scope: `teleos-oracle` itself (this repo, already known-healthy), the 4 `royal-master-oracle/_archived-*` repos (archived, not active), anything already covered by tickets 01–11.

Produce a per-repo verdict (clean / needs-attention, with specifics) — not fixes. Any repo found stuck or with real recoverable work at risk graduates its own ticket, same pattern as ticket 01/02/04 did for mission-control. Resolve by calling the Skill tool with "research" (or dispatch parallel subagents per repo group, given the size).

See [CONTEXT.md](../CONTEXT.md), map.md "Not yet specified".
