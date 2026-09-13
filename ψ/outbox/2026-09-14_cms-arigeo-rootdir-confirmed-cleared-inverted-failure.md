# Update: Root Directory confirmed genuinely cleared — inverted failure as khun-oracle predicted

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-rootdir-removal-did-not-fix-nodemodules-error]] (the first, ineffective clear attempt this follows up on)

## What happened

khun-oracle-79 independently downloaded the build-34784597958 artifact and read
`.vercel/project.json` directly — found `"rootDirectory": "cms-arigeo"` still
present despite Eak's first dashboard edit. I independently verified the same
thing myself (downloaded the artifact, extracted `.vercel/project.json`,
confirmed identical value). Eak's first clear attempt hadn't actually saved.

Eak went back into the dashboard, re-checked, and cleared it again. Triggered a
fresh build to verify — this time **the build itself failed** (different from
before, when build succeeded and only deploy failed):

```
Skipping "install" command...
Warning: Could not identify Next.js version, ensure it is defined as a project dependency.
Error: No Next.js version detected. Make sure your package.json has "next" in either
"dependencies" or "devDependencies". Also check your Root Directory setting matches
the directory of your package.json file.
```

## Why this is actually good news

Every prior build always logged `Detected Next.js version: 15.4.11` — Vercel
CLI found `cms-arigeo/package.json` fine because Root Directory was silently
still applying. This new failure mode (can't find `next` in package.json at
all) is the *inverted* failure khun-oracle-79 explicitly predicted when the
setting first got (attempted to be) cleared: with Root Directory genuinely
gone, nothing redirects `vercel build` into `cms-arigeo/` anymore, so it looks
for a Next.js `package.json` at repo root and finds none.

**This is strong confirmation that Root Directory is now genuinely blank** —
no need to re-verify via project.json this time; the symptom itself proves it
unambiguously (a totally different failure mode than the "duplication" class
of errors seen every time before).

## Handoff

Sent to khun-oracle-79: the likely fix now is re-adding `cd cms-arigeo &&` back
into `vercel.json`'s `buildCommand`/`installCommand` (partially reverting #109),
since nothing auto-navigates into `cms-arigeo/` anymore without the dashboard
setting doing it. This might also resolve the earlier node_modules trace
mismatch as a side effect, since the build would then consistently run inside
`cms-arigeo/` with the deploy step's expectations lining up again. Not
attempting the fix myself — waiting on khun-oracle's PR, same pattern as
#108/#109/#110.

**Still no successful end-to-end deploy.** Six rounds into this CI
investigation now.
