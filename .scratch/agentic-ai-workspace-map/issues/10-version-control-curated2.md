Type: grilling
Status: resolved

## Question

`mission-control-vercel-curated2`'s working tree is confirmed (ticket 07) to be the **only known source for a live Vercel deployment** (`prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq`, พี่เอก's personal Vercel account) — a "salary-certificate" Next.js feature. It currently has zero real version control: its `.git` is an inert leftover (ticket 03: 8KB, no object database, an interrupted-copy artifact). One accidental `rm -rf` away from being unrecoverable, with no history to fall back on.

Decide: how should this get real version control — a fresh standalone repo (pushed to a new remote under which account?), folded into an existing related repo, or something else? Is this feature meant to stay a small standalone thing, or does it belong inside one of the arigeo family / mission-control proper?

See [CONTEXT.md](../CONTEXT.md), ticket 03, ticket 07.

## Answer

Investigation before asking: the working tree's `package.json` identifies it as `"mission-control"` — "Marcuzx Forge local control and observability host" — matching the outer Workspace repo's own identity, not ARIGEO HR. So it's not an arigeo-hr ESS duplicate; it looks like a diverged snapshot/fork of a separate personal app, with the `salary-certificate` feature added on top.

**Decided (พี่เอก, this session):**
1. **`salary-certificate` gets its own standalone repo** — it's its own product, not folded into the Marcuzx Forge control-host app or into arigeo-hr. Matches its live personal-account Vercel deployment.
2. **Separately** (new work, not this ticket): พี่เอก wants a salary-certificate-*like* feature built into arigeo-hr's ESS module too, but with different field/detail requirements than the standalone product — a distinct implementation, not a copy. This is genuine new product development, out of scope for this map (which is inventory/cleanup, not feature-building) — noted as a follow-up outside this effort, not ticketed here.

Execution (init a real repo, push, from this working tree) graduated into ticket 11.
