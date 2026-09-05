# mattpocock/skills Repository Architecture

## Overview

`mattpocock/skills` is a curated, intentional collection of agent skills (Claude Code slash commands and Codex/other-harness agent behaviors) designed to operationalize real-world software engineering practices. The repository is a **monolithic skill collection** published as:

1. A **Claude Code plugin** (`.claude-plugin/plugin.json` + marketplace distribution)
2. An **installable via skills.sh** (for Codex and other Agent-Skills-compatible harnesses)
3. A **symlink-based local install** (`scripts/link-skills.sh` for development)

The philosophy: small, composable skills with explicit relationships, not a monolithic do-everything agent.

---

## Directory Structure & Organization Philosophy

### Root Level

```
skills/
  ├── skills/               [PRIMARY: Skill implementations, organized by lifecycle/domain]
  ├── .agents/              [Meta: ADRs, invocation rules, plugin infrastructure]
  ├── .claude-plugin/       [Plugin manifest & marketplace (Claude Code)]
  ├── .github/              [CI/CD and repository templates]
  ├── .out-of-scope/        [Knowledge base: what this repo explicitly won't do]
  ├── docs/                 [Public-facing documentation (mirrors promoted skills)]
  ├── scripts/              [Maintenance scripts: linking, validation, versioning]
  ├── package.json          [Monorepo root, npm version management]
  ├── CHANGELOG.md          [Release notes]
  ├── CONTEXT.md            [Domain language/vocabulary for the repo itself]
  ├── CLAUDE.md             [Project instructions & curation rules]
  └── README.md             [User-facing overview & install instructions]
```

### `skills/` Subdirectory: Lifecycle-Based Organization

Skills are organized into **four bucket folders** representing their lifecycle stage:

#### Promoted Buckets (shipped to users)

1. **`engineering/`** (18 skills)
   - Daily code work: building, reviewing, testing, debugging
   - User-invoked: `ask-matt`, `grill-with-docs`, `triage`, `improve-codebase-architecture`, `setup-matt-pocock-skills`, `to-spec`, `to-tickets`, `implement`, `wayfinder`
   - Model-invoked: `prototype`, `diagnosing-bugs`, `research`, `tdd`, `domain-modeling`, `codebase-design`, `code-review`, `resolving-merge-conflicts`, `wizard`

2. **`productivity/`** (9 skills)
   - Non-code workflow: communication, learning, process automation
   - User-invoked: (none listed as such in README)
   - Model-invoked: `grill-me`, `grilling`, `handoff`, `teach`, `to-questionnaire`, `wait-what`, `writing-for-agents`, `grill-me`, `grill-with-docs`
   - Note: Some entries appear in multiple places; mapping appears to also include routers

#### Non-Promoted Buckets (not shipped)

3. **`in-progress/`** (9 skills)
   - Beta features: public on purpose, feedback wanted, not in the plugin
   - Examples: `claude-handoff`, `implement-spec`, `loop-me`, `retro`, `setup-ts-deep-modules`, `writing-beats`, `writing-fragments`, `writing-shape`

4. **`deprecated/`**
   - Retired skills: no longer used, kept for historical context
   - Visible in `.out-of-scope/` or changelog

5. **`misc/`** (4 skills)
   - Kept around but rarely used, not promoted
   - Examples: `git-guardrails-claude-code`, `migrate-to-shoehorn`, `scaffold-exercises`, `setup-pre-commit`

### Skill Directory Structure (Uniform Pattern)

Each skill directory follows a consistent shape:

```
skills/<bucket>/<skill-name>/
  ├── SKILL.md                   [Primary: Skill definition + behavior]
  ├── agents/
  │   └── openai.yaml            [Codex UI metadata; invocation policy]
  ├── agents/                     [Some skills add subdirectories]
  └── [optional supporting files]
```

#### Common Supporting Files (Found in Various Skills)

- `PHASE-BOUNDARIES.md` — Phase transition logic (e.g., `ask-matt`)
- `AGENT-BRIEF.md` — How to write durable agent briefs (e.g., `triage`)
- `OUT-OF-SCOPE.md` — What a skill won't handle (e.g., `triage`)
- `DEEPENING.md`, `DESIGN-IT-TWICE.md` — Methodology docs
- `ADR-FORMAT.md`, `CONTEXT-FORMAT.md` — Shared vocabulary templates
- `SKILL-MECHANICS.md` — How skills work (e.g., `writing-for-agents`)
- `LOGIC.md`, `UI.md`, `HTML-REPORT.md` — Implementation details
- Domain-specific config files (e.g., `domain.md`, `triage-labels.md` in `setup-matt-pocock-skills`)

