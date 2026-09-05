# mattpocock/skills — Architecture

## Project Identity

**mattpocock-skills**: A curated collection of reusable agent skills (slash commands and behaviors) for Claude Code, Codex, and Agent-Skills-standard harnesses. Designed to address four core failure modes in AI-assisted development: misalignment, verbosity, buggy code, and architectural drift.

**Distribution**: Published as:
- Claude Code plugin (official marketplace)
- skills.sh installer (NPM-based, editable per-project)
- GitHub source (for forking/hacking)

**Ownership**: Matt Pocock. Licensed MIT.

---

## Directory Structure & Organization Philosophy

```
skills/
├── engineering/          [24 promoted skills for code work]
├── productivity/         [7 promoted skills for workflow]
├── in-progress/         [6 skills in beta, public, feedback wanted]
├── misc/                [4 skills rarely used, not promoted]
└── deprecated/          [retired skills, preserved for history]

docs/
├── engineering/         [public-facing .md for every promoted engineering skill]
└── productivity/        [public-facing .md for every promoted productivity skill]

.claude-plugin/
├── plugin.json         [Claude Code plugin manifest (explicit skill array)]
└── marketplace.json    [fallback marketplace entry for direct repo install]

.agents/
├── adr/                [architectural decision records]
├── install-block.md    [unified installation instructions]
├── invocation.md       [model-invoked vs. user-invoked contract]
└── writing-docs.md     [docs authoring standard]

.github/workflows/
└── release.yml         [automated versioning via changesets]

scripts/
├── link-skills.sh      [symlink promoted skills into ~/.claude/skills]
├── list-skills.sh      [enumerate all skills in repo]
└── sync-plugin-version.mjs  [keep plugin.json and package.json versions in sync]
```

### Bucketing Philosophy

**Promoted buckets** (`engineering/`, `productivity/`):
- Shipped in Claude Code plugin and installed via skills.sh
- Appear in top-level README.md with detailed reference entries
- Have dedicated public documentation pages (under `docs/`)
- Must maintain consistent invocation contract and naming

**Non-promoted buckets**:
- `in-progress/`: Beta skills, public, feedback actively solicited, not shipped in plugin
- `misc/`: Utilities kept around but rarely used, not actively promoted
- `deprecated/`: No longer used but preserved (Git history is immutable)

Every skill has its own directory, grouped by bucket. This segregation enforces discipline: a skill enters the public surface consciously, not by accident.

---

## Entry Points

### For Users (External)

1. **Claude Code Plugin** (`/plugin install mattpocock-skills`)
   - Reads `.claude-plugin/plugin.json` for skill list
   - Distributes via official marketplace (auto-updated when pin advances)
   - Skills are read-only; updates arrive automatically

2. **skills.sh** (`npx skills@latest add mattpocock/skills`)
   - Installs editable copies into project (`~/.claude/skills` or per-harness)
   - Supports Claude Code, Codex, and Agent-Skills-standard harnesses
   - User controls updates (`npx skills update`)

3. **Direct Repository**
   - Fork or clone for hacking
   - Scripts support local installation via `scripts/link-skills.sh`

### For Development (Internal)

1. **CLAUDE.md** (codebase conventions)
   - Defines bucketing rules, naming contract, and promotion workflow
   - Documents requirement that promoted skills appear in both README.md and plugin.json
   - Mandates ADR presence for major decisions

2. **scripts/link-skills.sh**
   - Symlinks all promoted (non-deprecated, non-misc, non-in-progress) skills into `~/.claude/skills` and `~/.agents/skills`
   - Re-run after adding, removing, or renaming skills

3. **changesets**
   - `.changeset/` directory holds individual change entries before versioning
   - `npm run version` triggers changesets action, tags release, updates CHANGELOG.md

---

## Core Abstractions & Relationships

### 1. Skill (Base Unit)

Every skill occupies a directory with:
- **SKILL.md**: Executable documentation (YAML frontmatter + Markdown body)
- **agents/openai.yaml**: Codex UI metadata + invocation policy
- **Supporting files** (optional): reference docs, examples, supplementary guides

