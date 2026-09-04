Type: task
Status: resolved

## Question

Execute the decision recorded in ticket 10: give `mission-control-vercel-curated2`'s working tree (the live "salary-certificate" feature) its own standalone repo.

Concretely:
1. Remove the inert `.git` leftover first (ticket 03: 8KB, no object database — nothing to lose).
2. Confirm with พี่เอก: new repo name, which GitHub account (personal, matching the personal Vercel deployment — not `E0993599799`), private or public.
3. `git init`, initial commit of the current working tree content, create the remote (`gh repo create` or ask พี่เอก to create it), push.
4. Confirm with พี่เอก whether to re-link the existing live Vercel project (`prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq`) to the new repo's Git integration (so future deploys are triggered by push instead of however it's currently being deployed), or leave Vercel's deployment method as-is for now.
5. Once pushed, confirm `mission-control-vercel-curated2` can be renamed/relocated out of the Workspace root's flat listing if desired (not required, just tidiness) — separate, optional, not blocking.

This touches a live production deployment (personal account) — confirm each step with พี่เอก before executing, not just the overall decision.

See [CONTEXT.md](../CONTEXT.md), ticket 03, ticket 07, ticket 10.

## Answer

Executed 2026-09-04/05, พี่เอก's go-ahead. `gh auth login` added under `E0993599799` (confirmed correct — not a separate personal account after all, per พี่เอก).

1. Removed the inert `.git` leftover (8KB, no object database — confirmed nothing lost).
2. Confirmed: repo name `salary-certificate`, account `E0993599799`, private.
3. `git init`, reviewed the full staged file list for secrets before committing (none found — `.vercel/project.json` has only non-secret IDs, `supabase.ts` reads credentials from env vars, no `.env*` files present), initial commit, `gh repo create E0993599799/salary-certificate --private --source=. --push`. Pushed: **https://github.com/E0993599799/salary-certificate**.
4. **Skipped, per พี่เอก** — re-linking Vercel's Git integration would change the live, smoothly-running deployment's trigger behavior (auto-deploy on push), which is a real production behavior change, not something to do just because it was on the original checklist. The actual goal (real version control so it's not one `rm -rf` from unrecoverable) is already achieved without it.
5. Not done — optional tidiness, not pursued.

Note: first commit attempt in `mission-control` (for the unrelated v2 plan files, same session) accidentally swept in Serra-oracle's already-staged Omega files; caught immediately via `git show --stat`, reversed with `git reset --soft HEAD~1` before it could cause any real problem — logged here since it happened during the same working session, not because it touched this ticket's own repo.
