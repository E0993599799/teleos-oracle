Type: task
Status: resolved

## Question

Execute the decision recorded in tickets 01 and 02: bring `mission-control` root in sync with `origin/main`, without touching Omega.

Concretely (in `mission-control` root):
1. Resolve the two DU (deleted-by-us) conflicts by accepting the deletion: `git rm pnpm-lock.yaml tools/LAST_BACKUP_DIR.txt`.
2. **Do not touch `Omega/`** — leave its staged/untracked state exactly as-is (per ticket 02, it's Serra-oracle's separate, Eak-approved work-in-progress).
3. Confirm the two minor modified files (`next-env.d.ts`, `package-lock.json`) are safe no-ops (build artifacts) before including/excluding them from any commit — don't assume.
4. Sync to `origin/main` (root is 0 ahead / 5 behind — a plain fast-forward pull should suffice once the working tree is clean of the above, but verify no other local changes get swept up).
5. Confirm afterward: `git status` clean (aside from Omega and the untracked nested-repo directories, which are expected), `git log -1` matches `origin/main`'s tip.

This is production-deploy-adjacent (root is what's live on Vercel for `prj_hfdIL1BYKitpZTxpH5EixAputdzQ`) — confirm with พี่เอก before running, per this map's Notes, even though the approach is already decided.

See [CONTEXT.md](../CONTEXT.md), ticket 01, ticket 02.

## Answer

Executed 2026-09-04, พี่เอก's go-ahead. Verified current state first (unchanged since tickets 01/02 closed: still 0 ahead / 5 behind, same 2 conflicts). Steps:

1. `git rm pnpm-lock.yaml tools/LAST_BACKUP_DIR.txt` — resolved both DU conflicts by accepting the deletions.
2. Confirmed neither of the 2 locally-modified files (`next-env.d.ts`, `package-lock.json`) was touched by the 5 incoming commits (`git diff --name-only HEAD origin/main` — no match) — safe to leave as local diffs through the pull, no stash needed.
3. `git pull --ff-only origin main` — succeeded cleanly (17 files, +478/-32).
4. Verified: `HEAD` (`65ee5fe`) now exactly matches `origin/main`'s tip. No conflicts remain. Omega's staged/untracked content is byte-for-byte unchanged (untouched, as required). The 2 build-artifact modifications remain as local uncommitted diffs, exactly as before.

Root is no longer stuck. Nothing was pushed (root was already behind, not ahead — this was a pull-only sync). Nested `arigeo-hr` remains the noted "safe to remove later" candidate, still not acted on.
