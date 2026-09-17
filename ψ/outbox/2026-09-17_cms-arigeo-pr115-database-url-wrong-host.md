# Finding: DATABASE_URL secret points to unreachable direct Supabase host, not the pooler

**Date**: 2026-09-17
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: cms-arigeo PR #115 (blocked), [[2026-09-17_cms-arigeo-pr115-migration-gate-fix-opened.md]] (the two prior fixes this follows)

## What happened

With PR #122's fixes in place (gate + secret name), dispatched "Vercel
Prebuilt Build" with `run_migrations: true` against PR #115's branch
(`fix/media-approved-public-read`), `environment: preview`.

Both prior fixes confirmed working — log showed `Database available: yes`,
`Run migrations: yes` — but the actual migration step then failed:

```
Error: getaddrinfo ENOTFOUND db.pkfgbbqbbgnzphihcyzc.supabase.co
```

Run: https://github.com/E0993599799/cms-arigeo/actions/runs/35164978763

## Root cause (verified from source, not guessed)

`secrets.DATABASE_URL` holds the **direct** Supabase host
(`db.<ref>.supabase.co`). GitHub Actions runners cannot resolve it — a
known issue: Supabase's direct-connection host is IPv6-only in many
regions, and GH-hosted runners have no IPv6 route.

The codebase already expects the **Supavisor pooler** host instead:
`scripts/supabase-pooler-mode.test.mjs` and `payload.config.ts` both
assert/normalize a `*.pooler.supabase.com` hostname (rewriting port
`5432`→`6543` for transaction mode). So the app's own DB-URL handling was
built around the pooler string; the secret's current value just isn't
that.

## Not acting unilaterally on this

Fixing this means changing the real `DATABASE_URL` GitHub secret to the
actual Supabase pooler connection string — pulled from Supabase Dashboard
→ Project Settings → Database → Connection pooling → Transaction mode.
Per standing policy (never touch prod credentials directly, never
guess/fabricate a connection string), did not attempt this — asked
Ekkarat to run `gh secret set DATABASE_URL -R E0993599799/cms-arigeo`
with the pooler string himself.

## Status

**Blocked on Ekkarat** updating the `DATABASE_URL` secret. Once updated,
re-dispatch "Vercel Prebuilt Build" with `run_migrations: true` against
`fix/media-approved-public-read`, confirm `payload migrate` actually runs
against the pooler, then re-test `GET /api/media` for the 500 before
merging PR #115.

## Lesson

Third distinct blocker layered on the same symptom chain (missing gate →
wrong secret name → wrong secret value), each one only surfaced by
actually running the thing, not by reading the YAML. Confirms the earlier
lesson from 09-14: verify live behavior at every layer, don't assume the
previous fix was the last one.
