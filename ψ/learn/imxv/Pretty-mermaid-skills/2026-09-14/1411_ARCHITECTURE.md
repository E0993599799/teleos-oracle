# Pretty Mermaid Skills — Architecture

**Repository**: `imxv/Pretty-mermaid-skills`  
**Type**: Claude skill for rendering Mermaid diagrams (SVG, PNG, ASCII)  
**Language**: Node.js (ES6+ modules)  
**Minimum Node.js**: 16+  
**License**: MIT

---

## Overview

Pretty Mermaid is a skill CLI that renders Mermaid diagram source files (`.mmd`) into multiple output formats—SVG for scalable docs, PNG for sharing, and ASCII/Unicode for terminal display. It runs locally without a browser, DOM, or external rendering server. The skill is distributed via `skills.sh` and integrates with Claude Code and other AI coding environments.

**Core abstraction**: A wrapper around the `beautiful-mermaid` library (v1.1.3+), paired with custom SVG-to-PNG rendering via `@resvg/resvg-js`. The skill CLI layers command parsing, file I/O, and format selection on top.

---

## Directory Structure

```
.
├── scripts/                    # CLI entry points and orchestration
│   ├── render.mjs             # Single-file diagram renderer (SVG, PNG, ASCII)
│   ├── batch.mjs              # Parallel multi-file renderer
│   ├── themes.mjs             # List available built-in themes
│   ├── png.mjs                # SVG→PNG conversion logic using @resvg/resvg-js
│   ├── smoke-test.mjs         # Integration test suite
│   ├── validate-docs.mjs      # Documentation validation
│   └── generate-theme-gallery.mjs  # Gallery generator (internal dev)
├── assets/
│   ├── example_diagrams/      # Template .mmd files (6 diagram types)
│   │   ├── flowchart.mmd
│   │   ├── sequence.mmd
│   │   ├── state.mmd
│   │   ├── class.mmd
│   │   ├── er.mmd
│   │   └── xychart.mmd
│   └── theme_gallery/         # Pre-rendered theme preview SVGs
├── references/                # Documentation for users & extenders
│   ├── DIAGRAM_TYPES.md       # Mermaid syntax by diagram class
│   ├── THEMES.md              # Built-in themes and color customization
│   └── api_reference.md       # beautiful-mermaid library API
├── docs/
│   └── THEME_GALLERY.md       # Visual theme comparisons
├── .github/
│   ├── workflows/
│   │   ├── ci.yml             # Lint & test on push/PR
│   │   └── release.yml        # Cut releases & publish to skills.sh
│   └── ISSUE_TEMPLATE/
├── SKILL.md                   # Workflow guide for the skill (how to use)
├── package.json               # Node.js dependencies & npm scripts
├── package-lock.json          # Locked dependency tree
├── README.md                  # Public overview + quick start
├── CONTRIBUTING.md            # Contribution guidelines
├── RELEASING.md               # Release process documentation
├── CHANGELOG.md               # Version history
├── SECURITY.md                # Security policy
└── LICENSE                    # MIT

```

---

## Entry Points

### CLI Binaries (in package.json `"bin"`)

1. **`render-mermaid`** → `scripts/render.mjs`  
   Render a single `.mmd` file to SVG, PNG, or ASCII.

2. **`batch-mermaid`** → `scripts/batch.mjs`  
   Render all `.mmd` files in a directory (parallel workers).

3. **`list-mermaid-themes`** → `scripts/themes.mjs`  
   Print the 15 available theme names and exit.

### npm Scripts (run from skill root)

- `npm test` — Run smoke tests (`scripts/smoke-test.mjs`)
- `npm run gallery` — Generate theme gallery (`scripts/generate-theme-gallery.mjs`)
- `npm run validate` — Validate docs (`scripts/validate-docs.mjs`)

---

## Core Abstractions

### 1. **Dependency: beautiful-mermaid**

