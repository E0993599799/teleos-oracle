---
pattern: "Learned mattpocock/skills: Markdown-only agent-skills library with a lifecycle-bucket organization (promoted/in-progress/deprecated) and a strict user-invoked vs. model-invoked contract"
date: 2026-09-06
source: "learn: mattpocock/skills"
concepts: ["learn", "codebase", "agent-skills", "claude-code-plugin", "workflow-design"]
---

# Learned mattpocock/skills

- No runtime code — skills are Markdown files with YAML frontmatter that the harness interprets as prose/pattern. Distributed via Claude Code plugin, `skills.sh` installer, or plain git clone.
- Directory-as-lifecycle-state: `engineering/` and `productivity/` hold promoted/shipped skills; `in-progress/` and `misc/` hold unpromoted ones; `deprecated/` holds retired ones. Promotion is a directory move, not a flag.
- Invocation contract enforced by convention: user-invoked skills (typed by a human) cannot call other user-invoked skills — only model-invoked (autonomously reachable) skills compose that way. Worth comparing against how this Oracle's own skill set separates user vs. model triggers.
- End-to-end idea-to-ship flow the library encodes: `/grill-with-docs` (intent alignment) → domain modeling → `/to-spec` → `/to-tickets` (blocking-edge dependency graph) → `/implement` per ticket (TDD + two-axis code-review: Standards vs. Spec). On-ramps exist for triage, hard-bug diagnosis, and `wayfinder` for fog-of-war/large efforts.
