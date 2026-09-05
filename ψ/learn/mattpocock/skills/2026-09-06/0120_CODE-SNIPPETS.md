# Code Snippets: mattpocock/skills Repository

**Analyzed**: 37 SKILL.md files across 5 categories (engineering, productivity, misc, in-progress, deprecated)  
**Repository**: https://github.com/mattpocock/skills  
**Source**: `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/mattpocock/skills`

## Entry Point: SKILL.md Format

Every skill is a Markdown file with YAML frontmatter. The format varies between **user-invoked** (disabled for model invocation) and **model-invoked** (reachable by agent or user).

### Minimal User-Invoked Skill
**Source**: `/skills/productivity/grill-me/SKILL.md`

```yaml
---
name: grill-me
description: A relentless interview to sharpen a plan or design.
disable-model-invocation: true
---

Call the Skill tool with "grilling".
```

**Pattern**: User-invoked skills often delegate to model-invoked skills via explicit Skill tool invocation.

### Comprehensive Model-Invoked Skill (Grilling)
**Source**: `/skills/productivity/grilling/SKILL.md` (excerpt)

```yaml
---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---
```

Body specifies the algorithm:

```markdown
Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body>

➡️ <your recommended answer>
```
```

**Key patterns**:
- Emoji formatting (`❓`, `➡️`) for visual structure
- Design tree as a mental model
- Frontier concept (action-ready subset at each round)
- Dispatch sub-agents for facts, ask user for decisions only

## Core Implementations: Complex Discipline Skills

### TDD (Test-Driven Development)
**Source**: `/skills/engineering/tdd/SKILL.md`

Defines the discipline explicitly:

```markdown
# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle: consult them before and during the loop, not after.
```

Supporting file **`tests.md`** provides concrete examples:

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Anti-patterns listed explicitly:

```typescript
// BAD: Expected value is recomputed the way the code computes it
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);  // ← Same logic as implementation
  expect(calculateTotal(items)).toBe(expected);  // ← Passes by construction
});

// GOOD: Expected value is an independent, known literal
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);  // ← Hard-coded expected
});
```

**Patterns**:
- Reference documentation embedded in skill itself
- Supporting files for detailed examples
- Anti-patterns named and explained
- Rules stated as checkboxes or numbered lists

### Diagnosing Bugs (6-Phase Discipline)
**Source**: `/skills/engineering/diagnosing-bugs/SKILL.md`

Phases with explicit completion criteria:

```markdown
## Phase 1: Build a feedback loop

This is the skill. Everything else is mechanical. If you have a **tight** pass/fail signal for the bug (one that goes red on _this_ bug), you will find the cause.

### Ways to construct one, in roughly this order

1. **Failing test** at whatever seam reaches the bug: unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
[... 7 more patterns ...]

### Completion criterion: a tight loop that goes red

Phase 1 is done when the loop is **tight** and **red-capable**:

- [ ] **Red-capable**: it drives the actual bug code path and asserts the **user's exact symptom**
- [ ] **Deterministic**: same verdict every run
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: you can run it unattended
```

**Pattern**: Multi-phase disciplines stated as ordered sections with completion criteria as checklists.

### Codebase Design (Deep Modules Vocabulary)
**Source**: `/skills/engineering/codebase-design/SKILL.md`

Establishes a **glossary** as a core pattern:

```markdown
## Glossary

Use these terms exactly: don't substitute "component," "service," "API," or "boundary." Consistent language is the whole point.

**Module**: anything with an interface and an implementation. Deliberately scale-agnostic: a function, class, package, or tier-spanning slice. _Avoid_: unit, component, service.

**Interface**: everything a caller must know to use the module correctly: the type signature, but also invariants, ordering constraints, error modes, required configuration, and performance characteristics. _Avoid_: API, signature.

**Depth**: leverage at the interface. The amount of behaviour a caller (or test) can exercise per unit of interface they have to learn.
```

Visual illustration using ASCII diagrams:

```markdown
**Deep module** = small interface + lots of implementation:

┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

**Patterns**:
- Glossary to fix terminology
- ASCII diagrams for structure
- Explicit "avoid" sections for wrong terminology
- Principles section with named tests (e.g., "The deletion test")

## Infrastructure & Shared Patterns

