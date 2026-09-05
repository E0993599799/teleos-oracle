# skills Learning Index

## Source
- **Origin**: ./origin/
- **GitHub**: https://github.com/mattpocock/skills

## Explorations

### 2026-09-06 0112 (default)
- [[2026-09-06/0112_ARCHITECTURE|Architecture]]
- [[2026-09-06/0112_CODE-SNIPPETS|Code Snippets]]
- [[2026-09-06/0112_QUICK-REFERENCE|Quick Reference]]

**Key insights**:
- A curated Markdown-only agent-skills library (no runtime code) — 24 engineering + 7 productivity skills, distributed via Claude Code plugin, `skills.sh` installer, or git. Skills are prose/pattern, interpreted by the harness, not executed.
- Organized by lifecycle bucket (`engineering/`, `productivity/` = promoted; `in-progress/`, `misc/` = unpromoted; `deprecated/` = retired) with a strict user-invoked vs. model-invoked invocation contract — user-invoked skills cannot call other user-invoked skills.
- Encodes a full idea-to-ship workflow: `/grill-with-docs` (align intent) → domain modeling → `/to-spec` → `/to-tickets` → `/implement` (TDD + two-axis code-review) — with on-ramps for triage, hard-bug diagnosis, and fog-of-war planning (`wayfinder`) on large efforts.