A synchronous/async library that parses Mermaid syntax and renders to SVG or terminal ASCII. Exported symbols:

- `renderMermaidSVG(text, options?)` → SVG string
- `renderMermaidASCII(text, options?)` → Terminal string (Unicode or ASCII)
- `THEMES` → Object mapping theme names to color objects (15 themes)

**Auto-install**: If `beautiful-mermaid` is not installed, any rendering script attempts `npm install` and retries.

### 2. **SVG-to-PNG Pipeline**

**File**: `scripts/png.mjs`

Converts an SVG string to PNG binary without external converters. Process:

1. Extract and resolve CSS custom properties (root `:root` and `svg` selectors only)
2. Replace CSS `var()` and `color-mix()` functions with concrete values
3. Validate that all colors are concrete hex values (PNG rasterization cannot handle unresolved CSS)
4. Pass the prepared SVG to `@resvg/resvg-js` with fit-to-width sizing
5. Render to PNG buffer

**Key functions**:
- `prepareSvgForPng(svg)` — Prepare SVG by resolving CSS, return `{ svg, background }`
- `renderSvgForPng(svg, width)` — Use Resvg to rasterize
- `renderSvgToPng(svg, width)` → PNG Buffer

**Constraints**: Only hex colors allowed; CSS variables scoped to root; no @import statements.

### 3. **Rendering Script Framework**

Both `render.mjs` and `batch.mjs` follow the same pattern:

1. Parse command-line arguments into an options object
2. Load `beautiful-mermaid` (with auto-install fallback)
3. Read input Mermaid source(s)
4. Look up theme by name (if provided) or build custom color object
5. Call `renderMermaidSVG` or `renderMermaidASCII` with appropriate theme/options
6. For PNG, pipe SVG through `renderSvgToPng`
7. Write output file or print to stdout
8. Report success or error

**Theme resolution**:
- If `--theme <name>` is passed, look it up in `beautiful-mermaid.THEMES`
- If custom color flags (`--bg`, `--fg`, `--line`, etc.) are passed, build a color object
- For ASCII output, map SVG color keys to ASCII role keys (`border`, `line`, `arrow`, `corner`, `junction`)

### 4. **Batch Renderer**

**File**: `scripts/batch.mjs`

Renders multiple files in parallel (default 4 workers):

1. List `.mmd` files in input directory
2. Split into batches of N files (where N = `--workers`)
3. Use `Promise.allSettled()` to render each batch concurrently
4. Collect results; report successes and failures
5. Exit with error status if any file failed

Output file names are derived by replacing `.mmd` extension with `.svg`, `.png`, or `.txt`.

---

## Command Examples

### Render single SVG with theme

```bash
node scripts/render.mjs \
  --input diagram.mmd \
  --output output.svg \
  --theme tokyo-night
```

### Render PNG with custom width

```bash
node scripts/render.mjs \
  --input diagram.mmd \
  --output output.png \
  --format png \
  --width 1200 \
  --theme github-dark
```

### Terminal ASCII output

```bash
node scripts/render.mjs \
  --input diagram.mmd \
  --output diagram.txt \
  --format ascii \
  --color-mode none
```

### Batch render with parallel workers

```bash
node scripts/batch.mjs \
  --input-dir ./diagrams \
  --output-dir ./rendered \
  --format svg \
  --theme dracula \
  --workers 4
```

### List themes

```bash
node scripts/themes.mjs
```

---

## Configuration & Options

### SVG Options

