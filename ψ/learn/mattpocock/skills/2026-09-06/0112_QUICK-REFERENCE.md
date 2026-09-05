# Matt Pocock's Skills: Quick Reference

## What It Does

**Matt Pocock's Skills** is a collection of reusable agent skills (slash commands and behaviors) that enable AI agents to follow software engineering best practices during real development work. These skills integrate with Claude Code, Codex, and other agents to solve four critical failure modes: misalignment between you and the agent, excessive verbosity, buggy code, and architectural entropy.

**Key philosophy**: Small, composable, easy to adapt skills that work with any model—based on decades of engineering experience, not vibe coding.

---

## Installation

### Option 1: Claude Code Plugin (Managed, Read-Only)

The official Claude Code plugin installs the full skill set automatically updated:

```bash
# From command line
claude plugins install mattpocock-skills

# Or from within a session
/plugin install mattpocock-skills
```

Installed from Claude Code's marketplace. Updates arrive automatically when new versions ship.

### Option 2: Via `skills.sh` (Editable, Forkable)

Install editable skill files into your project:

```bash
npx skills@latest add mattpocock/skills
```

You'll be prompted to:
- Select which skills to install
- Choose your coding agents
- **Select `setup-matt-pocock-skills` (required for engineering skills)**

Skills become ordinary repo files you own and can hack on. Update manually with `npx skills update` when desired.

### Option 3: For Tinkerers (Any Agent)

Use the installer on any agent (Claude Code, Codex, etc.):

```bash
npx skills@latest add mattpocock/skills
```

### Setup (One Per Repo)

After installation, run once per repository:

```
/setup-matt-pocock-skills
```

Configure:
- Issue tracker (GitHub, Linear, or local markdown files)
- Triage labels for issue states
- Documentation save location

---

## Core Features

### Problem #1: Misalignment ("Agent Didn't Do What I Want")

**Skills**: `/grill-me`, `/grill-with-docs`

Before starting any work, get the agent to ask you detailed questions about your intent until every design branch is resolved.

**Use when**:
- Starting a new feature or change
- Design is unclear or could go multiple ways
- You want to think deeply before building

**Example**:
```
/grill-me Let's add a new payment processor
```
The agent asks: Which processors? What's the migration path? Backward compat required? Rollback strategy? Success metrics?

---

### Problem #2: Excessive Verbosity ("Agent Uses 20 Words Where 1 Will Do")

**Skills**: `/grill-with-docs`, `/domain-modeling`

Build a shared domain language document (`CONTEXT.md`) that teaches agents your project's vocabulary and jargon.

**Example transformation**:
- BEFORE: "There's a problem when a lesson inside a section of a course is made 'real' (given a spot in the file system)"
- AFTER: "There's a problem with the materialization cascade"

**Benefits**:
- Agents spend fewer tokens thinking
- Variable/function naming matches vocabulary automatically
- Codebase becomes easier to navigate

---

### Problem #3: Buggy Code ("Code Doesn't Work")

**Skills**: `/tdd`, `/diagnosing-bugs`, `/code-review`

**Test-driven development** (`/tdd`):
- Red-green-refactor loop: write failing test → minimal implementation → repeat
- Tests are vertical slices of real behavior, not all-at-once
- Tests verify through public interfaces, not implementation details

**Example**:
```
/tdd Build cart checkout with valid credit card
```

**Debugging** (`/diagnosing-bugs`):
- Disciplined loop: build feedback → minimize → hypothesize → instrument → fix → regression test

**Code review** (`/code-review`):
- Two parallel axes: **Standards** (does it follow repo norms?) and **Spec** (does it implement the requirement?)

---

### Problem #4: Architectural Entropy ("We Built a Ball of Mud")

**Skills**: `/improve-codebase-architecture`, `/to-spec`, `/implement`, `/wayfinder`

**Codebase survey** (`/improve-codebase-architecture`):
- Scans your codebase for modules that should be deeper
- Returns candidates as an HTML report
- Grills through whichever you pick to sharpen
- Run every few days (survey, not rescue)

**Spec → Implementation flow**:
- `/to-spec`: Turn the current conversation into an issue-tracker spec (no interview, just synthesis)
- `/to-tickets`: Break spec into tracer-bullet tickets with blocking edges declared
- `/implement`: Build the work, running `/tdd` at pre-agreed seams, finishing with `/code-review`

**Massive work** (`/wayfinder`):
- Plans huge work (> one agent session) as a map of **decision tickets** on the issue tracker
- Resolves each decision ticket one at a time until the way to the destination is clear

---

## Engineering Skills Reference

### User-Invoked (Type These)

