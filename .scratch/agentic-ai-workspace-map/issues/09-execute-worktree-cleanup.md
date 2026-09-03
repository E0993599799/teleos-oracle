Type: task
Status: resolved

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

## Answer

Executed 2026-09-04, พี่เอก's go-ahead. Re-verified state first (unchanged since ticket 04).

1–2. `git worktree remove --force` failed for both registered worktrees: `fatal: validation failed, cannot remove working tree: '.../gitdir' file does not contain absolute path to the working tree location` — their `gitdir` files hold Windows-style paths (`D:/...`) rather than WSL-absolute paths, which `--force` can't override (this is the real Windows/WSL path-format issue the earlier research misattributed to the 3 orphans instead). Fixed via `git worktree prune -v`, which cleans up registrations git can't validate — succeeded, both gone from `git worktree list`. Then `rm -rf` the two physical directories; confirmed gone.
3–4. `rm -rf` on `mission-control-agent-2` and `mission-control-issue234-0a` (plain directories, never registered) — confirmed gone.
5–6. Confirmed `mission-control-hermes-watcher` and `mission-control-issue-286` still present, untouched.

All 4 removals verified. `git worktree list` now shows only root + `issue-286`.
