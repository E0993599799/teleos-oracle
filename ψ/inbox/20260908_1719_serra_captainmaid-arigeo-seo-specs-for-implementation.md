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

## Update — 2026-09-09 (via cross-session message from serra-oracle-12)

Both specs got a real content change (not just wording), pushed to `serra-oracle` main at `d650fa5`:

- Both `captain-maid` and `arigeo-project` product pages fetch a CMS SEO field (Payload's `seo.metaTitle`/`metaDescription`/`ogImage`/`noIndex` on Products/Brands, from `cms-arigeo`), but neither's `generateMetadata` actually reads it — staff editing that field in Payload admin currently does nothing.
- Folded into both specs: new item #1 in the captain-maid spec, new item 3b in the arigeo spec — added as an early step in each implementation order since it's small/isolated and belongs alongside the other `generateMetadata` work.
- Does **not** change the infra-scoped piece (the `NEXT_PUBLIC_SITE_URL` Vercel env var on captain-maid) — still the same fix, still in progress as of this note (env var set, redeploy triggered, live domain not yet confirmed to reflect it — see session for troubleshooting).

---

## Update — 2026-09-12 (Teleos, live-domain verification)

Confirmed against `https://www.captain-maid.com` directly (`curl`, no code inspection) that the infra-scoped fix is live and working:

- **`robots.txt`**: now includes `Sitemap: https://www.captain-maid.com/sitemap.xml`.
- **`sitemap.xml`**: no longer empty — lists all static routes plus product pages (e.g. `/th/products/glass-cleaner`), `lastmod` 2026-09-10.
- **Canonical tag**: `/th/products/glass-cleaner` now renders `<link rel="canonical" href="https://www.captain-maid.com/th/products/glass-cleaner"/>` — resolves to the actual product URL, no longer falling back to homepage metadata.

`captain-maid.com` (apex) 308-redirects to `www.captain-maid.com` as expected — not an issue.

This closes out the `NEXT_PUBLIC_SITE_URL` / infra-scoped piece of the captain-maid spec. The CMS-SEO-field `generateMetadata` wiring (item #1 from the 2026-09-09 update above) and the arigeo/cms-arigeo items are unaffected by this check — still open.

---

## Update — 2026-09-12 (Teleos, arigeo Content-Signal check + owner policy decision)

Verified current state of `arigeo.com` directly (`curl`, no code inspection) against the two arigeo-project gaps from the original spec — both confirmed still open, unchanged:

- **`Content-Signal`**: absent from both the HTTP response headers and `robots.txt` on every checked path. `robots.txt` currently has only `User-Agent: *` / `Allow: /` / `Disallow: /api/` / `Host` / `Sitemap` — no Content-Signal line.
- **`/llms.txt`**: still returns `HTTP 200` with `content-type: text/html`, serving the homepage — same silent-absorption bug the spec identified in the `[locale]` dynamic route.

**Owner decision (Eak, 2026-09-12)** — the policy-value blocker on Content-Signal is now resolved:

```
Content-Signal: search=yes, ai-train=no, ai-input=yes
```

i.e. allow search-index crawling and AI answer-engine use of arigeo.com content, but disallow using it for model training. This applies to `arigeo.com`; no decision requested yet for `captain-maid.com`, `cms-arigeo.com`, `hr.arigeo.com`, `auth.arigeo.com`, or `my.arige.com` (per project domain map Eak gave: arigeo.com is the main project, captain-maid.com is a product landing page, cms-arigeo.com/hr.arigeo.com/auth.arigeo.com are internal parts of the project, my.arige.com is another landing page — sic on spelling, not re-verified).

This decision unblocks item 2 of the original arigeo-project spec (`ψ/outbox/2026-09-08_SPEC-ARIGEO-SEO-FIX.md` in `serra-oracle`) for whoever implements it — the header can now be added to `next.config.mjs`/`vercel.json`/middleware (and mirrored into `robots.txt`) with this exact value, no further owner sign-off needed on the value itself.

---

## Update — 2026-09-12 (Teleos, cms-arigeo audit re-check against current code)

Re-verified the cms-arigeo audit (`ψ/outbox/2026-09-08_SPEC-CMS-ARIGEO-PAYLOAD-AUDIT.md` in `serra-oracle`) against the live local checkout at `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/cms-arigeo/cms-arigeo/`, which has moved on since the audit (repo HEAD now `23bb22eb`, 2026-09-11, vs. the audit's 2026-09-08 read). Read code directly (`payload.config.ts`, `Users.ts`, `payload-strategy.ts`), not docs.

- **Finding 1 (six ecommerce collections unregistered)** — still true, unchanged. `payload.config.ts` still registers exactly the same 21 collections (Users, Media, Brands, ProductCategories, Solutions, Products, Posts, Testimonials, Pages, SiteSettings, Categories, ProductVariants, 6 Builder collections, UserLoginLogs). `Cart.ts`, `Checkout.ts`, `Orders.ts`, `Payments.ts`, `Customers.ts`, `Wishlist.ts`, and `Tenants.ts` all still exist as files under `src/payload/collections/` and are still not imported anywhere in the config. No decision has been made yet.
- **Finding 3 (auth model drift)** — still true, unchanged. `Users.ts` still has `disableLocalStrategy: true`; admin auth is still routed exclusively through `arigeoOidcStrategy` (`src/lib/identity/payload-strategy.ts`) via `auth.arigeo.com`. Still undocumented in `CMS-DESIGN-V3.md`/`PHASE-3-ARCHITECTURE.md`.
- **Finding 4 (21 vs. 32 claimed collections)** — the 21-registered count independently reconfirmed against code (matches the audit exactly). Did not re-open `FINAL_SUMMARY.md`/`PHASE-3-SUMMARY.md` to check whether their 32-collection claim has since been corrected — unverified either way.
- **Findings 2, 5, 6** (stale disabled-collection docs, undocumented page-builder subsystem, two revalidation hooks) — not re-checked this pass; these are multi-doc comparisons rather than single-file code reads and weren't verified against current state.

**Net**: none of the audit's two decision-blocking findings (1 and the repo-layout question) have been resolved as of 2026-09-12. Nothing here is Teleos-scoped to fix — flagging status only, per the original spec's own routing note.

---

## Update — 2026-09-12 (Teleos, Finding 4 doc-text re-check)

Closed the one thing left unverified above: read `FINAL_SUMMARY.md` and `PHASE-3-SUMMARY.md` directly. Neither has been touched since before the audit — both still overclaim exactly as Finding 4 described:

- **`FINAL_SUMMARY.md`** (last commit `3e48fb7c`, 2026-08-01 — predates the audit): still claims **"32 localized collections"** (line 17), still has a **"Collections Overview (32 Total)"** section header (line 190) with a live-looking **"Multi-Tenant Collections (1)"** (line 196) and **"Ecommerce Collections (6)"** (line 207) breakdown, and repeats "32 collections" twice more (lines 462, 882). No correction, no date-stamp-as-historical.
- **`PHASE-3-SUMMARY.md`** (last commit `27164cec`, 2026-08-09 — also predates the audit): line 257 still states **"✅ Tenants collection enabled"** — confirmed false (`Tenants` is not in `payload.config.ts`, per the Finding 1 re-check above).

Net: Finding 4 is fully re-confirmed, zero drift toward correction. All three cms-arigeo decision items (Finding 1, the repo-layout question, and now Finding 4's doc fix) remain untouched since the 2026-09-08 audit.

---

## Update — 2026-09-12 (Teleos, Finding 6 — resolved the open runtime question)

Read both hooks directly (`revalidateFrontends.ts`, `revalidatePage.ts`) and grepped every place each is wired into a collection, to close the one thing the audit explicitly left open: "did not verify runtime behavior of either revalidation hook... whether `revalidatePage.ts` is actually still called anywhere, vs. dead code itself."

- **`revalidateFrontends.ts` — live and active.** Wired via `afterChange` on `Brands.ts` and `Products.ts`, both of which **are** registered in `payload.config.ts`. On save it POSTs to two hardcoded targets — `arigeo` (tags `brands`+`products`) and `captain-maid` (tag `products` only) — each with its own secret (`ARIGEO_REVALIDATE_SECRET`/`CAPTAIN_MAID_REVALIDATE_SECRET`, falling back to `REVALIDATE_SECRET`).
- **`revalidatePage.ts` — confirmed dead code, answering the audit's open question.** Its only wiring is `afterChange` on `DynamicPages.ts` — but `DynamicPages` is **not imported or registered anywhere in `payload.config.ts`** (grepped, zero matches). A collection that isn't registered with Payload never fires its hooks, so this hook cannot run in the deployed system. Not "possibly superseded" — it is inert.
- **New finding, not in the original audit's Finding 1 list**: `DynamicPages` is an 8th unregistered collection, alongside the six ecommerce ones and `Tenants`. Same shape as Finding 1 (file exists, hook wiring exists, never registered) — worth folding into whatever decision resolves Finding 1, since it's the same pattern of abandoned/paused work with no doc trail.

This resolves Finding 6's open runtime question outright: no decision needed on "which hook to keep" in the sense the audit framed it — `revalidateFrontends` is the only one actually running. The remaining decision is narrower: whether `revalidatePage.ts`/`DynamicPages` should be finished and registered, or deleted as dead code.

---

---

## Update — 2026-09-13 (Teleos, Content-Signal implemented)

Implemented item 2 of the arigeo-project spec (`ψ/outbox/2026-09-08_SPEC-ARIGEO-SEO-FIX.md` in `serra-oracle`) — the header piece that was blocked on owner policy, now unblocked by Eak's 2026-09-12 decision (`search=yes, ai-train=no, ai-input=yes`).

- Worked from a **fresh clone** in scratchpad, not the local checkout at `mission-control/arigeo-project` — that checkout is 30 commits stale and has unrelated uncommitted WIP (junk files, an image-hostname edit, a `.gitignore` change) that isn't mine to touch or build on top of. Left it untouched.
- `next.config.mjs`: added `headers()` returning `Content-Signal: search=yes, ai-train=no, ai-input=yes` on `/:path*` (all routes).
- `app/robots.ts` → replaced with `app/robots.txt/route.ts` (raw route handler). Next's typed `MetadataRoute.Robots` (`RobotsFile`) has no field for a `Content-Signal` directive — confirmed by reading the type in `node_modules/next/dist/lib/metadata/types/metadata-interface.d.ts` — so the old metadata-convention file would have silently dropped the line. The route handler emits the exact directive text, preserving the original `Allow`/`Disallow`/`Sitemap`/`Host` rules.
- Verified locally: `npx tsc --noEmit` clean, `next build` succeeded (`/robots.txt` compiled as a static route), then ran the built app (`next start`) and confirmed via `curl` both the HTTP header on `/` and `/th`, and the exact `robots.txt` body.
- Pushed to `E0993599799/arigeo` `master` at `1d1d732` (was `7884670`).

**Not yet done**: this repo's `vercel.json` has an `ignoreCommand` gate requiring `[deploy-production]` (or `[deploy-preview]`) literally in the commit message for Vercel to actually build — my commit doesn't have that tag, so `1d1d732` is on `master` but **has not triggered a production deploy**. Live `arigeo.com` still shows no `Content-Signal` as of this push. Whether/when to trigger the deploy is Eak's call, not assumed here.

- **`/llms.txt` fix** (also item 2's sibling gap) and the **CMS-SEO-field `generateMetadata` wiring** (2026-09-09 update above) remain open — not touched in this pass.

**Serra (Researcher Oracle)**
**Federation tag**: `[serra-oracle:serra]`