**SKILL.md structure**:
```yaml
---
name: skill-name
description: Human or model-facing description (per invocation type)
disable-model-invocation: true  # [optional, user-invoked only]
---
# Markdown body: discipline, patterns, and reasoning
```

### 2. Invocation Contract (User-Invoked vs. Model-Invoked)

**User-invoked** (`disable-model-invocation: true` + `policy.allow_implicit_invocation: false`):
- Only reachable by human typing the skill name (e.g., `/ask-matt`)
- Example: routers, orchestrators, one-off setup
- `description` is human-facing: concise, trigger-list stripped

**Model-invoked** (default):
- Reachable by model autonomously or human user
- Example: reusable disciplines, reference material
- `description` is model-facing: rich with triggers ("Use when the user says..., mentions..., asks for...")

**Constraint**: User-invoked skills cannot call other user-invoked skills; they may only invoke model-invoked skills (via Skill tool calls in markdown, phrased as explicit instructions).

### 3. Skill Dependency Graph

Skills reference each other via explicit **Skill tool calls** (not deep cross-references):
```markdown
Call the Skill tool with "grilling" for the interview primitive.
Call the Skill tool with "domain-modeling" to sharpen the shared vocabulary.
```

Non-operative prose (router maps, README.md listings) uses plain skill names: `/grill-me` rather than Skill tool calls, since no invocation is happening, only naming.

**Routing hub**: `ask-matt` (engineering) and `grill-me` (productivity) act as routers, mapping user-reachable skills to flows. These must be kept synchronized with actual skill additions/removals.

### 4. The Main Flow (Idea → Ship)

```
1. /grill-with-docs        [sharpen idea + build domain model + CONTEXT.md]
        ↓
2. Branch: runnable answer needed?
   ├─ Yes → /prototype      [throw away code to answer design question]
   │        /handoff         [carry findings back]
   └─ No → continue
        ↓
3. Branch: multi-session build?
   ├─ Yes → /to-spec         [synthesize thread into spec]
   │        /to-tickets      [split into tracer-bullet tickets, blocking edges]
   │        /implement × N   [build each ticket isolated, /tdd + /code-review]
   └─ No → /implement        [single context, same window]
        ↓
Final: /code-review         [two-axis: Standards + Spec, before commit]
```

### 5. On-Ramps (Starting Situations)

- **Bugs/requests backlog** → `/triage` → agent-ready issues → `/implement`
- **Hard bug** → `/diagnosing-bugs` (feedback loop-first) → regression test
- **Huge effort** → `/wayfinder` (decision-ticket map, foggy → clear) → `/to-spec` → main flow

### 6. Domain Model (Glossary + ADRs)

**CONTEXT.md**: Shared vocabulary for the project
- Defines domain-specific terms (e.g., "materialization cascade" vs. "making a lesson real")
- Reduces agent verbosity; enables concise communication
- Maintained by `/domain-modeling` skill

**ADRs** (`.agents/adr/`): Architectural decision records
- `0001-*`: Explicit setup pointer only for hard dependencies
- `0002-*`: Ship as Claude Code plugin (decision: defer Codex native plugin due to manifest limitations)
- Updated inline by `/grill-with-docs` and `/domain-modeling`

---

## Dependencies

### Build & Release

```json
{
  "name": "mattpocock-skills",
  "version": "1.2.3",
  "devDependencies": {
    "@changesets/cli": "^2.30.0",
    "@changesets/changelog-github": "^0.7.0"
  },
  "packageManager": "npm@10.9.4"
}
```

**No runtime dependencies**. Skills are pure Markdown documents; execution is handled by the harness (Claude Code, Codex, etc.).

### External Integrations

- **Claude Code plugin system**: Reads `.claude-plugin/plugin.json` for skill paths
- **skills.sh**: NPM-based installer, parses repo structure, copies files
- **GitHub**: Release workflow uses changesets to version and tag

