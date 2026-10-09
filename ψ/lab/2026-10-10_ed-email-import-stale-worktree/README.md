# Archived: stale ED-email-import worktree (IMAP path, never used)

**Archived**: 2026-10-10
**Original location**: `pharmacy-expiry-system-wt-ed-email-import` (git worktree of `pharmacy-expiry-system`, branch `feat/ed-retrospective-email-import`)
**Reason**: Superseded. The paused IMAP-based implementation here was abandoned mid-build on 2026-10-08
(see `ψ/memory/retrospectives/2026-10/08/21.18_popup-fix-ed-project-kpi-dedupe-pivot.md`, mission-memory
handoff #1225) when the owner redirected to reuse the existing `lib/google-gmail.ts` Gmail OAuth
infrastructure instead of IMAP. That OAuth-based implementation was built and shipped separately on
`origin/master` (commits `90e99a2`, `0d8c0fc`, `071a658`, deploy `28b8c7d` — 2026-10-10 03:58), without
ever touching this worktree. Confirmed via `/recap` on 2026-10-10: PR #313 (KPI dedupe, the task that
preempted this one) is also already MERGED.

**Contents**:
- `lib-ed-email-import/` — `lib/ed-email-import/types.ts` (IMAP-era types, never wired to any route)
- `20261008190000_ed_email_retrospective_import.sql` — DB migration for 4 tables + 5 SECURITY DEFINER
  functions supporting IMAP-based import; **never applied to any database** (confirmed in the
  retrospective's blocker log — no DB credential was available from this machine at the time).

**Disposition**: git worktree at the original path was removed via `git worktree remove --force`
after this archive was made. The branch `feat/ed-retrospective-email-import` itself was left intact
in the main `pharmacy-expiry-system` repo (not deleted) — only the working-tree checkout was removed.
