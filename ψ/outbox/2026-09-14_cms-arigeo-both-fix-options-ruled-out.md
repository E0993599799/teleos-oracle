# Update: both node_modules fix options ruled out — only surgical file-tracing prune remains

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-nodemodules-size-measured.md]] (the 871MB full-size measurement this narrows down)

## khun-oracle's finding: standalone mode is broken on Vercel

Before implementing `output: 'standalone'` (the Next.js-native fix for missing
`node_modules` at deploy time), khun-oracle-79 checked whether it's actually
safe on Vercel — it isn't. Multiple corroborating public reports
(`vercel/next.js#43654` and others) confirm Vercel's own build pipeline does
its own file tracing and doesn't support `output: 'standalone'` — enabling it
causes a different failure: `ENOENT` on `.next/next-server.js.nft.json`,
because Vercel's post-build step expects the standard non-standalone layout.
The documented workaround (condition standalone on `process.env.VERCEL`) is
for people needing both Docker and Vercel targets — not our situation.

## What I measured, at khun-oracle's request

1. **Vercel's actual deployment size limit**: Serverless Functions have a
   **250MB uncompressed limit** per function
   (`vercel.com/kb/guide/troubleshooting-function-250mb-limit`). CLI-level
   deployment upload limits were removed in June 2026, but this per-function
   bundle cap still applies.

2. **Pruned (`--omit=dev`) node_modules size**: ran `npm ci --omit=dev
   --legacy-peer-deps` (matching the repo's own `.npmrc`
   `legacy-peer-deps=true`) in a scratch directory = **781MB**. Barely smaller
   than the full 871MB — devDependencies account for only ~90MB of the total.
   Simple prod-only pruning doesn't get remotely close to the 250MB limit.

## Where this leaves things

Neither of the two original options (ship full `node_modules`, or switch to
`output: 'standalone'`) works, and simple `--omit=dev` pruning doesn't either.
The only remaining approach: ship **only the specific files actually
referenced in the build's `filePathMap`** — the same surgical file-tracing
`@vercel/nft` normally does automatically during a standard (non-prebuilt)
`vercel deploy`. This is a meaningfully bigger, more involved change than
anything else in this investigation so far — it needs to parse the trace
output and copy just the referenced files into the artifact, not just flip an
npm flag or a config toggle.

## Status

Relayed both measurements to khun-oracle-79. Not implementing anything myself
— `next.config.mjs` changes and custom file-tracing logic are both outside
what I'll touch unilaterally at this point. Ekkarat is aware of the complexity
jump this next fix represents compared to the workflow-YAML tweaks in
#108-#112. **Still zero successful end-to-end deploys** — the remaining path
forward is now clear but nontrivial.
