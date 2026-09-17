# Resolved: PR #115 fully unblocked — migration ran, GET /api/media returns 200

**Date**: 2026-09-17
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: cms-arigeo PR #115, PR #122, [[2026-09-17_cms-arigeo-pr115-database-url-wrong-host.md]] (the blocker this resolves)

## What happened

Three distinct, layered bugs blocked PR #115's migration from ever running,
each only surfaced by actually dispatching the workflow, not by reading
the YAML:

1. `RUN_DB_MIGRATIONS` was never set anywhere → fixed by adding a
   `workflow_dispatch` boolean input `run_migrations` (PR #122).
2. The build step passed `secrets.DATABASE_URI`/`secrets.POSTGRES_URL`,
   neither of which exist — only `DATABASE_URL` does, and that's what
   `payload.config.ts`/`build-ci.mjs` actually read → fixed the env var
   name (same PR #122).
3. `DATABASE_URL`'s *value* pointed at the direct Supabase host
   (`db.pkfgbbqbbgnzphihcyzc.supabase.co`), which GitHub Actions runners
   can't resolve (IPv6-only). The app's own code expects the Supavisor
   pooler host (`*.pooler.supabase.com`).

## The DATABASE_URL update saga

Ekkarat updated the secret via GitHub UI **twice**, confirming the exact
settings URL and secret name both times, and confirmed the value matched
the expected pooler pattern (`aws-0-ap-northeast-2.pooler.supabase.com`).
Despite that, **6 consecutive dispatch attempts across ~1.5 hours** all
failed with the identical unreachable-host error, and `gh secret list`
kept showing the secret's `updated_at` unchanged at `2026-07-18` the
entire time — even once, contradictorily, right after the GitHub UI
itself displayed "Updated 2 minutes ago" next to the secret.

Root cause of *that* discrepancy was never diagnosed (browser
account/tab mismatch is the leading theory, never confirmed). What fixed
it: asking Ekkarat to set the secret directly via
`gh secret set DATABASE_URL -R E0993599799/cms-arigeo` from his own
authenticated terminal instead of the browser. `gh secret list`
immediately showed the timestamp change (`2026-09-17T02:20:20Z`), and the
very next dispatch succeeded.

## Verified result

- Build [`35174066316`](https://github.com/E0993599799/cms-arigeo/actions/runs/35174066316):
  `run_migrations=true` against `fix/media-approved-public-read` —
  succeeded, log shows `Migrating: 20260914_231603_add_approved_for_public_use_to_media`
  → `Migrated: ... Done.`
- Deploy [`35174485533`](https://github.com/E0993599799/cms-arigeo/actions/runs/35174485533)
  → `https://cms-arigeo-lwjvht1ke-omega-project.vercel.app`
- `curl .../api/media` (unauthenticated) → **`HTTP 200`**,
  `{"docs":[],"totalDocs":0,...}` — correct: no media currently has
  `approvedForPublicUse: true`, and it no longer 500s.

## Status

**PR #115 is unblocked.** Recommended order: merge PR #122 first (the
workflow fix), then merge/re-test PR #115 itself.

## Lesson

When a UI-based state change (an "Updated 2 minutes ago" label) doesn't
match what the API/pipeline sees, don't keep retrying the same channel —
switch to a channel you can verify end-to-end yourself (CLI, same
authenticated session) rather than trusting a second-hand UI confirmation
a sixth time. Confirming "the pattern looks right" is not the same as
confirming "it landed where the pipeline reads it."