### Wizard Library (Reusable Bash Framework)
**Source**: `/skills/engineering/wizard/template.sh`

Self-contained bash script with immutable library above a marker:

```bash
#!/usr/bin/env bash
#
# A wizard walks a human through a manual procedure, step by step.
# Generated by the /wizard skill.
#
# Everything above the "STAGES" marker is the wizard library: do not hand-edit
# it. Author the per-step stages below the marker.

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────
# Wizard library: delightful, consistent UX, identical across every wizard.
# ──────────────────────────────────────────────────────────────────────────

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); RED=$(tput setaf 1)
else
  BOLD=""; DIM=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

_STAGE_INDEX=0
ENV_FILE="${ENV_FILE:-.env}"
WRITTEN_ENV=()
WRITTEN_SECRET=()
SKIPPED=()

_clear() {
  [[ -t 1 ]] || return 0
  if command -v tput >/dev/null 2>&1; then tput clear; else printf '\033[2J\033[3J\033[H'; fi
}

banner() {
  _clear
  printf '\n%s%s  %s%s\n' "$BOLD" "$BLUE" "$1" "$RESET"
  printf '%s  %s stages%s\n\n' "$DIM" "$TOTAL_STAGES" "$RESET"
  pause "Ready to start?"
}

stage() {
  _clear
  _STAGE_INDEX=$((_STAGE_INDEX + 1))
  printf '\n%s%s▸ Stage %s/%s · %s%s\n' "$BOLD" "$BLUE" "$_STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}

say()  { printf '  %s\n' "$1"; }
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }

open_url() {
  local url="$1"
  printf '  %s↗ opening%s %s\n' "$GREEN" "$RESET" "$url"
  { if   command -v wslview     >/dev/null 2>&1; then wslview "$url"
    elif command -v explorer.exe >/dev/null 2>&1; then explorer.exe "$url"
    elif command -v xdg-open    >/dev/null 2>&1; then xdg-open "$url"
    elif command -v open        >/dev/null 2>&1; then open "$url"
    else warn "couldn't open a browser; visit it manually: $url"; fi
  } >/dev/null 2>&1 || warn "couldn't open a browser, so visit it manually: $url"
}

ask() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Enter keeps current]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -r input || true
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

ask_secret() {
  local key="$1" prompt="$2" current input
  current=$(_existing "$key" || true)
  if [[ -n "$current" ]]; then
    printf '  %s%s%s %s[Enter keeps current]%s ' "$BOLD" "$prompt" "$RESET" "$DIM" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$prompt" "$RESET"
  fi
  read -rs input || true
  printf '\n'
  [[ -z "$input" && -n "$current" ]] && input="$current"
  printf -v "$key" '%s' "$input"
}

write_env() {
  local key="$1" value="$2" tmp
  touch "$ENV_FILE"
  tmp=$(mktemp)
  grep -vE "^${key}=" "$ENV_FILE" > "$tmp" || true
  printf '%s=%s\n' "$key" "$value" >> "$tmp"
  mv "$tmp" "$ENV_FILE"
  WRITTEN_ENV+=("$key")
  printf '  %s✓ wrote%s %s → %s\n' "$GREEN" "$RESET" "$key" "$ENV_FILE"
}

set_secret() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if printf '%s' "$value" | gh secret set "$name" >/dev/null 2>&1; then
      WRITTEN_SECRET+=("$name")
      printf '  %s✓ set%s GitHub secret %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("GitHub secret $name (set it manually: gh secret set $name)")
  warn "skipped GitHub secret $name: gh not ready; set it later"
}

finish() {
  _clear
  printf '\n%s%s  ✓ Setup complete%s\n' "$BOLD" "$GREEN" "$RESET"
  (( ${#WRITTEN_ENV[@]} ))    && note "wrote ${#WRITTEN_ENV[@]} value(s) to $ENV_FILE: ${WRITTEN_ENV[*]}"
  (( ${#WRITTEN_SECRET[@]} )) && note "set ${#WRITTEN_SECRET[@]} GitHub secret(s): ${WRITTEN_SECRET[*]}"
  if (( ${#SKIPPED[@]} )); then
    printf '\n'; warn "still to do by hand:"
    for s in "${SKIPPED[@]}"; do note "  - $s"; done
  fi
  printf '\n'
}

# ──────────────────────────────────────────────────────────────────────────
# STAGES: author this section.
# ──────────────────────────────────────────────────────────────────────────
```

