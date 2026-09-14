# Finding: PR #115 preview deploy fails — new field has no DB migration

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: cms-arigeo PR #115 (`approvedForPublicUse` field + `mediaRead` access function)

## What happened

Followed khun-oracle-79's explicit instruction: test PR #115 on preview
BEFORE merging, not merge-then-test.

1. Verified PR #115's diff against the actual PR-branch file content
   (`access.ts`, `Media.ts` at commit `88428d7`) — matches exactly.
2. CI checks green (2/2).
3. Triggered preview build directly against branch
   `fix/media-approved-public-read` (no merge) — build run `34865457499`,
   succeeded. Confirmed via workflow YAML that the checkout step uses
   `${{ inputs.ref }}`, and that step completed successfully — the build
   genuinely used the PR branch, not `main`.
4. Triggered preview deploy (run `34866456681`) from that build artifact —
   succeeded, deployed to
   `https://cms-arigeo-a4ks32o00-omega-project.vercel.app`.
5. Tested per the PR's own test plan: unauthenticated `GET /api/media`.

   **Result: `HTTP 500`, `{"errors":[{"message":"Something went wrong."}]}`**

   Compared against production `main` baseline: unauthenticated
   `GET https://cms.arigeo.com/api/media` → `403` (expected, old
   `authenticatedRead` behavior). So this is a real regression introduced by
   the PR branch, not pre-existing.

## Root cause (verified, not guessed)

- `payload.config.ts` on the PR branch: `postgresAdapter({ ..., push: false, ... })`
  — this project requires **explicit migrations**, no auto schema push.
- `PR #115`'s file list (`gh pr diff 115 --name-only`): only
  `src/payload/access.ts` and `src/payload/collections/Media.ts` changed.
  **No migration file added.**
- Latest migration in `src/migrations/` on the PR branch is still
  `20260902_020000_fix_block_definitions_site_type.ts` — nothing for the new
  `approvedForPublicUse` column.
- The new `Media` collection field (`approvedForPublicUse`, checkbox) has no
  matching column in the actual Postgres database, so any query touching it
  (the `mediaRead` access function's `where: { approvedForPublicUse: { equals: true } }`
  clause, evaluated on every unauthenticated read) throws — surfaced to the
  client as Payload's generic `"Something went wrong."` 500.

## Status

**Not merging.** This confirms exactly why khun-oracle-79's "preview first,
not merge-then-test" instruction mattered — this would have broken the
public `/api/media` endpoint in production (500 instead of the old 403, and
worse, likely breaks authenticated reads too since the field is part of the
collection schema, not just the access-filtered query).

Reported back to khun-oracle-79: PR #115 needs a migration for the new
`approvedForPublicUse` column before this can be re-tested/merged.

## Lesson

This codebase uses `push: false` (migration-gated schema, not dev
auto-push) — any PR that adds/changes a Payload collection field must ship
its own migration in the same PR, or the preview/production deploy will
type-check and build clean but fail at runtime on first query touching the
new column. CI passing and the build succeeding are not sufficient signals
for a schema change; only an actual query against the new field surfaces it
— exactly what the required preview-before-merge step caught.
