# Milestone: first successful end-to-end deploy of the cms-arigeo prebuilt pipeline

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-both-fix-options-ruled-out.md]] (the decision point this resolves)

## What happened

khun-oracle-79 built [cms-arigeo#113](https://github.com/E0993599799/cms-arigeo/pull/113)
— after `vercel build` produces `.vercel/output`, walk every function's
`.vc-config.json`, union their `filePathMap` entries, and prune `node_modules`
down to exactly that traced subset (replacing the full 871MB directory in
place). Fails loudly at build time (not silently, not at deploy time) if any
traced file is missing from disk or if the trace comes back empty. Also
discovered — by testing the collection logic against real downloaded artifact
data rather than just reasoning about it — that the `filePathMap` isn't
`node_modules`-only: 420 of 1165 unique traced entries are things like
`.next/server/webpack-runtime.js`, `vercel.json`, `.env.example`, etc. Fixed
before committing so the shipped artifact includes all of them, not just a
pruned `node_modules`.

## Review before merging

Read the full diff — sound design: defensive checks (refuses to produce an
empty prune, refuses to silently drop missing files), and the script prints
`du -sh node_modules` plus the manifest directly in the log so the actual
number is verifiable without downloading anything. Waited for the "build" PR
check to pass, merged (squash, branch deleted).

## Verified via direct log read (not a green checkmark)

Build (run [34789201963](https://github.com/E0993599799/cms-arigeo/actions/runs/34789201963)):
```
Traced dependency files: 1165, copied: 1165, missing: 0
32M	node_modules
```
**871MB → 32MB**, zero missing files, comfortably under Vercel's 250MB
per-function limit.

Deploy against it (run [34789508920](https://github.com/E0993599799/cms-arigeo/actions/runs/34789508920)):
```
Deploying omega--project/cms-arigeo
Preview: https://cms-arigeo-fqmvo3t87-omega-project.vercel.app
```
**Succeeded.** Curled the URL directly to confirm it's genuinely live, not
just a green checkmark: `HTTP/2 307`, `age: 0`.

## Significance

**This is the first fully successful build→deploy run of the entire
`vercel-prebuilt-build.yml` → `vercel-prebuilt-deploy.yml` pipeline**, across
the whole chain: #108 (job working-directory removed from build), #109
(vercel.json's own `cd` removed, later found wrong), #110 (deploy extraction
made flat, later found wrong), #111 (partial revert, still wrong for a
different reason), #112 (working-directory fully restored — fixed framework
detection), #113 (node_modules pruned to the traced subset — fixed the actual
missing-dependency bug). Every fix in that chain is now confirmed correct
end-to-end, not just individually plausible in isolation.

## What's next

Posted the milestone to
[cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5657002008).
Open question for Eak: run the real `environment=production` build+deploy now
for the actual Blob-store retest (the original point of this entire
investigation, `cms-arigeo#105`/`#106`), or have Serra do a preview-level
sanity check on the deployed URL first.

**The original Blob store token itself has still never been exercised by any
deploy** — that verification is what this whole CI investigation was blocking
on, and it's now finally within reach.
