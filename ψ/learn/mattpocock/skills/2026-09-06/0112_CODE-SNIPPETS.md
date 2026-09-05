# mattpocock/skills — Code Snippets & Implementation Patterns

## Repository Overview

**mattpocock/skills** is a curated collection of Claude Code agent skills — composable, discipline-oriented workflows for real software engineering: grilling/design, TDD, code review, domain modeling, codebase architecture, and more. The repo is shipped as a Claude Code plugin (`mattpocock-skills`) and distributed via `skills.sh` for other harnesses.

**Key observation**: This is NOT a traditional code repository. Skills are primarily **Markdown-based SKILL.md files** that describe workflows, constraints, and decision frameworks. The actual implementation is in how agents *orchestrate* using these files as guides. There are very few TypeScript/JavaScript files; the repo focuses on documenting processes, not shipping compiled code.

**Repository structure** (from `/CLAUDE.md`):
```
skills/
├── engineering/      # Daily code work (promoted)
├── productivity/     # Workflow tools (promoted)
├── misc/            # Rarely used (not promoted)
├── in-progress/     # Beta/feedback (not promoted)
└── deprecated/      # No longer used (not promoted)
```

---

## Main Entry Point Code

### 1. Plugin Manifest Sync Script

**File**: `/scripts/sync-plugin-version.mjs`

This is the primary "real" code file in the repo. It synchronizes version numbers between `package.json` and `.claude-plugin/plugin.json`:

```javascript
#!/usr/bin/env node
// Copies package.json's version into .claude-plugin/plugin.json.
// Runs as part of `npm run version`, immediately after `changeset version`.
// With --check it changes nothing and exits 1 if the two versions differ.

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repo = join(dirname(fileURLToPath(import.meta.url)), "..");
const pluginPath = join(repo, ".claude-plugin", "plugin.json");

const { version } = JSON.parse(readFileSync(join(repo, "package.json"), "utf8"));
const source = readFileSync(pluginPath, "utf8");
const plugin = JSON.parse(source);

if (plugin.version === version) {
  console.log(`plugin.json version is ${version} (already in sync)`);
  process.exit(0);
}

if (process.argv.includes("--check")) {
  console.error(
    `plugin.json version is ${plugin.version}, package.json is ${version}. Run \`node scripts/sync-plugin-version.mjs\`.`,
  );
  process.exit(1);
}

