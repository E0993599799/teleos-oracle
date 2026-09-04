# CONTEXT: Agentic AI workspace map & improvement plan

Glossary for the wayfinder effort mapping `/mnt/d/01 Main Work/Boots/Agentic AI/` (the **Workspace** — itself one git repo with 80+ nested/embedded projects inside it, see Workspace repo below).

## Terms

**Workspace** — `/mnt/d/01 Main Work/Boots/Agentic AI/`. The full scan scope for this effort.

**Workspace repo** — the entire `/mnt/d/01 Main Work/Boots/Agentic AI/` folder is itself one git repo, remote `brtstore4340-glitch/Marcuzx-Forge.git`, last commit 2026-08-22 "fix: remove stale mission-control submodule gitlink". That commit message means `mission-control` was once tracked as a git **submodule** of this outer repo and was deliberately detached — why is unresolved, see Not yet specified. Corrects the earlier assumption that the Workspace was a plain folder of independent repos: it's an outer repo with many embedded/nested repos inside it (mission-control among them).

**mission-control (root)** — the git repo at `Workspace/mission-control/`, remote `E0993599799/arigeo-hr.git`, branch `main`. This is the **deployed checkout**: its `.vercel/project.json` links it to Vercel project `prj_hfdIL1BYKitpZTxpH5EixAputdzQ` ("mission-control" in Vercel's UI). **No longer stuck** (resolved via ticket 08, 2026-09-04): `HEAD` now exactly matches `origin/main` (`65ee5fe`); the old DU conflict (`pnpm-lock.yaml`, `tools/LAST_BACKUP_DIR.txt`) is resolved by accepting the deletion. Omega (see below) remains staged and untouched inside it, deliberately.

**arigeo-hr (nested)** — `mission-control/arigeo-hr/`, a *second, separate clone* of the same `E0993599799/arigeo-hr.git` remote, nested one level inside the mission-control root's own working tree. Its HEAD (2026-09-03, "feat(ess): employee self-service payslip view") turned out to already be pushed and identical to `origin/main`'s tip — root now matches it too (ticket 08). No longer a divergence question; nested `arigeo-hr` is a redundant, zero-risk duplicate, noted as "safe to remove later" but not urgent.

**Omega** — `mission-control/Omega/` has no `.git` of its own; running git commands inside it silently resolves to the mission-control root (same lesson as `git -C <dir>` walking up to a parent repo when there's no `.git` present), which is why it first looked like an identical duplicate checkout. It's actually a plain subdirectory holding **"OMEGA — Fencing Competition Control"** — Serra-oracle's separate, Eak-approved, actively-developed product (confirmed via closed GitHub issues #322/#323), entirely unrelated to ARIGEO HR, staged since 2026-08-31, deliberately left uncommitted/untouched (ticket 02). Not Teleos's project to manage.

**mission-control-vercel-curated2** — resolved by tickets 03, 07, 10, 11. Its `.git` looked like a real embedded repo but was actually **inert** (8KB, no object database, an interrupted-copy leftover) — removed. The working tree is a "salary-certificate" Next.js feature, confirmed **live** on `prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq` (`team_okNwqr3o8ikdFxEEpcckhPlC`, a Vercel team distinct from `team_OS8nENECHPCuieeZsEhya9sF` used everywhere else, but — per พี่เอก — `E0993599799` is the right GitHub account for it, not a separate personal identity). Now has real version control: **https://github.com/E0993599799/salary-certificate** (private, pushed 2026-09-05). Vercel's Git integration deliberately left un-relinked — a live, working deploy's trigger method isn't changed just because it was on a checklist.

**mission-control worktree** — a sibling directory named `mission-control-<slug>` at the Workspace root whose `.git` is a worktree-link (not its own repo), sharing mission-control's object store. Confirmed registered worktrees (`git worktree list` on the root): `mission-control-issue-286` (functional, branch `hermes/issue-286-m1-truth-plane`, 3 dirty files — real in-progress work), `mission-control-gh-bridge-adapter` (detached, **prunable**, git-confirmed safe), `mission-control-hermes-watcher-smoke` (detached, **prunable**, git-confirmed safe). No CI/script/doc anywhere references either prunable slug by name.

**Orphaned worktree** — a `mission-control-<slug>` directory with a worktree-link `.git` file whose target (`mission-control/.git/worktrees/<slug>`) no longer exists — not a path-format issue, the registration itself was removed. `git worktree repair` has nothing to repair against; these are plain, git-unprotected directories. Resolved by ticket 04: `agent-2` and `issue234-0a` deleted (stale/no value, execution: ticket 09); `hermes-watcher` held back — has content not found elsewhere (an installer script, a `ψ/teams/` config) pending พี่เอก's own review.

**Marcuzx-Forge plain subdirs** — `mission-control-vercel-curated` and `mission-control-vercel-deploy` have no `.git` of their own; they're plain subdirectories of the Workspace repo itself (same walk-up-to-parent effect as Omega), not separate checkouts or a naming collision with an unrelated project. Content/purpose not yet read. (Compare `mission-control-vercel-curated2` above, which *does* have its own nested `.git` — a real anomaly, unlike these two.)

**The arigeo family** — deliberate microservices of one ARIGEO product suite (confirmed by พี่เอก, not accidental duplication): `arigeo-hr` (root + nested dup), `arigeo-auth` (own remote, branch `feat/portal-app-handoff`), `cms-arigeo` (own remote, branch `feat/portal-handoff-login`), `mission-control/arigeo-project` (remote is actually named `arigeo`, not `arigeo-project` — display-name mismatch, worth a naming-hygiene note but not a consolidation target). Out of scope for consolidation; the Registry should represent them as siblings, not flag them as overlap.

**Stray git-init artifact** — an empty `.git` directory with no real repo content, found inside `captain-maid/app`, `captain-maid/app/[locale]`, `captain-maid/app/products`, `captain-maid/components/products`, and a nested `arra-oracle-v3/arra-oracle-v3`. Not real checkouts; likely accidental `git init`.

**The Registry** — `PROJECT_REGISTRY.md`. Currently exists as **5 separate stale copies** (one each in `mission-control-agent-2`, `-gh-bridge-adapter`, `-hermes-watcher`, `-hermes-watcher-smoke`, `-issue-286`, `-issue234-0a`), all generated `2026-08-04`, machine-written. **No generator script exists anywhere in the tree** — contrary to Khun-Oracle's 2026-08-28 assumption that this was a `scripts/build-registry.sh` re-run. Building the Registry means writing that tooling, not invoking it.

**royal-master-oracle fleet** — `mission-control/royal-master-oracle/`, 13 active + 4 archived Oracle identity repos (each a Claude Code agent's own repo + `ψ/` vault). `teleos-oracle` (this repo) is one of the 13.

## Known facts (from research forks, not yet turned into Registry entries)

- **Standalone Workspace subdirs** (plain dirs in the Workspace repo, not separate checkouts): `ai-orchestrator` (has a CLAUDE.md — an orchestration project), `auth-portal` (Next.js app, but **no `package.json` at top level** — incomplete or build-artifact-only at this depth), `instagram-scraper` (Python/Instaloader IG scraper, has a README), `orry-thailand-landing` (static landing page, has `_redirects` — Netlify/Cloudflare Pages style), `pwp` (**completely empty**, 0 files — dead placeholder).
- **Cruft/backup total: ~2.63 GB** — `_archive` (1.7G), `_archive-bundles` (855M), `mission-control/_cleanup-trash-20260902` (53M), 2× `Oracle-Archive-*` (~2.5M), 1 tarball (172K), `zeus-oracle-memory-backup-20260729` (84K), `_site-hierarchy-patch-backup` (20K). Not yet checked whether any of this is git-tracked (adding to Workspace repo bloat) vs. untracked/ignored.

## Open questions (carried into ticket mapping, not resolved here)

- **How to reconcile mission-control root (stuck: merge conflict + uncommitted Omega feature) with nested arigeo-hr (1 commit ahead, cleaner)** — which becomes authoritative before either can be trusted as "the" deployed source.
- **Why was `mission-control` detached from submodule tracking in the Workspace repo** (per the "remove stale mission-control submodule gitlink" commit)? Affects whether other nested repos have the same buried history.
- ~~What is `mission-control-vercel-curated2`~~ — resolved by ticket 03 (inert `.git`, real working tree tied to a third Vercel project/team). New question this raised: see ticket 07.

**all-oracle** — `royal-master-oracle/all-oracle`, real git repo, clean. Fleet Scribe + Memory Coordinator, budded from `tham`, reports to Zeus.

**agent-brain** — `royal-master-oracle/agent-brain`, real git repo, clean. A private memory-hygiene store deliberately kept outside `mission-control` so no client/project repo can accidentally sweep it up via `git add` — references `INCIDENT_2026-07-18_fleet-repo-memory-hygiene.md`.

## Not a term, but load-bearing fact

`PROJECT_REGISTRY.md` staleness was already flagged once (Teleos → Khun-Oracle, 2026-08-27/28) and punted as "not a doc I own directly." This effort's destination absorbs that loose end.
