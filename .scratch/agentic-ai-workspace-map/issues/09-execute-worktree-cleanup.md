Type: task
Status: open

## Question

Execute the decision recorded in ticket 04:

1. `git worktree remove --force mission-control-gh-bridge-adapter` (from `mission-control` root) — registered, git-confirmed prunable.
2. `git worktree remove --force mission-control-hermes-watcher-smoke` — same.
3. Delete `mission-control-agent-2` outright (plain directory, not a real worktree — no `git worktree remove` needed, it's not registered).
4. Delete `mission-control-issue234-0a` outright (same — plain directory).
5. **Do not touch `mission-control-hermes-watcher`** — held pending พี่เอก's own review (ticket 04).
6. **Do not touch `mission-control-issue-286`** — functional, excluded throughout.

Confirm each removal succeeded (`git worktree list` no longer shows 1/2; directories for 3/4 no longer exist) before closing.

See [CONTEXT.md](../CONTEXT.md), ticket 04.
