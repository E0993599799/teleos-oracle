# rea: Architecture

**HEAD commit:** `df3d96da801976fdbe37a726c2f4f84af8ffbf90` (package `rea-agents` 6.4.0, per `package.json` at HEAD)

**What it is:** A TypeScript/Node.js CLI and stdio MCP server that lets terminal or agent clients reverse-engineer binaries and applications by driving external analysis engines (Hopper, Ghidra, IDA) and static readers, returning Evidence-backed results.

All paths below are at HEAD (read via `git show HEAD:<path>`). The working tree has staged deletions under `.agents/`; those were not used except where noted.

---

## 1. Directory structure

| Path | Role | Evidence |
|---|---|---|
| `src/` | All TypeScript runtime code (about 1,750 files tracked under `src/`). | `git ls-tree -r HEAD src` |
| `src/application/` | Shared workflows used by both CLI and MCP (about 310 files). Holds ports, session/registry logic, investigation records, and per-domain subfolders. | `src/application/BinarySession*`, `src/application/AnalysisProvider.ts` |
| `src/domain/` | Pure, side-effect-free modules: evidence, comparisons, schemas, reconstruction ledgers. Largest tree (about 540 files). | `src/domain/evidence.ts`, `src/domain/analysisErrorBase.ts` |
| `src/contracts/` | Caller-visible tool input/output schemas (MCP and CLI). | `src/contracts/toolContracts.ts`, `src/contracts/officialToolContracts.ts` |
| `src/composition/` | Production wiring: factories that build providers and sessions for CLI and MCP. | `src/composition/binary.ts` |
| `src/server/` | MCP adapter: `createServer`, per-domain `register*Tools.ts`, result delivery. | `src/server/createServer.ts` |
| `src/cli/` and `src/cli*.ts` | One-shot CLI adapter built on `incur`. | `src/cli.ts`, `src/cli/*Commands.ts` |
| `src/main.ts`, `src/main/` | Long-lived MCP stdio process: startup, transport, shutdown. | `src/main.ts`, `src/main/transport.ts` |
| `src/config/` | Zod-validated environment parsing. | `src/config/parseConfig.ts` |
| `src/process/` | Owned process groups, deadlines, bounded file reads, cleanup. | `src/process/snapshotEnvironment.ts` |
| Provider folders | `src/hopper/`, `src/ghidra/`, `src/ida/`, `src/wasm/`, `src/evm/`, `src/native/`, `src/browser/`, `src/inspector/`, `src/javascript/`, `src/dotnet/`, `src/firmware/`, `src/android/`, `src/apktool/`, `src/adb/`, `src/flutter/`, `src/go/`, `src/jeb/`, `src/pcap/`, `src/sqlite/`, `src/windows/`, `src/reference/`, `src/artifacts/` | Each is one engine or format adapter; see the mermaid diagram below. |
| `src/evaluation/` | Agent release evaluation (session transcript scoring). | `src/evaluation/` |
| `bridge/` | Scripts and code that run inside or alongside external engines (Python, Java, Swift). Shipped in the npm package. | `package.json` `files` array |
| `native/windows/` | Node-API addon source for Windows native controls (C++). | `native/windows/README.md`, `native/windows/src/addon.cc` |
| `scripts/` | Build, release, packaging, and `verify-*` scripts (about 325 files). `scripts/rea.mjs` is the executable. | `scripts/rea.mjs`, `package.json` `bin` |
| `docs/` | VitePress-style user and design docs, plus `docs/architecture.mermaid`. | `docs/architecture.mermaid`, `docs/cli.md`, `docs/mcp-contracts.md` |
| `experiments/` | Measurement studies, not runtime code. Only `experiments/analysis-efficiency/` exists (README, Python and `.mjs` measurement scripts, `corpus.json`, markdown findings). | `experiments/analysis-efficiency/README.md` |
| `tests/` | Vitest suite split into projects (`acceptance`, `boundary`, `composition`, `conformance`, `evaluation`, `fixtures`, `process-global`, `support`). | `vitest.config.ts`, `tests/` |
| `third_party/` | Vendored or pinned upstream components (binwalk, evmole, ghidra-nativeaot, jadx-headless-mcp, pwndbg, pwntools, unblob, wabt, wakaru, web-network-captures) with READMEs and licenses. | `third_party/README.md` |
| `website/` | Separate site content (Python scripts, templates, Cloudflare `wrangler.toml`). Not part of the runtime. | `website/README.md` |
| `skills/` | Listed in `package.json` `files`, but **not present in the HEAD tree**. Generated from `.agents/skills/reverse-engineer-anything` by `scripts/generate-skill-metadata.mjs`. | `scripts/generate-skill-metadata.mjs` lines 13-14 |

---

## 2. Entry points

