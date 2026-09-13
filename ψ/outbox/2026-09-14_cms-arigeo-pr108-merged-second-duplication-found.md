# Update: PR #108 merged (fixed spawn-sh-ENOENT layer 1), found a second duplication bug on preview test

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-redeploy-correction-and-ci-failure]] (the `spawn sh ENOENT` failure this PR fixes)

## What happened

khun-oracle-79 found the root cause of `spawn sh ENOENT` and opened
[cms-arigeo#108](https://github.com/E0993599799/cms-arigeo/pull/108): the build
job ran Vercel CLI steps from inside `cms-arigeo/` (job-level
`defaults.run.working-directory`), while the Vercel project's own dashboard
"Root Directory" setting is *also* `cms-arigeo` — double-applying it computed a
nonexistent `.../cms-arigeo/cms-arigeo` path, which made `vercel build` fail the
instant it tried to spawn a shell (matches vercel/community#2793).

## Independent verification before merging

Pulled root `vercel.json` directly rather than trusting the PR description:
confirmed `"git":{"deploymentEnabled":false}` (explains the earlier no-auto-deploy
finding) and that `buildCommand`/`installCommand`/`outputDirectory` are all
written assuming invocation from repo root (`"cd cms-arigeo && npm run
build:ci"`, `outputDirectory: "cms-arigeo/.next"`) — matches the PR's fix
exactly. Merged with Ekkarat's approval (squash, branch deleted).

## Preview test — progress, but a second bug

Ran `vercel-prebuilt-build.yml -f ref=main -f environment=preview` (per the PR's
own test plan — validate on preview before production) → run
[34777406848](https://github.com/E0993599799/cms-arigeo/actions/runs/34777406848).

**Failed again, but with a different, more specific error** — confirms #108's fix
landed correctly for the layer it targeted:
```
Running "cd cms-arigeo && npm run build:ci"
sh: 1: cd: can't cd to cms-arigeo
Error: Command "cd cms-arigeo && npm run build:ci" exited with 2
```

**Root cause of this one**: the Vercel *project itself* has Root
Directory=`cms-arigeo` set on the dashboard (confirmed earlier this session from
`.vercel/project.json`'s `rootDirectory` field). Now that the CLI runs from real
repo root (post-#108), the CLI applies that Root Directory setting itself
(shifts cwd to `cms-arigeo/`) — but `vercel.json`'s own `buildCommand` *still*
has a redundant `cd cms-arigeo` baked in, reaching for a nonexistent
`cms-arigeo/cms-arigeo`. Same bug class as #108 (a duplicated root-directory
application), one layer deeper: dashboard setting vs. vercel.json's own `cd`,
rather than job working-directory vs. dashboard setting.

## Handoff

Posted as a comment on
[cms-arigeo#106](https://github.com/E0993599799/cms-arigeo/issues/106#issuecomment-5655563595)
and messaged khun-oracle-79 directly. Ekkarat wants khun-oracle to own this next
fix since it's the same area as their #108 work — two options flagged, neither
attempted yet:
1. Strip `cd cms-arigeo &&` from `vercel.json`'s `buildCommand`/`installCommand`,
   change `outputDirectory` to `.next` (code-only fix, no dashboard access needed)
2. Remove the Root Directory setting from the Vercel dashboard instead (needs
   Eak or someone with Vercel dashboard access)

**Not retrying production** until this resolves and validates on preview again.
The Blob store token itself still hasn't been exercised by any successful build —
still can't confirm or deny it's correct.