| Flag | Default | Type | Purpose |
|------|---------|------|---------|
| `--theme <name>` | (none) | string | Named theme from built-in set |
| `--bg <hex>` | `#FFFFFF` | hex | Background color |
| `--fg <hex>` | `#27272A` | hex | Foreground color |
| `--line <hex>` | (derived) | hex | Edge/connector color |
| `--accent <hex>` | (derived) | hex | Arrow heads & highlights |
| `--muted <hex>` | (derived) | hex | Secondary text color |
| `--surface <hex>` | (derived) | hex | Node fill tint |
| `--border <hex>` | (derived) | hex | Node stroke color |
| `--font <name>` | `Inter` | string | Font family for SVG |
| `--transparent` | false | bool | Transparent background |
| `--padding <n>` | `40` | int (px) | Canvas padding |
| `--node-spacing <n>` | `24` | int (px) | Horizontal node spacing |
| `--layer-spacing <n>` | `40` | int (px) | Vertical layer spacing |
| `--component-spacing <n>` | `24` | int (px) | Spacing between components |
| `--interactive` | false | bool | Enable XY chart tooltips |

### PNG Options

| Flag | Default | Type | Purpose |
|------|---------|------|---------|
| `--width <n>` | `800` | int (px, 100–10000) | Output width (preserves aspect) |
| `--transparent` | false | bool | Transparent background |

### ASCII Options

| Flag | Default | Type | Purpose |
|------|---------|------|---------|
| `--use-ascii` | false | bool | Plain ASCII instead of Unicode |
| `--padding-x <n>` | `5` | int | Horizontal node spacing |
| `--padding-y <n>` | `5` | int | Vertical node spacing |
| `--box-border-padding <n>` | `1` | int | Inner box padding |
| `--color-mode <mode>` | `auto` | enum | `none`, `auto`, `ansi16`, `ansi256`, `truecolor`, `html` |

### Batch Options

| Flag | Default | Type | Purpose |
|------|---------|------|---------|
| `--workers <n>` | `4` | int | Number of parallel workers |

---

## Supported Diagram Types

All six Mermaid diagram types are auto-detected from source:

1. **Flowchart** — `flowchart LR` / `graph TD` (processes, decision trees)
2. **Sequence** — `sequenceDiagram` (messages, interactions)
3. **State** — `stateDiagram-v2` (lifecycle, state machines)
4. **Class** — `classDiagram` (OOP structures)
5. **ER** — `erDiagram` (entity-relationship models)
6. **XY Chart** — `xychart-beta` (bars, lines, trends)

Example templates in `assets/example_diagrams/`.

---

## Built-in Themes

15 themes provided by `beautiful-mermaid`:

**Light themes**: `zinc-light`, `github-light`, `tokyo-night-light`, `catppuccin-latte`, `solarized-light`

**Dark themes**: `zinc-dark`, `github-dark`, `tokyo-night`, `tokyo-night-storm`, `catppuccin-mocha`, `solarized-dark`, `dracula`, `one-dark`

**Neutral**: `nord`, `nord-light`

Theme objects include `bg`, `fg`, `line`, `accent`, `muted`, `surface`, `border` keys.

---

## Dependencies

From `package.json`:

- **`beautiful-mermaid@^1.1.3`** — Mermaid parsing & rendering
- **`@resvg/resvg-js@^2.6.2`** — SVG-to-PNG rasterization
- **Node.js >=16** (requirement in `engines`)

No other runtime dependencies.

---

## File I/O & Error Handling

### Input

- Single renderer: `--input <file>` must exist and be readable UTF-8 text
- Batch renderer: `--input-dir <dir>` must exist; lists all `.mmd` files
- If no input files are found in batch mode, exit with error status

### Output

- Default output: stdout (SVG or ASCII)
- If `--output <file>` provided: write to that path
- PNG mode: if no `--output`, derive from input filename (`.mmd` → `.png`)
- Batch mode: create output directory if missing; name outputs by replacing `.mmd`
- Overwriting existing files: allowed (no warning)

### Error Handling

- Unknown theme: thrown error with hint to run `themes.mjs`
- Parse error in Mermaid source: propagated from `beautiful-mermaid`
- PNG conversion failure: error if SVG contains unresolved CSS variables
- Auto-install failure: error with manual fallback instructions
- Exit code: 0 on success, 1 on error; batch renderer exits 1 if any file fails

