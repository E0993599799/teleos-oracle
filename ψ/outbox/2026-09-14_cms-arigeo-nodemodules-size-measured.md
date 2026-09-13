# Update: measured node_modules size — 871MB, favors Next.js standalone mode

**Date**: 2026-09-14
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-14_cms-arigeo-pr112-worked-real-root-cause-found.md]] (the node_modules-missing-from-artifact bug this measurement decides between fixes for)

## What happened

khun-oracle-79 independently downloaded build 34787600828's artifact and
confirmed the finding from scratch: `node_modules` absent from the whole tree,
`filePathMap` references the exact missing file, function bundles contain only
`.next/`, `.vc-config.json`, and the launcher. Path-duplication saga confirmed
closed.

For the actual fix, khun-oracle deliberately didn't pick a direction
unilaterally (unlike #108-#112) since this is a different kind of decision —
asked for the real `node_modules` footprint before choosing between:
1. Include `node_modules` (or a pruned prod-only subset) in the tarball —
   surgical CI-only change
2. Switch `next.config.mjs` to `output: 'standalone'` — the Next.js-native fix,
   but an application config change with broader behavior implications

## Measurement

`du -sh node_modules` in the local `cms-arigeo` checkout (installed via the
same `npm ci --include=optional` the CI uses, so devDependencies included):
**871MB**. Current artifact is 27.6MB — shipping the full folder would be a
~30x size increase.

Did not separately measure a devDependencies-pruned subset — 871MB already
answers the practicality question decisively per khun-oracle's own framing
("if it's huge, standalone mode is probably the right call regardless").

## Handoff

Relayed the number to khun-oracle-79. Not implementing either option myself —
flagged that `next.config.mjs` is an application behavior change I won't touch
unilaterally, same boundary as always. Waiting on their decision + PR.

**Eight-plus rounds into this CI investigation, still zero successful
deploys** — but the remaining decision is now a clear either/or with real data
behind it, not another blind patch attempt.
