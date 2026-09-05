# mattpocock/skills: Testing & Quality Patterns

**Repository**: https://github.com/mattpocock/skills  
**Analysis Date**: 2026-09-06  
**Agent**: Claude (Agent 4: Testing & Quality Patterns)

## Summary

This is a **Markdown-based skills collection**, not a code library. It has **no traditional test infrastructure** (no test runners, test files, or test frameworks). Quality assurance is enforced through **documentation structure, changesets versioning, and manual validation** rather than automated testing.

## Test Infrastructure: None Present

Verified via:
- `find ... -name "*test*" -o -name "*spec*"`: Only found references in documentation (a single SKILL.md file at `skills/engineering/tdd/tests.md`, changesets, and docs entries about testing practices)
- `package.json` scripts: Contains only `changeset`, `version`, and `check-plugin-version` — no test, lint, or validate commands
- `.github/workflows/`: Only `release.yml` exists — handles versioning only, no CI test checks
- `.git/hooks/`: Empty (no pre-commit, pre-push hooks)
- Root config files: No `.eslintrc`, `.prettierrc`, `jest.config.js`, `vitest.config.ts`, `tsconfig.json`, or equivalent

**This is correct and intentional** for the repo's purpose: it's a **curated collection of skill definitions and documentation**, not code that runs. Skills are Markdown files with YAML frontmatter and prose instructions for AI agents.

## Quality Gates That ARE Present

### 1. **Changeset-Based Versioning** (Primary QA Mechanism)

**Location**: `.changeset/` directory with `config.json`

- Every change to promoted skills is tracked via `.changeset/*.md` files (currently 9 pending changes)
- Each changeset is manually authored with a description of what changed and why
- `changesets/cli` orchestrates version bumps and changelog generation via GitHub Actions
- Configuration at `.changeset/config.json` specifies:
  - GitHub-based changelog generation
  - Private package versioning (tag all changes)
  - Base branch is `main`
  - Linked and fixed dependency groups (none currently configured)

**Quality role**: Ensures every change is *documented before merge* (changesets block until described), creates an auditable CHANGELOG.md, and gates releases.

### 2. **Plugin Version Sync Validation**

**Location**: `scripts/sync-plugin-version.mjs`

- Runs as part of `npm run version` (after `changeset version`)
- Validates that `package.json` version matches `.claude-plugin/plugin.json` version
- With `--check` flag, exits with status 1 if versions drift (used in CI via `npm run check-plugin-version`)
- Rewrites only the version line to preserve formatting and key order

**Quality role**: Prevents shipping a plugin with a stale version number (would break plugin updates).

### 3. **GitHub Actions Release Workflow**

**Location**: `.github/workflows/release.yml`

Steps:
1. Checkout repo (v4)
2. Setup Node.js 22
3. Install dependencies with `npm ci`
4. Run `changesets/action@v1` to:
   - Version (run `npm run version`)
   - Publish (run `npx changeset tag`)
   - Commit with message "chore: version skills"
   - Title: "chore: version skills"

**Quality role**: Automates versioning and tagging on main-branch pushes; prevents manual version mistakes.

### 4. **Skill Structure Validation** (Manual, Documentation-Based)

**Location**: `CLAUDE.md` + `.agents/` directory

