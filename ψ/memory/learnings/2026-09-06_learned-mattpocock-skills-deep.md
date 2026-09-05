---
pattern: "Deep-learned mattpocock/skills: no test infra, quality via changesets + version-sync; skill invocation contract is the real 'API surface'"
date: 2026-09-06
source: "learn --deep: mattpocock/skills"
concepts: ["learn", "codebase", "agent-skills", "claude-code-plugin", "quality-gates", "invocation-contract"]
---

# Deep-learned mattpocock/skills

Follow-up to [[2026-09-06_learned-mattpocock-skills]] using `/learn --deep` (5 agents: architecture, code-snippets, quick-reference, testing, api-surface).

- No test runners/frameworks/CI-test-checks/lint config exist (verified by file inspection, not assumed). Quality is enforced instead through changeset-based versioning (`.changeset/*.md` required per change) and a plugin-version-sync script (`scripts/sync-plugin-version.mjs`) gated in CI via `npm run check-plugin-version`.
- The library's real "API surface" is its skill-invocation contract: `disable-model-invocation: true` frontmatter flag marks user-invoked skills; the hard architectural rule is user-invoked skills may call model-invoked skills but never other user-invoked skills. This same contract is mirrored for the Codex harness via `agents/openai.yaml`.
- Found a reusable ~240-line bash "wizard" framework embedded in setup-style skills (TTY-aware color output, cross-platform URL opening for WSL/Windows/Linux/macOS, idempotent `.env` file handling, secret redaction) — worth reference if this Oracle ever builds its own interactive setup skill.
- Contamination check on all 5 deep docs came back clean (0 hits for host-repo vocabulary); the TESTING.md doc correctly reported "no test infrastructure" without padding from unrelated repos — the exact failure mode the /learn skill's absent-referent rule guards against.
