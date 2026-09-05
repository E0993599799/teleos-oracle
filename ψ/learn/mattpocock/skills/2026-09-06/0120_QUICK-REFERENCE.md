# Matt Pocock's Skills — Quick Reference

> **Version**: 1.2.3 | **License**: MIT | **Repository**: https://github.com/mattpocock/skills

## Executive Summary

Matt Pocock's **Skills** is a production-grade collection of 26 reusable agent skills (slash commands and behaviors) designed for real engineering workflows. These are not toy commands—they encode decades of software engineering discipline into repeatable practices: test-driven development, code review, domain modeling, debugging, and high-stakes planning.

The skills work with any Claude Code-compatible agent (Claude Code, Codex, and others), come in three delivery models (plugin, managed files, or local copy), and integrate with GitHub/GitLab/local issue trackers.

**Core philosophy**: Small, composable, adaptable skills that you can hack on yourself, based on proven engineering fundamentals.

---

## What It Is

### The Problem It Solves

1. **Misalignment** — Agent produces the wrong thing because there was a communication gap upstream. Solution: grilling sessions to align before building.
2. **Verbosity** — Agents waste tokens and readability talking around domain jargon. Solution: build a shared language (`CONTEXT.md` + ADRs) to reduce noise by 90%.
3. **Poor Feedback** — Code doesn't work because the agent never saw real feedback. Solution: tight test-driven loops that catch problems immediately.
4. **Architecture Decay** — Agents speed up coding but accelerate entropy, resulting in unmaintainable balls of mud. Solution: deliberate module design and depth, with regular architecture audits.

### Design Principles

- **Small**: each skill is one focused practice, not a monolithic framework
- **Composable**: skills call each other in well-defined flows; they don't own the process
- **Adaptable**: you own the code; fork and modify as your project evolves
- **Grounded**: based on decades of engineering practice (Kent Beck, David Thomas, John Ousterhout, Eric Evans)

### What You Get

26 skills organized in two primary buckets:
- **Engineering** (18 skills): code work, testing, review, design
- **Productivity** (8 skills): workflow, interviews, handoffs, teaching

Plus auxiliary skills for special cases (misc, in-progress, deprecated).

---

## Installation (Three Methods)

### Method 1: Claude Code Plugin (Recommended for Most Users)

**Simplest**: managed, read-only, auto-updates.

**Command**:
```bash
claude plugins install mattpocock-skills
```

Or from inside a Claude Code session:
```
/plugin install mattpocock-skills
```

**What you get**:
- All 26 promoted skills (engineering + productivity)
- Auto-updated whenever Matt ships changes
- Read-only; you can't modify them
- Configuration stored in `.claude/skills/` (symlinks into plugin)

**Tradeoff**: no local customization without forking the plugin.

---

### Method 2: skills.sh (Editable Files in Your Repo)

**Flexible**: you choose which skills, copy them as ordinary files you own.

**Command**:
```bash
npx skills@latest add mattpocock/skills
```

**What happens**:
1. Interactive menu: choose which skills to install (make sure `setup-matt-pocock-skills` is selected)
2. Choose which coding agents to install them on (Claude Code, Codex, etc.)
3. Skills are written to your repo as ordinary files (usually `./.claude/skills/` or `./.agents/skills/`)

**Updates**:
```bash
npx skills@latest update mattpocock/skills
```

**Tradeoff**: you maintain updates manually, but you own the code.

---

### Method 3: skills.sh Single-Skill Install

**For one skill at a time**:
```bash
npx skills@latest add mattpocock/skills --skill=tdd
npx skills@latest add mattpocock/skills --skill=code-review
```

Update one skill:
```bash
npx skills@latest update mattpocock/skills --skill=tdd
```

---

### Important: Pick One Method

Installing both the plugin and skills.sh leaves you with every skill twice. Choose one:
- **Plugin** if you want managed, auto-updating skills and don't plan to modify them
- **skills.sh** if you want to hack on them or carefully control what you install

---

## Quick Start (First Time Setup)

After installing skills by any method:

