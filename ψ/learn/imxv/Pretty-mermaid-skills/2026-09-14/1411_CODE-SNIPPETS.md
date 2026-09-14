# Pretty Mermaid Skills — Code Snippets

**Repository**: `imxv/Pretty-mermaid-skills`  
**Language**: JavaScript (Node.js)  
**Architecture**: Modular CLI tools for rendering Mermaid diagrams into SVG, PNG, and ASCII formats  
**Key Dependencies**: `beautiful-mermaid`, `@resvg/resvg-js`

---

## Overview

Pretty Mermaid is a Node.js toolset for rendering Mermaid diagrams locally without a browser or DOM. It provides:
- **Single-file rendering** via `render.mjs`
- **Batch processing** via `batch.mjs`  
- **PNG conversion** with SVG-to-PNG rasterization in `png.mjs`
- **Theme and color management** across multiple output formats
- **Comprehensive testing** via smoke tests and documentation validation

All scripts support three output formats:
1. **SVG** — scalable vector, themed, full styling
2. **PNG** — raster at specified width (100-10000px)
3. **ASCII/Unicode** — terminal and plain-text friendly

---

## Architecture

### File Structure
```
scripts/
  render.mjs              # Single-file rendering CLI entry point
  batch.mjs               # Batch directory processing with parallel workers
  png.mjs                 # SVG-to-PNG conversion and CSS resolution logic
  themes.mjs              # List available themes
  generate-theme-gallery.mjs  # Generate theme preview SVGs
  smoke-test.mjs          # Comprehensive test suite (37+ assertions)
  validate-docs.mjs       # Documentation and config validation
```

### Dependencies
```json
{
  "beautiful-mermaid": "^1.1.3",     // Core rendering library
  "@resvg/resvg-js": "^2.6.2"        // SVG rasterization
}
```

---

## Main Entry Points

### 1. render.mjs — Single-File Rendering

**Purpose**: Render one `.mmd` file to SVG, PNG, or ASCII with theme and color customization.

#### Argument Parsing
```javascript
function parseArgs() {
  const args = process.argv.slice(2);
  const opts = {
    input: null,
    output: null,
    format: 'svg',           // svg | png | ascii
    theme: null,
    bg: null,
    fg: null,
    font: 'Inter',
    transparent: false,
    useAscii: false,
    paddingX: 5,
    paddingY: 5,
    boxBorderPadding: 1,
    colorMode: 'auto',       // none | auto | ansi16 | ansi256 | truecolor | html
    padding: 40,
    nodeSpacing: 24,
    layerSpacing: 40,
    componentSpacing: 24,
    interactive: false,
    width: DEFAULT_PNG_WIDTH,
  };

  for (let i = 0; i < args.length; i++) {
    const key = args[i];
    const val = args[i + 1];

    switch (key) {
      case '--input': case '-i': opts.input = val; i++; break;
      case '--output': case '-o': opts.output = val; i++; break;
      case '--format': case '-f': opts.format = val; i++; break;
      case '--theme': case '-t': opts.theme = val; i++; break;
      case '--bg': opts.bg = val; i++; break;
      case '--fg': opts.fg = val; i++; break;
      // ... more flags ...
    }
  }

  if (!opts.input) {
    console.error('Error: --input is required. Use --help for usage.');
    process.exit(1);
  }
  return opts;
}
```

#### Color Theme Resolution
```javascript
function toAsciiTheme(colors) {
  if (!colors) return undefined;

  const border = colors.border ?? colors.fg;
  const line = colors.line ?? colors.fg;
  const arrow = colors.accent ?? colors.line ?? colors.fg;
  const corner = colors.border ?? colors.line ?? colors.fg;
  const junction = colors.accent ?? colors.border ?? colors.line ?? colors.fg;

  return {
    ...(colors.fg && { fg: colors.fg }),
    ...(border && { border }),
    ...(line && { line }),
    ...(arrow && { arrow }),
    ...(colors.accent && { accent: colors.accent }),
    ...(colors.bg && { bg: colors.bg }),
    ...(corner && { corner }),
    ...(junction && { junction }),
  };
}
```

