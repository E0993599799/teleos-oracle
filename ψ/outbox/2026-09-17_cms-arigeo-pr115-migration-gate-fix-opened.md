# Fix: opened PR #122 to unblock PR #115's migration (opt-in gate + wrong secret name)

**Date**: 2026-09-17
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: cms-arigeo PR #115 (blocked), [[2026-09-14_cms-arigeo-pr115-migration-never-runs-in-pipeline.md]] (the finding this fixes)

## What was done

Cloned `cms-arigeo` fresh (no local clone existed on this host), confirmed
via `gh pr view 115` it's still open/unmerged on `fix/media-approved-public-read`.

Opened **[cms-arigeo#122](https://github.com/E0993599799/cms-arigeo/pull/122)**
against `.github/workflows/vercel-prebuilt-build.yml`:

1. Added a `workflow_dispatch` boolean input `run_migrations` (default
   `false`) — makes running a DB migration an explicit, reviewable choice
   per dispatch, not an implicit always-off toggle.
2. Wired `RUN_DB_MIGRATIONS: ${{ inputs.run_migrations && 'true' || 'false' }}`
   into the "Strict production-compatible build" step.

## Second bug found (not in the original 09-14 finding)

While wiring up the DB env for that step, found the step was passing
`secrets.DATABASE_URI` / `secrets.POSTGRES_URL` — **neither secret exists**
in this repo (`gh secret list` shows only `DATABASE_URL`, created
2026-07-18). `payload.config.ts`, `build-ci.mjs`, and
`prepare-ci-migrations.mjs` all read `DATABASE_URL` (or pooler-key
fallbacks), never `DATABASE_URI`/`POSTGRES_URL`. So **even setting
`RUN_DB_MIGRATIONS=true` alone would have silently no-op'd**
(`isDatabaseAvailable=false`) rather than actually running the migration —
a second, independent blocker layered on top of the first. Fixed the env
var name to `DATABASE_URL` in the same PR (confirmed with the user this
scope was wanted before touching it).

Note: `DATABASE_URI`/`POSTGRES_URL` are real, used names elsewhere in this
codebase (`src/lib/identity/session.ts`, `entitlement.ts`,
`production-authz-preflight.mjs`) — those appear to be Vercel's actual
production env var names for a *different* Postgres pool (identity DB).
Did not touch those; only fixed the one CI step feeding Payload's own
migration path, which needs `DATABASE_URL` specifically.

## Status

**PR #122 open, not merged.** Test plan in the PR body: dispatch with
`run_migrations: false` first (regression check), then with
`run_migrations: true` against PR #115's branch to actually apply the
migration and re-verify `GET /api/media` no longer 500s — only then
merge/re-test #115.

## Lesson

A gate that's "never set" can hide a second bug behind it: fixing the
obvious missing toggle surfaced a silent env-var-name mismatch that would
have made the toggle a no-op anyway. Worth tracing the full call chain
(workflow env → script env read → actual secret list) rather than assuming
one flag is the whole story, especially for anything that mutates a real
database.
