---
pattern: Apply a peer's DO-NOT list to the discovery scope before running, and never judge a Windows-created git worktree "dead" from WSL git alone
date: 2026-10-21
source: rrr: teleos-oracle
concepts: [scoping, constraints, git-worktree, wsl, cross-os, verification]
---

# Two transferable lessons from a read-only git inventory

## 1. Put the DO-NOT list into the discovery step, not the output filter

I was told "do not touch Hermes" but wrote the repo-discovery `find` to prune only
caches and `node_modules`. It walked into the forbidden directories, ran read-only
`git status`/`du` there, and only afterwards did I filter them out of the report. The
access had already happened. Constraints from whoever gave the task belong in the
*scope definition* (`find -prune`, an allowlist of roots) before the first command runs.

## 2. WSL git cannot follow `D:/…` gitdirs — "non-existent" does not mean dead

A worktree created from Windows stores its gitdir as `D:/path`. Git on WSL cannot open
that, so `git worktree prune --dry-run` reports "gitdir file points to non-existent
location" even though the working tree and the admin dir exist and resolve under
`/mnt/d`. Running `prune` from WSL would delete live metadata.

Before trusting a prune list on a mixed Windows/WSL machine:
- map `X:/` to `/mnt/x/` and re-test existence;
- check the main repo's `.git/worktrees/*/gitdir` for a registration of the same path;
- prefer running prune from the OS that created the worktree.

## Small related traps

- `pgrep -f '<pattern>'` also matches the invoking shell's own command line; piping its
  result to `kill` can kill your own shell. Filter with `ps -eo comm` or check the PID's
  `cmdline` first.
- A filtered/abbreviated `ls` output can mislead counts; take counts from `wc -l`.