**Patterns**:
- Immutable library with "do not hand-edit" marker
- Color constant definitions at top with fallback for non-TTY
- Idempotent `.env` file handling with `grep -v` and upsert logic
- Cross-platform URL opening with command priority order (WSL → Windows → Linux → macOS)
- Stage tracking for progress display
- Secret value hiding with `read -rs` (no-echo)
- GitHub CLI integration with graceful fallback

## Interesting Patterns & Idioms

### 1. Skill Composition: Delegating via Skill Tool

**Pattern**: Skills delegate to other skills via explicit `Call the Skill tool with "..."` instructions.

```markdown
# grill-with-docs

Call the Skill tool twice, for "grilling" and "domain-modeling".
```

Rather than deep cross-references, all dependencies surface as explicit tool calls. This makes dependencies:
- Visible in harness-agnostic prose
- Testable (the tool name is always callable)
- Trackable for linting

### 2. Two-Axis Review (Code Review)

**Source**: `/skills/engineering/code-review/SKILL.md`

Deliberately separates concerns to prevent one from masking the other:

```markdown
## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
```

**Process** includes parallel sub-agents and aggregation without reranking.

### 3. Foggy Planning (Wayfinder)

**Source**: `/skills/engineering/wayfinder/SKILL.md`

Introduces the **frontier** concept (tasks that can be started now) and **fog of war** (decisions still pending):

```markdown
## Fog of war

The map is _deliberately_ incomplete: don't chart what you can't yet see. Beyond the live tickets lies the **fog of war**: the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open.

**Fog or ticket?** The test is whether you can state the question precisely now, _not_ whether you can answer it now.

- **Ticket when** the question is already sharp, even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply.
```

Uses tracking branches (`research/<name>`) for parallel sub-agent work.

### 4. Domain Modeling: Challenge Against Glossary

**Source**: `/skills/engineering/domain-modeling/SKILL.md`

Real-time term validation:

```markdown
### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `CONTEXT.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"
```

Lazy file creation pattern:

```markdown
Create files lazily: only when you have something to write. If no `CONTEXT.md` exists, create one when the first term is resolved.
```

### 5. Diagnosis Phase Completeness Criteria

**Source**: `/skills/engineering/diagnosing-bugs/SKILL.md`

Explicit checkpoint for phase completion as checklist:

```markdown
### Completion criterion: a tight loop that goes red

Phase 1 is done when the loop is **tight** and **red-capable**: you can name **one command** (a script path, a test invocation, a curl) that you have **already run at least once** (show the invocation and its output, redacted), and that is:

- [ ] **Red-capable**: it drives the actual bug code path and asserts the **user's exact symptom**, so it can go red on this bug and green once fixed.
- [ ] **Deterministic**: same verdict every run (flaky bugs: a pinned, high reproduction rate, per above).
- [ ] **Fast**: seconds, not minutes.
- [ ] **Agent-runnable**: you can run it unattended
```

### 6. Redaction Protocol (Security-Aware Skill Design)

**Source**: `/skills/engineering/diagnosing-bugs/SKILL.md`

```markdown
## Redact

This skill has you show commands, outputs and captured artifacts. **Redact every secret first**: write `<REDACTED>` in its place. Build loops against env vars, so the credential stays in the environment rather than in what you show. Captured artifacts carry auth headers: quote only the lines that carry the signal.

If the redacted output is not enough to diagnose the bug, say so and ask the user.
```

## Supporting Files & Format Templates

### CONTEXT Format (Domain Glossary)
**Source**: `/skills/engineering/domain-modeling/CONTEXT-FORMAT.md`

Skills reference external format templates for consistency:

```markdown
## During the session

### Update CONTEXT.md inline

When a term is resolved, update `CONTEXT.md` right there. Don't batch these up: capture them as they happen. Use the format in [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

`CONTEXT.md` should be totally devoid of implementation details.
```

### ADR Format (Architecture Decision Records)
**Source**: `/skills/engineering/domain-modeling/ADR-FORMAT.md`

Referenced for capture-as-you-go pattern.

### HTML Report Pattern (Improve Codebase Architecture)
**Source**: `/skills/engineering/improve-codebase-architecture/SKILL.md`

Generates self-contained HTML with CDN dependencies:

```markdown
The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via CDN** for diagrams where a graph/flow/sequence reliably communicates the structure.

