Type: grilling
Status: open

## Question

Facts are already gathered (see CONTEXT.md, "mission-control worktree" / "Orphaned worktree"): `mission-control-gh-bridge-adapter` and `mission-control-hermes-watcher-smoke` are git-confirmed prunable and unreferenced anywhere — safe to prune. `mission-control-agent-2`, `mission-control-hermes-watcher`, and `mission-control-issue234-0a` are actively broken (mismatched Windows/WSL worktree-link paths, `fatal: not a git repository`) — each needs either `git worktree repair` (if the work inside is still wanted) or manual removal (if not).

Decide: confirm pruning the 2 safe ones, and for each of the 3 broken ones, repair or remove. (`mission-control-issue-286` is excluded — it's functional with real in-progress work, not a cleanup candidate.)

See [CONTEXT.md](../CONTEXT.md).