#### Rendering Flow
```javascript
async function main() {
  const opts = parseArgs();
  const { renderMermaidSVG, renderMermaidASCII, THEMES } = await loadBeautifulMermaid();
  const input = readFileSync(opts.input, 'utf8');

  // Validate theme exists
  if (opts.theme && !Object.prototype.hasOwnProperty.call(THEMES, opts.theme)) {
    throw new Error(`Unknown theme: ${opts.theme}. Run node scripts/themes.mjs to list themes.`);
  }

  const theme = opts.theme ? THEMES[opts.theme] : undefined;
  const customColors = {
    ...(opts.bg && { bg: opts.bg }),
    ...(opts.fg && { fg: opts.fg }),
    ...(opts.line && { line: opts.line }),
    ...(opts.accent && { accent: opts.accent }),
    ...(opts.border && { border: opts.border }),
  };

  if (opts.format === 'ascii') {
    const ascii = renderMermaidASCII(input, {
      useAscii: opts.useAscii,
      paddingX: opts.paddingX,
      paddingY: opts.paddingY,
      boxBorderPadding: opts.boxBorderPadding,
      colorMode: opts.colorMode,
      theme: toAsciiTheme(theme || customColors),
    });
    if (opts.output) {
      writeFileSync(opts.output, ascii);
    } else {
      console.log(ascii);
    }
  } else {
    const colors = theme || {
      bg: opts.bg ?? '#FFFFFF',
      fg: opts.fg ?? '#27272A',
      ...(opts.line && { line: opts.line }),
      ...(opts.accent && { accent: opts.accent }),
    };

    const svg = renderMermaidSVG(input, {
      ...colors,
      font: opts.font,
      transparent: opts.transparent,
      padding: opts.padding,
      nodeSpacing: opts.nodeSpacing,
      layerSpacing: opts.layerSpacing,
      componentSpacing: opts.componentSpacing,
      interactive: opts.interactive,
    });

    if (opts.format === 'png') {
      const outputPath = opts.output || (
        /\.mmd$/i.test(opts.input) ? opts.input.replace(/\.mmd$/i, '.png') : `${opts.input}.png`
      );
      writeFileSync(outputPath, renderSvgToPng(svg, opts.width));
      console.log(`PNG diagram saved to ${outputPath}`);
    } else if (opts.output) {
      writeFileSync(opts.output, svg);
    } else {
      console.log(svg);
    }
  }
}
```

---

### 2. batch.mjs — Parallel Batch Processing

**Purpose**: Render all `.mmd` files in a directory with parallel workers.

#### File Processing Function
```javascript
async function renderFile(file, inputDir, outputDir, opts, lib) {
  const { renderMermaidSVG, renderMermaidASCII, THEMES } = lib;
  const inputPath = join(inputDir, file);
  const ext = opts.format === 'svg' ? '.svg' : opts.format === 'png' ? '.png' : '.txt';
  const outputPath = join(outputDir, file.replace(/\.mmd$/, ext));
  const input = readFileSync(inputPath, 'utf8');
  const theme = opts.theme ? THEMES[opts.theme] : undefined;
  const customColors = {
    ...(opts.bg && { bg: opts.bg }),
    ...(opts.fg && { fg: opts.fg }),
    ...(opts.line && { line: opts.line }),
    ...(opts.accent && { accent: opts.accent }),
    ...(opts.border && { border: opts.border }),
  };
  const asciiColors = theme || (Object.keys(customColors).length > 0 ? customColors : undefined);

  if (opts.format === 'ascii') {
    const ascii = renderMermaidASCII(input, {
      useAscii: opts.useAscii,
      paddingX: opts.paddingX,
      paddingY: opts.paddingY,
      boxBorderPadding: opts.boxBorderPadding,
      colorMode: opts.colorMode,
      theme: toAsciiTheme(asciiColors),
    });
    writeFileSync(outputPath, ascii);
  } else {
    const colors = theme || {
      ...(opts.bg && { bg: opts.bg }),
      ...(opts.fg && { fg: opts.fg }),
      ...(opts.line && { line: opts.line }),
      ...(opts.accent && { accent: opts.accent }),
      ...(opts.muted && { muted: opts.muted }),
      ...(opts.surface && { surface: opts.surface }),
      ...(opts.border && { border: opts.border }),
    };

    const svg = renderMermaidSVG(input, {
      ...colors,
      font: opts.font,
      transparent: opts.transparent,
      padding: opts.padding,
      nodeSpacing: opts.nodeSpacing,
      layerSpacing: opts.layerSpacing,
      componentSpacing: opts.componentSpacing,
      interactive: opts.interactive,
    });
    writeFileSync(outputPath, opts.format === 'png' ? renderSvgToPng(svg, opts.width) : svg);
  }
}
```