| Entry | File | What it does |
|---|---|---|
| Executable (`rea`, `rea-agents`) | `scripts/rea.mjs` | Dispatcher. `rea mcp` or `rea --mcp` routes to `dist/mcp/main.js`. Other commands route to `dist/cli-runtime/cli.js`. Prints a rebuild hint if `dist/` is missing. |
| MCP stdio server | `src/main.ts` (`run`) | Parses config, creates a `BinarySession`, opens an initial target, starts the stdio transport. Shutdown on SIGINT, SIGTERM, or stdin EOF. |
| One-shot CLI | `src/cli.ts` (`createCli`) | Builds the `incur` CLI and registers command groups from `src/cli/*Commands.ts`. Does not start an engine at import time; each analysis command opens and closes its own session. |
| Production wiring | `src/composition/binary.ts` (`createBinarySession`) | The "sole production wiring point" for both adapters. Instantiates `HopperProvider`, `GhidraProvider`, `IdaProvider`, and lazy auxiliary providers. |
| Direct analysis | `src/composition/directAnalysis.ts` | Binds one-shot CLI commands to a caller-selected environment. |
| Build runtime bundler | `scripts/bundle-runtime.mjs` | Rolldown-based bundling of `dist/` with external dependencies and lazy dynamic imports. |

---

## 3. Core abstractions and relationships

Layering is stated in `docs/architecture.mermaid`; the code confirms the central types below.

- **Adapters (outermost).** `src/server/` (MCP) and `src/cli/` (CLI) translate requests into calls on shared application code. Both must use the same composition (`src/composition/binary.ts`), so provider selection, profiles, lifecycle, and Evidence semantics match.
- **`BinarySession` (`src/application/binary/BinarySession.ts`).** Owns one immutable binding per target and routes operations to providers. Used by `src/main.ts` for the process lifetime and by one-shot commands via `src/composition/directAnalysis.ts`.
- **`AnalysisProviderRegistry` (`src/application/binary/AnalysisProviderRegistry.ts`).** Holds sorted candidate providers and selects deterministically with no fallback. Constructed in `src/composition/binary.ts` with `[hopper, ghidra, ida]` and `config.analysisProvider`.
- **`AnalysisProvider` interface (`src/application/AnalysisProvider.ts`).** Declares closed operation names (`AnalysisOperation`, built from the contract tool-name unions) and returns an `AnalysisExecution` carrying `result`, `rawResult`, `provider` identity, `limitations`, optional `relationshipCoverage`, `locations`, and `subject`.
- **Ports (`src/application/*Port.ts`).** Narrow interfaces the application layer depends on, implemented by providers. Examples: `BrowserObservationPort.ts`, `WebRuntimePort.ts`, `WebScriptArtifactPort.ts`, `WebNetworkCapturePort.ts`, `BrowserScenarioCapturePort.ts`.
- **Evidence and Unknowns (`src/domain/evidence.ts`, `src/application/investigation/`).** Results are Evidence records. Gaps are tracked as Unknowns. The investigation folder holds `InvestigationRecords` and its narrow record ports.
- **Domain (`src/domain/`).** Pure functions and Zod-backed schemas. No I/O. Used by everything else.
- **Contracts (`src/contracts/`).** Public schemas for tools. Adapters and `src/server/register*Tools.ts` consume them; the `AnalysisOperation` type is derived from them.
- **Configuration (`src/config/parseConfig.ts`).** Environment is snapshotted once (`src/process/snapshotEnvironment.ts`) and parsed with Zod.

Relationship sketch (from `docs/architecture.mermaid`):

```
scripts/rea.mjs -> src/cli.ts | src/main.ts
src/cli, src/server -> src/composition -> SessionProviderRouter / BinarySession
BinarySession -> AnalysisProviderRegistry (hopper | ghidra | ida)
                 + auxiliary providers (lazy)
src/application -> domain, contracts, process, browser, javascript recovery, ...
Provider adapters -> src/process (owned processes) -> src/windows (Windows boundary) -> native/windows addon
```

Engine bridges are launched by provider code, not by the bridges themselves:

- Hopper: `src/hopper/HopperProvider.ts` (line ~243) resolves `bridge/hopper_bridge.py`; the bridge runs inside Hopper and talks over a Unix socket (`src/hopper/HopperSocketConnection.ts`, `src/hopper/protocol.ts`).
- Ghidra: `src/ghidra/GhidraProviderClient.ts` (line ~588) resolves `bridge/ghidra/ReaGhidraBridge.java`, a headless script.
- Native (macOS): `src/native/LldbCallTracer.ts` uses `bridge/native/rea_lldb_tracer.py`; `src/native/NativeUiHelperRuntime.ts` uses `bridge/native/ReaNativeUI.swift`.
- Swift helper `bridge/process/ProcessRunTokenReader.swift` (purpose not traced in this pass).

---

## 4. Direct dependencies (`package.json` at HEAD)

**Runtime `dependencies` (34):**

