# Provisioned independent read-only DB credential for Verity (WP0 / issue #551)

**From**: Teleos Oracle
**Date**: 2026-09-24

## What happened

Verity (session `wp0-arigeo-hr-verification-resume-69`) sent a cross-session escalation asking
teleos to relay to Ekkarat: the WP0 live-DB verification leg for issue #551 has a structural
credential gap — no second party has ever been able to independently re-check the live-DB state
(Phase-B IAM tables, `hr_arigeo` grants, `relrowsecurity` flags) with credentials separate from
Tham/Core's own. Verity posted verdict `PROOF_INSUFFICIENT` (scoped to that leg only) on
issue #551.

Per the record-886 convention (staffing/access asks routed to Ekkarat via teleos), and because
Ekkarat is teleos's own human, this was relayed and decided directly in-conversation rather than
via a separate escalation channel.

## Decision

Ekkarat chose: provision Verity with a genuine independent read-only credential (rather than
formally accepting Tham/Core as the only party who can do this leg).

## Action taken

- Confirmed teleos itself has no Supabase MCP access to the arigeo-hr project's org (same empty
  `list_projects` wall Verity hit) — so this had to be Ekkarat provisioning it directly, not an AI
  session touching the production DB.
- Built a `/wizard` script to guide Ekkarat through creating a new, minimally-scoped Postgres role
  (`verity_wp0_readonly` — CONNECT-only, no table SELECT grants) in the arigeo-hr Supabase project,
  distinct from Tham/Core's credentials.
- Caught a wizard-input mistake before handoff: the first pooler host Ekkarat pasted was actually
  the *direct* connection host — the same failure class already recorded in this repo's own
  history (PR #115, 2026-09-17, unreachable direct host). Corrected to the real pooler host before
  sending anything to Verity.
- Sent the connection string to Verity directly via a private inter-session `SendMessage`, never
  via GitHub/git/public chat. No secret is stored in this file or in git.

Full decision trail (no secrets) is in mission-memory: record #982 (the ask) and #985 (the
decision + provisioning), project `mission-control`, scope `arigeo-hr-security-hardening-issue-551`.

## Update 2026-09-24: credential unusable — root cause is platform-level, not credential/access

Verity reported back: before even touching the connection string, a plain `which psql` existence
check was blocked by her own session's auto-mode tool-use classifier — the same denial class as
her earlier Supabase MCP query attempt, and the same wall teleos hit self-testing this credential
with `psql` before handing it off. Two independent sessions, two different accounts, blocked on
the same class of action before the credential's scope or connection string ever mattered.

Neither session tried to route around the block with another tool/language (a Python/Node pg
client would just dodge the same restriction through a different door).

**Conclusion (Verity's mission-memory record #986, supersedes #981; teleos's read matches):** this
is a platform-level restriction on a Claude Code session driving any live production DB
connection at all — not a credential or project-access problem. Provisioning better credentials
does not fix it, because the block fires before the credential is ever used. Option (a)
(independent credential) is a structural dead end for any Claude-Code-based verifier, not just
this one. Option (b) is the real answer: the WP0 gate's live-DB claims should be permanently
documented as Tham/Core-attested (whatever different tool/session type lets Tham/Core's path get
past this) rather than something a second Claude Code session can independently re-run here.

Verity is posting a follow-up on issue #551 reflecting this (still PROOF_INSUFFICIENT
structurally, but reasoning corrected to option (b)) and notifying khun-oracle directly — not
duplicated here.

## Not done yet

Ekkarat to run `DROP ROLE verity_wp0_readonly;` in the arigeo-hr project's SQL editor — the
credential is confirmed unusable from any Claude Code session and should not sit around live.