#### Parallel Worker Pattern
```javascript
async function main() {
  const opts = parseArgs();
  const lib = await loadBeautifulMermaid();

  if (opts.theme && !Object.prototype.hasOwnProperty.call(lib.THEMES, opts.theme)) {
    throw new Error(`Unknown theme: ${opts.theme}. Run node scripts/themes.mjs to list themes.`);
  }

  mkdirSync(opts.outputDir, { recursive: true });

  const files = readdirSync(opts.inputDir).filter(f => f.endsWith('.mmd'));
  if (files.length === 0) {
    console.error(`No .mmd files found in ${opts.inputDir}`);
    process.exit(1);
  }

  console.log(`Found ${files.length} diagram(s) to render...`);

  let success = 0;
  const failed = [];

  // Process in batches of `workers` size
  for (let i = 0; i < files.length; i += opts.workers) {
    const batch = files.slice(i, i + opts.workers);
    const results = await Promise.allSettled(
      batch.map(file => renderFile(file, opts.inputDir, opts.outputDir, opts, lib))
    );

    results.forEach((result, idx) => {
      const file = batch[idx];
      if (result.status === 'fulfilled') {
        console.log(`✓ ${file}`);
        success++;
      } else {
        console.error(`✗ ${file}: ${result.reason?.message || result.reason}`);
        failed.push([file, result.reason?.message || String(result.reason)]);
      }
    });
  }

  console.log(`\n${success}/${files.length} diagrams rendered successfully`);

  if (failed.length > 0) {
    console.error(`\n${failed.length} failed:`);
    for (const [file, error] of failed) {
      console.error(`  - ${file}: ${error}`);
    }
    process.exit(1);
  }
}
```

---

## Core Implementations

### 3. png.mjs — SVG-to-PNG Conversion with CSS Resolution

**Purpose**: Convert SVG to PNG with full CSS variable and color-mix resolution, width scaling, and background handling.

#### Core Constants and Exports
```javascript
import { Resvg } from '@resvg/resvg-js';

export const DEFAULT_PNG_WIDTH = 800;
export const MIN_PNG_WIDTH = 100;
export const MAX_PNG_WIDTH = 10000;

const CUSTOM_PROPERTY = /(--[\w-]+)\s*:\s*([^;}]+);?/g;
const CSS_RULE = /([^{}]+)\{([^{}]*)\}/g;
const HEX_COLOR = /^#([\da-f]{3,4}|[\da-f]{6}|[\da-f]{8})$/i;

export function parsePngWidth(value = DEFAULT_PNG_WIDTH) {
  const text = String(value);
  if (!/^\d+$/.test(text)) {
    throw new Error(`PNG width must be an integer from ${MIN_PNG_WIDTH} to ${MAX_PNG_WIDTH}.`);
  }

  const width = Number(text);
  if (width < MIN_PNG_WIDTH || width > MAX_PNG_WIDTH) {
    throw new Error(`PNG width must be an integer from ${MIN_PNG_WIDTH} to ${MAX_PNG_WIDTH}.`);
  }

  return width;
}
```

