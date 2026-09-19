---
pattern: When auditing many git worktrees for delete-safety, verify with a direct `git status` (look for a `fatal:` prefix) instead of trusting a loop that redirects git's stderr to /dev/null — an orphaned worktree with a dead `.git/worktrees/<name>` registry entry makes every git subcommand fail silently, and a naive line-count check reads that failure as "clean" rather than "unknown."
date: 2026-09-19
source: "rrr: teleos-oracle"
concepts: [git-worktrees, shell-scripting, false-negative, wsl, disk-cleanup, vhdx]
---

## Context

Auditing 30 git worktrees across `~/wt` and `~/.hermes-worktrees` (spread over several
`mission-control` sub-repos) to find safe deletion candidates for a D: drive cleanup. A
shell loop computed `dirty`/`ahead`/`stashes` counts per worktree via
`git status --porcelain 2>/dev/null | wc -l` and similar.

## What happened

For 10 of the 30 worktrees, the `.git` file still pointed at a
`<repo>/.git/worktrees/<name>` registry directory that no longer existed (removed by a
prior `git worktree remove` or manual cleanup that never touched the checkout itself).
Every git subcommand in those directories failed with `fatal: not a git repository`, but
because stderr was redirected to `/dev/null` and the counts came from `wc -l` on the
(empty) stdout, the loop reported `dirty=0`, `ahead=0`, `stashes=0` — indistinguishable
from a genuinely clean, verified-safe worktree. Only a manual spot-check with
`git status` (no stderr suppression) surfaced the `fatal:` line and caught the false
negative before any deletion decision was made on it.

## Why it matters elsewhere

Any audit script that gates a destructive action (delete, force-push, cleanup) on a
count derived from possibly-failed command output needs to distinguish "verified zero"
from "command failed, count defaulted to zero." This is a general shell-scripting trap,
not specific to git or to this repo — the same shape of bug (silent failure read as a
safe/passing state) applies to CI health checks, backup verification, or any "is it safe
to delete" heuristic built on `| wc -l` over a command whose stderr is suppressed.

## Fix / rule of thumb

- Check the exit code of the underlying command explicitly (`git rev-parse --git-dir
  >/dev/null 2>&1 || echo "INVALID"`) before trusting any downstream count from it.
- When stderr must be suppressed for clean output formatting, capture it to a variable
  instead of `/dev/null` and surface it alongside a zero count, so "verified clean" and
  "check failed" never render identically.
- Before a bulk destructive action based on an audit table, spot-check a few "looks safe"
  rows by hand with the un-suppressed command — cheap insurance against exactly this
  class of false negative.