### CI/CD

**`.github/workflows/release.yml`**:
- Trigger: push to main
- Steps:
  1. Checkout repo
  2. Setup Node.js v22
  3. Install changesets
  4. Run `npm run version` (changesets action creates PR + tags)
  5. Publish tags
- Uses changesets for version + changelog automation

---

## Key Design Decisions

### 1. Bucketing + Curation

**Why**: Distinguishes promoted (shipped in plugin) from experimental/deprecated skills. Prevents accidental breakage when forking.

**Implementation**: CLAUDE.md enforces that promoted skills appear in both `README.md` and `plugin.json`. Scripts validate consistency.

### 2. Invocation as First-Class Contract

**Why**: Different skill types have different semantics (orchestration vs. reusable discipline). Marking this explicitly prevents accidental breakage when skills invoke each other.

**Implementation**: Frontmatter flags (`disable-model-invocation`), parallel config in Codex (`agents/openai.yaml`), and strict validation in invocation.md.

### 3. Claude Code Plugin Over Codex

**Why**: Claude Code's `.claude-plugin/plugin.json` accepts an explicit skill array; Codex only accepts a single path and discovers recursively. There's no way to curate the promoted subset for Codex without restructuring or duplicating.

**Current approach**: 
- Ship Claude Code plugin (official marketplace)
- Keep skills.sh as universal installer (covers Codex, other harnesses)
- Defer native Codex plugin until ecosystem improves

### 4. Markdown + YAML Frontmatter Only

**Why**: Skills are executable documentation. No code to compile, no dependencies to install, no framework lock-in. Harness interprets SKILL.md directly.

**Consequence**: All skill logic is prose, patterns, and checklists. The harness is responsible for orchestrating the flow.

### 5. Symlink Strategy for Local Development

**Why**: Developers modify skills in the repo; symlinks keep those changes live in `~/.claude/skills` without copying.

**Limitation**: Codex drops symlinks on install, so native Codex plugin distribution requires either restructuring or flat copies.

---

## File Relationships & Sync Points

| File | Purpose | Sync Point |
|------|---------|-----------|
| `package.json` | Project metadata + version | Same version as `.claude-plugin/plugin.json` |
| `.claude-plugin/plugin.json` | Claude Code manifest | Lists all and only promoted skills (both buckets) |
| `README.md` (top-level) | User-facing reference | Links to every promoted skill's `SKILL.md`, grouped as User-invoked / Model-invoked |
| `skills/*/README.md` | Bucket rosters | Lists every skill in the bucket with one-line description + `SKILL.md` link |
| `docs/*/SKILL.md` | Promoted skill docs | Public version at `aihero.dev/skills-<name>`, mirrors `skills/` bucketing |
| `.agents/adr/*` | Decisions | Updated inline when a decision affects multiple buckets |
| `CLAUDE.md` | Development rules | Updated when bucketing rules or sync points change |
| `.agents/writing-docs.md` | Docs template | Consulted when creating `docs/*/SKILL.md` |
| `skills/*/SKILL.md` | Skill content | Source of truth; updated first, then propagate to docs |

**Release cycle** (via changesets):
1. Author `.changeset/*.md` entries describing changes
2. `npm run version` → bumps `package.json`, updates `.claude-plugin/plugin.json` version, tags release
3. GitHub Action publishes to official marketplace (pin advances when tag is cut)

---

## Execution Model

### How Claude Code Runs a Skill

1. User types `/skill-name` (user-invoked) or model decides skill is relevant
2. Claude Code loads `SKILL.md` from `.claude-plugin/plugin.json` path
3. Parses frontmatter (name, description, invocation type)
4. Renders Markdown as a system prompt / guidance to Claude
5. Claude executes the discipline (tdd red-green-refactor, code review axes, etc.) within a single conversation
6. Skill may call other (model-invoked) skills via Skill tool; markdown prose directs the flow

### No Runtime Compiled Code