// Rewrite only the version line, to keep the key order and the formatting.
const updated = source.replace(
  /("version"\s*:\s*")[^"]*(")/,
  `$1${version}$2`,
);

if (JSON.parse(updated).version !== version) {
  console.error(`Could not find a version field to replace in ${pluginPath}.`);
  process.exit(1);
}

writeFileSync(pluginPath, updated);
console.log(`plugin.json version ${plugin.version} -> ${version}`);
```

**Pattern Notes**:
- Uses Node.js file APIs (`readFileSync`, `writeFileSync`) for simple file operations
- Regex-based JSON field replacement to preserve formatting/key order (line 30–32)
- Validates state before modifying files
- Exits with status codes for CI integration
- Works as a CLI tool with optional `--check` flag for validation

### 2. Plugin Manifest (Entry Point for Claude Code)

**File**: `/.claude-plugin/plugin.json`

```json
{
  "name": "mattpocock-skills",
  "version": "1.2.3",
  "description": "Matt Pocock's agent skills for real engineering: grilling, spec/ticket flows, TDD, code review, domain modelling and more. Plug-and-play, not vibe coding.",
  "author": {
    "name": "Matt Pocock",
    "url": "https://www.aihero.dev"
  },
  "homepage": "https://www.aihero.dev/s/skills-newsletter",
  "repository": "https://github.com/mattpocock/skills",
  "license": "MIT",
  "keywords": [
    "engineering",
    "skills",
    "tdd",
    "code-review",
    "grilling",
    "domain-modeling",
    "productivity"
  ],
  "skills": [
    "./skills/engineering/ask-matt",
    "./skills/engineering/diagnosing-bugs",
    "./skills/engineering/grill-with-docs",
    "./skills/engineering/triage",
    "./skills/engineering/improve-codebase-architecture",
    "./skills/engineering/setup-matt-pocock-skills",
    "./skills/engineering/tdd",
    "./skills/engineering/to-spec",
    "./skills/engineering/to-tickets",
    "./skills/engineering/wayfinder",
    "./skills/engineering/implement",
    "./skills/engineering/prototype",
    "./skills/engineering/research",
    "./skills/engineering/domain-modeling",
    "./skills/engineering/codebase-design",
    "./skills/engineering/code-review",
    "./skills/engineering/resolving-merge-conflicts",
    "./skills/engineering/wizard",
    "./skills/productivity/grill-me",
    "./skills/productivity/grilling",
    "./skills/productivity/handoff",
    "./skills/productivity/teach",
    "./skills/productivity/to-questionnaire",
    "./skills/productivity/wait-what",
    "./skills/productivity/writing-for-agents"
  ]
}
```

**Pattern Notes**:
- Explicit array of skill paths (not glob patterns) to curate exactly which skills ship
- Version must match `package.json` (enforced by `sync-plugin-version.mjs`)
- This is the authoritative entry point; Claude Code reads it to discover skills

---

## Core Skill Implementations (SKILL.md Format)

### Skill Metadata & Structure

Every skill is a directory containing a `SKILL.md` file with **YAML frontmatter** followed by workflow description:

```yaml
---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
disable-model-invocation: true
---
```

**Key fields**:
- `name`: unique identifier (used in paths and CLI invocation)
- `description`: one-line summary for UI/discovery
- `disable-model-invocation: true` → user-invoked only (slash command, not auto-triggered)
- Omitted or `false` → model-invoked (agent can reach for it automatically)

### Core Patterns

#### 1. **Grilling Pattern** (Recursive Decision Tree Interview)

**File**: `/skills/productivity/grilling/SKILL.md`

**Pattern**: Interview the user in **rounds** over a **design tree**. Calculate the **frontier** (questions whose prerequisites are settled) and ask only those in one round, with recommended answers.

```markdown
Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

**Key discipline**: 
- Frontier-based sequencing (only ask questions unblocked by prior answers)
- Finding facts is the agent's job; decisions are the user's
- Dispatch subagents for facts (filesystem, tools) without blocking the frontier
- Session ends when frontier is empty (every branch of the tree visited)

#### 2. **TDD Pattern** (Red-Green-Refactor Discipline)

**File**: `/skills/engineering/tdd/SKILL.md` (with `tests.md` and `mocking.md`)

**Core rule**:
```
Rules of the loop:
- **Red before green.** Write the failing test first, then only enough code to pass it.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactoring is not part of the loop.** It belongs to the review stage.
```

**Good test example** (from `/skills/engineering/tdd/tests.md`):
```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

**Bad test example** (implementation-coupled):
```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

**Mocking rules** (from `/skills/engineering/tdd/mocking.md`):
```typescript
// GOOD: Dependency injection at seams
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// BAD: Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

#### 3. **Code Review Pattern** (Two-Axis Review)

**File**: `/skills/engineering/code-review/SKILL.md`

**Pattern**: Review a diff on two independent axes that can conflict:
1. **Standards**: Does it follow repo conventions + Fowler smell baseline?
2. **Spec**: Does it faithfully implement the originating issue/spec?

**Fowler Smell Baseline** (from `/skills/engineering/code-review/SKILL.md`):
```
- **Mysterious Name**: rename it; if no honest name comes, design's murky
- **Duplicated Code**: extract shared shape, call from both
- **Feature Envy**: move the method onto the data it envies
- **Data Clumps**: bundle repeated fields into one type
- **Primitive Obsession**: give domain concepts their own small types
- **Repeated Switches**: replace with polymorphism or shared map
- **Shotgun Surgery**: gather scattered edits into one module
- **Divergent Change**: split so each module changes for one reason
- **Speculative Generality**: delete unused abstractions
- **Message Chains**: hide long a.b().c().d() walks behind one method
- **Middle Man**: cut delegation, call the real target direct
- **Refused Bequest**: drop inheritance, use composition
```

**Two-axis separation rationale**:
- Standards ✓ + Spec ✗ = follows conventions but does wrong thing
- Spec ✓ + Standards ✗ = does the right thing but breaks conventions
- Reporting separately prevents one axis from masking the other

#### 4. **Codebase Design Pattern** (Deep Modules)

**File**: `/skills/engineering/codebase-design/SKILL.md`

**Core vocabulary** (consistent across the skill ecosystem):
```
**Module**: anything with an interface and implementation
**Interface**: everything a caller must know (type sig, invariants, constraints)
**Depth**: leverage at interface (behavior per unit interface learned)
**Seam** (Michael Feathers): place to alter behavior without editing there
**Adapter**: concrete thing satisfying interface at a seam
**Leverage**: what callers get from depth
**Locality**: what maintainers get from depth (concentrated vs. scattered)
```

**Deep vs Shallow**:
```
DEEP MODULE (good)
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│  Deep Implementation│  ← Complex logic hidden
└─────────────────────┘

SHALLOW MODULE (avoid)
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

**Testability principles**:
```typescript
// 1. Accept dependencies, don't create them
function processOrder(order, paymentGateway) {}  // ✓ Testable

// 2. Return results, don't produce side effects
function calculateDiscount(cart): Discount {}  // ✓ Testable
// vs
function applyDiscount(cart): void { cart.total -= discount; }  // ✗ Hard to test

// 3. Small surface area (fewer methods = fewer tests needed)
```

#### 5. **Domain Modeling Pattern** (Glossary + ADR Format)

**CONTEXT.md Format** (from `/skills/engineering/domain-modeling/CONTEXT-FORMAT.md`):
```markdown
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

**Rules**:
- Be opinionated (pick one term, list others under `_Avoid_`)
- Keep definitions tight (one or two sentences, define WHAT not WHAT it does)
- Only include project-specific concepts (not general programming concepts)

**ADR Format** (from `/skills/engineering/domain-modeling/ADR-FORMAT.md`):
```markdown
# {Short title of the decision}

{1-3 sentences: context, what we decided, why.}
```

**When to offer an ADR** (all three must be true):
1. Hard to reverse (meaningful cost to change)
2. Surprising without context (reader will wonder "why this way?")
3. Result of real trade-off (genuine alternatives considered)

---

## Interesting Patterns & Idioms

### 1. **Skill Composition Pattern** (grill-with-docs)

**File**: `/skills/engineering/grill-with-docs/SKILL.md`

The simplest skill — it delegates to two others:
```yaml
---
name: grill-with-docs
description: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
disable-model-invocation: true
---

Call the Skill tool twice, for "grilling" and "domain-modeling".
```

**Pattern**: Skills can orchestrate other skills. This one runs the interview primitive (`grilling`) while simultaneously building and sharpening domain language (`domain-modeling`).

### 2. **Frontier-Based Questioning Pattern**

**Used in**: grilling, triage, wayfinder, improve-codebase-architecture

Core principle: Calculate which questions have their prerequisites met ("frontier"), ask only those, wait for answers, recalculate frontier, repeat.

**Pseudo-algorithm**:
```
1. Build decision tree (every decision → subquestions that depend on it)
2. Calculate frontier = {decisions with no unresolved prerequisites}
3. Ask all frontier questions in one numbered round with recommended answers
4. Wait for user answers
5. User answers reshape tree (settled decisions push frontier outward)
6. Repeat from step 2 until frontier is empty
```

**Benefit**: Maximizes information collected per round; minimizes back-and-forth.

### 3. **Fact-Finding Delegation Pattern**

**Documented in**: grilling, triage, wayfinder

When a question has a factual prerequisite (filesystem state, API docs, existing code), the agent dispatches a **subagent** to find it without blocking the frontier:

```
Main agent: "While researching Q7's prerequisites, ask the other frontier questions now."
Subagent: Investigates filesystem/tools in background, reports findings.
Main agent: Uses findings to inform Q7's context.
```

**Benefit**: Parallelizes fact-finding with user decision-making.

### 4. **Spec Template Pattern** (to-spec)

**File**: `/skills/engineering/to-spec/SKILL.md`

Synthesizes conversation into structured spec WITHOUT re-interviewing:

```markdown
## Problem Statement
{user's perspective on problem}

## Solution
{solution from user's perspective}

## User Stories
{numbered list: "As an <actor>, I want <feature>, so that <benefit>"}

## Implementation Decisions
{modules, interfaces, technical choices, schema changes, API contracts}
_(Note: no file paths/code snippets unless they encode decisions)_

## Testing Decisions
{what makes good test, which modules tested, prior art}

## Out of Scope
{deliberately excluded from this spec}

## Further Notes
```

**Pattern**: Uses prior conversation context; doesn't re-grill.

### 5. **Wayfinder Pattern** (Fog-of-War Mapping)

**File**: `/skills/engineering/wayfinder/SKILL.md`

For huge efforts too big for one session: Chart a **shared map** of **decision tickets** on issue tracker, work one at a time until fog clears.

**Map structure**:
```markdown
## Destination
{What this map is finding its way to: spec, decision, or change}

## Notes
{Domain; skills to consult; standing preferences}

## Decisions so far
- [Closed ticket title](link): one-line gist of answer

## Not yet specified
{Fog of war: suspected but unprecisable questions in scope, one per line}

## Out of scope
{Work deliberately ruled out (past destination)}
```

**Ticket types**:
- **Research** (AFK): Background agent finds facts
- **Prototype** (HITL): Raise fidelity with rough artifact
- **Grilling** (HITL): Conversation (default)
- **Task** (AFK|HITL): Work that must happen before decisions

**Discipline**: Don't ticket the fog; only ticket when the question is sharp. Fog graduates to tickets as frontier advances.

### 6. **Markup Conventions for Agent Communication**

**Used throughout**:
```markdown
> *This was generated by AI during triage.*  # Disclaimer

❓ **Q1** - **Title**: Body           # Numbered questions
➡️ Recommended answer                 # Suggested direction

[Issue Title](link): gist             # Reference by name, not number
#42 #43 #44                           # Avoid bare IDs (illegible)
```

---

## Error Handling & Edge Cases

### Error Handling: Generally Not Present in SKILL.md Files

This repository's skills are **workflow/decision frameworks**, not executable code, so traditional error handling (try-catch, error logging) is absent. However, there are **failure modes** the skills explicitly address:

### 1. **Triage Conflict Handling** (code-review.md)

```
Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`)
and the diff is non-empty. A bad ref or empty diff should fail here,
not inside two parallel sub-agents.
```

**Pattern**: Validate inputs upfront before dispatching work.

### 2. **Plugin Version Sync Validation** (sync-plugin-version.mjs)

```javascript
if (JSON.parse(updated).version !== version) {
  console.error(`Could not find a version field to replace in ${pluginPath}.`);
  process.exit(1);
}
```

**Pattern**: Validate transformation worked before writing file.

### 3. **Out-of-Scope Knowledge Base** (triage/OUT-OF-SCOPE.md)

A structured way to capture and reference **rejected feature requests** so future triagers don't re-ask:

```markdown
_[Directory `.out-of-scope/` holds markdown files documenting rejected requests]_

A rejected enhancement lives here so the next triage knows why the answer was "no."
```

### 4. **Verification Before Spec** (triage.md)

```
**Verify the claim** before any grilling:
- For a bug: reproduce it from the reporter's steps
- For a PR: check out diff, run tests, confirm it does what it claims
- Report: confirmed (with code path), failed, or insufficient detail
```

**Pattern**: Validate the premise is sound before committing effort.

### 5. **Blockage & Frontier** (wayfinder)

```
A ticket is **unblocked** when every ticket blocking it is closed;
the **frontier** is the open, unblocked, unclaimed children.
```

**Pattern**: Use blocker relationships (not status comments) to avoid work-in-progress blindness.

---

## Key File Structure & Citations

### Configuration Files
- **`package.json`**: Node.js project metadata + version entry point
  - `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/mattpocock/skills/package.json`

- **`.claude-plugin/plugin.json`**: Claude Code plugin manifest (curated promoted skills)
  - `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/mattpocock/skills/.claude-plugin/plugin.json`

- **`.claude-plugin/marketplace.json`**: Fallback single-plugin marketplace (if installing directly)
  - (Not examined, but referenced in ADR-0002)

### Core Scripts
- **`scripts/sync-plugin-version.mjs`**: Keeps plugin.json version in sync with package.json
  - `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/mattpocock/skills/scripts/sync-plugin-version.mjs`

### Documentation & Standards
- **`CLAUDE.md`**: Repo conventions (skill buckets, promotion/demotion rules, naming)
  - `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/mattpocock/skills/CLAUDE.md`

- **`.agents/adr/0002-ship-as-a-claude-code-plugin.md`**: Why ship as plugin vs. Codex, constraints on manifest format
  - `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/mattpocock/skills/.agents/adr/0002-ship-as-a-claude-code-plugin.md`

### Skill Directories (Sample)
```
skills/engineering/
├── ask-matt/SKILL.md                    # Router/navigation skill
├── codebase-design/SKILL.md             # Deep module vocabulary reference
├── code-review/SKILL.md                 # Two-axis review discipline
├── diagnosing-bugs/SKILL.md             # Disciplined debugging loop
├── domain-modeling/
│   ├── SKILL.md
│   ├── CONTEXT-FORMAT.md                # Glossary document template
│   ├── ADR-FORMAT.md                    # Architectural decision template
├── grill-with-docs/SKILL.md             # Interview + domain modeling
├── implement/SKILL.md                   # Build feature via TDD + code-review
├── improve-codebase-architecture/SKILL.md
├── prototype/SKILL.md                   # Throwaway design validation
├── research/SKILL.md                    # Delegate fact-finding to background agent
├── setup-matt-pocock-skills/SKILL.md    # Configure tracker, labels, layout
├── tdd/
│   ├── SKILL.md
│   ├── tests.md                         # Good vs. bad test patterns
│   ├── mocking.md                       # Mocking at boundaries only
├── to-spec/SKILL.md                     # Synthesize conversation to spec
├── to-tickets/SKILL.md                  # Break spec into tracer-bullet tickets
├── triage/
│   ├── SKILL.md
│   ├── AGENT-BRIEF.md                   # How to write durable agent briefs
│   ├── OUT-OF-SCOPE.md                  # Rejected request knowledge base
├── wayfinder/SKILL.md                   # Plan huge efforts via decision map
├── wizard/SKILL.md                      # Interactive bash for human-only steps

skills/productivity/
├── grill-me/SKILL.md                    # Stateless interview (no repo)
├── grilling/SKILL.md                    # Interview primitive (no wrapper)
├── handoff/SKILL.md                     # Compact context for new harness/colleague
├── teach/SKILL.md                       # Multi-session learning workspace
├── to-questionnaire/SKILL.md            # Interview for decision-maker
├── wait-what/SKILL.md                   # Corrective re-pitch mid-conversation
├── writing-for-agents/SKILL.md          # Reference: writing docs agents consume
```

---

## Summary: Patterns & Principles

| Pattern | Where | Purpose |
|---------|-------|---------|
| **Frontier-based questioning** | grilling, triage, wayfinder | Only ask questions unblocked by prior answers |
| **Fact-finding delegation** | grilling, triage, wayfinder | Dispatch subagents for facts; don't block frontier |
| **Two-axis separation** | code-review | Standards ⊥ Spec; neither masks the other |
| **Deep modules** | codebase-design, tdd | Behavior behind small interface at clean seam |
| **Seams first** | tdd, codebase-design | Test/design at public boundaries, never internals |
| **Domain-first naming** | domain-modeling, all skills | Glossary vocabulary in CONTEXT.md, ADRs for decisions |
| **Red-green-refactor** | tdd | Write failing test, minimal code, review separately |
| **Spec without re-interview** | to-spec | Synthesize prior conversation, don't re-grill |
| **Fog-of-war mapping** | wayfinder | Don't ticket the fog; only ticket sharp questions |
| **Skill composition** | grill-with-docs, implement, wayfinder | Skills orchestrate other skills via Skill tool |
| **Version sync** | sync-plugin-version.mjs | One source of truth; script keeps copies in sync |

---

## Architecture Decision Records

### ADR-0002: Ship as Claude Code Plugin (key decision)

**File**: `/.agents/adr/0002-ship-as-a-claude-code-plugin.md`

**Decision**: Ship native Claude Code plugin (curated skill set via `.claude-plugin/plugin.json`); defer Codex plugin.

**Rationale**: 
- Claude Code's manifest accepts explicit skill-directory paths (curates promoted set)
- Codex's manifest accepts only a single path string (would ship non-promoted skills too)
- Restructuring or duplicating would be larger scope

**Invariants created**:
- Every promoted skill has entry in `.claude-plugin/plugin.json` `skills` array
- `.claude-plugin/plugin.json` version always matches `package.json` version (enforced by script)

---

## Notes & Observations

1. **No TypeScript/implementation code** for skills themselves; only the sync script and plugin JSON
2. **Markdown is the implementation language** — skills describe workflows and constraints agents follow
3. **Skills are composable** — grill-with-docs = grilling + domain-modeling; implement = tdd + code-review
4. **References are by name, never ID** — "Order Completion" instead of "#42" for readability
5. **Version is centralized** — package.json is source of truth; sync script propagates to plugin.json
6. **Skills shipped as read-only plugin OR editable copies** — plugin route (managed, auto-updates) vs. skills.sh route (owned, forkable)
