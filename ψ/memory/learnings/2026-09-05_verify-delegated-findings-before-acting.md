---
pattern: A delegated subagent's finding is a claim to re-verify at the moment it becomes load-bearing, not a fact to carry forward silently
date: 2026-09-05
source: rrr: teleos-oracle
concepts: [subagent-delegation, verification, wayfinder, worktree]
---

# Verify delegated findings before acting on them, not just before reporting them

While charting a wayfinder map, a research subagent reported that 3 orphaned git worktrees had "mismatched Windows/WSL worktree-link paths." That specific claim got copied into a decision ticket as fact. During execution days later, `git worktree remove --force` failed on a *different* pair of worktrees — the ones the ticket had filed as simply "safe to prune." The real path-mismatch problem was on those two, not the three orphans. No harm done (the failure surfaced before anything broke), but the wrong diagnosis rode untouched through a full grilling round, a written decision, and a graduated execution ticket before reality corrected it.

**Why**: a subagent's finding gets treated as settled once it's been "verified before reporting" (i.e., cross-checked at gathering time), but a technical claim about system state (a path format, a file's git status, whether something is prunable) can still be correct-when-gathered and wrong-by-the-time-it's-acted-on, or simply mis-transcribed on the way into a ticket. Re-verifying only at the reporting boundary isn't enough for anything that becomes the basis of a real action later.

**How to apply**: when a ticket, plan, or decision is about to trigger an actual mutating command (delete, force-remove, merge, resolve-conflict), re-check the *specific* technical claim it rests on with a fresh, direct command — not just "does the overall conclusion still seem right," but "is this exact fact (this path, this status, this file) still true right now." Cheap to do, and it's exactly the moment a stale or transcribed-wrong detail would otherwise slip through unnoticed.
