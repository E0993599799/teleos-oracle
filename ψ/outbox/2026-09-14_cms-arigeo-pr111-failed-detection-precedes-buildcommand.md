# Update: PR #111 merged but build still fails — found the actual mechanism (detection precedes buildCommand)

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-rootdir-confirmed-cleared-inverted-failure.md]] (the inverted failure #111 was meant to fix)

## PR #111 merged

khun-oracle-79 opened [cms-arigeo#111](https://github.com/E0993599799/cms-arigeo/pull/111) —
restored `cd cms-arigeo &&` in `vercel.json`'s `buildCommand`/`installCommand`
(undoing #109's specific change), reverted #110's deploy extraction back to
nesting under `cms-arigeo/`, kept #108 as-is. Also traced *why* the
node_modules trace error happened in the first place:
`cms-arigeo/next.config.mjs` sets `outputFileTracingRoot: dirname` — verified
independently by reading the file myself, confirmed real. Waited for both
"build" and "CodeRabbit" PR checks to pass, merged (squash, branch deleted).

## Still fails — same error as before the fix

Fresh build (`vercel-prebuilt-build.yml -f environment=preview`, run
[34787062608](https://github.com/E0993599799/cms-arigeo/actions/runs/34787062608))
**failed with the identical "No Next.js version detected" error**, even with
`buildCommand` restored to `"cd cms-arigeo && npm run build:ci"`.

## Found the actual mechanism

Log sequencing is the key clue: `Skipping "install" command...` is
*immediately* followed by `Could not identify Next.js version` — **before any
buildCommand line is ever echoed to the log**. Every prior successful build
(when Root Directory=`cms-arigeo` was still set) showed `Detected Next.js
version: 15.4.11` at that exact same log position instead.

**Conclusion**: Vercel CLI's framework auto-detection step scans for
`package.json` at the actual invocation cwd (or via the dashboard Root
Directory setting) — it runs *before* `buildCommand` is even read/executed, so
`buildCommand`'s own `cd cms-arigeo &&` prefix can't influence it at all. Both
#109 (removing the cd) and #111 (restoring the cd) were addressing the wrong
mechanism for this specific failure — buildCommand only matters for what
happens *after* detection succeeds.

## What's likely actually needed (not yet done)

The `vercel build` GitHub Actions step itself probably needs
`working-directory: cms-arigeo` (so cwd is correct for detection) — while
`vercel.json`'s `buildCommand` should NOT have `cd cms-arigeo` (redundant once
cwd is already there). This is a different combination than either #109 or
#111 tried: effectively re-adding `working-directory` to the build workflow's
Vercel-CLI step specifically (which #108 removed), while keeping #108's other
changes (e.g., the deploy-side working-directory removal may still be
independently valid — not yet re-examined against this new understanding).

## Handoff

Sent full mechanism analysis to khun-oracle-79. Not attempting the fix myself.
**Seven rounds into this CI investigation now, still zero successful
end-to-end deploys.** Considering whether to suggest re-adding the Root
Directory dashboard setting as a simpler alternative to further workflow
patches, given how much more reliable it was before Ekkarat's removal — worth
raising if round 8 doesn't land cleanly.
