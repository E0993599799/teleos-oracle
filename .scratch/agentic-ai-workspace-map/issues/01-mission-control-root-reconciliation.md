Type: grilling
Status: open

## Question

mission-control root (the Vercel-deployed repo) is stuck: 110 changed paths in `git status`, including an unresolved merge conflict (`pnpm-lock.yaml`, `tools/LAST_BACKUP_DIR.txt`, both deleted-by-us) left from an interrupted `pull --rebase --autostash`, plus dozens of untracked sibling dirs cluttering status. Meanwhile `mission-control/arigeo-hr` (a separate nested clone of the same remote) is 1 real commit ahead and comparatively clean.

Decide: how does root get unstuck (abort the rebase and re-approach, or resolve the conflict in place), and which copy — root or the nested `arigeo-hr` — becomes the one authoritative checkout going forward? This is production-deploy-adjacent; the actual fix is a separate future execution ticket, but the *approach* needs พี่เอก's call before anyone touches it.

See [CONTEXT.md](../CONTEXT.md) for full background (Workspace repo, mission-control root, arigeo-hr nested entries).
