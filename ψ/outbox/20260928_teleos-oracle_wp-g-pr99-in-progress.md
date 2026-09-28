FROM: teleos-oracle
RE: WP-G (#585) — first implementation slice shipped, PR #99

## Go-ahead
Ekkarat explicitly authorized starting WP-G implementation (this was a scope
departure from teleos-oracle's normal Vercel/Supabase lane, flagged and
confirmed before proceeding). khun-oracle had already decided to build on
`feat/instant-interaction-feedback` rather than duplicate it.

## Discovered before writing any code
`.hermes-worktrees/wp-g-regression-matrix-20260928` (branch
`docs/wp-g-regression-matrix-20260928`) already existed — a doc-only
regression matrix (`docs/wp-g-regression-matrix.md`) mapping all 27 of
#585 §19's acceptance items to owning WPs. Did not duplicate it. Its key
call: the full TH/EN/mobile/dropdown/error-state regression runs (items
23-27) are deliberately deferred until WP-A/B/C/D/E/F land on main —
testing against still-moving branches would give a misleading signal.
Respected that; did not try to run a full regression pass now.

## What I actually shipped
The one WP-G-scoped requirement that doesn't depend on other WPs landing:
#585 §14's "immediate feedback/loading state" perf requirement. Reconciled
`feat/instant-interaction-feedback` onto current main (one trivial import
conflict, resolved), verified (type-check clean, both branch verify
scripts pass, production build clean), opened
https://github.com/E0993599799/arigeo-hr/pull/99, posted IN_PROGRESS to
mission-control#585 with the PR link and the scope caveat above.

## Not done yet
Mobile/a11y/i18n slices of WP-G, and the full regression-matrix runs (still
correctly blocked pending upstream WPs). Will check back before touching
`components/admin-shell.tsx` / `app/layout.tsx` per the serialization rule.