#### SVG Preparation for PNG
```javascript
export function prepareSvgForPng(svg) {
  const rootTag = svg.match(/<svg\b[^>]*>/i)?.[0];
  if (!rootTag) {
    throw new Error('PNG conversion requires a valid SVG document.');
  }

  const stylesheets = [...svg.matchAll(/<style\b[^>]*>([\s\S]*?)<\/style>/gi)]
    .map(match => stripCssImports(match[1]));
  const rootDeclarations = new Map();
  let declarationOrder = 0;
  
  for (const css of stylesheets) {
    declarationOrder = collectRootCustomProperties(css, rootDeclarations, declarationOrder);
  }
  
  const rootVariables = new Map(
    [...rootDeclarations].map(([name, declaration]) => [name, declaration.value]),
  );
  const rootStyle = rootTag.match(/\sstyle=(['"])(.*?)\1/i)?.[2] ?? '';
  collectCustomProperties(rootStyle, rootVariables);
  rejectScopedInlineCustomProperties(svg);
  const resolveRootVariable = createVariableResolver(rootVariables);

  const prepared = mapCssContexts(
    svg,
    css => resolveCssValue(stripCssImports(css), resolveRootVariable).replace(CUSTOM_PROPERTY, ''),
    (_, value) => resolveCssValue(value, resolveRootVariable).replace(CUSTOM_PROPERTY, ''),
  );

  let unresolved;
  forEachCssContext(prepared, context => {
    unresolved ||= context.match(/(?:^|[^-\w])((?:var|color-mix)\s*\()/i)?.[1];
  });
  if (unresolved) {
    throw new Error(`PNG conversion cannot resolve CSS expression ${unresolved}`);
  }

  const backgroundValue = rootStyle.match(/(?:^|;)\s*background(?:-color)?\s*:\s*([^;]+)/i)?.[1];
  const background = backgroundValue
    ? resolveCssValue(backgroundValue, resolveRootVariable)
    : undefined;

  return { svg: prepared, background };
}
```

#### PNG Rendering
```javascript
export function renderSvgForPng(svg, width = DEFAULT_PNG_WIDTH) {
  const validWidth = parsePngWidth(width);
  const prepared = prepareSvgForPng(svg);
  const renderer = new Resvg(prepared.svg, {
    fitTo: { mode: 'width', value: validWidth },
    ...(prepared.background && { background: prepared.background }),
    font: { loadSystemFonts: true },
  });

  return renderer.render();
}

export function renderSvgToPng(svg, width = DEFAULT_PNG_WIDTH) {
  return Buffer.from(renderSvgForPng(svg, width).asPng());
}
```

#### CSS Variable Resolution with Circular Reference Detection
```javascript
function createVariableResolver(variables) {
  const resolved = new Map();

  return function resolveVariable(name, stack = []) {
    if (resolved.has(name)) return resolved.get(name);
    if (stack.includes(name)) {
      throw new Error(`Circular CSS variable reference: ${[...stack, name].join(' -> ')}`);
    }
    if (!variables.has(name)) {
      throw new Error(`PNG conversion cannot resolve CSS variable ${name}. Use concrete color values.`);
    }

    const value = resolveCssValue(variables.get(name), resolveVariable, [...stack, name]);
    resolved.set(name, value);
    return value;
  };
}
```

#### CSS Color Mixing (color-mix Support)
```javascript
function mixCssColors(expression) {
  const parts = splitTopLevel(expression, ',').map(part => part.trim());
  if (parts.length !== 3 || parts[0].toLowerCase() !== 'in srgb') {
    throw new Error(`Unsupported CSS color mix: color-mix(${expression})`);
  }

  const first = parseWeightedColor(parts[1]);
  const second = parseWeightedColor(parts[2]);
  if (first.weight === undefined && second.weight === undefined) {
    first.weight = 50;
    second.weight = 50;
  } else if (first.weight === undefined) {
    first.weight = 100 - second.weight;
  } else if (second.weight === undefined) {
    second.weight = 100 - first.weight;
  }

  if (first.weight < 0 || second.weight < 0) {
    throw new Error(`Invalid CSS color mix: color-mix(${expression})`);
  }

  const total = first.weight + second.weight;
  if (total <= 0) {
    throw new Error(`Invalid CSS color mix: color-mix(${expression})`);
  }

  const firstWeight = first.weight / total;
  const secondWeight = second.weight / total;
  const mixedAlpha = first.color.a * firstWeight + second.color.a * secondWeight;
  if (mixedAlpha === 0) return 'transparent';

  const channel = key => Math.round(
    (first.color[key] * first.color.a * firstWeight + second.color[key] * second.color.a * secondWeight) / mixedAlpha,
  );
  const alpha = mixedAlpha * Math.min(1, total / 100);
  const color = { r: channel('r'), g: channel('g'), b: channel('b'), a: alpha };
  return formatColor(color);
}
```