### 1. Run `/setup-matt-pocock-skills` (once per repo)

This interactive setup skill configures the skills for your repo by asking:

- **Issue tracker**: Where do issues live? (GitHub Issues, GitLab Issues, local markdown files, or other)
- **Triage labels**: What label strings do you use for triage states? (defaults: `needs-triage`, `ready-for-agent`, etc.)
- **Domain docs layout**: Where do you keep `CONTEXT.md` and ADRs? (single-context at root, or multi-context for monorepos)

**Output**: Creates `docs/agents/` folder with three config files:
- `issue-tracker.md` — which issue tracker, how to use it
- `domain.md` — where domain docs live, consumer rules
- `triage-labels.md` — label vocabulary (if triage is installed)

Also updates `CLAUDE.md` or `AGENTS.md` with an `## Agent skills` block pointing at these files.

### 2. Choose Your First Skill

Run `/ask-matt` to see which skill fits your immediate need, or pick from the flows below.

---

## The Main Flows

### Flow 1: Idea → Spec → Tickets → Build → Review → Ship

The bread-and-butter path for building new features or substantial fixes.

```
/grill-with-docs          ← sharpen idea via interview, record learnings in CONTEXT.md
    ↓
decide: need a prototype? ← if design is hard to settle on paper
    yes ↓ /handoff → /prototype → /handoff back ↓
    no ↓ continue
    ↓
/to-spec                  ← synthesize a spec from the conversation
    ↓
/to-tickets               ← break spec into tracer-bullet vertical slices
                             (each tickets declares blocking edges)
    ↓
/implement (per ticket)   ← builds using /tdd internally, ends with /code-review
    ↓
commit & merge
```