**Mandatory requirements for promoted skills** (tracked in `CLAUDE.md`):
- Must have entry in top-level `README.md` with link to `SKILL.md`
- Must appear in `.claude-plugin/plugin.json` `skills` array
- Must have reference in relevant bucket `README.md` (engineering/, productivity/)
- Must have human-facing docs page at `docs/<bucket>/<skill-name>.md` (four mandatory sections: What it does, When to reach for it, Common questions, It's working if)
- Every `SKILL.md` must link to its docs page
- No em-dashes allowed anywhere in prose (enforced via document review)
- User-invoked vs model-invoked distinction enforced via frontmatter (`disable-model-invocation: true`)
- Codex compatibility layer: each skill must have `agents/openai.yaml` with metadata

**Quality role**: Ensures consistency, discoverability, and multi-harness compatibility. Non-compliance is caught during pull review.

### 5. **Plugin Validation Tool** (User-Invoked, Not Automated)

**Mentioned in**: CLAUDE.md line 11

```bash
claude plugin validate . --strict
```

- Can be run after touching plugin manifest (`.claude-plugin/plugin.json`)
- Not integrated into CI; user is responsible for running it
- Validates plugin structure and content

**Quality role**: Validates plugin correctness before shipping; prevents malformed plugin distribution.

### 6. **ADR (Architecture Decision Record) Pattern**

**Location**: `.agents/adr/` directory (2 ADRs present)

- Decisions about the repo's evolution are recorded as markdown files with numbered prefixes
- Used to explain non-obvious choices (e.g., why it ships as Claude Code plugin rather than Codex plugin)

**Quality role**: Institutional memory and reasoning transparency.

## Skills That Teach & Support Quality (Not Infrastructure Tests)

The repo itself doesn't test skills, but it *provides* skills that teach quality practices for users:

### Model-Invoked Skills (Auto-Triggered During Work)
- **`/tdd`** — Test-driven development red-green-refactor loop
- **`/code-review`** — Two-axis code review (Standards + Spec fidelity)
- **`/diagnosing-bugs`** — Disciplined debugging loop
- **`/domain-modeling`** — Active domain model sharpening (challenges terms, stress-tests edge cases, updates CONTEXT.md)
- **`/codebase-design`** — Shared discipline for designing deep modules
- **`/resolving-merge-conflicts`** — Hunk-by-hunk conflict resolution

### User-Invoked Skills (Manual Trigger)
- **`/grill-with-docs`** — Grilling + domain model building (builds shared language)
- **`/improve-codebase-architecture`** — Scans for deepening opportunities (scopes to actively-developed paths, not dormant code)

These skills are *for users of the repo*, not *internal testing* of the skills themselves.

## Documentation as Quality Enforcement

The repo uses **documentation rigor as a quality gate**:

1. **SKILL.md frontmatter** — YAML metadata declaring invocation mode and behavior
2. **CONTEXT.md** — Domain language glossary (shared vocabulary reduces verbosity and prevents miscommunication)
3. **docs/** — User-facing skill documentation with four mandatory sections
4. **README.md hierarchy** — Promotes skills by listing and linking them (non-promotion means no listing)
5. **Prose standards** — No em-dashes (enforced via code review, not linting)

**Why this matters**: Skills are instructions for AI agents. The quality gate is whether the agent can understand them clearly and consistently. Documentation rigor ensures that; automated code tests would not.

## Naming & Categorization

Skills are categorized by:
- **Promotion level**: `engineering/` and `productivity/` = shipped and documented; `in-progress/` = public but beta; `misc/` and `deprecated/` = not promoted
- **Invocation**: User-invoked (explicit slash command) vs model-invoked (agent-reachable, can auto-trigger)
- **Type**: Research (AFK), Prototype (HITL), Grilling (HITL), Task (HITL or AFK) — for `wayfinder` decision tickets only

## Version Management

- **Current version**: 1.2.3 (from `package.json`)
- **Sync point**: `.claude-plugin/plugin.json` must match `package.json` version
- **Release cadence**: Changeset-driven (on-demand, not scheduled)
- **Changelog**: Auto-generated from changesets via `@changesets/changelog-github`

## Missing or Not Present

- **No unit tests**: Skills are documentation, not code
- **No integration tests**: No test harness or test runner
- **No linting**: No ESLint, Prettier, or style checkers
- **No pre-commit hooks**: Manual discipline only
- **No automated skill evaluation**: No tool to verify a skill works as documented
- **No continuous deployment**: Release is manual (changeset workflow on push to main)

## Validation Checklist (Pre-Release, Manual)

Based on `CLAUDE.md` and observed practice:

- [ ] Every changed promoted skill has a changeset file
- [ ] Changeset describes what changed and why
- [ ] SKILL.md frontmatter is correct (invocation mode declared)
- [ ] Docs page updated or created with four mandatory sections
- [ ] README entries updated (top-level + bucket)
- [ ] Plugin manifest updated (`.claude-plugin/plugin.json`)
- [ ] No em-dashes in prose
- [ ] `npm run check-plugin-version` passes
- [ ] `claude plugin validate . --strict` passes (if touched manifests)
- [ ] `scripts/link-skills.sh` runs successfully (if adding/removing skills)

## Conclusion

**mattpocock/skills is a documentation-and-process-driven repository**, not a code-tested one. Its quality assurance relies on:
1. **Changeset gating** (every change is described before merge)
2. **Documentation requirements** (consistency enforced through structure)
3. **Version sync checks** (prevents shipping with stale metadata)
4. **GitHub Actions release automation** (prevents manual versioning errors)
5. **Manual code review** (prose standards, linking, invocation correctness)

This is appropriate for a **skill collection** where the "code" is human-readable instructions for AI agents, and correctness is enforced by clarity and consistency of prose, not by automated test execution.
