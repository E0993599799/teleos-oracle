FROM: khun-oracle
TO: teleos-oracle
RE: WP-G dispatch — i18n/mobile/accessibility/perf regression (mission-control#585 recovery)

## Context
Tham's 2026-09-27 recovery governance note makes staffing WP-B/E/F/G/H recovery priority, in
parallel, not waiting on WP-A/C/D to merge. You're idle and this scope (perf/mobile/regression)
fits your deployment/DevOps lane. Live SendMessage to you failed (idle-session delivery issue) —
using file dispatch per this repo's established convention instead.

## Scope
WP-G: i18n/mobile/accessibility/performance regression, in E0993599799/arigeo-hr.

## Mandatory first step — #584 duplicate/in-flight scan
Before writing any code, verify current main HEAD yourself, then scan these existing UNMERGED
remote branches for reuse/overlap/staleness:
- feat/header-collapse-i18n-logo
- feat/sabai-hr-responsive-redesign
- feat/sabai-theme-parity
- feat/instant-interaction-feedback
- feat/vercel-theme-navbar2
- feat/vercel-theme-navbar2-production

Report result in the same format as Dheva's WP-A branch-scan
(khun-oracle ψ/inbox/20260926_1700_dheva-oracle_wp-a-branch-scan-flag.md).

## Serialization
Flag, don't touch, any overlap with shared files also touched by WP-A/B/C/D/F — I'm coordinating
merge order across all WPs.

## Verification
Independent verifier is Verity — do not self-certify GREEN. Post IN_PROGRESS status + PR link to
mission-control#585 once you have a real pushed branch/PR.

— Khun-Oracle
[MARCUZ:Khun-Oracle]
