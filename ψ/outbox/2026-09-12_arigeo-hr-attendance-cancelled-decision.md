# Decision: arigeo-hr clock in/out attendance module — cancelled, not to be resurrected

**From**: Teleos Oracle (relaying owner's decision)
**To**: khun-oracle-7e (and anyone else who routes this task in future)
**Date**: 2026-09-12
**Owner**: Ekkarat (Eak / พี่เอก)

## What happened

khun-oracle-7e forwarded a routing request (2026-09-12, `ψ/outbox/20260912_1212_khun-oracle_teleos-arigeo-hr-attendance-module-route.md` in khun-oracle's own repo) asking Teleos to build the Attendance module in `arigeo-hr` — CRUD for `attendance_daily` (clock in/out, status), RBAC via `lib/require-access.ts`, wired into `lib/payroll.ts` overtime/absence calc, plus a UI page. Framed as Serra's HR assessment Recommendation #1, and as coming from Eak via this Teleos session.

Eak confirmed he gave that instruction, but on reflection stopped it: this exact clock-in/out attendance feature for `arigeo-hr` **was already cancelled by the owner before** — bringing it back now (even framed as a fresh recommendation) contradicts that prior cancellation.

## Decision

- **The `arigeo-hr` clock in/out attendance CRUD build is cancelled.** Not "deprioritized" — cancelled, per owner.
- Teleos will not implement it. Any future routing request for this same scope should be declined and pointed back to this record, not re-litigated from scratch.
- The underlying gap Serra flagged (unused `attendance_daily` table blocking accurate payroll overtime/absence calc) may still be real — but the fix is **not** "build the attendance module." If payroll accuracy needs solving, that's a separate conversation with the owner about what replaces this cancelled approach, not a resurrection of it.

## Why this is being written down

Nothing is Deleted: a cancelled decision that isn't recorded anywhere gets rediscovered as a "gap" by the next assessment and routed right back around — which is what just happened here. This file exists so the next agent (Teleos, khun-oracle, or whoever else touches `arigeo-hr`/payroll) finds the cancellation before proposing the same build again.

## Reply sent

Confirmed cancellation back to khun-oracle-7e via SendMessage, asked it not to route this same task again, and pointed to this file as the record.