- MCP and CLI: `@modelcontextprotocol/client` 2.3.1, `@modelcontextprotocol/server` 2.3.1, `incur` 0.6.1, `@clack/prompts` 1.7.0
- Validation and data: `zod` 4.4.3, `ajv` 8.20.0, `ajv-formats` 3.0.1, `yaml` 2.9.0, `smol-toml` 1.9.0, `jsonc-parser` 3.3.1, `lossless-json` 4.3.1, `canonicalize` 3.0.0, `cborg` 6.1.3, `diff` 9.0.0, `semver` 7.8.5, `tokenx` 1.3.0
- Parsing and formats: `@babel/parser` 8.0.4, `@babel/types` 8.0.4, `@jridgewell/trace-mapping` 0.3.31, `parse5` 8.0.1, `plist` 5.0.0, `@xmldom/xmldom` 0.9.12, `stream-chain` 4.2.6, `stream-json` 3.7.0, `evmole` 0.9.3, `har-schema` 2.0.0
- Archives and files: `@electron/asar` 4.2.0, `@zip.js/zip.js` 2.15.0, `ignore` 7.0.6, `write-file-atomic` 7.0.0
- Process and terminal: `@lydell/node-pty` 1.1.0, `cross-spawn` 7.0.6, `@xterm/headless` 6.0.0, `@xterm/addon-serialize` 0.14.0, `ws` 8.21.0
- Browser and VCS: `playwright-core` 1.58.2, `isomorphic-git` 1.38.7
- Logging: `pino` 10.4.0

**Optional:** `frida` 17.23.2 (`optionalDependencies`).

**Dev (`devDependencies`, 17):** `vitest` 5.0.3, `@vitest/coverage-v8`, `@fast-check/vitest`, `typescript` 7.0.2 (plus `typescript-termux` = typescript 5.9.3), `turbo` 2.11.7, `oxlint` 1.87.0, `oxfmt` 0.72.0, `knip` 6.39.0, `jscpd` 5.0.12, `rolldown` 1.2.12, `vitepress` 1.6.4, `husky` 9.1.7, `lint-staged` 16.4.0, `@types/node` 26.6.4.

The package has no `workspaces` field; the Turbo task graph is defined in `turbo.json`.

---

## 5. Build and runtime requirements

**Node and tooling**
- `package.json` `engines.node`: `^22.19.0 || ^24.11.0 || >=26.0.0`. `.nvmrc`: `24.18.0`. `packageManager`: `npm@11.16.0`.
- `package.json` `type`: `module`.
- Build: `npm run build` runs Turbo over `artifacts:skills`. `turbo.json` defines `compile` (outputs `dist/**`), `typecheck`, `lint`, and `metadata:check`. `tsconfig.json` emits to `dist/` (`rootDir: "."`); `tsconfig.build.json` covers `src/**/*.ts` minus tests and fixtures.
- Tests: `vitest run`. Projects are defined in `vitest.config.ts`. `test:python` runs `bridge/native/test_rea_lldb_tracer.py` and the experiments tests with `python3`.

**Runtime external prerequisites (not installed by npm)**
- **Hopper:** separate commercial application. Installer and launcher path (`HOPPER_LAUNCHER_PATH`) described in `docs/installation.md`.
- **Ghidra and a full JDK:** bring-your-own. Ghidra discovery in `src/ghidra/GhidraInstallation.ts`; `native/windows/README.md` also states Ghidra and JDK remain prerequisites on Windows.
- **IDA:** through an external `ida-pro-mcp` (`src/ida/`, `docs/ida-provider.md`).
- **Python 3:** for `bridge/hopper_bridge.py`, `bridge/pwntools/`, `bridge/pwndbg/`, and `bridge/mitmproxy/`.
- **Platform-specific:** Windows native addon is a Windows x64 Node-API 8 artifact at `native/windows/build/rea-windows-x64.node` (listed in package `files`; `build/` is git-ignored, so it is absent from the HEAD tree); Windows 10+ and fixed local NTFS volumes only. Build of that artifact needs Linux with MinGW-w64 (`native/windows/README.md`, `scripts/build-windows-native.mjs`).
- **Termux:** handled explicitly in `scripts/rea.mjs` (Playwright cache path); browser launch needs a caller-supplied Chromium.
- Not present: a Dockerfile or container build definition was not found at HEAD in the root listing.

**Packaging**
- `package.json` `files` includes `dist`, `skills`, `bridge/**` subsets, `scripts/rea.mjs`, `install.sh`, and `native/windows/build/*`. `prepack` and `prepare` scripts live in `scripts/prepack.mjs` and `scripts/prepare.mjs`.
- `scripts/bundle-runtime.mjs` bundles `dist/` with Rolldown, keeping dependencies external.

---

## 6. Not verified / out of scope

- Runtime behaviour of each engine bridge was not executed.
- `.agents/` skill sources are staged-deleted in the working tree; their content was not needed for this document.
