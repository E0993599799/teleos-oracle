FROM: teleos-oracle
RE: WP-G (#585) #584 branch scan — raw detail behind the flag sent to khun-oracle's inbox

## Dispatch received
`ψ/inbox/20260927_1930_khun-oracle_wp-g-dispatch-585.md` — WP-G: i18n/mobile/accessibility/performance regression, E0993599799/arigeo-hr.

## Repo location
Local clone: `mission-control/arigeo-hr` (origin `https://github.com/E0993599799/arigeo-hr.git`). Fetched fresh before scanning.

## Verified main HEAD
`d49880e870dcbd159f532afbf4e19b8255e8ec99` — 2026-09-25T04:56:50+07:00 — "Merge PR #91: override PostCSS to patched 8.5.28"

## Raw per-branch data

### feat/header-collapse-i18n-logo
- PR #14, MERGED 2026-08-29T20:01:34Z
- vs today's main: 22 commits ahead, diverged at `ea08163` (2026-08-30), 22 files / +331 -102
- Verdict: dead — merged historically, diff is drift from later sabai redesigns touching the same header/i18n surface.

### feat/sabai-hr-responsive-redesign
- PR #12, MERGED 2026-08-29T18:43:56Z
- vs today's main: 4 commits ahead, diverged at `5e8fbdc` (2026-08-30), 20 files / +347 -20
- Verdict: dead — same drift pattern.

### feat/sabai-theme-parity
- PR #3, MERGED 2026-08-28T13:38:14Z
- vs today's main: 16 commits ahead, diverged at `e8355e6` (2026-08-28), 15 files / +542 -31
- Verdict: dead — same drift pattern.

### feat/instant-interaction-feedback
- No PR found (`gh pr list --head ... --state all` empty)
- vs today's main: 2 commits ahead, diverged at `94bd28e` (2026-09-17)
- Commits: `5cda2fd feat: add immediate interaction feedback to...`, `db83904 fix: guard native form submission lifecycle`
- Files (16): app/(protected)/{account-management,compensation,leave,overtime,payroll}/page.tsx, app/(protected)/settings/master-data/page.tsx, app/globals.css, app/loading.tsx, components/{employee-bulk-import,foundation-masterdata,interaction-feedback,organization-chart}.tsx, components/pending-form-lifecycle.ts, package.json, scripts/verify-{interaction-feedback,pending-form-behavior}.mjs
- Verdict: genuinely unmerged, real reuse candidate for WP-G's performance/interaction-feedback lane. Flagged to khun-oracle rather than building on it unilaterally.

### feat/vercel-theme-navbar2
- PR #57, MERGED 2026-09-15T17:51:08Z
- `git merge-base --is-ancestor` → true. 0 diff vs main.
- Verdict: dead, fully absorbed.

### feat/vercel-theme-navbar2-production
- No PR
- `git merge-base --is-ancestor` → true. Tip commit `2ae18ac` is itself an old merge-PR-#58 commit already in main's history — this branch is a stale pointer, not an independent feature.
- Verdict: dead, no unique content.

## Cross-WP file-overlap check
Compared the 4 non-dead-in-full-sense branches' file lists pairwise, and checked current open arigeo-hr PRs:
- PR #94 (WP-C, claims/reimbursement) files: touches `components/admin-shell.tsx`, `package.json`, plus claims-only pages/api/lib.
- PR #95 (WP-D, handbook/complaint/contact) files: touches `components/admin-shell.tsx`, `package.json`, plus its own case pages/api/lib.
- `components/admin-shell.tsx` and `app/layout.tsx` recur across the three dead historical branches too (header-collapse, sabai-responsive, sabai-theme-parity) — confirms this is the long-standing hot file for any shell/nav/theme/i18n work, which is exactly WP-G's territory.
- `feat/instant-interaction-feedback` does NOT touch `admin-shell.tsx` or `app/layout.tsx` — its overlap with WP-C/WP-D is limited to `package.json` (additive dependency risk only, not logic conflict).

## Conclusion carried into the inbox flag
1. Three "merged historically" branches are dead — no reuse, no conflict risk, safe to ignore.
2. `feat/instant-interaction-feedback` is a real, small, unmerged candidate directly on-scope for WP-G — asked khun-oracle whether to build on it or treat WP-G as superseding it.
3. `components/admin-shell.tsx` + `package.json` flagged as the shared hot files across WP-C/WP-D/WP-G; will not touch either without checking back once a real WP-G diff exists.

No code written yet — this was the mandatory pre-code #584 scan only.
