# mattpocock/skills: API Surface

## Overview

`mattpocock/skills` is a library of 26 composable agent skills (slash-command workflows) organized by invocation model and purpose. The library is distributed through two channels: as a managed Claude Code plugin (plug-and-play, read-only) and via skills.sh (editable copies into a user's project). Both channels expose the same skill set, but the invocation contract differs slightly between harnesses.

## Public API: Skill Invocation Contract

Every skill has a **frontmatter** block defining its invocation model:

```yaml
---
name: <skill-name>
description: <description-text>
disable-model-invocation: true  # Optional; only on user-invoked skills
---
```

### User-Invoked vs. Model-Invoked Split

Skills split along one axis: **who can invoke them**.

**User-invoked** (`disable-model-invocation: true`):
- Reachable only by the human typing the skill name (e.g., `/grill-me`, `/implement`)
- Zero context load to the model; the model never sees the description
- Description is human-facing: one-line summary, no trigger phrases
- Cannot invoke other user-invoked skills (architectural invariant)
- Can invoke model-invoked skills explicitly
- Examples: `grill-with-docs`, `implement`, `to-spec`, `ask-matt`

**Model-invoked** (no `disable-model-invocation`):
- Reachable by model autonomously or by human typing
- Always-loaded description in context; costs tokens on every turn
- Description is model-facing: rich trigger phrasing ("Use when the user wants…, mentions…, asks for…")
- Can be invoked by other skills via `Call the Skill tool with "<skill-name>"`
- Used as shared reference when needed by multiple skills
- Examples: `grilling`, `tdd`, `prototype`, `research`, `domain-modeling`

### Harness-Specific Metadata

Each skill carries `agents/openai.yaml` alongside `SKILL.md`:

```yaml
interface:
  display_name: <Display Name>
  short_description: <Brief description>
policy:
  allow_implicit_invocation: false  # Only for user-invoked skills in Codex
```

The `policy.allow_implicit_invocation: false` is present only for user-invoked skills and must be kept in sync with the `disable-model-invocation` frontmatter field across harnesses (Claude Code and Codex each exclude user-invoked skills in their own way).

### Skill Composition: Cross-References

Skills reference each other through **explicit Skill tool calls** (not prose mentions or deep file links). Composition patterns:

**Within-skill composition** (user-invoked skills invoking model-invoked ones):
- Expressed as: `Call the Skill tool with "<skill-name>"`
- Example: `grill-me` → `grilling`, `implement` → `tdd` + `code-review`
- Multiple calls are explicit: `Call the Skill tool twice, for "grilling" and "domain-modeling"`

**Router skills** (navigation):
- `ask-matt` is the primary router over user-invoked skills
- Routes to flows: main flow (idea → ship), on-ramps (bugs/requests, hard bugs, greenfield projects), codebase health, vocabulary
- Contains prose labels naming skills, not Skill tool calls (navigation, not invocation)

**Precondition chain**:
- `setup-matt-pocock-skills` must run once per repo before other skills
- Stateful: configures issue tracker, triage labels, doc layout
- Other skills assume its configuration; failure path is explicit user action ("tell the user to run `/setup-matt-pocock-skills`")

**Main flow dependencies** (from `ask-matt`):
1. `grill-with-docs` (or `grill-me`) → sharpens idea with stateful docs
2. `prototype` (optional detour via `handoff`) → throwaway code for design questions
3. `to-spec` → turns conversation into spec for issue tracker
4. `to-tickets` → breaks spec into tracer-bullet tickets with blocking edges
5. `implement` (one per ticket) → builds each ticket via `tdd` internally, closes with `code-review`

**On-ramp dependencies**:
- `triage` → incoming bug reports/requests → feeds `implement`
- `diagnosing-bugs` → hard bugs → `improve-codebase-architecture` (post-mortem)
- `wayfinder` → huge efforts → `to-spec` when map clears

**Vocabulary layer** (passive reference, not active skills):
- `domain-modeling` and `codebase-design` are model-invoked references living beneath flows
- Other skills pull them in; reach directly when the problem is vocabulary, not process
- Shared source of truth: `CONTEXT.md` (domain) and ADR pattern (architectural)

### Invocation Semantics Across Harnesses

**Claude Code**:
- Skill names are top-level slash commands: `/grill-with-docs`, `/implement`
- Model invocation works through auto-discovery on description text
- Plugin manifest: `.claude-plugin/plugin.json` with explicit `skills` array of directory paths
- Plugin installation: `claude plugins install mattpocock-skills` (from official marketplace) or in-session `/plugin install mattpocock-skills`

**Codex and other Agent-Skills harnesses**:
- Same skill invocation primitives; metadata lives in `agents/openai.yaml`
- Installation via skills.sh: `npx skills@latest add mattpocock/skills`
- Curated to promoted skills only (`engineering/` and `productivity/`)
- Symlinks into `~/.agents/skills` or `~/.claude/skills` (harness-dependent)

**Both harnesses**:
- Skill names are referenced by name only (no `/` prefix in operative invocations)
- Composition always goes through `Call the Skill tool with "<name>"`, never a prose mention intended to be auto-fired

## Extension Points: Adding New Skills

### Skill Lifecycle

Skills live in buckets under `skills/<bucket>/`:
- **`engineering/`** and **`productivity/`**: promoted (shipped in plugin, promoted READMEs, docs pages, CLAUDE.md listed)
- **`in-progress/`**: beta (public, feedback wanted, no docs pages, not in plugin)
- **`misc/`**: maintained but rarely used, not promoted
- **`deprecated/`**: retired, kept for history

### Adding a Promoted Skill (engineering/ or productivity/)

1. Create `skills/<bucket>/<skill-name>/SKILL.md` with frontmatter:
   ```yaml
   ---
   name: <skill-name>
   description: <model-facing or human-facing per invocation choice>
   disable-model-invocation: true  # Only if user-invoked
   ---
   ```

2. Create `skills/<bucket>/<skill-name>/agents/openai.yaml`:
   ```yaml
   interface:
     display_name: <Display Name>
     short_description: <Brief>
   policy:
     allow_implicit_invocation: false  # Only if user-invoked
   ```

3. Add entry to `.claude-plugin/plugin.json` `skills` array:
   ```json
   "./skills/<bucket>/<skill-name>"
   ```

4. Add entry to top-level `README.md` and `skills/<bucket>/README.md`, grouped under **User-invoked** or **Model-invoked**

5. Create human-facing docs at `docs/<bucket>/<skill-name>.md` (promoted skills only)

6. If skill references `ask-matt`, update `ask-matt/SKILL.md` to include the new skill in the map

7. Run validation:
   ```bash
   claude plugin validate . --strict
   scripts/link-skills.sh
   ```

### Optional Skill Files

Skills may include supporting files beside `SKILL.md`:
- **Reference files** (`tests.md`, `mocking.md`, etc.): disclosed reference behind context pointers
- **Separate agents directories**: per-harness metadata (Codex-only currently)

These are co-located with `SKILL.md`, not at the root.

### Promoted Skill Conventions

From `CLAUDE.md`:
- Every promoted skill has an entry in `plugin.json` `skills` array
- Plugin version and `package.json` version must stay in sync
- Documentation page must have four sections: What it does, When to reach for it, Common questions, It's working if
- No em-dashes in prose (SKILL.md, docs, README.md, CHANGELOG.md, ADRs, changesets)

## Integration Patterns: Composition and Reuse

### Explicit Skill Tool Calls (the Primitive)

All operative composition goes through explicit `Call the Skill tool` instructions, not prose hints:

✅ **Correct**: `Call the Skill tool with "grilling".`  
❌ **Incorrect**: Use `/grilling` or `"reach for grilling"` (leaves auto-invocation to chance)

### Router Skills

`ask-matt` is the canonical router. It:
- Maps every user-reachable skill and when to use each
- Names flows: main flow (idea → ship), on-ramps (triage, diagnosing, wayfinder), codebase health, vocabulary, standalone
- Must be updated whenever a user-invoked skill is added, renamed, or changes how it fits the flows
- Contains prose labels for navigation; no Skill tool calls within the map itself

### Shared Reference

Model-invoked skills act as shared reference when needed by multiple skills:
- `grilling` (interview primitive behind `grill-me`, `grill-with-docs`, `triage`, `wayfinder`, `improve-codebase-architecture`)
- `domain-modeling` (vocabulary for domain language)
- `codebase-design` (vocabulary for module shape, seams, interfaces)
- `writing-for-agents` (reference for writing any agent-consumed document)

### Phase Boundaries

Flows break at **phase boundaries** between grilling, spec, tickets, implementation, and QA. Options at each boundary:
- **Continue**: stay in context (default)
- **Clear**: wipe window when nothing matters forward
- **Handoff**: write portable markdown for switching harness/directory (via `handoff` skill)
- **Subagent**: dispatch tightly-scoped task to separate session
- **Compact**: compress context and seed new session (at bottom of decision tree)

Decision logic lives in `ask-matt/PHASE-BOUNDARIES.md`.

## Plugin/Middleware Architecture

### Claude Code Plugin Distribution

**Plugin manifest**: `.claude-plugin/plugin.json`
```json
{
  "name": "mattpocock-skills",
  "version": "1.2.3",
  "skills": [
    "./skills/engineering/grill-with-docs",
    // ... 25 more promoted skills
  ]
}
```

**Marketplace metadata**: `.claude-plugin/marketplace.json`
- Makes the repo a single-plugin marketplace for direct git installs
- Not the documented user route (Claude Code has official marketplace now)
- Retained as fallback for unreleased commits or forks

**Installation**:
- Primary: `claude plugins install mattpocock-skills` (from official marketplace, auto-updates)
- In-session: `/plugin install mattpocock-skills`
- Skills are read-only; updates arrive transparently when Claude Code updates the plugin

**Plugin validation**:
```bash
claude plugin validate . --strict
```

Checked after touching plugin manifests or skill lists.

### skills.sh Distribution (Universal)

**Installer**: `npx skills@latest add mattpocock/skills`
- Copies editable skill files into user's project
- Curated to promoted skills only (engineering/ and productivity/); all others are excluded
- Generates per-repo setup: `.claude-plugin/config.json`, skill symlinks into `~/.claude/skills` or harness-equivalent
- Updates via `npx skills update` (explicit, not automatic)

**Why two routes?**
- **Plugin**: plug-and-play, managed, always-current (for Claude Code users who want it)
- **skills.sh**: owned, editable, harness-neutral (for Codex, local editing, or preference for control)
- **Invariant**: installing both doubles every skill; documentation recommends picking one

### Harness Portability

Skills are harness-agnostic at the `.SKILL.md` level. Per-harness differences:
- **Claude Code**: `disable-model-invocation` frontmatter toggle
- **Codex**: `agents/openai.yaml` `policy.allow_implicit_invocation` toggle
- Both toggles must stay in sync for a skill to be user-invoked in both harnesses

Composition primitives (`Call the Skill tool`) are harness-independent.

### Version Coordination

- `package.json` version drives releases (via changesets and `changeset version`)
- `.claude-plugin/plugin.json` `version` must match `package.json` on release
- Script: `scripts/sync-plugin-version.mjs` (run via `npm version` hook)
- Official marketplace reads `.claude-plugin/plugin.json` at tag time; sha pinning means updates lag commits by minutes to hours

## Domains and Conventions

### Domain Language (CONTEXT.md)

The library codifies its own domain model in `CONTEXT.md`:
- **Issue tracker**: tool hosting issues (GitHub Issues, Linear, local markdown)
- **Issue**: tracked unit of work (bug, task, spec, slice from `to-tickets`)
- **Decision ticket**: `wayfinder` unit holding a question/decision, not an implementation slice
- **Triage role**: canonical state-machine label (e.g., `needs-triage`, `ready-for-afk`)

Terms are used consistently across all skill descriptions and documentation.

### Documentation Standards

From `.agents/writing-docs.md` and `SKILL-MECHANICS.md`:

**Writing-for-agents primitives**:
- **Context pointers**: references encoding a condition for reaching material (skill description, AGENTS.md line)
- **Information hierarchy**: steps → in-file reference → disclosed reference (separate file behind pointer)
- **Completion criteria**: fuzzy vs. clear; clarity defends against premature completion
- **Leading words**: pretrained concepts (e.g., _tight_, _red_, _tracer bullets_) that accumulate distributed definitions
- **Progressive disclosure**: push reference behind pointers to keep steps legible

**Skill-specific**:
- **Invocation choice**: model-invoked (always-loaded description, agent auto-fire) vs. user-invoked (zero context load, cognitive load on human)
- **Split by invocation**: new model-invoked skill when agent must reach it autonomously or another skill must reference it
- **Router skills**: user-invoked skill that names others, curing piled cognitive load with one skill to remember

### Directory Layout (Enforced)

```
skills/
  engineering/
    <skill-name>/
      SKILL.md
      agents/
        openai.yaml
      <reference-files>  # Optional: tests.md, etc.
  productivity/
    <skill-name>/
      SKILL.md
      agents/
        openai.yaml
  in-progress/
  misc/
  deprecated/
docs/
  engineering/
    <skill-name>.md  # Promoted skills only
  productivity/
    <skill-name>.md  # Promoted skills only
.claude-plugin/
  plugin.json  # Manifest with explicit skills array
  marketplace.json  # Fallback for direct installs
.agents/
  invocation.md  # Invocation choice rules
  writing-docs.md  # Writing reference
  install-block.md  # Canonical install wording
  adr/
    0001-*.md
    0002-*.md  # Plugin distribution decision
scripts/
  link-skills.sh  # Symlink local skills to harness directories
```

## Summary: API Surface Specification

**Invocation Model**:
- User-invoked: `/skill-name` typed by human only; `disable-model-invocation: true`
- Model-invoked: auto-discovered on description; omit the flag

**Composition**:
- `Call the Skill tool with "<skill-name>"` for operative calls (not prose mentions)
- User-invoked skills cannot call other user-invoked skills
- Model-invoked skills are shared reference; called by other skills or users

**Distribution**:
- Claude Code plugin: `claude plugins install mattpocock-skills` (official marketplace, read-only, auto-updates)
- skills.sh: `npx skills@latest add mattpocock/skills` (editable, harness-universal, explicit updates)

**Extension**:
- Add to promoted bucket (engineering/ or productivity/), add to plugin.json, add to READMEs, create docs page, run validation

**Constraints**:
- User-invoked skills can invoke model-invoked skills but never other user-invoked skills
- Every promoted skill appears in plugin.json, top-level README, bucket README, docs, and ask-matt map
- Harness invocation toggles (Claude Code frontmatter vs. Codex agents/openai.yaml) must stay in sync
