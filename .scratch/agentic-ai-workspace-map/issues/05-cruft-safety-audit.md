Type: research
Status: resolved

## Question

~2.63 GB of backup/archive-pattern items were sized (see CONTEXT.md, "Known facts"): `_archive` (1.7G), `_archive-bundles` (855M), `mission-control/_cleanup-trash-20260902` (53M), 2× `Oracle-Archive-*`, 1 deprecated-fork tarball, `zeus-oracle-memory-backup-20260729`, `_site-hierarchy-patch-backup`. Sizing was done; safety wasn't checked.

Investigate: for each item, is it git-tracked (bloating the Workspace repo) or untracked/ignored, and does it hold anything not recoverable elsewhere (check for a README/manifest explaining why it was kept, check if any referenced elsewhere in the tree). Produce a per-item safe-to-delete verdict, not a deletion. Resolve by calling the Skill tool with "research".

## Answer

**Key overall finding**: none of the 8 items are or ever were git-tracked in the outer Workspace repo (two are additionally covered by an explicit `.gitignore` rule for `mission-control/`) — all ~2.63G is pure untracked/ignored filesystem cruft, not bloating repo history. No item carries a top-level README/manifest explaining why it was kept. A full-tree reference grep did not finish in reasonable time for 6 of 8 items (large, slow `/mnt/d` WSL mount) and was backed by a clean check of all high-probability doc/script locations instead — treat "none found" as "none found in partial scan + high-probability locations," not exhaustive.

| Item | Size | Git status | Referenced elsewhere | Verdict |
|---|---|---|---|---|
| `_archive` | 1.7G | untracked, no history | none found | **needs-owner-confirmation** — mixed contents (a 92MB `.7z`, 33MB zip, stray lockfile, untitled `New-folder`), large and undocumented enough to warrant a glance first |
| `_archive-bundles` | 855M | untracked, no history | none found | **needs-owner-confirmation** — contains `captain-maid-full-20260718.bundle`, a deliberate git-history backup; worth confirming captain-maid's real remote still has that history before deleting the safety net |
| `mission-control/_cleanup-trash-20260902` | 53M | gitignored, no history | none found | **safe-to-delete** — name + contents (typo-fix folders, duplicate copies, migration scratch) signal disposable trash; still only 2 days old, light-confidence |
| `Oracle-Archive-20260706_060741` | 1.4M | untracked, no history | 3 passive PROJECT_REGISTRY scan-snapshot mentions (historical records, not live dependencies) | **safe-to-delete** |
| `Oracle-Archive-20260706_062113` | 1.1M | untracked, no history | none found | **safe-to-delete** — looks like an archive-of-an-archive, leftover housekeeping |
| `mission-control/_deprecated-fork-cms-arigeo.backup-20260901.tar.gz` | 172K | gitignored, no history | none found | **safe-to-delete** — filename + internal `DO-NOT-USE.md` both confirm deprecation |
| `zeus-oracle-memory-backup-20260729` | 84K | untracked, no history | none found | **safe-to-delete** — superseded memory snapshot, same project as item 4 |
| `_site-hierarchy-patch-backup` | 20K | untracked, no history | none found | **needs-owner-confirmation** (low stakes) — a rollback kit for a specific patch; safe once that patch is confirmed applied and stable |

**Scope note from the audit**: the outer Workspace repo itself currently has unrelated uncommitted changes (modified/deleted tracked files under `ai-orchestrator/`, `auth-portal/`, and others) — outside this ticket's scope, not touched, but flagged as a new open question (see CONTEXT.md).
