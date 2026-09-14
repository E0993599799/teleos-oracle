# Milestone: cms-arigeo image upload confirmed working — #105/#106 saga closed

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-blob-token-never-actually-set.md]] (the last blocker), the full #108-#114 chain this closes

## What happened

Ekkarat redid the Blob store connection with explicit post-connect
verification (checked `BLOB_READ_WRITE_TOKEN` actually shows for Production
scope in the env var list, not just trusting the UI). Triggered a fresh
production build (run 34861047484) + deploy (run 34861619267), aliased to
`cms.arigeo.com`.

**Ekkarat tested the real image upload live on production admin —
succeeded.**

## Full chain, for the record

This started as a routing note from khun-oracle (2026-09-13, commit
`086a74c`) asking Teleos to fix two blockers on `cms-arigeo#105`/`#106`.
What it actually took:

1. **Round 1 (yesterday)**: found Teleos lacked tool access for either fix
   (no Vercel Blob-config tool, no DB tool) — escalated to Ekkarat directly.
2. **Blob store access mismatch**: Ekkarat provisioned a new public Blob
   store himself, first attempt didn't persist (silent dashboard-save
   failure), redone with verification — this is the fix that finally landed
   today.
3. **`payload_preferences` DB investigation**: queried production Postgres
   directly, found no stale row matching the originally-diagnosed cause —
   turned out to be a red herring; the real admin-crash cause was #4 below.
4. **CI pipeline was fundamentally broken** (discovered while trying to
   redeploy the Blob fix): `vercel-prebuilt-build.yml`/
   `vercel-prebuilt-deploy.yml` had never successfully completed an
   end-to-end run. Six distinct bugs fixed across
   [cms-arigeo#108](https://github.com/E0993599799/cms-arigeo/pull/108)–[#113](https://github.com/E0993599799/cms-arigeo/pull/113)
   (khun-oracle, reviewed and merged by Teleos each round): job
   working-directory duplication, `vercel.json`'s own redundant `cd`, deploy
   artifact extraction layout, Next.js framework-detection ordering
   (depends on actual invocation cwd, not `buildCommand` strings), and
   finally the artifact never including `node_modules` at all (871MB → 32MB
   pruned via `filePathMap` tracing).
5. **React #418 nested-`<html>` crash** blocking `/admin` entirely — found
   live via direct browser check (not curl — client-side hydration crash),
   root-caused and fixed by khun-oracle in
   [cms-arigeo#114](https://github.com/E0993599799/cms-arigeo/pull/114),
   verified live on production via browser (zero console errors, full admin
   nav rendering, vs. completely blank before).
6. **The morning's Blob token fix had silently not persisted** — same
   Vercel-dashboard-save failure pattern as an earlier Root Directory
   setting that also didn't stick. Diagnosed via live error (`ENOENT: mkdir
   'media'` → traced to `payload.config.ts`'s `blobEnabled` gate) and
   redone with explicit verification.
7. **Serra caught a stale asset list**: the original 6-image mapping
   (`products/*.png`) was superseded by captain-maid's actual asset
   registry (`products-img/*`) — corrected before Ekkarat uploaded.

## Status

**All pieces of the original `cms-arigeo#105`/`#106` report are now
confirmed working end to end in production**, verified by a real upload
succeeding. Posted the final confirmation to
[cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5666347102).
Not closed the GitHub issues myself — that's Ekkarat's call.

## Fleet process note

A new mandatory fleet directive landed mid-session
(`mission-control/CLAUDE.md`, 2026-09-14): every oracle session must call a
mission-memory MCP tool (`memory_bootstrap`/`memory_record`/
`memory_handoff`/`memory_finalize`) before/during/after work, with
`MEMORY_GATE_UNAVAILABLE` as the required response if the tool doesn't
exist. Checked — no such tool is available to this session. Flagged this to
Ekkarat rather than silently ignoring the rule, but continued using this
oracle's existing `ψ/outbox/` durable-note pattern throughout (which serves
the same "don't rely on chat history alone" intent) rather than blocking on
a tool this session doesn't have.

## Also today (unrelated to cms-arigeo)

- Diagnosed and fixed two WSL2 host freezes (RAM/swap thrash → Bun-thread
  soft lockup) — hardware upgrade report published to `man-os-library`
- Hardened teleos-oracle's own Thai-language response rule via
  `.claude/settings.json` (language setting + UserPromptSubmit reminder
  hook) after this session answered a `/recap` entirely in English
- `/learn`-explored `imxv/Pretty-mermaid-skills`
