# Milestone: React #418 hydration crash confirmed fixed on production

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-pr114-verified-stale-test-blocks-ci.md]] (PR #114 review), a mid-session identity confusion with the khun-oracle-79 peer session (resolved — same session throughout, confirmed by Ekkarat and then independently by khun-oracle-79 finding the actual clone and pushing the test fix)

## What happened

After khun-oracle-79 pushed the `seo-production-wiring.test.mjs` fix (commit
`e30f3c4` — verified independently: asserts `src/app/layout.tsx` no longer
exists AND `[locale]/layout.tsx` now contains `<html>`/`<body>`/`lang={locale}`,
correctly inverted from the old invariant), the PR #114 build check passed.
Merged (squash, branch deleted).

## Preview test blocked by an unrelated known issue

Ran preview build+deploy — build succeeded, but the preview URL redirected to
`/api/auth/arigeo/login` and errored out before reaching the products page —
the separate preview-environment auth env var gap khun-oracle flagged earlier
in their root-cause analysis (`PROJECT_CMS_ARIGEO`/`PROJECT_CMS_CAPTAINMAID`
incomplete), unrelated to #114's code. Couldn't verify #418 via preview.

Asked Eak how to proceed rather than guessing; he chose to skip straight to a
production build+deploy given the code fix was already thoroughly
independently verified and production is where the bug was originally
confirmed live this session.

## Production verified fixed — via live browser check

Production build+deploy succeeded, aliased to `cms.arigeo.com`. Checked
`https://cms.arigeo.com/admin/collections/products` directly in a real
browser (not curl — this is a client-side hydration crash, invisible to
server-status checks):

- **Before**: `React error #418` fired immediately in console on every load;
  main content area completely empty, only the page header rendered.
- **After**: **zero console errors of any kind**. `get_page_text` returns the
  full admin navigation sidebar (Users, Media, Brands, Products, Posts, Site
  Settings, all Builder V2 collections, etc.) — real DOM content where there
  was previously nothing.

Screenshot capture itself was flaky (CDP timeouts, likely unrelated
browser/rendering-pipeline noise), so relied on `get_page_text` +
`read_console_messages` for verification instead — both gave clean, decisive
signal.

Didn't see actual product row *data* render in the main panel — almost
certainly because this browser session has no CMS admin login, not a code
issue. Not tested further; no admin credentials to use.

## Status

Posted the confirmation to
[cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5662767208)
and to khun-oracle-79. **The React #418 hydration crash blocking `/admin` in
production is fixed.**

## What's still open on #105/#106

- Preview-environment auth env vars (separate, not touched this session —
  needs Vercel dashboard/env var access)
- The actual Blob store image upload itself has still never been confirmed
  working by an authenticated test — needs Serra (or Eak) to do a real
  upload now that both the CI pipeline (#108-#113) and the admin crash
  (#114) are resolved
