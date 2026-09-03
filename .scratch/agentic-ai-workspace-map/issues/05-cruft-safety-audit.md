Type: research
Status: claimed

## Question

~2.63 GB of backup/archive-pattern items were sized (see CONTEXT.md, "Known facts"): `_archive` (1.7G), `_archive-bundles` (855M), `mission-control/_cleanup-trash-20260902` (53M), 2× `Oracle-Archive-*`, 1 deprecated-fork tarball, `zeus-oracle-memory-backup-20260729`, `_site-hierarchy-patch-backup`. Sizing was done; safety wasn't checked.

Investigate: for each item, is it git-tracked (bloating the Workspace repo) or untracked/ignored, and does it hold anything not recoverable elsewhere (check for a README/manifest explaining why it was kept, check if any referenced elsewhere in the tree). Produce a per-item safe-to-delete verdict, not a deletion. Resolve by calling the Skill tool with "research".