### Meta Directories

#### `.agents/`
Infrastructure, ADRs, and plugin development guidance:
- `adr/` — Architectural Decision Records
  - `0001-explicit-setup-pointer-only-for-hard-dependencies.md`
  - `0002-ship-as-a-claude-code-plugin.md` (decision rationale for plugin architecture)
- `install-block.md` — Canonical install instructions (single source of truth)
- `invocation.md` — Model-invoked vs user-invoked classification rules
- `writing-docs.md` — Documentation standards and templates

#### `.claude-plugin/`
Claude Code plugin distribution:
- `plugin.json` — Plugin manifest with explicit skills array (paths to promoted skills only)
- `marketplace.json` — Fallback single-plugin marketplace (for direct repo install)
- Version synced with `package.json`

#### `.out-of-scope/`
Knowledge base: documented non-goals and scope boundaries

#### `docs/`
Public-facing documentation (mirrors promoted skills structure):
- `docs/engineering/` — ~18 pages (one per promoted skill)
- `docs/productivity/` — ~9 pages (one per promoted skill)
- Pattern: four-section structure (What it does, When to reach for it, Common questions, It's working if)
- Published at `https://aihero.dev/skills-<skill-name>` (bucket-agnostic URL)

---

## Entry Points (All of Them)

### 1. User-Invoked Skills (Human as Caller)

**Reachable only when typed explicitly** (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false`).

#### Primary Router
- **`/ask-matt`** (user-invoked)
  - Maps all user-reachable skills
  - Outlines the main flow (`idea → ship`)
  - Describes on-ramps (triage, bug diagnosis, greenfield planning)
  - Updated whenever skills are added/renamed

#### Setup Precondition
- **`/setup-matt-pocock-skills`** (user-invoked)
  - Configures issue tracker (GitHub, Linear, or local)
  - Configures triage labels
  - Configures doc layout
  - Must run once per repo before other skills work

#### Daily Code Flows
- **`/grill-with-docs`** (user-invoked) → `grilling` (model-invoked)
  - Interview to sharpen ideas, build CONTEXT.md and ADRs
- **`/triage`** (user-invoked) → `grilling`, `domain-modeling` (model-invoked)
  - Move issues through state machine; produces agent-ready briefs
- **`/to-spec`** (user-invoked)
  - Converts conversation thread into a spec
- **`/to-tickets`** (user-invoked)
  - Breaks specs/plans into tracer-bullet tickets with blocking edges
- **`/implement`** (user-invoked, but internally drives `tdd` and `code-review`)
  - Builds work from a spec/ticket set
- **`/wayfinder`** (user-invoked) → `grilling`, `domain-modeling` (model-invoked)
  - Plans huge efforts via decision tickets on issue tracker

#### Codebase Health
- **`/improve-codebase-architecture`** (user-invoked) → `grilling`, `codebase-design` (model-invoked)
  - Surfaces deepening opportunities

### 2. Model-Invoked Skills (Agent as Caller)

**Reachable by model or user** (rich trigger phrasing in description). Can be called by other skills via the Skill tool or triggered auto-invocation by the model.

#### Vocabulary / Reference Layer
- **`/domain-modeling`** (model-invoked)
  - Sharpen domain language, challenge fuzzy terms, write ADRs
  - Single source of truth for project vocabulary
- **`/codebase-design`** (model-invoked)
  - Deep-module vocabulary: module, interface, depth, seam, adapter, leverage
  - Shape design for modules

#### Development Primitives
- **`/grilling`** (model-invoked)
  - Raw interview loop: rounds, frontier, facts/decisions split
  - Invoked by `grill-with-docs`, `grill-me`, `triage`, `wayfinder`, `improve-codebase-architecture`
- **`/tdd`** (model-invoked)
  - Red-green-refactor loop, vertical slices
  - Invoked internally by `implement`
- **`/code-review`** (model-invoked)
  - Two-axis review: Standards + Spec
  - Invoked by `implement` before commit

#### Specialized Diagnostics & Research
- **`/diagnosing-bugs`** (model-invoked)
  - Disciplined bug fix: tight feedback loop → minimize → hypothesize → instrument → fix → regress-test
- **`/research`** (model-invoked, background agent)
  - Investigates questions against primary sources; produces cited Markdown

#### Merge Conflict Handling
- **`/resolving-merge-conflicts`** (model-invoked)
  - Resolves in-progress merge/rebase conflicts hunk by hunk by intent

#### Prototyping & Planning
- **`/prototype`** (model-invoked)
  - Throwaway code answering one design question (state model or UI)
- **`/wizard`** (model-invoked)
  - Interactive bash for human-only steps (credentials, infrastructure, dashboards)

#### Phase Transitions & Handoffs
- **`/handoff`** (model-invoked)
  - Portable markdown file between harnesses/directories/colleagues
- **`/clear`** (mentioned in flows, clears context window)

#### Communication & Learning
- **`/grill-me`** (model-invoked)
  - Stateless grilling (no CONTEXT.md)
- **`/wait-what`** (model-invoked)
  - Re-pitches recent message using CONTEXT.md vocabulary
- **`/teach`** (model-invoked)
  - Multi-session learning using repo as workspace
- **`/to-questionnaire`** (model-invoked)
  - Writes a questionnaire when the blocker is in someone else's head
- **`/writing-for-agents`** (model-invoked)
  - Reference for writing documents agents consume

#### Productivity (Varied)
- **`/handoff`** (productivity/handoff) — transition between contexts
- **`/write-for-agents`** — see above (productivity/writing-for-agents)
- In-progress: `loop-me`, `retro`, `claude-handoff`

### 3. Setup Entry Point

**Mandatory one-time configuration**:
```
/setup-matt-pocock-skills
```
Configures:
- Issue tracker (GitHub Issues, Linear, local `.scratch/` Markdown files)
- Triage labels (maps canonical role names to tracker label strings)
- Doc output directory

---

## Core Abstractions & Their Relationships

### 1. The Skill Abstraction

A **skill** is the atomic unit. Core properties:

- **SKILL.md** — Behavior specification (frontmatter + markdown prose)
- **Frontmatter** (YAML):
  - `name` — Skill identifier
  - `description` — One-line summary (human-facing for user-invoked; rich triggers for model-invoked)
  - `disable-model-invocation` — (optional) Makes it user-only
- **agents/openai.yaml** — Codex UI metadata
  - `interface.display_name` — UI label
  - `interface.short_description` — Picker description
  - `policy.allow_implicit_invocation: false` — For user-invoked skills in Codex
- **Lifecycle**: promoted (`engineering/`, `productivity/`) or non-promoted (`in-progress/`, `misc/`, `deprecated/`)

### 2. Invocation Modes

Two orthogonal axes:

**User-invoked**:
- Reachable only when human types it (Claude Code: `disable-model-invocation: true`; Codex: `policy.allow_implicit_invocation: false`)
- Description is human-facing (no trigger lists)
- Cannot call another user-invoked skill (only model-invoked ones)
- Examples: `ask-matt`, `grill-with-docs`, `triage`, `implement`, `to-spec`, `to-tickets`, `wayfinder`

**Model-invoked**:
- Reachable by model or user
- Description includes rich triggers ("Use when the user wants…, mentions…, asks for…")
- Can be called by other skills via Skill tool
- Can be auto-triggered by model when conditions match
- Examples: `grilling`, `tdd`, `code-review`, `domain-modeling`, `codebase-design`

### 3. Dependency Expression (Skill-to-Skill)

Dependencies are **explicit tool calls**, not file references:

```
Call the Skill tool with "grilling"
```

This maintains harness neutrality and ensures proper invocation. Naming rules:
- **Operative** invocation: `Call the Skill tool with "<skill-name>"`
- **Router prose** (in README, ask-matt): bare skill names acceptable (human choice)
- **Two skills needed**: make two calls (not one call with both names)
- **Precondition is user-invoked**: phrase as human instruction, not Skill tool call

### 4. Flow Structures

The skill set encodes **five distinct flow patterns**:

#### Main Flow: Idea → Ship
1. **Grilling** (`/grill-with-docs`) → sharpen idea
2. **Branch on scope**: Prototype (`/prototype` → `/handoff` → `/handoff` back) if needed
3. **Branch on size**:
   - Single session: `/implement` (drives `/tdd` + `/code-review`)
   - Multi-session: `/to-spec` → `/to-tickets` → `/implement` per ticket (each with fresh context)
4. **Closure**: `/code-review` before commit

#### On-Ramp: Triage
- Incoming issues → `/triage` → state machine → agent-ready briefs → `/implement`

#### On-Ramp: Bug Diagnosis
- Regression/intermittent → `/diagnosing-bugs` → tight feedback loop → regression test

#### On-Ramp: Greenfield Planning
- Large, foggy efforts → `/wayfinder` → decision ticket map (on issue tracker) → map clears → `/to-spec` → `/to-tickets` → `/implement`

#### On-Ramp: Codebase Health
- Spare moment → `/improve-codebase-architecture` → surfaces deepening candidate → `/grill-with-docs` on chosen one

#### Standalone (off all flows)
- `/grill-me` (stateless grilling)
- `/resolving-merge-conflicts` (mid-conflict)
- `/research` (background investigation)
- `/to-questionnaire` (delegate to external person)
- `/wizard` (human-only steps)
- `/wait-what` (re-pitch current message)
- `/teach` (multi-session learning)

### 5. Phase Boundaries

**Five options at phase boundaries** (grilling → implementation, etc.):
1. **Continue** — stay in same context
2. **Clear** — empty window, lose history
3. **Handoff** — portable markdown (new harness/directory/colleague)
4. **Subagent** — tightly scoped task to new window, get report back
5. **Compact** — compress context, seed fresh session (default)

Decision tree and reasoning in `ask-matt/PHASE-BOUNDARIES.md`.

### 6. Domain Modeling (Vocabulary)

Three key documents per repo:

- **CONTEXT.md** — Glossary of domain terms, hard-to-reverse decisions
- **ADRs** (Architecture Decision Records) — Formalized decisions
- **AGENT-BRIEF.md patterns** — How triaged issues are briefed to agents

Updated inline during `/grill-with-docs`, `/triage` (via `/grilling`), `/domain-modeling`, and `/wayfinder`.

### 7. Issue Tracker Abstraction

Skills work with three tracker types:

1. **GitHub Issues** — Native blocking links, labels, milestones
2. **Linear** — Similar feature set
3. **Local** — `.scratch/<feature>/issues/` directory with Markdown files (one file per ticket)

Configured once via `/setup-matt-pocock-skills`. Triage labels map canonical names (`needs-triage`, `ready-for-agent`, `ready-for-human`, `wontfix`) to tracker label strings.

---

## Dependencies (Direct + Transitive Patterns)

### Package.json Dependencies

**Root `package.json`** (monorepo root):
```json
{
  "name": "mattpocock-skills",
  "version": "1.2.3",
  "private": true,
  "scripts": {
    "changeset": "changeset",
    "version": "changeset version && node scripts/sync-plugin-version.mjs",
    "check-plugin-version": "node scripts/sync-plugin-version.mjs --check"
  },
  "devDependencies": {
    "@changesets/changelog-github": "^0.7.0",
    "@changesets/cli": "^2.30.0"
  },
  "packageManager": "npm@10.9.4"
}
```

**No individual skill has its own `package.json`**. This is a documentation-and-markdown-driven repo, not a Node.js build artifact.

### Dependency Patterns (Skill-to-Skill)

#### Explicit Invocations (Skill Calls)

Skills invoke other skills via prose instructions. Key patterns:

**`ask-matt`** (router) → all user-reachable skills (names them, doesn't invoke)

**`grill-with-docs`** → calls `/grilling`, updates `CONTEXT.md`/ADRs in place

**`triage`** → calls `/grilling` and `/domain-modeling` (per issue)

**`improve-codebase-architecture`** → calls `/grilling` and `/codebase-design`

**`wayfinder`** → calls `/grilling` and `/domain-modeling` (per decision ticket)

**`implement`** → internally drives `/tdd` (red-green slices) + `/code-review` (before commit)

**`diagnosing-bugs`** → produces regression test (tight feedback loop)

**`research`** → background agent, outputs cited Markdown file

**`prototype`** → outputs shareable HTML or UI variations file

**Handoff chain**: `/handoff` out → `prototype` (in new directory) → `/handoff` back

#### Primitive Reuse

- **`/grilling`** — Core interview primitive used by: `grill-with-docs`, `grill-me`, `triage`, `wayfinder`, `improve-codebase-architecture`
- **`/tdd`** — Red-green-refactor driving `/implement` internally
- **`/code-review`** — Two-axis review (Standards + Spec) closing `/implement`
- **`/codebase-design`** vocabulary — Referenced by `/tdd` and `/improve-codebase-architecture`
- **`/domain-modeling`** — Vocabulary layer referenced by all flows

#### Context Hygiene Dependencies

Skills depend on **CONTEXT.md** being accurate and current:
- `grill-with-docs` builds/updates it
- `wait-what` reads it to rephrase
- `teach` uses it as a workspace
- All other skills assume it's available and current

Triage labels (from `/setup-matt-pocock-skills` config) are depended on by `/triage`, `/wayfinder`, `/improve-codebase-architecture`.

### Infrastructure Dependencies

#### Plugin Distribution Chain

```
package.json (version X.Y.Z)
  ↓ (sync via scripts/sync-plugin-version.mjs)
.claude-plugin/plugin.json (version X.Y.Z)
  ↓ (reads list of skill paths)
skills/ (promoted skills only)
  ↓ (publish)
Claude Code official marketplace (auto-update)
```

Invariants:
- `package.json` version ≠ `.claude-plugin/plugin.json` version → validation failure
- `.claude-plugin/plugin.json` skills array must list ALL promoted skills, no more, no less

#### Local Dev Chain

```
scripts/link-skills.sh
  ↓ (finds all SKILL.md excluding deprecated/ and misc/)
creates symlinks
  ↓
~/.claude/skills/ (Claude Code)
~/.agents/skills/ (Codex and Agent-Skills harnesses)
```

Skips: `deprecated/`, `misc/`. Includes: `engineering/`, `productivity/`, `in-progress/`.

#### Documentation Chain

```
skills/<bucket>/<skill-name>/SKILL.md
  ↓ (manually synced per .agents/writing-docs.md rules)
docs/<bucket>/<skill-name>.md
  ↓ (published)
https://aihero.dev/skills-<skill-name>
```

Sync triggered by changes to SKILL.md or skill additions/renames.

### README Chains

**Promoted skills** must appear in:
1. Top-level `README.md` (grouped by User-invoked / Model-invoked)
2. Bucket `README.md` (e.g., `skills/engineering/README.md`)
3. `.claude-plugin/plugin.json` `skills` array
4. `docs/<bucket>/<skill-name>.md` (new page or update)
5. `ask-matt/SKILL.md` router (if user-reachable)

**Non-promoted skills** must NOT appear in: top-level README, `.claude-plugin/plugin.json`, docs/.

---

## Installation & Distribution

### Two Philosophies

1. **Claude Code Plugin** (managed, read-only)
   ```bash
   claude plugins install mattpocock-skills
   ```
   - One command, auto-updates
   - Read-only bundle
   - Promoted skills only
   - Manifest: `.claude-plugin/plugin.json`

2. **skills.sh** (editable, all harnesses)
   ```bash
   npx skills@latest add mattpocock/skills
   ```
   - User picks skills at install time
   - Copies editable files into project
   - Works on Codex, Claude Code, others
   - Forking-friendly
   - **Must** include `setup-matt-pocock-skills`

Both routes available, not both at once (symlink linking).

### Local Development Install

```bash
scripts/link-skills.sh
```

Creates symlinks in `~/.claude/skills` and `~/.agents/skills` to this repo's `skills/` tree, excluding `deprecated/` and `misc/`.

---

## Curation & Lifecycle Rules

From `CLAUDE.md`:

1. **Promoted buckets** (`engineering/`, `productivity/`):
   - Must appear in top-level README.md with link to SKILL.md
   - Must have entry in `.claude-plugin/plugin.json` `skills` array
   - Must have reference in bucket README.md (User-invoked / Model-invoked groups)
   - Must have docs page at `docs/<bucket>/<skill-name>.md`
   - Can be router skill (e.g., `ask-matt`) or standalone

2. **Non-promoted buckets** (`in-progress/`, `misc/`, `deprecated/`):
   - Must NOT appear in top-level README.md
   - Must NOT appear in `.claude-plugin/plugin.json`
   - May appear in bucket README.md (flat list)
   - Must NOT have docs page

3. **Skills in any bucket**:
   - Every SKILL.md must have `agents/openai.yaml` beside it (Codex UI metadata)
   - User-invoked skills: `disable-model-invocation: true` + `policy.allow_implicit_invocation: false` in both files
   - Model-invoked skills: omit both, keep rich trigger phrasing in description
   - No em-dashes in prose (use comma, colon, period, parentheses, or conjunction)

4. **ask-matt Router**:
   - Must be updated whenever a user-reachable skill is added/renamed/changed
   - Maps all flows and on-ramps
   - Describes phase boundaries and phase transition options
   - Single source of truth for user-invoked entry points

---

## Key Files & Their Purposes

| File/Dir | Purpose |
|----------|---------|
| `package.json` | Monorepo version (synced to `.claude-plugin/plugin.json`) |
| `CONTEXT.md` | Domain language for the repo itself (issue tracker, triage, vocabulary) |
| `CLAUDE.md` | Curation rules, bucket lifecycle, router maintenance |
| `README.md` | User-facing overview, install routes, motivation for each skill category |
| `.claude-plugin/plugin.json` | Claude Code plugin manifest (promoted skills + version) |
| `.claude-plugin/marketplace.json` | Fallback marketplace (direct repo install) |
| `.agents/adr/0002-ship-as-a-claude-code-plugin.md` | Why Claude plugin (not Codex); deferral of Codex native plugin |
| `.agents/install-block.md` | Single source of truth for install wording |
| `.agents/invocation.md` | User-invoked vs model-invoked classification rules |
| `.agents/writing-docs.md` | Template, section order, and update triggers for docs pages |
| `scripts/link-skills.sh` | Symlinks promoted + in-progress skills to local harness directories |
| `scripts/sync-plugin-version.mjs` | Keeps `package.json` version in sync with `.claude-plugin/plugin.json` |
| `skills/<bucket>/<skill>/SKILL.md` | Skill behavior specification (frontmatter + markdown) |
| `skills/<bucket>/<skill>/agents/openai.yaml` | Codex UI metadata (display name, short description, policy) |
| `docs/<bucket>/<skill>.md` | Public-facing documentation (What it does, When to reach for it, Common questions, It's working if) |
| `.out-of-scope/` | Knowledge base of documented non-goals |
| `CHANGELOG.md` | Release notes |

---

## Data Flow Summary

### User → Skill → Outcome

1. **User types** `/skill-name`
2. **Harness resolves** (Claude Code plugin loader, or symlink in ~/.claude/skills, or local SKILL.md)
3. **Skill SKILL.md** → frontmatter parsed, behavior executed
4. **Skill may call** other skills via Skill tool (model-invoked skills only)
5. **Skill may generate** CONTEXT.md, ADRs, agent briefs, issues/PRs, docs, code, tests
6. **Outcome** fed back to user for next action

### Skill Composition Example

```
/to-tickets (user invokes)
  ↓ (reads current context thread, calls Skill tool with "grilling")
/grilling (model-invoked primitive)
  ↓ (rounds of questions, updates CONTEXT.md)
user answers
  ↓ (calls Skill tool with "domain-modeling")
/domain-modeling (model-invoked reference)
  ↓ (challenges terms, writes ADRs inline)
/to-tickets resumes
  ↓ (writes tickets with blocking edges to issue tracker)
issue tracker updated
```

---

## Summary

`mattpocock/skills` is an **intentionally curated collection** organized around software engineering workflows. Its architecture achieves:

- **Clarity**: Explicit skill boundaries, invocation modes, and dependencies (no implicit coupling)
- **Composability**: Skills invoke each other declaratively via Skill tool
- **Lifecycle management**: Four bucket types (promoted/non-promoted, live/deprecated) with curation rules
- **Distribution flexibility**: Claude Code plugin (managed), skills.sh (editable), local symlinks (dev)
- **Domain coherence**: CONTEXT.md and ADRs as shared vocabulary layers
- **User agency**: Router skill (`ask-matt`) maps all flows; users choose their path

The repo is a **documentation-driven system**: behavior lives in SKILL.md prose, not code; domain knowledge lives in CONTEXT.md; architecture decisions in ADRs and CLAUDE.md.
