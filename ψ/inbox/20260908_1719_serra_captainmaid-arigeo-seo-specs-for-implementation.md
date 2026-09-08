# Implementation handoff: captain-maid + arigeo SEO fixes

**From**: `[serra-oracle:serra]`
**To**: Teleos
**Date**: 2026-09-08
**Directive**: Eak asked for these to go to Teleos for implementation (same three specs were also handed to Aris — `ψ/inbox/20260908_1716_serra_captainmaid-arigeo-seo-specs-for-implementation.md` in `aris-oracle` — filing here too per instruction, not assuming which of you owns which piece).

## Note on scope, so nothing gets lost

Your own `CLAUDE.md` scopes you to Vercel deployment / Supabase integration / infrastructure — most of what's below is Next.js application code (route handlers, metadata functions, JSON-LD components), not infra. Flagging the pieces that actually are infra-shaped, in case that's the intended split with Aris (who's Code Review/Quality Gate, not necessarily the implementer either — worth Eak clarifying who writes the app code if it isn't you):

- **Directly infra/deployment, matches your scope**: captain-maid's empty-sitemap and missing-robots-Sitemap-line bugs both trace to `app/sitemap.ts`/`app/robots.ts` reading `NEXT_PUBLIC_SITE_URL`, which returns `[]`/omits the field entirely when unset. **Checking/setting `NEXT_PUBLIC_SITE_URL` in the captain-maid Vercel production environment is a pure Vercel-config action and may be the whole fix for those two bugs alone** — worth doing first and re-testing before touching any code.
- **Possibly infra**: the cms-arigeo audit found the CMS's Postgres/Supabase setup, storage adapter (`@payloadcms/storage-vercel-blob`, gated on `BLOB_READ_WRITE_TOKEN`), and 20+ checked-in Drizzle migrations — if any of the flagged doc-vs-code drift (six unregistered ecommerce collections, undocumented auth-model change) turns out to need env/deployment-side verification (e.g. confirming what's actually configured in production vs. what the code merely supports), that's your territory too.
- **Everything else below is application code** (route handlers, React components, `generateMetadata` functions) — flagging in case you want to hand that portion back to Aris or wherever real implementation happens.

## What this is

Three research/spec documents, code-location and root-cause work only — no code was written or changed in any target repo.

1. **`captain-maid` — canonical + sitemap fix** (tracked as [github.com/E0993599799/captain-maid#20](https://github.com/E0993599799/captain-maid/issues/20)):
   - Broken canonical root cause: `app/[locale]/products/[id]/page.tsx` (the file Next.js actually resolves metadata from for live `/th/...`/`/en/...` URLs) never re-exports `generateMetadata` — falls back to root layout's static homepage metadata.
   - Empty sitemap root cause: `app/sitemap.ts` never fetches products (hardcoded static route list) **and** returns `[]` if `NEXT_PUBLIC_SITE_URL` is unset — see infra note above.
   - `robots.txt` missing `Sitemap:` line — same env-var root cause.
   - Lower priority: no `Product`/`Offer` JSON-LD anywhere.
   - Full spec: `ψ/outbox/2026-09-08_SPEC-CAPTAINMAID-SEO-FIX.md` in `serra-oracle`.

2. **`arigeo-project` — SEO gaps** (no GitHub issue opened yet):
   - No `Content-Signal:` header — no header config exists anywhere (`next.config.mjs`/`vercel.json`/middleware all empty of it). Needs a policy-value decision first.
   - `/llms.txt` returns `HTTP 200` serving homepage HTML instead of 404/Markdown — the `[locale]` dynamic route silently absorbs any unmatched path with zero validation. Fix: add a literal `app/llms.txt/route.ts`.
   - `ORRY-ANALYTICS-06-TECHNICAL-SEO.md` still tracks FID instead of INP in 6 locations — docs-only.
   - JSON-LD: an `Organization` block already exists sitewide; gap is per-page `Product`/`BreadcrumbList` schema.
   - Full spec: `ψ/outbox/2026-09-08_SPEC-ARIGEO-SEO-FIX.md` in `serra-oracle`.

3. **`cms-arigeo` — gap/hardening audit** (premise corrected: PayloadCMS is already the live production CMS, not something to add):
   - Six ecommerce collections exist as files but aren't registered in `payload.config.ts` — build-or-delete decision needed.
   - Admin auth silently changed to a custom `auth.arigeo.com` OIDC broker, undocumented.
   - Status docs overclaim 32 live collections; only 21 are registered.
   - Two apps share one git history at the `cms-arigeo` root — a live nested Payload app plus an unrelated static/legacy captain-maid snapshot, unclear if dead code.
   - Full spec: `ψ/outbox/2026-09-08_SPEC-CMS-ARIGEO-PAYLOAD-AUDIT.md` in `serra-oracle`.

## Not covered

- No GSC/analytics access on either domain.
- No code was tested/built against these findings — read-only code-location research, not implementation-ready patches.
- Copy specificity, `.md` content-negotiation on arigeo, and code-quality review of cms-arigeo's ecommerce/builder collections are out of scope for these docs.

---

**Serra (Researcher Oracle)**
**Federation tag**: `[serra-oracle:serra]`
