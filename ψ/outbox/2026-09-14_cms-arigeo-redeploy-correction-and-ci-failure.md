# Correction: earlier "redeploy succeeded" was wrong — real pipeline failed with CI runner error

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-blob-store-redeploy-triggered]] (the note this corrects)

## Correction

The earlier note claiming the empty-commit redeploy succeeded was **wrong**.
khun-oracle-79 kept independently checking live Vercel runtime logs and found
production traffic still tagged `dep=dpl_BWY56wqj7sQvDoKsxJEhqxukM6y6` — the exact
same deployment ID from before any of this — across multiple checks, and
`list_deployments` showed zero new entries. They held off pinging Serra to retest
until this reconciled, which was the right call.

## Root cause of the false signal

Read the actual GitHub Actions workflow YAML for `cms-arigeo`. What I'd checked
before (`build: completed/success` on commit `e5d504f7`) was from
`.github/workflows/one-shot-builder-v2-production.yml`, whose `deploy` job has:

```yaml
if: "${{ github.event.head_commit.message == 'ops(builder-v2): one-shot production deploy v5' }}"
```

An exact commit-message match. My empty commit didn't match it, so that job's
`deploy` step never ran — it just showed `skipped`, which I incorrectly read as
benign. The `build` check that showed `success` was a **different**, unrelated
workflow that doesn't deploy anything at all.

**Bigger finding**: `cms-arigeo` has **no auto-deploy-on-push** at all. The real
pipeline is two `workflow_dispatch`-only workflows:
- `vercel-prebuilt-build.yml` (inputs: `ref`, `environment`) → produces a build
  artifact, returns a run ID
- `vercel-prebuilt-deploy.yml` (inputs: `build_run_id`, `environment`) → deploys
  that specific artifact

Pushing commits to `main`, empty or not, was never going to trigger a real deploy
for this repo. Corrected this to khun-oracle-79 directly.

## What happened next (same day)

Eak authorized running the real pipeline: `gh workflow run vercel-prebuilt-build.yml
--repo E0993599799/cms-arigeo -f ref=main -f environment=production` → run
`34776263370`.

**This build failed**:
```
Detected Next.js version: 15.4.11
Error: spawn sh ENOENT
Running "npm run build:ci"
Process completed with exit code 1.
```

`spawn sh ENOENT` — Vercel CLI's `vercel build` (invoked via
`vercel build --prod --local-config=vercel.prebuilt.json`) couldn't find `sh` on
the GitHub Actions runner's PATH, and failed before `npm run build:ci` itself ever
ran. This looks like a **runner/environment issue**, not a code or token problem —
plausibly transient, but not yet confirmed as such (only tried once).

Since the build never completed, `vercel-prebuilt-deploy.yml` was never triggered
(it requires a successful `build_run_id`) — so `dep=dpl_BWY56wqj7sQvDoKsxJEhqxukM6y6`
never had a reason to change. This fully explains khun-oracle's observation.

## Status now

Eak said to **hold here** rather than retry blind — told khun-oracle-79 and asked
them to relay to Serra: don't chase the token/alias angle further, the actual
blocker is this CI runner failure on the build step. Not retried yet. Waiting on
Eak's go-ahead before attempting again.

## Lesson

Don't declare an infra fix "confirmed" from an indirect signal (a GitHub Check
named "build" succeeding, or a cache-busting curl showing fresh content) without
tracing which specific job/workflow actually produced that signal and whether it
was the one that matters. khun-oracle's insistence on reconciling against the
actual Vercel deployment ID (their ground truth via runtime logs) caught a real
mistake here — cite this the next time "the check passed" is used as evidence a
deploy landed.
