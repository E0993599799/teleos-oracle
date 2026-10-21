---
pattern: A claim of absence ("no callers", "unrelated") must rest on complete, untruncated search output — never on results cut with `head` or a partial file list
date: 2026-10-21
source: rrr: teleos-oracle
concepts: [verification, search, evidence, read-only-audit]
---

# Don't claim absence from truncated search output

In a read-only reconcile of two conflicting scan reports, I ran
`git grep -n -E '<symbols>' | head -30` and then wrote that `forge_truth_events` was
"unrelated to the cockpit" and that `transitionMission` had "no caller in src". Both were
wrong: the matches that disproved them (`truth-reader.mjs:36-40`, `mission.ts:106`) sat
past the cutoff or were in files outside the scoped search. A later full-repo search
corrected it, but only because a background task happened to finish.

## Rules

1. When the conclusion is "X does not exist / is not called", count the matches
   (`| wc -l`) before trimming, and never trim with `head`.
2. Prefer a targeted search per symbol over one OR-pattern across everything; a short
   output for one symbol is easy to read completely.
3. Two same-named things (here `transitionMission` in three modules, `khun-oracle` as both
   a repo and a folder) are the usual source of a "conflicting reports" situation. List
   every definition before comparing claims.
4. For "what is live right now", check the process's real working directory
   (`readlink /proc/<pid>/cwd`) — identical command lines (`server.ts`) can be different
   programs.