#### Hex Color Parsing (3-digit, 6-digit, 8-digit support)
```javascript
function parseColor(value) {
  if (value.toLowerCase() === 'transparent') {
    return { r: 0, g: 0, b: 0, a: 0 };
  }

  const match = value.match(HEX_COLOR);
  if (!match) {
    throw new Error(`PNG conversion supports hex colors, but received: ${value}`);
  }

  let hex = match[1];
  if (hex.length === 3 || hex.length === 4) {
    hex = [...hex].map(character => character.repeat(2)).join('');
  }
  if (hex.length === 6) hex += 'ff';

  return {
    r: Number.parseInt(hex.slice(0, 2), 16),
    g: Number.parseInt(hex.slice(2, 4), 16),
    b: Number.parseInt(hex.slice(4, 6), 16),
    a: Number.parseInt(hex.slice(6, 8), 16) / 255,
  };
}

function formatColor({ r, g, b, a }) {
  if (a >= 1) {
    return `#${[r, g, b].map(channel => channel.toString(16).padStart(2, '0')).join('')}`;
  }
  return `rgba(${r}, ${g}, ${b}, ${Number(a.toFixed(4))})`;
}
```

#### CSS Function Replacement (Parenthesis Depth Tracking)
```javascript
function replaceCssFunctions(source, functionName, replace) {
  const prefix = `${functionName.toLowerCase()}(`;
  const lowerSource = source.toLowerCase();
  let cursor = 0;
  let output = '';

  while (cursor < source.length) {
    let start = lowerSource.indexOf(prefix, cursor);
    while (start !== -1 && start > 0 && /[-_a-z0-9]/i.test(source[start - 1])) {
      start = lowerSource.indexOf(prefix, start + prefix.length);
    }
    if (start === -1) {
      output += source.slice(cursor);
      break;
    }

    output += source.slice(cursor, start);
    let depth = 1;
    let end = start + prefix.length;
    while (end < source.length && depth > 0) {
      if (source[end] === '(') depth++;
      if (source[end] === ')') depth--;
      end++;
    }

    if (depth !== 0) {
      throw new Error(`Unclosed CSS function ${functionName}().`);
    }

    const inner = source.slice(start + prefix.length, end - 1);
    output += replace(inner);
    cursor = end;
  }

  return output;
}
```

#### Top-Level Delimiter Splitting (Respects Parenthesis Nesting)
```javascript
function splitTopLevel(source, delimiter) {
  const parts = [];
  let depth = 0;
  let start = 0;

  for (let index = 0; index < source.length; index++) {
    if (source[index] === '(') depth++;
    if (source[index] === ')') depth--;
    if (source[index] === delimiter && depth === 0) {
      parts.push(source.slice(start, index));
      start = index + 1;
    }
  }

  parts.push(source.slice(start));
  return parts;
}
```

---

## Interesting Patterns

### 1. Dependency Auto-Installation

Both `render.mjs` and `batch.mjs` auto-install `beautiful-mermaid` if missing:

```javascript
async function loadBeautifulMermaid() {
  try {
    return await import('beautiful-mermaid');
  } catch {}

  console.error('[beautiful-mermaid] Dependency not found. Installing automatically...');
  try {
    execSync('npm install --no-fund --no-audit', {
      cwd: skillRoot,
      stdio: ['pipe', 'pipe', 'inherit'],
      timeout: 120000,
    });
    console.error('[beautiful-mermaid] Installed successfully.\n');
  } catch (e) {
    console.error(`[beautiful-mermaid] Auto-install failed: ${e.message}`);
    console.error(`Manual fix: cd ${skillRoot} && npm install`);
    process.exit(1);
  }

  try {
    const pkgPath = join(skillRoot, 'node_modules', 'beautiful-mermaid', 'dist', 'index.js');
    return await import(pkgPath);
  } catch (e) {
    console.error(`[beautiful-mermaid] Failed to load after install: ${e.message}`);
    process.exit(1);
  }
}
```

### 2. Promise.allSettled for Fault-Tolerant Batch Processing

The batch processor never crashes on individual file failures:

```javascript
for (let i = 0; i < files.length; i += opts.workers) {
  const batch = files.slice(i, i + opts.workers);
  const results = await Promise.allSettled(
    batch.map(file => renderFile(file, opts.inputDir, opts.outputDir, opts, lib))
  );

  results.forEach((result, idx) => {
    const file = batch[idx];
    if (result.status === 'fulfilled') {
      console.log(`✓ ${file}`);
      success++;
    } else {
      console.error(`✗ ${file}: ${result.reason?.message || result.reason}`);
      failed.push([file, result.reason?.message || String(result.reason)]);
    }
  });
}
```

### 3. Comprehensive Smoke Testing

The smoke test suite verifies all output formats, themes, and edge cases:

```javascript
for (const file of files) {
  const source = readFileSync(join(examplesDir, file), 'utf8');
  const svg = renderMermaidSVG(source, THEMES['tokyo-night']);
  const ascii = renderMermaidASCII(source, { colorMode: 'none' });
  const preparedSvg = prepareSvgForPng(svg).svg;
  const png = renderSvgToPng(svg, 320);

  assert.ok(svg.startsWith('<svg'), `${file} did not render valid SVG`);
  assert.ok(ascii.trim().length > 0, `${file} did not render ASCII output`);
  assert.doesNotMatch(preparedSvg, /(?:var|color-mix)\s*\(/, `${file} retained unsupported CSS`);
  assert.ok(png.subarray(0, 8).equals(pngSignature), `${file} did not render valid PNG`);
  assert.equal(png.readUInt32BE(16), 320, `${file} PNG width was not applied`);
}
```

### 4. Documentation Validation

The validator checks:
- All markdown links resolve to real files
- Theme gallery matches available themes
- SKILL.md is under 500 lines

```javascript
function collectMarkdownFiles(directory) {
  const files = [];
  for (const entry of readdirSync(directory)) {
    if (ignoredDirectories.has(entry)) continue;
    const path = join(directory, entry);
    if (statSync(path).isDirectory()) {
      files.push(...collectMarkdownFiles(path));
    } else if (entry.endsWith('.md')) {
      files.push(path);
    }
  }
  return files;
}

const markdownFiles = collectMarkdownFiles(skillRoot);
for (const file of markdownFiles) {
  const markdown = readFileSync(file, 'utf8');
  for (const target of localTargets(markdown)) {
    const path = resolve(dirname(file), target);
    assert.ok(existsSync(path), `${file} links to missing local target: ${target}`);
  }
}
```

### 5. Theme Gallery Generation Script

Programmatically renders all 15 themes:

```javascript
for (const theme of themes) {
  const output = join(outputDir, `${theme}.svg`);
  execFileSync(process.execPath, [
    renderer,
    '--input', input,
    '--output', output,
    '--theme', theme,
    '--padding', '28',
  ], { stdio: 'inherit' });

  if (!readFileSync(output, 'utf8').startsWith('<svg')) {
    throw new Error(`Gallery render did not produce SVG: ${theme}`);
  }
}
```

---

## Key Design Insights

1. **No External Rendering**: PNG conversion happens entirely in Node.js via Resvg, avoiding the need for Chromium or a browser environment.

2. **CSS Variable Resolution**: The PNG converter parses and resolves all CSS custom properties (CSS variables) and `color-mix()` functions before rasterization, since Resvg doesn't support dynamic CSS resolution.

3. **Circular Reference Detection**: The variable resolver tracks the resolution stack to prevent infinite loops in CSS variable definitions.

4. **Graceful Degradation**: Fallback color chains (`fg → border → line → accent`) ensure that partial theme definitions still render correctly.

5. **Modular Batch Processing**: The batch renderer reuses the core rendering logic and applies parallel processing with configurable worker count and fault tolerance.

6. **Assertion-Heavy Testing**: The smoke test uses strict assertions to validate SVG structure, PNG signature bytes, PNG width metadata, ASCII output, and CSS resolution completeness.

7. **Protected Themes**: The code explicitly rejects inherited object properties (e.g., `toString`, `constructor`) to prevent template injection via theme names.

---

## Usage Summary

| Command | Purpose |
|---------|---------|
| `render.mjs --input dia.mmd --output out.svg --theme tokyo-night` | Single SVG render |
| `render.mjs --input dia.mmd --output out.png --format png --width 640` | PNG render at width |
| `render.mjs --input dia.mmd --format ascii --color-mode truecolor` | ASCII with ANSI colors |
| `batch.mjs --input-dir ./in --output-dir ./out --theme github-dark` | Batch SVG render |
| `batch.mjs --input-dir ./in --output-dir ./out --format png --workers 8` | Parallel PNG batch |
| `themes.mjs` | List all 15 built-in themes |
| `npm test` | Run smoke tests |
| `npm run validate` | Validate docs and config |