**Context hygiene**: Keep steps 1–3 in one unbroken context (don't clear between them) so spec and tickets build on the same thinking. Each `/implement` starts fresh from its ticket.

---

### Flow 2: Bug Report Arrives

```
/triage                   ← categorize (bug/enhancement), state (needs-triage/ready-for-agent/etc)
                             may grill to sharpen; outputs agent-ready issue
    ↓
/implement                ← picks up the triaged issue, builds with /tdd
```

---

### Flow 3: Something Is Broken (Hard Bug)

```
/diagnosing-bugs          ← builds tight feedback loop → reproduces → minimizes
                             hypothesizes → instruments → fixes → regression test
```

Five-phase discipline, gated so you don't jump straight to guessing.

---

### Flow 4: The Way Forward Isn't Clear (Huge Effort)

```
/wayfinder                ← map huge work as decision tickets on issue tracker
                             resolve them one at a time until fog clears
    ↓
/to-spec                  ← collapse the map into a buildable spec
    ↓
/to-tickets → /implement (rest of main flow)
```

Wayfinder is for work too big to hold in one session, where the destination is foggy and the route isn't visible.

---

## All 26 Skills: Organized Reference

### Engineering Skills (18 Total)

#### User-Invoked (Start Here)

| Skill | What It Does | When to Use | Config Required |
|-------|--------------|-------------|-----------------|
| **ask-matt** | Router over all skills; shows flows and relationships | "I don't remember which skill fits" | none |
| **grill-with-docs** | Relentless interview + records decisions in `CONTEXT.md` and ADRs | Sharpening a new feature idea before building | issue-tracker, domain docs |
| **setup-matt-pocock-skills** | One-time config: issue tracker, triage labels, domain doc layout | After installing skills on a new repo | (creates the config) |
| **triage** | Move issues through state machine (needs-triage → ready-for-agent → etc) | Incoming bugs/feature requests that need evaluation | issue-tracker, triage-labels |
| **to-spec** | Synthesize a spec from current conversation; publish to issue tracker | After `/grill-with-docs` is done sharpening | issue-tracker |
| **to-tickets** | Break spec/plan into tracer-bullet tickets with blocking edges | After spec; before building | issue-tracker |
| **implement** | Build work from spec or tickets; drives `/tdd` internally | Building a feature; picking up a ticket | (inherits from context) |
| **wayfinder** | Chart huge foggy work as decision tickets; resolve them one by one | Greenfield project or multi-session effort; destination unclear | issue-tracker |
| **improve-codebase-architecture** | Scan codebase for deepening opportunities; present as report | Spare moment to keep codebase clean; run every few days | none |

#### Model-Invoked (Called by Agent as Needed)

| Skill | What It Does | When Used | Config Required |
|-------|--------------|-----------|-----------------|
| **tdd** | Red-green-refactor loop; reference for good tests vs anti-patterns | Building features or fixing bugs with `/implement` | none |
| **code-review** | Two-axis review (Standards + Spec) of diff against fixed point | Reviewing work before commit; runs in parallel sub-agents | issue-tracker |
| **diagnosing-bugs** | Five-phase bug diagnosis: feedback loop → reproduce → minimize → hypothesize → fix | Hard bugs, intermittent flakes, performance regressions | none |
| **domain-modeling** | Challenge and sharpen project's domain language; update `CONTEXT.md`/ADRs inline | Any time domain terms come up or conflict; called by `/grill-with-docs` | none |
| **codebase-design** | Vocabulary and discipline for designing deep modules (interface, seam, depth) | Designing a module; called by `/tdd` and `/improve-codebase-architecture` | none |
| **prototype** | Throwaway code answering one design question (logic or UI) | Can't settle design on paper; need a concrete artifact to react to | none |
| **research** | Investigate question against primary sources; write findings as cited Markdown | Gathering facts a decision waits on; runs as background agent | none |
| **resolving-merge-conflicts** | Work through merge/rebase conflict hunk by hunk, resolve by intent | Mid-merge conflict; never runs `--abort` | none |
| **wizard** | Generate interactive bash wizard walking humans through manual steps | Setting up credentials, provisioning infra, testing a cutover | none |

---

### Productivity Skills (8 Total)

#### User-Invoked

| Skill | What It Does | When to Use | Config Required |
|--------|--------------|-------------|-----------------|
| **grill-me** | Relentless interview (stateless, no `CONTEXT.md`) | Sharpening a plan/design outside a working directory | none |
| **handoff** | Compact current conversation into portable Markdown | Handing off to a colleague or another session/agent | none |
| **teach** | Multi-session teaching framework; uses current directory as workspace | Teaching someone a skill over multiple sessions | none |
| **to-questionnaire** | Turn a decision into async-fillable questionnaire for the decision-maker | Getting input from one person who's not in the session | none |
| **wait-what** | Re-pitch a message with context when something doesn't land | Moment a message isn't understood | none |

#### Model-Invoked

| Skill | What It Does | When Used | Config Required |
|-------|--------------|-----------|-----------------|
| **grilling** | Interview primitive: rounds, frontier, facts vs decisions | Called by `/grill-me`, `/grill-with-docs`, `/triage`, etc. | none |
| **writing-for-agents** | Discipline for writing docs agents will read (skills, CLAUDE.md, pointers) | Writing docs; called by `/grill-with-docs` when recording ADRs | none |

---

### Auxiliary Skills

#### Miscellaneous (rarely used, not in plugin)

- **git-guardrails-claude-code** — pre-commit integration for Claude Code
- **migrate-to-shoehorn** — migration helper (Shoehorn framework)
- **scaffold-exercises** — exercise generation
- **setup-pre-commit** — pre-commit hook setup

#### In-Progress (beta, public feedback wanted, not in plugin)

- **claude-handoff** — handoff variant
- **implement-spec** — spec-to-implementation
- **loop-me** — recurring task loop
- **retro** — retrospective generation
- **setup-ts-deep-modules** — TypeScript deep-module scaffold
- **writing-beats** — writing structure helper
- **writing-fragments** — fragment assembly
- **writing-shape** — writing shape design

#### Deprecated (no longer used)

Historical; see repo for archive.

---

## Key Configuration Options

All configuration lives in `docs/agents/` (created by `/setup-matt-pocock-skills`):

### `docs/agents/issue-tracker.md`

**Controls**: where skills read/write issues

**Options**:
- **GitHub Issues** (default) — uses `gh` CLI to create/read issues
- **GitLab Issues** — uses `glab` CLI
- **Local markdown** — issues as files under `.scratch/<feature>/issues/`
- **Other (Jira, Linear, etc.)** — describe in freeform; skills treat as custom

**GitHub template includes a flag** (default off): "PRs as a request surface" (whether to triage external PRs through `/triage`).

### `docs/agents/triage-labels.md`

**Controls**: label strings for triage states

**Five canonical roles** (names are canonical; label strings are configurable):
1. `needs-triage` — not yet evaluated
2. `needs-info` — waiting on reporter
3. `ready-for-agent` — spec'd, ready for agent
4. `ready-for-human` — spec'd, needs human judgment
5. `wontfix` — will not be actioned

**Default**: label strings match role names. Override only if your tracker already uses different strings (e.g., `bug:triage` instead of `needs-triage`).

### `docs/agents/domain.md`

**Controls**: where domain docs live and consumer rules

**Two layouts**:
- **Single-context** (default): `CONTEXT.md` + `docs/adr/` at repo root
- **Multi-context**: `CONTEXT-MAP.md` at root, pointing to per-package `CONTEXT.md` files (for monorepos)

**Also specifies**: consumer rules (which docs agents should read, in what order).

---

## Key Concepts & Vocabulary

### Tracer Bullet / Vertical Slice

A complete, thin path through every layer (schema, API, UI, test). Not horizontal slicing of one layer. Each slice is:
- Demoable on its own
- Sized to fit one context window
- Gated by previous slices it depends on (blocking edges)

### Blocking Edges

The other tickets a ticket depends on. A ticket with no blockers can start immediately. On GitHub/GitLab, expressed as native blocking links; local tracker uses file-based "Blocked by" list.

### Seam

The public boundary where you observe behavior. Tests live at seams, never against internals. Pre-agreed seams are the first question in `/tdd`.

### Domain Model

The glossary of terms your codebase uses: Customer, Order, Cancellation, etc. Built and kept sharp in `CONTEXT.md` (a live document that updates during sessions). Avoids implementation details.

### ADR (Architecture Decision Record)

A record of a hard-to-reverse decision and why it was made. Format: Decision, Context, Consequences. Created sparingly by `/domain-modeling` when a choice is surprising, costly to reverse, and the result of a real trade-off.

### Fog of War

The dim view of decisions and investigations beyond the frontier when planning huge work. Recorded in "Not yet specified" section of a wayfinder map, then graduated into tickets as the frontier advances.

### Tight Feedback Loop

In `/diagnosing-bugs`: one command (a test, a curl, a script) you can run repeatedly that goes red on _this specific bug_ and green once fixed. The foundation of effective debugging.

### Deep Module

A module with a lot of behavior behind a small interface. The opposite of a shallow module (big interface, little behavior). Term from John Ousterhout's _A Philosophy of Software Design_. Designed via `/codebase-design`.

---

## Skill Relationships & Dependencies

### Hard Dependencies (Require Config)

- **`triage`, `to-spec`, `to-tickets`, `implement`, `code-review`, `wayfinder`** all require `docs/agents/issue-tracker.md`
- **`triage`** also requires `docs/agents/triage-labels.md` (only if triage is installed)
- Skills that grill or model domains expect **`CONTEXT.md`** and **`docs/adr/`** to exist (created on first use; not required to exist before)

### Soft Dependencies (Use When Relevant)

- **`/implement`** automatically calls **`/tdd`** at pre-agreed seams and **`/code-review`** at the end
- **`/grill-with-docs`** automatically calls **`/domain-modeling`** to sharpen and record decisions
- **`/triage`** automatically calls **`/grilling`** and **`/domain-modeling`** if the issue needs fleshing out
- **`/diagnosing-bugs`** has no dependencies but produces tight feedback loops suitable for **`/tdd`**

### Independence (No Dependencies)

- **`/ask-matt`** — pure router
- **`/grill-me`** — same as `grill-with-docs` but stateless
- **`/grilling`**, **`/domain-modeling`**, **`/codebase-design`**, **`/prototype`**, **`/research`**, **`/resolving-merge-conflicts`**, **`/wizard`** — can be reached directly or via other skills

---

## Architecture & Organization

### Repository Structure

```
skills/
├── engineering/               ← 18 code-work skills
│   ├── ask-matt/
│   ├── tdd/
│   ├── code-review/
│   ├── grill-with-docs/
│   ├── to-spec/
│   ├── to-tickets/
│   ├── implement/
│   ├── triage/
│   ├── wayfinder/
│   ├── improve-codebase-architecture/
│   ├── diagnosing-bugs/
│   ├── prototype/
│   ├── research/
│   ├── domain-modeling/
│   ├── codebase-design/
│   ├── resolving-merge-conflicts/
│   ├── setup-matt-pocock-skills/
│   └── wizard/
├── productivity/              ← 8 workflow skills
│   ├── grill-me/
│   ├── grilling/
│   ├── handoff/
│   ├── teach/
│   ├── to-questionnaire/
│   ├── wait-what/
│   └── writing-for-agents/
├── misc/                      ← rarely used
├── in-progress/               ← beta, feedback wanted
├── deprecated/                ← archived
├── .claude-plugin/            ← plugin config
│   ├── plugin.json            (26 promoted skills)
│   └── marketplace.json       (fallback marketplace)
├── CLAUDE.md                  (contributor guidelines)
├── CONTEXT.md                 (project glossary)
└── README.md                  (main documentation)

docs/
├── <bucket>/                  ← published docs per bucket
│   ├── grill-me.md
│   ├── tdd.md
│   ├── code-review.md
│   └── ...
```

### Invocation Types

**User-invoked** (`disable-model-invocation: true`):
- Reachable only when you type the command (e.g., `/grill-me`)
- Job: orchestrate
- Examples: `/grill-with-docs`, `/to-spec`, `/implement`

**Model-invoked**:
- Reachable by user or automatically by agent when the task fits
- Job: provide reusable discipline
- Examples: `/tdd`, `/domain-modeling`, `/code-review`

### File Organization Rules (For Contributors)

- Every skill must have a `SKILL.md` with YAML frontmatter (name, description, invocation type)
- Promoted skills (in `engineering/` or `productivity/`) must be referenced in `README.md` and `plugin.json`
- Each promoted skill gets a published docs page at `docs/<bucket>/<skill>.md`
- Non-promoted skills (misc, in-progress, deprecated) are listed flat in their bucket's `README.md`, no docs page

---

## Common Patterns & Examples

### Example 1: Build a New Feature (Ideal Path)

1. **Have an idea**. Run `/grill-with-docs` to sharpen it; the grilling session updates `CONTEXT.md` and records decisions as ADRs.
2. **Extract a spec**. Run `/to-spec` (no interview, just synthesis). Publishes to issue tracker with `ready-for-agent` label.
3. **Break into tickets**. Run `/to-tickets`, which breaks the spec into tracer-bullet vertical slices with blocking edges. Approve the breakdown.
4. **Build ticket by ticket**. Run `/implement` on the first unblocked ticket. It:
   - Drives `/tdd` at pre-agreed seams (red → green → refactor cycles)
   - Runs `/code-review` on the diff before committing
   - Commits the work
5. **Repeat** for each subsequent ticket.

**Total context**: Steps 1–3 stay in one context (don't clear between them). Each `/implement` starts fresh.

### Example 2: Triage an Incoming Issue

1. Issue arrives: bug report with steps to reproduce.
2. Run `/triage #42`.
   - Read the report
   - Recommend a category (bug/enhancement) and state (needs-triage/ready-for-agent/etc.)
   - If unclear, grill the reporter to sharpen it
   - Publish an agent-ready brief with acceptance criteria
3. Issue now has `ready-for-agent` label; any agent can pick it up with `/implement`.

### Example 3: Debug a Hard Bug

1. Someone says: "The checkout flow is hanging intermittently."
2. Run `/diagnosing-bugs`.
   - **Phase 1**: Build a tight feedback loop (e.g., `npm test -- checkout.test.ts` that consistently reproduces the hang)
   - **Phase 2**: Reproduce and minimize (cut the repro down to the smallest scenario still red)
   - **Phase 3**: Generate 3–5 ranked hypotheses before testing any
   - **Phase 4**: Instrument the code (add logging, assertions, etc.)
   - **Phase 5**: Fix and regression-test
   - **Phase 6**: Reflection (post-mortem; hand off to `/improve-codebase-architecture` if the bug exposed a design issue)

### Example 4: Plan Huge Work (Wayfinder)

1. Someone says: "We need to migrate to a new database, but I don't know where to start."
2. Run `/wayfinder`.
   - Define the **destination** ("migration complete, queries fast, no downtime")
   - Create decision tickets on the issue tracker (research API, prototype new schema, grill on cutover strategy, etc.)
   - Work through them one at a time, resolving decisions until the fog clears
   - Notes section records the domain and skills every session should consult
3. Once the map is done (no open tickets, fog cleared), run `/to-spec` to collapse decisions into a buildable plan.

---

## Invocation Cheat Sheet

### Quick Lookup by Trigger Word

| If you hear... | Skill |
|---|---|
| "Design a feature" | `/grill-with-docs` |
| "Write a spec" | `/to-spec` |
| "Break this into tickets" | `/to-tickets` |
| "Build this" | `/implement` |
| "Review the code" | `/code-review` |
| "This is broken" | `/diagnosing-bugs` |
| "This issue is vague" | `/triage` or `/grill-me` |
| "Too much work for one session" | `/wayfinder` |
| "Improve the codebase" | `/improve-codebase-architecture` |
| "Test this" | `/tdd` |
| "Write tests" | `/tdd` |
| "I don't know which skill" | `/ask-matt` |
| "Handoff to someone else" | `/handoff` |
| "Teach me X" | `/teach` |

---

## Configuration File Templates

### `docs/agents/issue-tracker.md` (GitHub)

```markdown
# Issue Tracker

This repo uses **GitHub Issues** for tracking work.

## Workflow

- Issues are GitHub Issues in this repo
- Creation: `gh issue create --title "..." --body "..."`
- Agents read issues via `gh issue view <number>`
- Links: `#123` in commit messages closes the issue

## Labels

See `triage-labels.md` for triage role labels.

## PRs as a Request Surface

External PRs are not triaged as requests. Set to true if you want them in the triage queue.

PRs as request surface: false
```

### `docs/agents/triage-labels.md`

```markdown
# Triage Labels

Map canonical roles to issue tracker label strings.

| Role | Label |
|------|-------|
| needs-triage | needs-triage |
| needs-info | needs-info |
| ready-for-agent | ready-for-agent |
| ready-for-human | ready-for-human |
| wontfix | wontfix |

## Category Labels

- bug
- enhancement
```

### `docs/agents/domain.md`

```markdown
# Domain Documentation

## Layout

This repo uses **single-context** domain documentation:

- `CONTEXT.md` at the repo root (glossary)
- `docs/adr/` at the repo root (decisions)

## Consumer Rules

When agents operate in this repo, they should:

1. Read `CONTEXT.md` first for domain vocabulary
2. Check `docs/adr/` for decisions in the area they're touching
3. Update both inline as decisions land (don't batch)
```

---

## Frequently Asked Questions

### Q: Which installation method should I choose?

**Plugin** if you don't plan to modify skills and want them to stay up-to-date automatically. **skills.sh** if you want to customize them or have tight control over which skills are installed.

### Q: Do I have to use every skill?

No. Pick what fits your workflow. You can use just `/grill-with-docs` + `/implement` and skip the rest. Or use only `/diagnosing-bugs` for bug work. The architecture is modular.

### Q: Can I use these skills on my own project if it's not JavaScript?

Yes. The skills are language-agnostic (except ones that mention TypeScript tools). They work with any codebase. Run `/setup-matt-pocock-skills` once, then use whichever skills fit your work.

### Q: What if my issue tracker is Jira / Linear / something else?

Run `/setup-matt-pocock-skills` and choose "Other" when asked about the issue tracker. Describe your workflow in freeform prose. The setup skill will record it, and the skills will read from that description.

### Q: Can I modify these skills after installing them?

Yes, if you used **skills.sh** to install. Edit the files directly in `.claude/skills/` or `.agents/skills/`. If you used the **plugin**, skills are read-only (symlinks into the plugin directory). Fork the repo or use skills.sh to make changes.

### Q: How do I update skills if I used skills.sh?

```bash
npx skills@latest update mattpocock/skills
```

Or update one skill:
```bash
npx skills@latest update mattpocock/skills --skill=tdd
```

### Q: What does "tracer bullet" mean?

A **tracer bullet** is a complete, thin vertical slice through every layer (schema, API, UI, test) that you can deploy and see work end-to-end. Opposite of horizontal slicing (schema work, then API work, then UI work in separate tickets). Tracer bullets stay green batch by batch, so you catch integration problems immediately.

### Q: Why is `/diagnosing-bugs` so long and gated?

Debugging is where most developers fail: they jump straight to hypothesizing without a tight feedback loop. No loop = guessing in the dark. The skill refuses this by requiring a red-capable command first. Once you have it, phases 2–6 are fast.

### Q: What's the difference between `/grill-me` and `/grill-with-docs`?

Both run the same interview (via `/grilling`). **`/grill-me`** saves nothing locally (stateless; good for non-repo contexts). **`/grill-with-docs`** records decisions in `CONTEXT.md` and ADRs (good for repos; it's strictly better when you have a working directory).

### Q: When should I use `/wayfinder`?

When the destination is clear but the path is foggy and too big for one session. Examples: greenfield project, multi-month migration, reorganizing architecture. Use `/grill-with-docs` for well-scoped features you can hold in one context; wayfinder for the work you can't.

### Q: Do I have to run `/setup-matt-pocock-skills` every time I clone the repo?

No, once per repo. It creates `docs/agents/` config files that stay in the repo. New sessions in the same repo read those configs automatically.

### Q: Can I use these with Codex or other agents?

Yes. These skills are Claude Code plugins, but skills.sh works with any agent that supports skill installation (Codex, etc.). Use the skills.sh route and choose which agents during setup.

---

## Common Workflows Condensed

### Quick Bug Fix (30 min)
```
/diagnosing-bugs → tight loop → fix → regression test
```

### New Feature (1–2 hours)
```
/grill-with-docs → /to-spec → /implement (one pass, no tickets)
```

### Feature Too Big for One Session
```
/grill-with-docs → /to-spec → /to-tickets → (/implement per ticket)
```

### Triage Backlog
```
/triage → work through inbox → each issue becomes ready-for-agent
```

### Multi-Month Effort with Fog
```
/wayfinder → resolve decision tickets → /to-spec → rest of flow
```

### Architecture Cleanup
```
/improve-codebase-architecture → pick one opportunity → /grill-with-docs on it → rest of flow
```

---

## Further Resources

- **Official Site**: https://www.aihero.dev (docs, newsletter signup, skill details)
- **GitHub Repo**: https://github.com/mattpocock/skills
- **Source Files**: Read `SKILL.md` in each skill folder for complete discipline docs
- **Newsletter**: ~60,000 devs follow updates at https://www.aihero.dev/s/skills-newsletter
- **ADR on Plugin Design**: `.agents/adr/0002-ship-as-a-claude-code-plugin.md` (why a plugin, not a Codex native one)

---

## Version & Attribution

- **Version**: 1.2.3
- **License**: MIT
- **Author**: Matt Pocock (https://www.aihero.dev)
- **Last Updated**: This reference is based on repository state as of the most recent scan.

---

**Note**: This is a quick reference. Each skill has a full `SKILL.md` with edge cases, examples, and nuance. Refer to those for deep dives.
