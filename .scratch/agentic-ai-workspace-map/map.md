# Map: Agentic AI workspace map & improvement plan

## Destination

A fresh, accurate `PROJECT_REGISTRY.md` snapshot — one canonical file at the Workspace root (`/mnt/d/01 Main Work/Boots/Agentic AI/PROJECT_REGISTRY.md`), one row per repo (path, remote, branch, last commit, purpose, owner, status incl. `archived`), replacing the 5 fragmented stale copies — plus a companion narrative doc in Teleos's `ψ/` with prioritized findings and recommendations across hygiene, consolidation, and process/tooling. **Plan only**: this map documents and prioritizes; it doesn't execute fixes itself. Building the generator script/automation is also deferred to a ticket, not assumed to happen for free.

## Notes

- Domain/glossary: see [CONTEXT.md](./CONTEXT.md) in this same directory — read it before working any ticket, terms are load-bearing.
- Skills every session should consult: `grilling` + `domain-modeling` for HITL decision tickets; `research` for AFK fact-finding tickets.
- Standing preference: never execute a fix (prune a worktree, resolve a conflict, delete cruft) without it being its own resolved ticket first — even an obviously-safe one. The whole point of this effort is that "obviously safe" already got a Workspace into a stuck-and-undocumented state once.
- The arigeo family (arigeo-hr, arigeo-auth, cms-arigeo, arigeo-project) is confirmed deliberate microservices — do not open a consolidation ticket for it.
- mission-control root is the Vercel-deployed repo for the mission-control project (`prj_hfdIL1BYKitpZTxpH5EixAputdzQ`) and is currently stuck (merge conflict + uncommitted feature) — treat anything touching it as production-adjacent, confirm with พี่เอก before any real change even after a ticket resolves.

## Decisions so far

- [What is mission-control-vercel-curated2](issues/03-vercel-curated2-investigation.md): its `.git` is an inert leftover (8KB, no object database, interrupted-copy artifact) safe to remove — but the working tree is a real "salary-certificate" feature tied to a *third* distinct Vercel project/team. Graduated a new question into ticket 07.
- [Cruft/backup safety audit](issues/05-cruft-safety-audit.md): none of the 2.63G is git-tracked (no history-bloat risk). 5 of 8 items are safe-to-delete; `_archive` (1.7G), `_archive-bundles` (855M, contains a deliberate captain-maid git-bundle backup), and `_site-hierarchy-patch-backup` need a quick owner glance before deletion.
- [mission-control root reconciliation](issues/01-mission-control-root-reconciliation.md): root has zero commits not already in `origin/main` (0 ahead, 5 behind) — no real divergence from nested `arigeo-hr` to reconcile, root is just stale plus local mess. Sync root to `origin/main`; accept both DU-conflict deletions (`pnpm-lock.yaml`, `tools/LAST_BACKUP_DIR.txt`); nested `arigeo-hr` left as a low-priority "remove later" candidate. Execution graduated into ticket 08.
- [Omega feature disposition](issues/02-omega-feature-disposition.md): Omega isn't abandoned debris — it's **"OMEGA — Fencing Competition Control,"** Serra-oracle's separate, Eak-approved, actively-developed product (confirmed via closed GitHub issues #322/#323), unrelated to ARIGEO HR. Leave entirely untouched; not Teleos's call. Root's sync (ticket 08) must explicitly preserve it.
- [Execute root sync](issues/08-execute-root-sync.md): done. Root's `HEAD` now exactly matches `origin/main` (`65ee5fe`); both conflicts resolved by accepting deletion; Omega untouched byte-for-byte. Root is no longer stuck.
- [Worktree cleanup decision](issues/04-worktree-cleanup-decision.md): the 3 "broken" worktrees weren't a path-format issue — their registration was fully removed from `mission-control/.git/worktrees/`, they're plain unprotected directories now. Remove `gh-bridge-adapter`, `hermes-watcher-smoke` (registered, prunable), delete `agent-2` and `issue234-0a` outright (stale/no value); hold off on `hermes-watcher` (has uniquely-located content) pending พี่เอก's own look. Execution graduated into ticket 09.
- [Execute worktree cleanup](issues/09-execute-worktree-cleanup.md): done. `gh-bridge-adapter`/`hermes-watcher-smoke` actually had the Windows-path mismatch (not the 3 orphans as first thought) — `git worktree remove --force` refused, fixed via `git worktree prune`. All 4 directories removed and verified gone; `hermes-watcher` and `issue-286` confirmed untouched.
- [Registry & narrative doc](issues/06-registry-and-narrative-doc.md): both destination deliverables written. `/mnt/d/01 Main Work/Boots/Agentic AI/PROJECT_REGISTRY.md` (25 rows, explicit needs-audit markers, no silent omissions) and `teleos-oracle/ψ/writing/2026-09-04_agentic-ai-workspace-map-findings.md` (prioritized narrative). Generator automation flagged as a gap, not built.

## Not yet specified

- The outer Workspace repo itself (remote `brtstore4340-glitch/Marcuzx-Forge.git`) currently has unrelated uncommitted changes (modified/deleted tracked files under `ai-orchestrator/`, `auth-portal/`, and others) — surfaced incidentally by the cruft audit, not yet scoped or investigated. Separate from mission-control root's own stuck state (ticket 01).

- Individual git-health audits for repos beyond mission-control (captain-maid, control_fleet, arigeo-auth, cms-arigeo, and the 13 `royal-master-oracle` fleet members) — not yet scanned for the same class of issues (stuck merges, uncommitted staged work, broken worktrees) found in mission-control root. Worth a pass once mission-control's own resolution ticket sets a template for what to look for.
- Whether `ai-orchestrator`, `auth-portal` (no top-level `package.json` — is it actually broken, or just read at the wrong depth?), `instagram-scraper`, `orry-thailand-landing` need real documentation (a CLAUDE.md/README) beyond a Registry one-liner.
- `pwp` (empty placeholder) — likely a trivial removal note in the narrative doc rather than its own ticket, but not yet decided.
- Whether the Workspace repo's own structure (submodule detached, several embedded nested repos found by accident) is itself worth a structural-hygiene ticket, once the "why was mission-control detached" open question has an answer.
- Whether OMEGA (a second, unrelated product living inside `mission-control/` by directory-nesting accident) eventually deserves its own repo — explicitly not this map's call; Serra owns it.

## Out of scope

- Consolidating the arigeo family into fewer services — confirmed deliberate microservice architecture, not duplication (พี่เอก, this session).
- Executing any fix this map surfaces — every fix is a ticket for a future "Work through the map" session, never done during charting.