| Skill | Purpose |
|-------|---------|
| `/ask-matt` | Router: "Which skill fits my situation?" |
| `/grill-with-docs` | Grilling + domain modeling + ADR updates |
| `/triage` | Move issues through a state machine |
| `/improve-codebase-architecture` | Scan for deepening opportunities (visual HTML report) |
| `/setup-matt-pocock-skills` | One-time config per repo |
| `/to-spec` | Conversation → issue tracker spec |
| `/to-tickets` | Spec → tracer-bullet tickets with blocking edges |
| `/implement` | Build the work, `/tdd` + `/code-review` |
| `/wayfinder` | Plan huge work as decision-ticket map |

### Model-Invoked (Agent Reaches For)

| Skill | Purpose |
|-------|---------|
| `/prototype` | Throwaway prototype: HTML for logic, or UI variations |
| `/diagnosing-bugs` | Feedback loop for hard bugs + regressions |
| `/research` | Investigate against primary sources, save as cited Markdown |
| `/tdd` | Test-driven development with red-green-refactor |
| `/domain-modeling` | Build domain model: challenge terms, stress-test, update `CONTEXT.md` |
| `/codebase-design` | Design deep modules: small interfaces, clean seams, testable |
| `/code-review` | Two-axis review: Standards + Spec |
| `/resolving-merge-conflicts` | Work through conflicts hunk by hunk, never abort |
| `/wizard` | Generate interactive bash wizard for manual-only steps |

---

## Productivity Skills Reference

### User-Invoked

| Skill | Purpose |
|-------|---------|
| `/grill-me` | Relentless interview about a plan or design |
| `/handoff` | Compact current conversation for another agent |
| `/teach` | Multi-session teaching using directory as workspace |
| `/to-questionnaire` | Turn a decision into an async questionnaire |
| `/wait-what` | Restate a message with context you're missing |

### Model-Invoked

| Skill | Purpose |
|-------|---------|
| `/grilling` | The reusable interview primitive (used by `/grill-me`, `/grill-with-docs`, etc.) |
| `/writing-for-agents` | Guidelines for writing docs agents can read |

---

## Organization & Governance

**Skill buckets**:
- `engineering/`: daily code work (promoted)
- `productivity/`: non-code workflow tools (promoted)
- `misc/`: rarely used, kept around
- `in-progress/`: beta, feedback wanted
- `deprecated/`: no longer used

**Promoted skills** appear in:
- Top-level `README.md`
- `.claude-plugin/plugin.json` (Claude Code plugin)
- Human-facing docs at `aihero.dev/skills-<name>`

**Domain language** (CONTEXT.md):
- `Issue tracker`: GitHub Issues, Linear, or local markdown
- `Issue`: Single tracked unit of work
- `Decision ticket`: A `wayfinder` child holding a *question* (not a build slice)
- `Triage role`: State-machine label on an issue (e.g., `needs-triage`, `ready-for-afk`)

---

## Usage Patterns

### Recommended Workflow for Features

1. **Align** with `/grill-with-docs` (builds domain language, creates ADRs)
2. **Plan** with `/to-tickets` (break into tracer bullets with blocking edges)
3. **Build** with `/implement` (drives `/tdd` at pre-agreed seams, ends with `/code-review`)
4. **Review** with `/code-review` (Standards + Spec axes in parallel)
5. **Improve** with `/improve-codebase-architecture` (run every few days)

### Testing & Debugging

- **Building new features**: `/tdd` (red-green-refactor)
- **Fixing bugs**: `/diagnosing-bugs` (feedback → minimize → hypothesize → instrument → fix)
- **Merge conflicts**: `/resolving-merge-conflicts` (never abort, resolve by intent)

### Large-Scale Planning

- **Work > one session**: `/wayfinder` (decision-ticket map)
- **Complex decisions**: `/to-questionnaire` (async questionnaire for the person who can answer)
- **Handoff to another agent**: `/handoff` (compact the conversation)

### Infrastructure & Automation

- **Manual-only steps**: `/wizard` (generate interactive bash wizard)
- **One-time setup**: `setup-matt-pocock-skills` (per repo)

---

## Key Principles

1. **Nothing is deleted**: history and learnings are preserved
2. **Patterns over intentions**: what actually happened matters more than what was intended
3. **Small, composable skills**: adapt and hack on them to fit your workflow
4. **Red-green-refactor**: small vertical slices, not bulk-then-implement
5. **Seams matter**: test at public interfaces, not implementation details
6. **Domain language reduces verbosity**: agents spend fewer tokens thinking

---

## Additional Resources

- **Installation command library**: `.agents/install-block.md`
- **Plugin validation**: `claude plugin validate . --strict`
- **Architecture decisions**: `.agents/adr/` (e.g., `0002-ship-as-a-claude-code-plugin.md`)
- **Docs template**: `.agents/writing-docs.md`
- **Changelog**: `CHANGELOG.md`

---

## Source

- Repository: `mattpocock/skills` on GitHub
- Version: 1.2.3
- License: MIT
- Latest updates: https://github.com/mattpocock/skills
