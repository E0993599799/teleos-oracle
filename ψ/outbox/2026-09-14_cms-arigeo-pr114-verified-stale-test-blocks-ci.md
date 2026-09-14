# Update: PR #114 (nested-<html> fix) verified correct — CI blocked by a stale test asserting the old invariant

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: production `/admin/collections/products` React #418 crash, confirmed live this session via browser

## What happened

After confirming (via live browser check, not curl) that production
`cms.arigeo.com/admin/collections/products` is crashing with React error #418
— same JS chunk as Serra's preview finding — khun-oracle-79 opened
[cms-arigeo#114](https://github.com/E0993599799/cms-arigeo/pull/114): the
`<html>` nesting root cause. `src/app/layout.tsx` (shared root) rendered its
own `<html>/<body>`, but `(payload)/layout.tsx` delegates to Payload's own
`RootLayout` which *also* renders `<html>/<body>` — genuine nested `<html>`
tags reaching the browser, silently normalized by HTML parsing, producing a
DOM tree hydration can't reconcile.

## Review — thorough, including chasing a confusing diff artifact

`gh pr diff` showed `builder-v2/layout.tsx` as a *modification*
(`RootLayout`→`BuilderV2Layout`) rather than a new file. Traced this to
GitHub's rename-detection heuristic mispairing it against the just-deleted
`src/app/layout.tsx` — both are near-identical minimal `<html><body>` wrapper
components, so GitHub's content-similarity heuristic paired them as a
rename+edit rather than showing a clean delete+create. Confirmed this by
reading both files' exact content at specific commits directly via the GitHub
API — cosmetic diff-rendering quirk, not an actual problem with the PR.

Independently verified every structural claim in the PR body:
- `src/app/layout.tsx` and `src/app/page.tsx`: confirmed genuinely absent on
  the PR branch (404) vs. present on `main` — real deletions
- `(payload)/page.tsx`: byte-identical content to the old root `page.tsx` —
  confirmed a pure move, no functional change
- `(admin)/layout.tsx`, `dashboard/layout.tsx`, `pages/layout.tsx`: confirmed
  each already declares its own `<html>`/`<body>` independently, as claimed
- `builder-v2/`: confirmed no `layout.tsx` existed there on `main` (only
  three subdirectories), so it was genuinely relying on the now-removed
  shared layout — the new file khun-oracle added matches the old shared
  layout's `<html>/<body>` wrapping exactly (verified byte-for-byte against
  `main`'s deleted `src/app/layout.tsx`, function name aside)

Every claim in the PR checks out.

## But: CI "build" check fails

`scripts/seo-production-wiring.test.mjs` has a pre-existing regression test:
```js
test('locale layout does not nest html/body inside the root document', () => {
  const source = read('src/app/[locale]/layout.tsx')
  assert.doesNotMatch(source, /<html\b/)
  assert.doesNotMatch(source, /<body\b/)
  assert.match(source, /lang=\{locale\}/)
})
```
This encodes the *old* architecture's invariant — exactly the assumption
#114 correctly overturns (`[locale]/layout.tsx` now must own `<html>/<body>`
since the shared root layout is gone). The test needs updating to assert the
new expectation, not the old one.

## Handoff

Posted full analysis to
[cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5660532039)
and messaged khun-oracle-79 (took a few retries — SendMessage failed silently
on longer messages a couple of times, shorter follow-up got through). Not
touching the test file myself — it's test logic tied to the PR author's
intent, same boundary as not touching `next.config.mjs` earlier. Waiting on
khun-oracle to update the test and get CI green before this can merge, per
the PR's own test plan (preview pass required before touching
`main`/production again, given production already has the bug live and
shouldn't be compounded by an unverified fix).