For each candidate, render a card with:

- **Files**: which files/modules are involved
- **Problem**: why the current architecture is causing friction
- **Solution**: plain English description of what would change
- **Benefits**: explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram**: side-by-side, custom-drawn, illustrating the shallowness and the deepening
- **Recommendation strength**: one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge
```

Uses temp directory (`$TMPDIR` with fallback to `/tmp`, or `%TEMP%` on Windows) for artifacts.

## Error Handling & Robustness

### Graceful Fallback (Wizard URL Opening)

```bash
open_url() {
  local url="$1"
  { if   command -v wslview     >/dev/null 2>&1; then wslview "$url"
    elif command -v explorer.exe >/dev/null 2>&1; then explorer.exe "$url"
    elif command -v xdg-open    >/dev/null 2>&1; then xdg-open "$url"
    elif command -v open        >/dev/null 2>&1; then open "$url"
    else warn "couldn't open a browser; visit it manually: $url"; fi
  } >/dev/null 2>&1 || warn "couldn't open a browser, so visit it manually: $url"
}
```

**Pattern**: Priority-order `if` chain testing for available commands, falls back to manual instruction.

### GitHub CLI with Degradation (Wizard set_secret)

```bash
set_secret() {
  local name="$1" value="$2"
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if printf '%s' "$value" | gh secret set "$name" >/dev/null 2>&1; then
      WRITTEN_SECRET+=("$name")
      printf '  %s✓ set%s GitHub secret %s\n' "$GREEN" "$RESET" "$name"
      return
    fi
  fi
  SKIPPED+=("GitHub secret $name (set it manually: gh secret set $name)")
  warn "skipped GitHub secret $name: gh not ready; set it later"
}
```

**Pattern**: Checks for tool availability and auth status, tracks skipped items for final summary.

### Loop Without Blocking (Diagnosing Bugs)

```markdown
Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now.
```

**Pattern**: Parallel exploration where blocking facts don't stop parallel discovery.

## Repository Organization Patterns

### Skill Bucket Hierarchy
```
skills/
├── engineering/          # Daily code work (promoted)
├── productivity/         # Workflow tools (promoted)
├── misc/                 # Rarely used
├── in-progress/          # Beta/feedback
└── deprecated/           # No longer used
```

### Promotion Status Determines Visibility

- **Promoted** (`engineering/`, `productivity/`): appear in top-level `README.md`, `.claude-plugin/plugin.json`, and get `docs/<bucket>/<skill>.md` pages
- **Non-promoted** (`misc/`, `in-progress/`, `deprecated/`): internal only, no docs, flat list in bucket `README.md`

### Invocation Policy Combinations

User-invoked skills:
- YAML frontmatter: `disable-model-invocation: true`
- OpenAI/Codex manifest: `policy.allow_implicit_invocation: false`
- Cannot be reached by other skills

Model-invoked skills:
- Omit `disable-model-invocation`
- Reachable by model or user
- Can be delegated to via Skill tool

## Summary

The mattpocock/skills repository encodes software engineering wisdom as **composable, reproducible skill definitions**. Key architectural choices:

1. **Format consistency**: Every skill is a Markdown file with YAML frontmatter
2. **Glossary-driven design**: Shared terminology (codebase-design, domain-modeling) prevents semantic drift
3. **Phase-based disciplines**: Multi-phase workflows with explicit completion criteria (TDD, diagnosing-bugs, wayfinder)
4. **Frontier concept**: Deliberately incomplete plans that grow as fog clears (wayfinder)
5. **Two-axis review**: Separating concerns to prevent masking (code-review)
6. **Immutable infrastructure**: Reusable libraries (wizard template.sh) with clear "do not edit" boundaries
7. **Skill composition**: Dependencies expressed as explicit tool invocations, not cross-references
8. **Graceful degradation**: Fallback chains and tracking of skipped actions (wizards)
9. **Parallel work patterns**: Sub-agents and non-blocking exploration (diagnosing-bugs, wayfinder)
10. **Lazily created supporting files**: CONTEXT.md, ADRs created when needed, not upfront
