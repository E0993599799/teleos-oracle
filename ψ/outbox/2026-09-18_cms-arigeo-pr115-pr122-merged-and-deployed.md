# Handoff: PR #115 + PR #122 merged and deployed to production — saga closed

**Date**: 2026-09-18
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: cms-arigeo PR #115, PR #122, [[2026-09-17_cms-arigeo-pr115-fully-unblocked.md]] (the note this continues from)

## What happened

Continuation of yesterday's "fully unblocked" state. That note left one
uncommitted file and two open-but-green PRs. This session finished both:

1. Committed the pending `2026-09-17_cms-arigeo-pr115-fully-unblocked.md`
   outbox note (was untracked since the prior session ended).
2. Checked CI on PR #122 (`build` + `CodeRabbit` both SUCCESS, mergeable
   CLEAN) → merged. Commit landed on `main` at `2026-09-17T18:35:11Z`.
3. Checked CI on PR #115 (same two checks SUCCESS, though last run
   2026-09-14 — predates #122; no new CI was triggered by the merge since
   Strict Build/CodeRabbit don't touch DB/migration behavior) → merged.
   Commit landed on `main` at `2026-09-17T18:46:13Z` (head `711dc96`).
4. Confirmed via prior mission-memory record (id 805) that this repo does
   **not** auto-deploy on push to main — `One-shot Builder V2 Production
   Deploy` fired on the push but concluded `skipped` (its trigger is
   gated on a specific commit message, not a normal merge).
5. Ran the manual two-step production deploy used in the earlier saga:
   - `gh workflow run "Vercel Prebuilt Build" -f ref=main
     -f environment=production -f run_migrations=false` → run
     [35261592916](https://github.com/E0993599799/cms-arigeo/actions/runs/35261592916),
     SUCCESS. `run_migrations=false` because the `approvedForPublicUse`
     migration was already applied during the earlier verification pass
     (build run 35174066316) — Payload migrations are tracked/idempotent,
     re-running would just be a no-op.
   - `gh workflow run "Vercel Prebuilt Deploy" -f build_run_id=35261592916
     -f environment=production` → run
     [35262287340](https://github.com/E0993599799/cms-arigeo/actions/runs/35262287340),
     SUCCESS. Log shows `▲ Aliased https://cms.arigeo.com` →
     `cms-arigeo-r4bezwko9-omega-project.vercel.app`.
6. Verified independently: `curl https://cms.arigeo.com/api/media` →
   **HTTP 200**.

## Status

**Saga closed.** Both PRs merged, production redeployed on commit
`711dc96`, endpoint verified live and returning 200. No further action
needed unless a new media item gets `approvedForPublicUse: true` and
should be spot-checked on `GET /api/media`.

## Mission memory

Recorded and finalized under session `ms_82cb6027-a9da-421d-aa0b-070d85f3802a`
(project `cms-arigeo`, scope `media-approved-public-read`):
- record id 819 — merge state (superseded)
- record id 821 — production deploy proof (current, VERIFIED)

## Lesson

Same lesson as yesterday's note generalizes cleanly: this repo's deploy
is a deliberate two-step manual dispatch (build artifact → deploy
artifact), not push-triggered. After merging any PR here, always check
whether a redeploy is needed — merging to `main` alone does not ship
anything to `cms.arigeo.com`.
