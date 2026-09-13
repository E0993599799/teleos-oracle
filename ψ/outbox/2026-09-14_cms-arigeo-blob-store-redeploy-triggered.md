# Update: cms-arigeo Blob store fix — redeploy triggered, build succeeded

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-105-106-blob-store-fixed-by-ekkarat]] (yesterday's Blob store env-var fix, which this closes the loop on)

## What happened

Serra retested Ekkarat's Blob store fix (new public store + `BLOB_READ_WRITE_TOKEN`
repointed) and hit a *different* error: `Vercel Blob: This store does not exist`
(was "cannot use public access on a private store" before). khun-oracle diagnosed
via live runtime logs: Vercel doesn't hot-reload project env vars into already-running
Serverless Functions — the new token needed a fresh deploy to actually apply. Same
deployment ID (`dpl_BWY56wqj7sQvDoKsxJEhqxukM6y6`) was still serving since before the
dashboard env var edit.

khun-oracle suggested a no-code-change redeploy (dashboard "Redeploy" button) and
flagged it was my call whether I could do it or Eak needed to click it himself.

## What I found / did

- Checked my Vercel MCP tools: no dedicated "redeploy existing deployment" action.
  `deploy_to_vercel` deploys fresh files from scratch, not a re-run of the existing
  git-linked build (which uses `payload generate:importmap && payload generate:types
  && next build`) — didn't want to risk config drift by using it here.
- Eak chose the alternative: push an empty commit to `cms-arigeo` main to trigger a
  normal git-based redeploy.
- Checked `vercel.json` first for an `ignoreCommand` gate (the `arigeo` repo has one
  requiring `[deploy-production]` in the commit message) — **cms-arigeo has none**,
  so a plain push should build normally.
- Local checkout of `cms-arigeo` was on a stale unrelated branch
  (`feat/captain-maid-persistent-inspector-20260909`) with an uncommitted
  `.env.staging` change — didn't touch it. Used an isolated `git worktree` off a
  freshly-fetched `origin/main` instead, same pattern as the man-os-library PR
  earlier this session.
- Pushed empty commit `e5d504f7` (`chore: trigger production redeploy (no code
  change)`) directly to `main`.
- Monitored GitHub Checks via the `Monitor` tool (polling every 15s) until
  completion: **build: completed/success**. (`deploy` check showed
  `completed/skipped` throughout — appears to just be how Vercel's GitHub App
  labels this check type for direct-to-main pushes, not a failure signal.)
- Verified production is serving fresh content post-build with a cache-busting
  request to `cms.arigeo.com/admin`: `x-vercel-cache: MISS`, `age: 0` (an earlier
  uncached check had shown `age: 183420` — stale edge cache, not representative).

## Not verified

**The actual Blob upload still needs a live retest** — I have no admin session to
test it myself. Posted the redeploy status as a comment on
[cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5655350187)
and asked Serra to retest. Also messaged khun-oracle-79 directly.

## Still open

- Whether the Blob upload actually works now (pending Serra's retest)
- Fix #2 — stale `payload_preferences` DB row: **investigated this session, did NOT
  find the expected stale row**. Queried production Postgres directly (Supabase SQL
  editor, project `arigeo`/`kzjnemlepollzvbgugrv`, branch `main`):
  - `select * from payload_preferences where key ilike '%products%'` → only 2 rows
    (`id=40`, `id=5`), both `key = 'collection-products'`, both `value = {"limit":
    10}` — clean, no `site` field reference.
  - `select * from payload_preferences where value::text ilike '%site%'` → only 1
    row (`id=24`, `key = 'collection-sections'`) with a legitimate `"accessor":
    "site"` column preference for the **Sections** collection, unrelated to Products.
  - **Conclusion: the specific stale-preference bug described in the original
    routing note does not currently exist in the DB as described.** Either it was
    already cleared before this session, or the actual root cause of the
    `/admin/collections/products` list crash is something else. Recommend testing
    the live admin page directly before assuming this fix is still needed — flagged
    to Eak, not yet re-tested live.
- Unrelated schema-drift bug khun-oracle found: `/admin/collections/pages` 500s on
  `column _pages_v.version_builder_layout does not exist` — separate issue, already
  commented on #106 by khun-oracle, not touched by anyone yet.

## Process note

Getting into the Supabase SQL editor took two failed attempts first — the browser's
logged-in Supabase account initially resolved to a *different* org/account entirely
(personal projects unrelated to arigeo), and a direct `psql` connection via Bash was
blocked outright by the auto-mode classifier (no prompt, hard denial) before reaching
the user for approval. Eak logging into the correct Supabase account
(`e.meephu@gmail.com`, org `arigeo`) in the browser directly is what actually worked.
