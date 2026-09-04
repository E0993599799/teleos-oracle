Type: grilling
Status: resolved

## Question

Facts are already gathered (see CONTEXT.md, "mission-control worktree" / "Orphaned worktree"): `mission-control-gh-bridge-adapter` and `mission-control-hermes-watcher-smoke` are git-confirmed prunable and unreferenced anywhere — safe to prune. `mission-control-agent-2`, `mission-control-hermes-watcher`, and `mission-control-issue234-0a` are actively broken (mismatched Windows/WSL worktree-link paths, `fatal: not a git repository`) — each needs either `git worktree repair` (if the work inside is still wanted) or manual removal (if not).

Decide: confirm pruning the 2 safe ones, and for each of the 3 broken ones, repair or remove. (`mission-control-issue-286` is excluded — it's functional with real in-progress work, not a cleanup candidate.)

See [CONTEXT.md](../CONTEXT.md).

## Answer

Correction from further investigation: the 3 "broken" ones aren't a path-format issue — `mission-control/.git/worktrees/` has no entries for `agent-2`, `hermes-watcher`, or `issue234-0a` at all (only `gh-bridge-adapter`, `hermes-watcher-smoke`, `issue-286` are registered). Their worktree registration was fully removed at some point; they're plain directories now with a dangling `.git` pointer file — nothing inside them is protected by git in any way. `git worktree repair` has nothing to repair against.

Content check before deciding: `agent-2` is stale (governance PowerShell scripts, nothing past Aug 1). `issue234-0a` is just a failed test-run log (`BLOCKED_TOOLING`) — diagnostic noise. `hermes-watcher` has at least one file not found anywhere else in the real `royal-master-oracle` tree (`install-hermes-github-watcher-task.ps1`, a Windows Task Scheduler installer) plus a `ψ/teams/mission-control-probe-tests.yaml` config, also not found elsewhere.

**Decided (พี่เอก, this session):**
1. Remove `mission-control-gh-bridge-adapter` and `mission-control-hermes-watcher-smoke` (registered, git-confirmed prunable) — `git worktree remove --force` each.
2. Delete `mission-control-agent-2` outright (stale, no unique content).
3. Delete `mission-control-issue234-0a` outright (just a failed test log).
4. **Hold off on `mission-control-hermes-watcher`** — leave it alone. It has uniquely-located content (the installer script, the team config) worth พี่เอก's own 30-second glance before anything happens to it, rather than a blanket delete.
5. `mission-control-issue-286` untouched throughout — functional, real in-progress work, never a cleanup candidate.

Execution (the actual `git worktree remove` / `rm -rf` calls for items 1–3) graduated into ticket 09.

**Follow-up (2026-09-05):** พี่เอก reviewed `hermes-watcher`'s held-back content. Confirmed real and wanted — it's the `khun-runtime` toolkit (15 files: health checks, start/send-to scripts, the Hermes GitHub watcher Task Scheduler installer), which existed only in this orphaned worktree and nowhere in the real tree. Recovered into `royal-master-oracle/tools/khun-runtime/` (commit `3de5bc1`, pushed). The orphaned `mission-control-hermes-watcher` directory itself is now redundant (its unique content is safely committed) — same disposition as the other two orphans, not yet deleted, see below.
