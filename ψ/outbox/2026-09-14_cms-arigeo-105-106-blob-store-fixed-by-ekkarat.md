# Update: cms-arigeo#105/#106 — Blob store fix #1 done by Ekkarat, DB fix #2 still open

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-13_cms-arigeo-105-106-status-tooling-gap]] (yesterday's status — tooling gap that led to this)

## What happened

After yesterday's tooling-gap report (Teleos has no tool to change Vercel Blob store
access mode or touch Postgres), Eak decided to fix it himself rather than wait.

Tried the Vercel dashboard first, couldn't find a private→public toggle on the
existing Blob store. Checked current Vercel docs (`vercel.com/docs/vercel-blob/manage-blob-storage`)
to confirm why: **access mode is set only at store creation** (`--access public|private`),
immutable afterward — there is no dashboard toggle to flip an existing store. This
explains the "can't find it" report; it wasn't a UI-navigation miss, the control
genuinely doesn't exist.

**Fix landed**: Eak provisioned a new **public** Blob store and repointed the
`cms-arigeo` project's `BLOB_READ_WRITE_TOKEN` at it. This resolves the exact error
from the routing note (`Vercel Blob: Cannot use public access on a private store`).

Posted as a comment on [cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5654855319).

## Not verified

My Vercel MCP connector was disconnected at the time (`claude.ai Vercel` MCP server
showed "not connected" on repeated tool calls) — could not pull runtime
logs/errors to confirm `/api/media` 500s have actually stopped. Flagged this
explicitly in the GitHub comment. Worth a live test upload before treating
`cms-arigeo#105`'s image-upload step as unblocked.

## Still open

**Fix #2 — stale `payload_preferences` Postgres row** (the one causing
`/admin/collections/products` list view to crash) is **untouched**. Eak confirmed
he only fixed the Blob store, not this. Still needs either DB access from someone
with credentials, or Eak doing it himself the same way he did fix #1.

## Also done

Appended a Round 8 entry to khun-oracle's own memory file
(`cms-arigeo-issue-105-product-images.md`) noting this update, since it's the
canonical round-by-round history for this issue — flagged to khun-oracle-79 via
SendMessage rather than treating the edit as mine to own going forward.
