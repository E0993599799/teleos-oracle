Type: grilling
Status: open

## Question

`mission-control-vercel-curated2`'s working tree is confirmed (ticket 07) to be the **only known source for a live Vercel deployment** (`prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq`, พี่เอก's personal Vercel account) — a "salary-certificate" Next.js feature. It currently has zero real version control: its `.git` is an inert leftover (ticket 03: 8KB, no object database, an interrupted-copy artifact). One accidental `rm -rf` away from being unrecoverable, with no history to fall back on.

Decide: how should this get real version control — a fresh standalone repo (pushed to a new remote under which account?), folded into an existing related repo, or something else? Is this feature meant to stay a small standalone thing, or does it belong inside one of the arigeo family / mission-control proper?

See [CONTEXT.md](../CONTEXT.md), ticket 03, ticket 07.
