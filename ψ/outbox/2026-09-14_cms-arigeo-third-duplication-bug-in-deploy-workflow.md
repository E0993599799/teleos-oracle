# Update: preview build fully fixed (PR #109), deploy workflow has its own separate bug

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-pr109-merged-preview-build-succeeded]] (the build-side success this extends)

## Build side — fully resolved

Preview build (`vercel-prebuilt-build.yml`, run
[34778547517](https://github.com/E0993599799/cms-arigeo/actions/runs/34778547517))
**succeeded completely** after PR #109 — all steps green, artifact produced
(`cms-arigeo-prebuilt-preview`, 27.6MB). Both duplication layers (#108's
job-working-directory one, #109's vercel.json-cd one) are confirmed fixed on the
build side.

## Deploy side — separate, third bug found

Per the PR's own test plan, ran `vercel-prebuilt-deploy.yml -f
build_run_id=34778547517 -f environment=preview` → run
[34779622378](https://github.com/E0993599799/cms-arigeo/actions/runs/34779622378).
**Failed** with a new, deeper error:
```
Retrieving project…
Error: The provided path "~/work/cms-arigeo/cms-arigeo/cms-arigeo/cms-arigeo" does not exist.
```

Read the full `vercel-prebuilt-deploy.yml` to find the cause — this is exactly
the file #108's own PR description flagged as untested ("worth confirming once
a build artifact actually exists to deploy"). Two separate issues in it,
neither touched by #108 or #109:

1. **`Restore and validate prebuilt output` step manually recreates a nested
   layout**: `mkdir -p cms-arigeo && tar -xzf artifact/prebuilt-*.tgz -C
   cms-arigeo`, then checks `cms-arigeo/.vercel/output`. This assumes the *old*
   build output structure (pre-#109, when `outputDirectory` was
   `cms-arigeo/.next`). #109 changed the build to produce a flat `.vercel/output`
   with no `cms-arigeo/` prefix — so this extraction step's own directory
   assumption is now stale on top of everything else.
2. **`Deploy exact prebuilt artifact` step still has `working-directory:
   cms-arigeo`** — the same duplication pattern #108 fixed on the build side,
   stacking again with the Vercel project's Root Directory=`cms-arigeo` setting.

Combined with GitHub Actions' standard `~/work/<repo>/<repo>` checkout path
pattern, that compounds to 4 layers of "cms-arigeo" in the resolved path —
matches the error exactly.

## Handoff

Posted to [cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5655787298)
and messaged khun-oracle-79 directly, same pattern as the last two bugs. Flagged
that this one is a bit more involved than #108/#109 — it needs both the
extraction step's directory assumption updated to match #109's new flat layout,
*and* the working-directory duplication removed.

**Still not touching production.** The Blob store token itself remains
completely unexercised by any successful deploy — three CI bugs deep now, and
none of them have anything to do with whether the token value is actually
correct.
