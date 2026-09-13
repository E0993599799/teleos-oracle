# Update: PR #109 merged, preview build fully succeeded, testing deploy step

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-pr108-merged-second-duplication-found]] (the second duplication bug this PR fixes)

## What happened

khun-oracle-79 independently pulled run 34777406848's log to confirm the exact
error before acting, then opened [cms-arigeo#109](https://github.com/E0993599799/cms-arigeo/pull/109)
— went with the code-only fix (strip `cd cms-arigeo &&` from root `vercel.json`'s
`buildCommand`/`installCommand`, change `outputDirectory` to `.next`) rather than
touching the Vercel dashboard Root Directory setting, since the code route didn't
need anyone's Vercel dashboard access.

## Review before merging

Diff was minimal and exact:
```diff
-  "buildCommand": "cd cms-arigeo && npm run build:ci",
-  "installCommand": "cd cms-arigeo && npm ci --include=optional",
-  "outputDirectory": "cms-arigeo/.next"
+  "buildCommand": "npm run build:ci",
+  "installCommand": "npm ci --include=optional",
+  "outputDirectory": ".next"
```
Unlike #108 (immediately CLEAN), this PR's merge status was **UNSTABLE** — a
"Strict Build" check (triggered by the `pull_request` event, a real CI test
suite, separate from the manual redeploy pipeline) was still `in_progress`.
Waited for it to go green before merging rather than merging past a pending
check. Passed, then merged (squash, branch deleted).

## Preview build — full success

Ran `vercel-prebuilt-build.yml -f ref=main -f environment=preview` → run
[34778547517](https://github.com/E0993599799/cms-arigeo/actions/runs/34778547517).
**Succeeded completely** — all steps green, artifact produced
(`cms-arigeo-prebuilt-preview`, 27.6MB). Both duplication layers (#108's
job-working-directory one and #109's vercel.json-cd one) are now confirmed fixed.

## Now testing the deploy step

Per the PR's own test plan (build succeeding isn't enough — confirm `vercel
deploy --prebuilt` also works against the resulting artifact layout), running
`vercel-prebuilt-deploy.yml -f build_run_id=34778547517 -f environment=preview`
→ run 34779622378. Still in progress as of this note. **Not touching production
until this deploy step is also confirmed working on preview.**
