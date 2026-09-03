Type: grilling
Status: resolved

## Question

mission-control root (the Vercel-deployed repo) is stuck: 110 changed paths in `git status`, including an unresolved merge conflict (`pnpm-lock.yaml`, `tools/LAST_BACKUP_DIR.txt`, both deleted-by-us) left from an interrupted `pull --rebase --autostash`, plus dozens of untracked sibling dirs cluttering status. Meanwhile `mission-control/arigeo-hr` (a separate nested clone of the same remote) is 1 real commit ahead and comparatively clean.

Decide: how does root get unstuck (abort the rebase and re-approach, or resolve the conflict in place), and which copy — root or the nested `arigeo-hr` — becomes the one authoritative checkout going forward? This is production-deploy-adjacent; the actual fix is a separate future execution ticket, but the *approach* needs พี่เอก's call before anyone touches it.

See [CONTEXT.md](../CONTEXT.md) for full background (Workspace repo, mission-control root, arigeo-hr nested entries).

## Answer

A fresh `git fetch` (this session) revealed the situation is simpler than the question assumed: **root has zero commits of its own not already in `origin/main`** — `git rev-list --left-right --count HEAD...origin/main` returns `0  5`. Origin/main's tip (`65ee5fe feat(ess): employee self-service payslip view`) is exactly nested `arigeo-hr`'s HEAD. So there's no real divergence between root and the nested copy to reconcile — root is simply 5 commits stale, carrying local uncommitted mess (the 2 conflicted files, the staged Omega feature, and 2 minor modified build files) that made it look worse than it is.

**Decided (พี่เอก, this session):**
1. **Approach**: sync root fully to `origin/main` once its local state is cleared — no merge/reconciliation needed, since root has nothing unique to preserve.
2. **The 2 conflicted files** (`pnpm-lock.yaml`, `tools/LAST_BACKUP_DIR.txt`, both deleted-by-us from a failed autostash pop): accept both deletions. Consistent with the npm-based CI tooling already built for arigeo-hr (no `pnpm-workspace.yaml`, no `packageManager` field) — `pnpm-lock.yaml` is leftover debris.
3. **Omega** blocks this sync (staged, uncommitted) — resolved immediately after via ticket 02, same session, rather than leaving root half-fixed.
4. **Nested `arigeo-hr`**: left as-is for now. Zero-risk (no unique commits), not urgent to remove — flagged as a "safe to remove later" candidate rather than decided today.

**Not yet done**: this ticket recorded the decision, not the execution — actually running the git commands (accept deletions, resolve/handle Omega per ticket 02, pull to sync) needs its own task ticket per this map's "decide, don't execute during charting/decision tickets" convention. See ticket 08.
