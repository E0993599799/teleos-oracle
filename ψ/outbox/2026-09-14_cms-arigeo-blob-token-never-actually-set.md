# Correction: Blob store/token from earlier today never actually persisted — same dashboard-save pattern as Root Directory

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-105-106-blob-store-fixed-by-ekkarat.md]] (the fix this corrects), [[2026-09-14_cms-arigeo-rootdir-removal-did-not-fix-nodemodules-error.md]] (the earlier instance of the same dashboard-save failure mode)

## What happened

Ekkarat tested the real product image upload live on production
(`cms.arigeo.com/admin/collections/media`) after #114 (the #418 fix) landed.
Got `POST /api/media 500`, response body `{"errors":[{"message":"Something
went wrong."}]}`.

Walked through diagnosis live:
1. Unauthenticated probe confirmed the 500 happens *after* auth passes (got
   403 unauthenticated, 500 when Eak's real session hit it) — a real
   server-side exception, not an access-control issue.
2. Had Eak pull the actual error from Vercel's Runtime Logs dashboard
   directly (Vercel MCP connector still disconnected all session):
   ```
   ERROR: ENOENT: no such file or directory, mkdir 'media'
   ```
3. Read `cms-arigeo/payload.config.ts` directly — found the Blob plugin is
   gated:
   ```js
   const blobToken = process.env.BLOB_READ_WRITE_TOKEN?.trim() || ''
   const blobEnabled = blobToken.startsWith('vercel_blob_rw_')
   ...
   vercelBlobStorage({ enabled: blobEnabled, ... })
   ```
   If `BLOB_READ_WRITE_TOKEN` isn't set (or doesn't start with the expected
   prefix), the plugin silently disables and Payload falls back to local
   disk storage — which fails immediately in a serverless function (`mkdir`
   on a read-only/ephemeral filesystem).
4. Asked Eak to check the Vercel dashboard directly — **confirmed there was
   no Blob store and no `BLOB_READ_WRITE_TOKEN` at all.**

## Why

This is the same failure class as this morning's Root Directory setting:
a Vercel dashboard change (creating the public Blob store + connecting it,
done hours earlier per the 2026-09-14 morning outbox note) **did not actually
persist**, for reasons never fully diagnosed (browser/session issue,
dashboard UI glitch, or a save that silently didn't take). This is now the
**second** confirmed instance today of a Vercel dashboard setting appearing
to save but not actually sticking — worth remembering as a real, recurring
risk with this project's Vercel dashboard, not a one-off fluke.

## Fix (this time, redone properly)

Guided Eak through it again with explicit verification steps:
1. Storage tab → Create Database → Blob → public access
2. Connect to Project → `cms-arigeo`
3. **Explicitly checked Environment Variables afterward to confirm
   `BLOB_READ_WRITE_TOKEN` shows for the Production scope** — the step
   skipped/not verified this morning.

Eak confirmed "done, connected." Triggered a fresh production build+deploy
(run pending as of this note) to pick up the new token and test again.

## Lesson

After any Vercel dashboard change on this project, **do not trust the UI's
apparent success** — independently verify the setting actually persisted
(re-read the env var list, or check a fresh build's captured config) before
treating a fix as done. This is now confirmed twice in one day.
