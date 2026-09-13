# Correction: removing Vercel dashboard Root Directory did NOT fix the node_modules error

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-pr110-merged-fourth-rootdir-symptom.md]] (the theory this corrects)

## What happened

Eak cleared the Vercel project's dashboard Root Directory setting (was
`cms-arigeo`, now blank) per the working theory that it was the recurring
root cause. Reran the full pipeline from scratch:

- Build: `vercel-prebuilt-build.yml -f environment=preview` → run
  [34784597958](https://github.com/E0993599799/cms-arigeo/actions/runs/34784597958)
  — **succeeded**. Sanity-checked the log before chaining to deploy per
  khun-oracle-79's warning that #109/#110 might now be wrong in the opposite
  direction — nothing looked off (`npm run build:ci` ran and completed cleanly,
  `.vercel/output` produced).
- Deploy: `vercel-prebuilt-deploy.yml -f build_run_id=34784597958
  -f environment=preview` → run
  [34784920244](https://github.com/E0993599799/cms-arigeo/actions/runs/34784920244)
  — **failed with the exact same error as before the dashboard change**,
  byte-for-byte:
  ```
  Deploying omega--project/cms-arigeo
  Error: Please ensure project dependencies have been installed:
  File does not exist: "cms-arigeo/node_modules/@swc/helpers/_/_interop_require_default/package.json"
  ```

## Why this matters

An identical error before and after the dashboard change is more informative
than a *different* error would have been: it proves Root Directory was never
the cause of this specific symptom. The theory built up over #108→#110 (every
failure traces to the same Root-Directory-duplication class) was wrong for
this last one.

## Actual likely cause (not yet fixed)

The build's npm-based steps (`npm ci`, `npm run build:ci`) still run with
explicit `working-directory: cms-arigeo` on each step individually — #108's
diff only removed the *job-level* default, deliberately keeping per-step
overrides on the npm/test steps. So `node_modules` genuinely lives at
`cms-arigeo/node_modules` during the build, and Next.js's serverless-function
dependency trace bakes that literal path into `.vercel/output`'s manifest.
#110 then changed the deploy step to extract the artifact **flat** (no
`cms-arigeo/` folder at all) — so the trace's `cms-arigeo/node_modules/...`
reference has nothing to resolve against.

This is a mismatch between where the build actually executes (inside
`cms-arigeo/`) and how the artifact gets unpacked at deploy time (flat),
**independent of the Root Directory dashboard setting**. Two possible fixes,
neither attempted:
1. Revert #110's flat extraction back to nesting under `cms-arigeo/` (matching
   where the build actually ran and what the trace file expects), or
2. Stop the build's npm steps from using `working-directory: cms-arigeo` too,
   so node_modules ends up at repo root matching the flat deploy layout
   (harder — needs `npm --prefix cms-arigeo` or similar since `package.json`
   only exists inside that subfolder).

## Status

Root Directory is now blank on the dashboard — probably fine to leave that way
(no evidence it caused a regression), but it is **not** what will fix this.
Flagged to khun-oracle-79 as the owner of this fix chain. Not attempting a
fix myself. **Production still untouched.** Five rounds into this CI pipeline
investigation and the Blob store token itself remains completely unexercised.
