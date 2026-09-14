# Finding: PR #115's migration is correct but this pipeline never runs migrations

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: cms-arigeo PR #115, [[2026-09-14_cms-arigeo-pr115-preview-500-missing-migration.md]] (the first-round finding this follows up on)

## What happened

khun-oracle-79 added migration `20260914_231603_add_approved_for_public_use_to_media.ts`
(commit `8dd8c5e`), verified correct: `ALTER TABLE media ADD COLUMN
approved_for_public_use boolean DEFAULT false NOT NULL`, registered properly
in `src/migrations/index.ts`.

Re-ran preview build (run `34869075770`) + deploy (run `34869768009`) against
the updated branch. Both succeeded. Re-tested unauthenticated `GET /api/media`
on the new preview URL (`cms-arigeo-rd2cr0xl2-omega-project.vercel.app`):

**Still `HTTP 500`, `{"errors":[{"message":"Something went wrong."}]}`**

## Root cause (verified from the build logs directly, not guessed)

`cms-arigeo/.github/workflows/vercel-prebuilt-build.yml`'s "Strict
production-compatible build" step runs `npm run build:ci` →
`scripts/build-ci.mjs`, which gates migrations behind
`process.env.RUN_DB_MIGRATIONS === 'true'`. Build log, this run:

```
🗃️  Run migrations: no
⏭️  Step 1: Skipping CI migration preparation (RUN_DB_MIGRATIONS is not enabled)
⏭️  Step 2: Skipping Payload migrations (RUN_DB_MIGRATIONS is not enabled)
```

Checked the workflow YAML in full — `RUN_DB_MIGRATIONS` is never set
anywhere in `vercel-prebuilt-build.yml` (no `env:` block sets it, and it is
not exposed as a `workflow_dispatch` input). So **no path through this CI
pipeline as it exists today ever actually applies a migration** — the
migration file being correct and merged doesn't help until something runs
`payload migrate` against the real database with `RUN_DB_MIGRATIONS=true`.

This looks like a deliberate safety gate (comment in the script: "Database
migrations are explicit opt-in via RUN_DB_MIGRATIONS=true... normal CI/Vercel
builds never mutate the database") — correct design intent, just never wired
to an actual trigger.

## Not acting unilaterally on this

Running a migration mutates the real preview/production database schema.
Per this oracle's standing policy (never touch prod DB directly, never
assume authorization for infra mutations beyond what's already been
explicitly scoped), **did not**:
- fabricate DB credentials or connect directly,
- silently add a `run_migrations` opt-in input to the workflow and fire it,
- or guess which path Ekkarat would prefer.

## Status

Flagged to Ekkarat directly (asking how he wants to proceed: add an explicit
opt-in `workflow_dispatch` input so this stays reviewable, or have someone
run `payload migrate` locally against preview with real credentials, or
another approach). Not merging PR #115 until the column actually exists in
a live-tested database, confirmed via the same `/api/media` check.

## Lesson

A migration file matching the correct SQL is necessary but not sufficient —
must also verify it actually *runs* against the target environment before
declaring a fix ready. This is a second, distinct blocker from the first
(missing migration) even though both manifest identically (500 on
`/api/media`) — don't assume the same symptom means the same root cause is
now fixed; re-verify the actual live behavior every time, which is exactly
what caught this.
