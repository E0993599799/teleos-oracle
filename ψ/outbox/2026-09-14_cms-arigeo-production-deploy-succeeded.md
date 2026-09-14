# Milestone: production build+deploy succeeded, aliased to cms.arigeo.com

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-first-successful-end-to-end-deploy.md]] (the preview-level success this extends to production)

## What happened

Ekkarat asked to run the real `environment=production` build+deploy for the
actual Blob-store retest, now that #113 confirmed the pipeline works
end-to-end on preview.

**Build** (`vercel-prebuilt-build.yml -f environment=production`, run
[34816645228](https://github.com/E0993599799/cms-arigeo/actions/runs/34816645228)):
confirmed via direct log read — `Detected Next.js version: 15.4.11`, pruned
`node_modules` 871MB → 32MB, `Traced dependency files: 1165, copied: 1165,
missing: 0`. Identical outcome to the successful preview run.

**Deploy** (`vercel-prebuilt-deploy.yml -f build_run_id=34816645228
-f environment=production`, run
[34817196102](https://github.com/E0993599799/cms-arigeo/actions/runs/34817196102)):
**succeeded**, and critically:
```
Production      https://cms-arigeo-ngarsgspr-omega-project.vercel.app
▲ Aliased        https://cms.arigeo.com
```
This is aliased to the **real production domain** — not a preview-only URL.
Verified live with a cache-busting curl request: `age: 0`, `x-vercel-cache:
MISS`.

## Not yet verified

The Vercel MCP connector is still disconnected on my end, so I couldn't pull
runtime logs/errors to directly confirm the actual `/api/media` Blob upload
succeeds. Did not attempt an admin-session test upload myself (no CMS admin
credentials, and that's Serra's territory per the original routing note).
Posted to [cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5660441487)
and messaged khun-oracle-79 — this is ready for Serra to do the real image
upload retest now.

## Where this leaves the original issue

This is the first time both halves of the original `#105`/`#106` fix are
genuinely live together in production: the Blob store token (fixed by Eak
directly in the Vercel dashboard, 2026-09-14 early) and a working deploy
pipeline (fixed across #108-#113, this session). The actual proof — a real
image upload succeeding — still depends on Serra's live test, not anything
verifiable from this session alone.
