# Correction: don't close #105 yet — Media access policy gap confirmed still unfixed

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-upload-confirmed-working-saga-closed.md]] (the premature "fully closed" claim this corrects)

## What happened

Right after declaring the saga closed (successful admin upload confirmed),
Serra flagged a concern from khun-oracle's own 2026-09-12 comment on `#105`
that had never been re-confirmed as fixed: `Media`'s access policy
(`authenticatedRead`) was never upgraded to match `Products`' public-read
policy, and Payload silently drops unreadable relations from `hasMany`
arrays — meaning images could be uploaded+attached in admin and *still*
render as empty on the storefront if that access gap wasn't separately
fixed. Both `#105` and `#106` are still open, no comment since 2026-09-12
confirms this was addressed.

## Verified directly (not assumed)

1. Read `cms-arigeo/src/payload/collections/Media.ts` — confirmed
   `access: { read: authenticatedRead, ... }`, unchanged from the original
   diagnosis.
2. `curl https://cms.arigeo.com/api/media` unauthenticated → still `403`.
3. `curl https://cms.arigeo.com/api/products?depth=1` (public) → the product
   checked still returns `images: []`.

**Serra's concern is confirmed real.** The access gap was never fixed.

## The confusing wrinkle

Checked `captain-maid.com`'s live rendered HTML directly — product pages
*do* show correct images right now (`products-img/floor-lavender.webp`
etc., matching the corrected filenames Serra provided), but served via
`/_next/image?url=%2Fimages%2Fproducts-img%2F...` — captain-maid's own
bundled static assets, not an obviously CMS-fetched URL at request time.

This raises a real open question: does `captain-maid.com` actually depend
on CMS-fetched media URLs at all (via `lib/captain-products.ts`, per
Serra's earlier message about the asset registry), or does it use static
local image references entirely independent of the `cms-arigeo` `Media`
collection? If the latter, today's successful admin upload may not connect
to anything user-visible at all yet — the access-policy fix would still be
a fully separate, still-open item regardless of upload success.

## Status

Posted the correction to
[cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5666389194).
Asked khun-oracle to clarify the actual captain-maid data flow before
anyone treats `#105` as closed. **Retracting the earlier "fully resolved"
milestone note's closure framing** — the CI pipeline and admin-crash fixes
are genuinely done and confirmed; the original user-facing symptom (product
images visible on the live storefront) is *not* yet independently confirmed
fixed.

## Lesson

Don't let a successful *admin-side* action (upload succeeding) stand in for
the *actual* originally-reported symptom (images visible on the public
storefront) without checking the full path end to end. This session
declared victory one step too early — caught only because Serra
specifically remembered a prior finding and asked for it to be
re-verified before closing.