---

## Development & Testing

### npm Scripts

- **`npm test`** — Run `smoke-test.mjs` (integration tests on example diagrams)
- **`npm run validate`** — Run `validate-docs.mjs` (check SKILL.md and references for completeness)
- **`npm run gallery`** — Generate `docs/THEME_GALLERY.md` (visual comparisons)

### Example Diagrams

Six starter templates in `assets/example_diagrams/`:
- `flowchart.mmd`, `sequence.mmd`, `state.mmd`, `class.mmd`, `er.mmd`, `xychart.mmd`

Useful for testing all diagram types and for users to copy.

### CI/CD

- **`.github/workflows/ci.yml`** — Lint & test on push/PR
- **`.github/workflows/release.yml`** — Cut releases, publish to skills.sh

---

## Documentation Structure

- **`SKILL.md`** — Workflow guide for skill users (when to render, which diagram type, output format selection, command examples, troubleshooting)
- **`README.md`** — Public overview, badges, quick start, feature list
- **`references/DIAGRAM_TYPES.md`** — Mermaid syntax by type (consult when authoring new diagrams)
- **`references/THEMES.md`** — Theme definitions and color customization
- **`references/api_reference.md`** — `beautiful-mermaid` library API for extenders
- **`docs/THEME_GALLERY.md`** — Visual theme comparisons (generated)
- **`CONTRIBUTING.md`** — Contribution guidelines
- **`RELEASING.md`** — How to cut a release
- **`SECURITY.md`** — Security policy
- **`CHANGELOG.md`** — Version history

---

## Integration Points

### Installation

Installed via `skills.sh`:
```bash
npx skills add imxv/pretty-mermaid-skills@pretty-mermaid -g -y
```

Makes `render-mermaid`, `batch-mermaid`, `list-mermaid-themes` binaries available globally.

### AI Environment Support

Tested with: Claude Code, Cursor, Gemini CLI, Antigravity, OpenCode, Codex, qoder.

Skills are invoked by the AI agent's orchestration layer; the skill itself is stateless and request-driven.

---

## Key Design Decisions

1. **No browser required**: Delegates rendering to libraries rather than spawning Chromium, reducing memory and startup time.

2. **Synchronous SVG rendering**: `beautiful-mermaid` is synchronous; PNG is post-processed synchronously. Simplifies CLI error handling and file I/O.

3. **CSS variable resolution in PNG pipeline**: Rather than trust SVG-embedded CSS during rasterization, the PNG converter strips and resolves all variables upfront, ensuring predictable color output.

4. **Parallel batch processing**: Batch renderer uses worker pool to handle 3+ diagrams efficiently without spawning a child process per file.

5. **Auto-install fallback**: Rendering scripts attempt `npm install` if dependencies are missing, allowing the skill to bootstrap itself on first use.

6. **Flexible theme system**: 15 built-in named themes + per-color flags allow users to customize appearance without editing templates or config files.

7. **Example diagrams as templates**: `assets/example_diagrams/` provides working starters; users copy and modify rather than authoring from scratch.

---

## Summary

Pretty Mermaid is a thin, focused skill CLI that wraps `beautiful-mermaid` rendering and adds SVG-to-PNG conversion. Its architecture emphasizes:

- **Stateless operation**: Each invocation is independent; no server, no persistent state.
- **Multi-format output**: One Mermaid source, three consumer formats (SVG for docs, PNG for sharing, ASCII for terminals).
- **Minimal dependencies**: Only two npm packages (`beautiful-mermaid`, `@resvg/resvg-js`).
- **Transparent CLI**: Command-line flags directly map to rendering options; no config files.
- **Batch-friendly**: Parallel rendering and consistent option application across files.

The skill is designed for AI agents to invoke directly when a user requests a diagram, offering a complete path from Mermaid prose to rendered output without requiring the user to understand rendering infrastructure.
