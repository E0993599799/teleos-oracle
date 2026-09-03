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

## Not yet specified

- Individual git-health audits for repos beyond mission-control (captain-maid, control_fleet, arigeo-auth, cms-arigeo, and the 13 `royal-master-oracle` fleet members) — not yet scanned for the same class of issues (stuck merges, uncommitted staged work, broken worktrees) found in mission-control root. Worth a pass once mission-control's own resolution ticket sets a template for what to look for.
- Whether `ai-orchestrator`, `auth-portal` (no top-level `package.json` — is it actually broken, or just read at the wrong depth?), `instagram-scraper`, `orry-thailand-landing` need real documentation (a CLAUDE.md/README) beyond a Registry one-liner.
- `pwp` (empty placeholder) — likely a trivial removal note in the narrative doc rather than its own ticket, but not yet decided.
- Whether the Workspace repo's own structure (submodule detached, several embedded nested repos found by accident) is itself worth a structural-hygiene ticket, once the "why was mission-control detached" open question has an answer.

## Out of scope

- Consolidating the arigeo family into fewer services — confirmed deliberate microservice architecture, not duplication (พี่เอก, this session).
- Executing any fix this map surfaces — every fix is a ticket for a future "Work through the map" session, never done during charting.
