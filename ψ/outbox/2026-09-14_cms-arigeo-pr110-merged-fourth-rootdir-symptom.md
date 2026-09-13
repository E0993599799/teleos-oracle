# Update: PR #110 merged, deploy got furthest yet, fourth symptom of the same root cause

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-third-duplication-bug-in-deploy-workflow]] (the bug #110 fixes)

## PR #110 merged

khun-oracle-79 independently confirmed the exact 4-layer-path error via `gh run
view --log` before acting, opened
[cms-arigeo#110](https://github.com/E0993599799/cms-arigeo/pull/110) — two fixes
in `vercel-prebuilt-deploy.yml`: flat tar extraction (no more manufactured
`cms-arigeo/` folder, matching #109's new flat build layout) and removed the
`working-directory: cms-arigeo` from the deploy step. Diff verified minimal and
exact. Waited for the "Strict Build" PR check (pending → pass), merged (squash,
branch deleted).

## Full pipeline retest — furthest progress yet, but a new (related) failure

Fresh build (`vercel-prebuilt-build.yml`, run
[34780037099](https://github.com/E0993599799/cms-arigeo/actions/runs/34780037099))
succeeded. Chained straight into deploy (`vercel-prebuilt-deploy.yml`, run
[34780300501](https://github.com/E0993599799/cms-arigeo/actions/runs/34780300501))
— **first time the deploy step got past path resolution entirely** (log shows
`Deploying omega--project/cms-arigeo` — real progress). Then failed:
```
Error: Please ensure project dependencies have been installed:
File does not exist: "cms-arigeo/node_modules/@swc/helpers/_/_interop_require_default/package.json"
```

## Root cause — same class, 4th surfacing

The Vercel *project's own dashboard* Root Directory=`cms-arigeo` setting is
still in effect. Even with #110's fix (deploy step runs `vercel deploy
--prebuilt` from repo root, no working-directory override), the Vercel CLI
itself applies that dashboard setting during deploy, looking for
`cms-arigeo/node_modules/...` — which doesn't exist because the artifact's
layout is now flat (no `cms-arigeo/` prefix at all, per #110's extraction fix).

This is the exact same duplication class surfacing a **4th time**: job
working-directory (#108) → vercel.json's own `cd` (#109) → deploy's artifact
extraction + working-directory (#110) → now deploy-time dependency-path
resolution, still driven by the same dashboard setting. Three patches in, the
actual root cause — the dashboard Root Directory setting conflicting with
every repo-root-relative operation — was never removed, so it keeps resurfacing
somewhere new.

## Decision

Recommended fixing the actual source this time instead of patching a 5th
symptom. **Eak agreed** and is going into the Vercel dashboard himself
(`https://vercel.com/omega--project/cms-arigeo/settings` — the exact URL
Vercel's own error message provides) to clear the Root Directory setting
entirely. No tool in my Vercel MCP connector can do this (checked — only
deployment-protection settings are exposed, nothing for build/root-directory
config), so this needs Eak's direct dashboard action, same as the earlier Blob
store fix.

Flagged to khun-oracle-79 for awareness/independent verification once cleared.
**Once Eak confirms**, will rerun the full build+deploy preview pipeline from
scratch — if this really is the root cause, this should be the run that finally
works end to end.
