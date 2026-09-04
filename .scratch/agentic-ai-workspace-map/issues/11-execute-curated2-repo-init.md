Type: task
Status: open

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
