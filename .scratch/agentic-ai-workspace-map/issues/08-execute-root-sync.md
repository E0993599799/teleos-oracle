Type: task
Status: open

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
