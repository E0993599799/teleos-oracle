# Route: Fix the two infra-side blockers on cms-arigeo#105 (product images)

**From**: `[MARCUZ:Khun-Oracle]`
**To**: Teleos (`teleos-oracle`)
**Date**: 2026-09-13
**Authorized by**: Ekkarat (พี่เอก), 2026-09-13 — "delegate to teleos-oracle ทำงานที่ค้าง" (delegate the pending work to teleos-oracle)
**Re**: `cms-arigeo#105` / `cms-arigeo#106`

## Why you're getting this

`cms-arigeo#105` (product images missing on captain-maid.com's storefront) has been
fully root-caused across several rounds of investigation, but the actual fix requires
two infra-side actions neither I nor Serra have the credentials to make from outside
Vercel's dashboard / the CMS's Postgres instance. This is squarely deployment/DevOps
territory, so Ekkarat routed it to you rather than have it sit blocked.

Full diagnostic trail: `cms-arigeo#105` and `cms-arigeo#106` on GitHub
(`E0993599799/cms-arigeo`), plus `khun-oracle`'s memory file
`cms-arigeo-issue-105-product-images.md` if you want the complete round-by-round history.

## The two concrete fixes needed

**1. Vercel dashboard — Blob store access mismatch**

`POST /api/media` 500s unconditionally (even a trivial 1×1 pixel test upload).
Confirmed via live production runtime logs (`get_runtime_logs` on the `cms-arigeo`
Vercel project):

```
Vercel Blob: Cannot use public access on a private store. The store is configured with private access.
```

The installed `@payloadcms/storage-vercel-blob` plugin (v3.87.0) hardcodes
`access: 'public'` on every upload — its own type declares "Currently, only 'public'
is supported." There is no code-side workaround. Fix is one of:
- Flip the project's existing Blob store to public access in the Vercel dashboard
  (Storage → this store's settings), **or**
- Provision a new public Blob store and repoint the `BLOB_READ_WRITE_TOKEN` env var
  at it.

Vercel project: `cms-arigeo`, team `omega--project` (team ID
`team_OS8nENECHPCuieeZsEhya9sF`).

**2. CMS Postgres — stale admin preference**

`/admin/collections/products` list view crashes on every load (`Cannot find field
for path at site` → cascades into a React hydration error #418 client-side).
Confirmed by reading `Products.ts` and its full git history: this collection has
**never** had a `site` field, in schema or code. The only `site` field in the codebase
belongs to unrelated Builder-v2 collections. A path that no code references, failing
identically on every list load, is the signature of a stale row in Payload's
`payload_preferences` table (per-admin-user saved sort/column/filter state).

Fix: find and delete the `payload_preferences` row scoped to the `products`
collection with a `site` sort/column/searchable-field reference — or have the
affected admin user reset their view once the admin UI is reachable again.

## What's already been ruled out

- Not a code defect in either case — confirmed by reading the plugin's own type
  declarations and by `git log` on `Products.ts` showing `site` was never there.
- Not something fixable via a PR against `cms-arigeo` — flagging so you don't spend
  time reviewing one.
- Media collection itself is confirmed empty (checked before hitting these blockers)
  — no orphaned/duplicate uploads to worry about when this unblocks.

## Side note (not filed as an issue, your call)

The last 20 production deployments of `cms-arigeo` all show `gitDirty: "1"` in Vercel
deployment metadata — production has been deployed from an uncommitted working tree
every time, not from a clean `main` commit. Flagging in case that's not intentional;
worth a look while you're in the Vercel dashboard for this anyway.

## After you unblock this

`cms-arigeo#105`'s actual remaining step (upload + attach 6 product images) was
previously routed to Serra, who hit these exact two bugs before she could do it —
see her attempt logged in `cms-arigeo#106`. Once both infra fixes land, ping Serra
(or Khun-Oracle) so the image upload can actually happen; it doesn't need you to do
the upload itself, just to clear the path.

## Scope note

Please comment on `cms-arigeo#106` when each fix lands (or if you hit something that
needs Ekkarat's decision, e.g. no Vercel dashboard access) so the fleet record stays
in sync:
- https://github.com/E0993599799/cms-arigeo/issues/105
- https://github.com/E0993599799/cms-arigeo/issues/106

— `[MARCUZ:Khun-Oracle]`
