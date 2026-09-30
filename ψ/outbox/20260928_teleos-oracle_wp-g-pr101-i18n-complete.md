FROM: teleos-oracle
RE: WP-G (#585) — i18n slice shipped, PR #101. All three buildable-now slices done.

Continued WP-G per Ekkarat's instruction: i18n after mobile/a11y.

Audit: all 25 pages on main already call getLanguage() — full per-page i18n
wiring already complete. Real gap was global, non-WP-owned chrome:
- app/forbidden/page.tsx — Thai-only 403 page, no getLanguage() call.
- app/global-error.tsx — hardcoded lang="th", Thai-only error text.
- components/app-polish.tsx — ⌘K command palette + shortcuts overlay,
  14 route labels + 8 UI strings English-only.

Localized all three via the existing arigeo_hr_lang cookie mechanism,
reusing browserLanguage()/BrowserLanguage already exported from
language-menu.tsx. Deliberately did not touch per-module content
(leave/OT-ET/payroll/claims/handbook/complaint/Document-Center/Salary-
Certificate) since those are owned by WP-A/B/C/D/F, still open — respects
docs/wp-g-regression-matrix.md's serialization reasoning.

https://github.com/E0993599799/arigeo-hr/pull/101
Status posted: https://github.com/E0993599799/mission-control/issues/585#issuecomment-5873361487

## WP-G summary: all buildable-now slices shipped
- perf/interaction-feedback: arigeo-hr#99
- mobile/a11y (WCAG 2.5.5 touch target): arigeo-hr#100
- i18n (error/access-denied pages, command palette): arigeo-hr#101

Remaining WP-G scope (#585 §19 items 23-27, the full cross-module
regression matrix) stays correctly blocked pending WP-A/B/C/D/E/F landing
on main plus live Supabase/production access (fleet-wide #551 gap) — not
something achievable from this session without that infrastructure. No
shared hot file touched across any of the three PRs. Independent verifier
for all three: Verity, not self-certifying GREEN.

Operational note for future sessions: background bash tasks
(run_in_background:true) got killed unexpectedly mid-build several times
this session with no output, even after multi-minute idle waits between
notifications. Foreground execution with the tool's max 600000ms timeout
worked reliably — worth defaulting to that for long next-build runs in
this environment.
