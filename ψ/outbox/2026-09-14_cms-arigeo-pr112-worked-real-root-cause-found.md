# Update: PR #112 confirmed correct (paths finally right), but real root cause found — node_modules never in the artifact

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-pr111-failed-detection-precedes-buildcommand.md]] (the detection-order bug PR #112 fixes)

## PR #112 — confirmed working for what it targeted

khun-oracle-79 opened [cms-arigeo#112](https://github.com/E0993599799/cms-arigeo/pull/112)
— a full revert of #108's changes to `vercel-prebuilt-build.yml`, restoring the
original job-level `defaults.run.working-directory: cms-arigeo` (matching
pre-#108 commit `69a32b2f`). Left `vercel.json` untouched — reasoned that with
`working-directory` restored, the CI script's dynamic
`vercel.prebuilt.json`-generation step (`JSON.parse(fs.readFileSync('vercel.json'))`)
would read `cms-arigeo/vercel.json` instead of root's, and that file already
declares `"framework": "nextjs"` explicitly.

Independently verified `cms-arigeo/vercel.json` before merging — confirmed it
exists and has exactly that explicit framework declaration, plus traced how
`vercel.prebuilt.json` actually gets generated at runtime (cwd-dependent, not a
static file) to confirm the mechanism genuinely bypasses the ambiguous
auto-detection this whole investigation has been chasing. Waited for the
"build" PR check to pass, merged (squash, branch deleted).

**Confirmed via direct log read** (per khun-oracle's explicit "don't trust a
green checkmark" instruction, having been burned twice already): fresh build
(run [34787600828](https://github.com/E0993599799/cms-arigeo/actions/runs/34787600828))
log shows `Detected Next.js version: 15.4.11` at the exact position that failed
the last two rounds. **The detection-order bug is genuinely fixed.**

## Deploy — still fails, but with the real underlying bug now exposed

Ran deploy against it (run
[34787900863](https://github.com/E0993599799/cms-arigeo/actions/runs/34787900863))
— failed again, but meaningfully differently:
```
Deploying omega--project/cms-arigeo
Error: Please ensure project dependencies have been installed:
File does not exist: "node_modules/@swc/helpers/_/_interop_require_default/package.json"
```

**No more "cms-arigeo/" prefix** — the path is now genuinely correct (matches
deploy's cwd=`cms-arigeo/` per #111, and matches how the build's trace records
paths now that its own cwd is `cms-arigeo/` too per #112). **Every path-related
fix across #108→#112 is now confirmed correct and complete.**

## The actual, previously-hidden root cause

Checked the build workflow's "Package immutable artifact" step directly:
```bash
tar -czf "prebuilt-${{ inputs.environment }}.tgz" .vercel/output .vercel/project.json
```

**`node_modules` has never been included in the artifact tarball, at any point
in this entire investigation.** Every one of the five prior path-duplication
fixes was correctly computing *where* `node_modules` should be found relative
to various cwds — but the actual file was never packaged into what gets shipped
to the deploy job, regardless of how the path resolved. This is a separate,
deeper bug that was masked by all the path-computation noise.

Why deploy needs it at all: `cms-arigeo/next.config.mjs`'s
`outputFileTracingRoot: dirname` makes Next.js's serverless function trace
reference dependency files *external* to `.vercel/output`'s otherwise
self-contained bundle. `vercel deploy --prebuilt` skips `npm install` entirely
by design (that's the point of "prebuilt") — nothing ever puts `node_modules`
where the deploy step's trace expects to find it.

## Handoff

Sent full analysis to khun-oracle-79, including a size caveat worth deciding on
deliberately: the artifact is already 27.6MB without `node_modules`; shipping
the full folder could be much larger (GitHub Actions artifact limits and
practicality both worth checking before just adding it to the tar command
blindly). Possible alternative: Next.js standalone output mode, if not already
in use, which is designed to produce a genuinely self-contained deploy bundle
without needing external `node_modules`.

**Eight rounds into this CI investigation. Still zero successful end-to-end
deploys** — but for the first time, every remaining known issue traces to one
clearly-identified, previously-hidden bug rather than a chain of
still-unexplained symptoms.