Skills are **not** programs; they're **patterns**. The agent follows the pattern, making decisions at each step. This allows:
- Maximum flexibility (each run is unique, contextual)
- Zero installation burden (just files)
- Model-agnostic (any LLM can read Markdown)
- Forkable/hackable (edit a .md file, not code)

---

## Extension Points

### Adding a New Skill

1. Create `skills/<bucket>/<skill-name>/`
2. Write `SKILL.md` with frontmatter + discipline
3. Write `skills/<bucket>/<skill-name>/agents/openai.yaml` with UI metadata + invocation policy
4. If promoted (engineering/productivity):
   - Add entry to `.claude-plugin/plugin.json` `skills` array
   - Add entry to top-level `README.md` under User-invoked or Model-invoked
   - Add entry to `skills/<bucket>/README.md`
   - Create `docs/<bucket>/<skill-name>.md` with four sections: What it does, When to reach for it, Common questions, It's working if
   - Update `skills/engineering/ask-matt/SKILL.md` if a user-reachable skill
5. Run `scripts/link-skills.sh` to symlink into local harness directories

### Evolving an Existing Skill

1. Edit `skills/<bucket>/<skill-name>/SKILL.md`
2. Update `skills/<bucket>/<skill-name>/agents/openai.yaml` if invocation logic changes
3. If promoted and behavior/trigger changed, update `docs/<bucket>/<skill-name>.md`
4. If user-reachable, re-read `ask-matt/SKILL.md` and sync router if needed
5. Create `.changeset/<slug>.md` entry describing the change
6. On next release, `npm run version` auto-updates changelog + tag

---

## Notable Patterns

### Grilling Pattern

`/grill-me` and `/grill-with-docs` both invoke the model-invoked `/grilling` skill, which implements the interview primitive. This reuse of a core discipline across multiple user-invoked flows is central to composability.

### Discipline Over Tooling

Skills encode best practices (red-green-refactor, two-axis code review, domain-modeling loops) as Markdown checklists, not as framework code. This shifts responsibility to the agent, which is more flexible.

### Decision vs. Deliverable

`/wayfinder` explicitly produces decisions (decision tickets, ADRs), not features. Only when the way is clear does it hand off to `/to-spec` + `/implement` for deliverables. This distinction prevents large efforts from becoming accidental builds.

### Context Hygiene

Flows emphasize keeping conversation context unbroken through critical phases (grilling → spec → tickets) so later phases inherit all the reasoning. Phase boundaries (`/handoff`) are explicit breaking points.

---

## Out-of-Scope / Limitations

1. **No Codex native plugin** (yet): Codex manifest doesn't support explicit skill arrays. Awaiting either API evolution or restructuring.
2. **No compiled/executable components**: Skills are pure Markdown; no CLI binaries, no generated code, no middleware.
3. **No cross-session state**: Each skill runs in isolation within a single conversation. Persistent state (e.g., test results across sessions) must be managed by the harness or external tools.
4. **em-dashes banned**: Codebase style rule (CLAUDE.md) forbids em-dashes; rewrite with comma, colon, period, parenthesis, or conjunction instead.

---

## Summary

**mattpocock/skills** is a curated library of AI-agent behaviors, not a framework. Its architecture prioritizes:
- **Composability**: Small, inverted skills that invoke each other via explicit Skill tool calls
- **Forkability**: Pure Markdown, no dependencies, editable everywhere
- **Curation**: Bucketing enforces clear promotion boundaries (what ships vs. what's experimental)
- **Discipline**: Encodes patterns (TDD, domain modeling, code review) as reusable, teachable workflows
- **Versioning**: Changesets manage releases; version sync enforced across manifests

Distribution spans three channels: Claude Code plugin (managed, auto-updating), skills.sh (editable, self-updating), and git (for hacking). Each skill is a self-contained `.md` file paired with harness-specific metadata (`agents/openai.yaml`). The invocation contract (user-invoked vs. model-invoked) ensures skills compose predictably without accidental circular dependencies.
