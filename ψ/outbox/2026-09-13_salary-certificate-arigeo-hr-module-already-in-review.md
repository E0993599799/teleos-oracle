# Note: salary-certificate → arigeo-hr module scoping was already done, PR #38 open

**Date**: 2026-09-13
**Owner**: Ekkarat (Eak / พี่เอก)
**Related**: [[2026-09-12_salary-certificate-repo-mixup-correction]] — the correction that established the real intent (module inside `arigeo-hr`, not a standalone repo).

## What happened

Eak asked to start scoping the salary-certificate feature as a module inside `arigeo-hr`
(the open item left at the end of the 2026-09-12 correction). Before starting fresh work,
checked the local `arigeo-hr` checkout's git state per the ambiguous-scope protocol — found
it was already done, not just scoped:

- Branch `feat/salary-certificate-module`, commit `6ee1a5f` (`feat(hr): add salary-certificate
  module`, 2026-09-13 01:35, same-day session `session_01Dt28EuZsXrNJBiarvC76Vy`) — a full v1
  implementation: employee self-service request + HR-only approve/reject workflow, mirroring
  the existing overtime module's pattern (request/review lib functions, form-post API route,
  `requireHrAccess`-gated page, `iam_audit_events` trail). Scoped to tracking/approval only —
  no PDF/DOCX generation, no SLA tracking, no historical data migration; review restricted to
  `system_admin`/`hr_admin`/`hr_manager` (managers can submit but not approve, since requests
  carry salary/bank/loan details).
- Already pushed to origin and opened as **PR #38** (`feat(hr): add salary-certificate
  module`), currently **open**, not yet merged.
- The commit message itself references the same mixup/archival this note's related file
  describes, so this was done with full awareness of the correction.

**No new work done in this session** on this item — just verified and left as-is. Nothing to
scope; the scoping and implementation already happened.

## Why this is being written down

Same shape as the two 2026-09-12 corrections: a routed/queued task ("scope the module") can
look open from the outbox note alone, but the actual repo state had already moved past it.
Recording this here so the next session doesn't redo the implementation from scratch or
re-plan something that's sitting in review — check PR #38's status first.
