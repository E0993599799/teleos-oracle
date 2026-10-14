# rea (rea-agents 6.5.0) — Architecture

Source: `github.com/morluto/rea` at HEAD `3b79af28e` (read-only). All paths are relative to that repository root unless noted. Claims cite files; anything not found in the checkout is marked "not present".

## 1. Top-level layout and organization

Top level (`ls` at repo root): `.agents/`, `.github/`, `.husky/`, `bridge/`, `docs/`, `experiments/`, `licenses/`, `native/`, `scripts/`, `src/`, `tests/`, `third_party/`, `website/`, plus build/config files (`package.json`, `tsconfig*.json`, `vitest*.ts`, `turbo.json`, `stryker*.mjs`, `knip.json`, `.jscpd.json`, `release-please-config.json`).

- **`src/`** — TypeScript runtime, organized by layer and then by provider. Layer directories (see §3): `main/`, `cli/`, `composition/`, `server/`, `application/`, `contracts/`, `domain/`, `config/`, `process/`, `windows/`. Provider directories (one per engine or format family): `hopper/`, `ghidra/`, `ida/`, `cutter/`, `android/`, `frida/`, `gdb/`, `inspector/`, `browser/`, `javascript/`, `dotnet/`, `wasm/`, `evm/`, `firmware/`, `flutter/`, `go/`, `rust/`, `jeb/`, `adb/`, `apktool/`, `pcap/`, `signals/`, `sqlite/`, `objdump/`, `rizin/`, `native/`, `artifacts/`, `reference/`, `electron/`, `evaluation/`, `filesystem/`. Each provider has the same shape: a `*Provider.ts` implementing the analysis port, a launcher/transport/client, a `protocol.ts` or `*Values.ts`, and `*.test.ts` siblings. Example: `src/hopper/` contains `BridgeLauncher.ts`, `HopperSocketConnection.ts`, `HopperClient.ts`, `HopperProvider.ts`, `protocol.ts`.
- **`src/application/`** — shared workflows used by both CLI and MCP (e.g. `application/binary/BinarySession*.ts`, `application/investigation/`, `application/analysisView/`, `application/reverse/`). Host-install helpers for Hopper live at this level as `MacHopper.ts`, `LinuxHopper.ts`, `HopperDownload.ts` (not in a subdirectory).
- **`src/domain/`** — pure modules (e.g. `evidence.ts`, `residualUnknown.ts`, `reconstructionUnknowns.ts`, `analysisSnapshot.ts`, `binaryTarget.ts`, `canonicalDigest.ts`). The architecture diagram calls it "Pure side-effect-free modules" (`docs/architecture.mermaid`).
- **`bridge/`** — code that runs *inside* third-party tools (Python/Java/Swift scripts). Subdirs: `hopper` (single file `bridge/hopper_bridge.py`), `cutter/rea_bridge.py`, `ghidra/` (Java HeadlessScript and extensions), `android/ReaJadxBridge.java`, `nativeaot/` (Java), `native/` (Swift + LLDB Python), `process/` (Swift), `pwntools/`, `pwndbg/`, `mitmproxy/capture.py`.
- **`native/windows/`** — Node-API addon source (`native/windows/src/`, README). Built artifact `native/windows/build/rea-windows-x64.node` is listed in `package.json` `files`; the build output itself is not in the checkout.
- **`third_party/`** — vendored or pinned upstream material: `binwalk`, `evmole`, `ghidra-nativeaot` (Java sources under `src/main/java/nativeaot/`), `jadx-headless-mcp` (with `scripts/Launcher.java`), `pwndbg`, `pwntools`, `unblob`, `wabt`, `wakaru`, `web-network-captures`. Each has a README/LICENSE.
- **`scripts/`** — Node/Python tooling: `rea.mjs` (executable dispatcher), `bundle-runtime.mjs`, `build-*.mjs`, `generate-*.mjs` (catalogs, metadata, skill metadata), `ci/`, `lib/`, `fixtures/` (per-platform fixture inputs), and `verify/` plus ~100 `verify-*.mjs` scripts (package, real-engine, browser, client-config checks).
- **`tests/`** — Vitest suites: `acceptance/`, `boundary/`, `composition/`, `conformance/` (per-engine probe sources: `conformance/ghidra/*.java`, `conformance/native/*.swift`, `conformance/swift/*`), `evaluation/`, `fixtures/`, `process-global/`, `support/`.
- **`website/`** — VitePress/Python-generated site (`website/evidence`, `locales`, `templates`); `docs/` is the Markdown source (`docs/index.md`, `docs/mcp-contracts.md`, `docs/ida-provider.md`, etc.).
- `dist/` is not present in the checkout (it is produced by `npm run compile` / `build:cached`; `scripts/rea.mjs` expects `dist/mcp/main.js` and `dist/cli-runtime/cli.js`).

Organization philosophy (as stated in-tree): `docs/architecture.mermaid` defines the dependency direction (Entry Points → Composition → Adapters → Application → Provider Layers → Process Foundation; Contracts and Domain are leaves). Enforcement is by `scripts/verify-module-boundaries.mjs` and `npm run verify:architecture-guards` (referenced from `package.json` `check` script).

## 2. Entry points

| Entry | File | Role |
|---|---|---|
| Executable (`bin.rea`, `bin.rea-agents`) | `scripts/rea.mjs` | Dispatcher. Reads `package.json` version into `REA_PACKAGE_VERSION`. If argv is `mcp`/`--mcp` it imports `dist/mcp/main.js` and calls `runEntrypoint()`. If `mcp doctor` it imports `dist/cli-runtime/mcpDoctor.js`. Otherwise it loads `dist/cli-runtime/cli.js`. Missing build output prints a rebuild instruction and exits 1. |
| MCP server | `src/main.ts` (`run`, `runEntrypoint`) | Stdio MCP adapter. Calls `snapshotEnvironment` → `parseConfig` → `createBinarySession` → `openInitialTarget` → `startMcpTransport` → `createShutdown`. Uses `serveStdio` from `@modelcontextprotocol/server/stdio`. Helpers in `src/main/` (`startup.ts`, `transport.ts`, `shutdown.ts`, `types.ts`, `messages.ts`). |
| One-shot CLI | `src/cli.ts` (`createCli`) | Builds an `incur` `Cli` and registers command groups from `src/cli/*Commands.ts` (about 50 files: `coreAnalysisCommands`, `cutterCommands`, `fridaCommands`, `setupCommands`, `browserCommands`, …). Does not start Hopper at import time; each command acquires and closes its own session. |
| Server registration | `src/server/createServer.ts` | Calls `registerBinaryAnalysisTools`, `registerReverseEngineeringTools`, `registerFridaTools`, `registerCutterTools`, `registerGdbTools`, `registerAdbTools`, `registerAndroidTools`, `registerJebTools`, … (lines ~439–664). Per-family `src/server/register*Tools.ts` files translate MCP calls into application services. |
| Package metadata | `package.json` `bin`, `imports["#javascript-analysis-worker"]` → `dist/composition/javascriptAnalysisWorkerProcess.js` | The JS analysis worker is a separate process, addressed via a `#` import alias. |
| MCP registry | `server.json` | Declares `io.github.morluto/rea`, npm package `rea-agents@6.5.0`, `runtimeHint: npx`, stdio transport, positional argument `mcp`. |
| Installer | `install.sh` (listed in `package.json` `files`) | Shell installer; not read in depth for this doc. |

## 3. Layering and core abstractions

Layers as they appear in `docs/architecture.mermaid`:

1. **Composition root** — `src/composition/binary.ts`. `createBinarySession(config, logger, env)` is documented as "the sole production wiring point, so both adapters share identical provider selection, profile, lifecycle, and Evidence semantics." It constructs `HopperProvider`, `GhidraProvider`, `IdaProvider`, plugs them into `AnalysisProviderRegistry([hopper, ghidra, ida], config.analysisProvider)`, and adds `LazyAnalysisProvider` wrappers for `auxiliaryAnalysisProviderDeclarations(env)`, then calls `composeBinarySession`. Other factories: `createManagedBinarySession` (`ManagedStaticProvider` only, no native selection), `createArtifactBinarySession` (dynamic import of `ArtifactProvider`, no deep engines). `src/composition/directAnalysis.ts` and `reverseEngineering.ts` build the same kinds of ports for CLI commands.
2. **Application** — `src/application/binary/BinarySession.ts`, `AnalysisProviderRegistry`, `BinarySessionComposition`, `LazyAnalysisProvider`. Registry selection is "sorted deep candidates, deterministic selection, no fallback" (mermaid). Investigation records (`application/investigation/`) own `EvidenceLedger` and Unknown records through narrow ports.
3. **Domain** — the two core records:
   - **Evidence**: `src/domain/evidence.ts`. Schema (`evidenceBaseSchema`, ~lines 120–140) has `evidence_id` (prefixed digest `ev_…`), `subject`, `provider`, `analysis_profile`, `predicate_type`, `operation`, `parameters`, `raw_result`, `normalized_result`, `confidence` (`observed | derived | inferred`), `authority`, `environment`, `limitations[]`, `relationship_coverage`, `locations[]`, `evidence_links[]`. `createEvidence` is at line 340. Evidence IDs are content-derived; a refinement checks the ID matches the record (`evidence.ts` ~line 54–60).
   - **Unknowns**: `src/domain/residualUnknown.ts`. IDs are `unk_` + SHA-256 over question/domain/scope (`stableUnknownId`, top of file). `createResidualUnknown` at line 287; `recordUnknownInputSchema` / `updateUnknownInputSchema` (lines 247, 269) define the write path. `src/domain/reconstructionUnknowns.ts` selects the latest revision per `unknown_id` (`reconstructionUnknownHeads`, line 12). Unknowns are first-class, not an absence of Evidence: the 6.5.0 changelog repeatedly stresses "explicit unknown coverage" and "Preserve unknown rather than converting it to zero".
   - Relationship between them: Evidence carries `limitations` and `relationship_coverage`; Unknowns capture what Evidence cannot establish, with revisions tracked separately.
4. **Contracts** — `src/contracts/`. Caller-visible Zod schemas per tool family (`toolContracts.ts` aggregates ~30 `*_TOOL_CONTRACTS` arrays, e.g. `cutterToolContracts.ts`, `evm/evmToolContracts.ts`). `errorSchemas.ts` holds shared error schemas; `docs/error-contract.schema.json` is the generated published form. `docs/mcp-contracts.md` documents the surface.
5. **Adapters** — `src/cli/` and `src/server/`. Both wrap the same application services. Output shaping lives in `src/server/toolResult.ts` (response budget via `REA_MCP_MAX_RESPONSE_BYTES`) and `src/server/retainedSummaryDelivery.ts` (retained/paged results, new in 6.5.0).
6. **Process foundation** — `src/process/` (`ProcessOwnership.ts`, `OwnedCommand.ts`, `ProviderDeadline.ts`, `ExecFileBoundedOutput.ts`, `PrivateRuntimeRoot.ts`, `LinuxResourceLimits.ts`). Every spawned engine goes through `spawnOwnedProviderProcess`, which creates a process group owned by REA, with deadlines and bounded output.
7. **Config** — `src/config/environment.ts` (Zod-parsed env, §5), `parseConfig.ts`.

## 4. Engine bridges: start and authentication

**Hopper** (`src/hopper/`, `bridge/hopper_bridge.py`)
- Start: `BridgeLauncher.ts` writes a bootstrap file containing `REA_SOCKET = <unix socket path>`, `REA_TOKEN = <random token>`, `REA_RECONNECT_TIMEOUT_SECONDS` (lines ~403–408), then runs a Hopper helper with `--socket <path>` (line ~469) via `spawnOwnedProviderProcess`. The bootstrap is removed on every non-success path (lines ~289, ~358).
- Auth: `BridgeSession { socketPath, token }` (line ~42–45). The Python bridge creates the Unix socket, `chmod 0o600`, single-client (`hopper_bridge.py` ~1144–1149), and requires each request to be `{id, token, method, params}` with `hmac.compare_digest(request["token"], REA_TOKEN)` (~1044–1056).
- Platform launch: macOS installs a verified vendor DMG to `~/Applications` and then `open <app>` (`src/application/MacHopper.ts`, disclosure at ~line 49, `openApplication` at ~307). Linux installs a verified vendor package (`.deb`/`.rpm`/`.pkg.tar.xz`, `src/application/LinuxHopper.ts`, Hopper 6.4.2 demo at ~30–40). Windows Hopper is "not present".
- Timeouts: `REA_HOPPER_STARTUP_TIMEOUT_MS`.

**Ghidra** (`src/ghidra/`, `bridge/ghidra/`)
- Start: `GhidraLauncher.ts` runs `analyzeHeadless` (path comes from `GhidraInstallation.ts`, with `GHIDRA_INSTALL_DIR` and `JAVA_HOME` from env) with a `LaunchSupport.jar` on `-cp` (`GhidraLauncher.ts` ~113). Java args built in `GhidraJavaLaunch.ts`.
- Bridge: `bridge/ghidra/ReaGhidraBridge.java` is a packaged read-only HeadlessScript (header line 1–2: "REA's packaged, read-only Ghidra headless bridge"). Other Java files: `ReaGhidraBundleActivator.java` (compiles a no-op activator so Ghidra does not generate a second one), `ReaGhidraAnalysisOptions.java`, `ReaGhidraApplySeeds.java`, `ReaGhidraNoReturnFix.java`, `ReaGhidraMipsSoftFloat.java`, `ReaGhidraPrepareRaw.java`, `ReaGhidraPrepareCom.java`, `ReaGhidraExtensions.java`.
- Transport: `GhidraTransportKind = "unix-socket" | "authenticated-loopback-tcp"` (`src/ghidra/GhidraTransport.ts` line 12). Unix uses `bridge.sock`; Windows uses `bridge-endpoint.json` with loopback TCP (line ~31). Each import has a `GhidraLaunchSession.token` (`GhidraLauncher.ts` line ~55) passed to the socket connection (`GhidraSocketConnection.ts`).
- Env: `REA_GHIDRA_STARTUP_TIMEOUT_MS`, `REA_GHIDRA_LANGUAGE_ID`, `REA_GHIDRA_COMPILER_SPEC_ID`, `REA_GHIDRA_DISABLED_ANALYZERS`, `REA_GHIDRA_SEED_FILE`, `REA_GHIDRA_NATIVEAOT_JAR`.

**IDA** (`src/ida/`)
- Not started by REA in the default path. REA is a client of an external `ida-pro-mcp` (`docs/architecture.mermaid`: "External ida-pro-mcp — GUI proxy or database supervisor").
- Configured by `REA_IDA_MCP_CONFIG`, an absolute path to a JSON registration (`src/ida/IdaConfiguration.ts`, 64 KiB limit at line ~64). Schema (lines ~8–45): `mode: "attached" | "headless"` (default attached), optional `protocol: "native"` (requires attached), `timeoutMs` (default 300000), and one transport: `stdio` (`command`, `args`, `env`) or `http` (`url` restricted to `localhost`, `127.0.0.1` or `[::1]` with no credentials, plus `headers`).
- Client: `src/ida/IdaMcpConnection.ts` uses `StdioClientTransport` or `StreamableHTTPClientTransport` from the MCP SDK, with a 64 MiB stdio message cap (line ~68).
- Changelog 6.5.0 adds an "attached native IDA MCP" bridge with an optional native protocol.

**Cutter** (`src/cutter/`, `bridge/cutter/rea_bridge.py`)
- The bridge runs inside Cutter's Python plugin environment (`import cutter`, PySide6/PySide2 imports at lines 28–33). It binds to loopback and requires a per-process random token stored in a user-only descriptor file (header comment lines 4–5).
- Client: `CutterBridgeClient.ts` reads the descriptor (`descriptorSchema`: `host`, `port` 1–65535, `token` ≥20 chars, `session_id`, `cutter_version`), from the user home directory (`homedir()`, `join`). Requests are HMAC-signed (`createHmac`, `timingSafeEqual`); Windows descriptor access goes through `requireWindowsNativeAuthority`.

**Android / JADX** (`src/android/`, `bridge/android/ReaJadxBridge.java`)
- Pinned headless JADX: `JadxSession.ts` creates an MCP `Client` (name `rea-android-adapter`) over `JadxMcpTransport`, which spawns the JAR through `spawnOwnedProviderProcess` (stdio). The JAR is `REA_JADX_MCP_JAR` (`JadxConfiguration.ts` line ~367), validated as a Java archive that contains the bridge metadata classes (lines ~290–305). Java runtime: `JAVA_HOME` or `java` on PATH, with `REA_JADX_HEAP_MIB` and `REA_JADX_ACTIVE_PROCESSOR_COUNT`.
- `ReaJadxBridge.java` is the metadata boundary for "the unmodified jadx-headless-mcp 0.7.1 JAR" (line 24).
- ADB: `src/adb/` with `REA_ADB_PATH`; `REA_APKTOOL_COMMAND` for `src/apktool/`.

**Frida** (`src/frida/FridaInstrumentationManager.ts`)
- Uses the npm `frida` package as an *optional* dependency (`package.json` `optionalDependencies.frida` 17.23.2, `allowScripts` entry). It is loaded lazily with `await import("frida")` (line ~129). Local and remote target selection, caller-supplied scripts (6.5.0).

**GDB / Rizin / pwndbg / pwntools / WABT / Binwalk / Unblob / tshark / sigrok / Wakaru / capinfos**
- Spawned as owned processes: `src/gdb/GdbSessionManager.ts` (GDB/MI), `src/rizin/`, `src/native/pwndbg/` (uses `bridge/pwndbg/launch.py`), `src/native/pwntools/` (`bridge/pwntools/*.py`), `src/firmware/` (Binwalk/Unblob), `src/wasm/` (WABT via `REA_WABT_BIN_DIRECTORY`), `src/pcap/` (`REA_TSHARK_COMMAND`, `REA_TSHARK_PRLIMIT_COMMAND`), `src/signals/` (`sigrok-cli`, Linux-only, 6.5.0), `REA_CAPINFOS_COMMAND`, `REA_WAKARU_COMMAND`, `REA_BINWALK_COMMAND`, `REA_UNBLOB_COMMAND`, `REA_PWNDBG_GDB`, `REA_PWNDBG_VENV_PATH`, `REA_PWNTOOLS_PYTHON`.

**LLDB and native UI** (`src/native/`, `bridge/native/`)
- `bridge/native/rea_lldb_tracer.py` runs inside LLDB's embedded Python (module docstring line 1–10) for bounded native call observation; `src/native/LldbCallTracer.ts` launches it.

**Browser / Electron / Inspector** — `src/browser/` (CDP/Playwright via `playwright-core`, `REA_BROWSER_EXECUTABLE`), `src/electron/`, `src/inspector/` (passive V8 Inspector attach). Attachment is to a loopback endpoint; no launch unless requested (6.5.0 "passive browser attachment").

## 5. Configuration

`src/config/environment.ts` defines the Zod `environmentSchema`. Key variables include `REA_ANALYSIS_PROVIDER` (default `auto`), `REA_MCP_MAX_RESPONSE_BYTES`, `REA_MCP_INPUT_SCHEMA_PROFILE`, `REA_MCP_OUTPUT_SCHEMA_PROFILE`, `REA_IDA_MCP_CONFIG`, `GHIDRA_INSTALL_DIR`, `JAVA_HOME`, `REA_LOG_LEVEL`. A broader list of `REA_*` names is spread across `src/` (grep result includes `REA_ADB_PATH`, `REA_JEB_MCP_URL`, `REA_JADX_MCP_JAR`, `REA_HOPPER_STARTUP_TIMEOUT_MS`, `REA_GHIDRA_STARTUP_TIMEOUT_MS`, `REA_SWIFTC_COMPILE_TIMEOUT_MS`, and others). `src/config/providerStartupTimeout.ts` supplies the defaults.

## 6. Swift helpers and Java handlers

Swift (only in `bridge/` and `tests/`; no Swift in `src/`):
- `bridge/native/ReaNativeUI.swift` — macOS helper importing AppKit, ApplicationServices, ScreenCaptureKit, CryptoKit and Darwin. Its `Request` decodes `pid`, `window_id`, `executable`, `sha256`, `launch_time`: it captures/inspects a window of a verified target process. Consumed by `src/native/NativeUiHelperRuntime.ts` / `NativeUiObservation.ts`.
- `bridge/native/NativeUIChildren.swift` — Foundation-only helper returning bounded batches of child accessibility elements (`ChildBatch<Element>` with `values` and `complete`; `ChildCount`).
- `bridge/process/ProcessRunTokenReader.swift` and `ProcessRunTokenReaderMain.swift` — Darwin helper that reads per-process run tokens, code-signing flags (`csops`) and process identity, returning `RunTokenResponse` / `ProcessIdentityResponse` JSON. Consumed by `src/process/DarwinProcessRunTokenReader.ts`.
- Test-only Swift: `tests/conformance/native/*.swift` (archive, UI, dispatch fixtures), `tests/conformance/swift/*.swift`, `tests/fixtures/processRunTokenParserProbe.swift`, `tests/fixtures/processRunTokenSnapshotProbe.swift`, `tests/fixtures/native-macos/archive-xml-encoding/producer.swift`.

Java:
- `bridge/ghidra/*.java` — Ghidra HeadlessScript and extensions (described in §4).
- `bridge/android/ReaJadxBridge.java` — JADX metadata boundary.
- `bridge/nativeaot/*.java` (`NativeAotExtension.java`, `NativeAotDirectory.java`, `NativeAotMethodConventions.java`, `NativeAotTypeMetadata.java`) — "Optional headless facade over the unchanged upstream analysis primitives" for .NET NativeAOT under Ghidra.
- `third_party/ghidra-nativeaot/src/main/java/nativeaot/**` — vendored upstream Ghidra NativeAOT plugin (analyzer, object model, rehydration, refactoring, browser UI). Not REA-authored.
- `third_party/jadx-headless-mcp/scripts/Launcher.java` — vendored launcher.
- `tests/conformance/{ghidra,android,swift}/*.java` — probe programs for regression checks (e.g. `ReaNoReturnProbe.java`, `ReaSwitchEvidenceProbe.java`, `ReaSwiftDecoderRegressions.java`).

Python bridge scripts (for context, since they are the other "inside-the-tool" code): `bridge/hopper_bridge.py`, `bridge/cutter/rea_bridge.py`, `bridge/native/rea_lldb_tracer.py`, `bridge/mitmproxy/capture.py`, `bridge/pwntools/*.py`, `bridge/pwndbg/*.py`.

## 7. Direct dependencies (`package.json` `dependencies`)

Grouped by role (versions as pinned):
- MCP and CLI: `@modelcontextprotocol/client` 2.3.1, `@modelcontextprotocol/server` 2.3.1, `incur` 0.6.1, `@clack/prompts` 1.7.0, `zod` 4.4.3, `ajv` 8.20.0, `ajv-formats` 3.0.1.
- Parsing and formats: `@babel/parser` 8.0.4, `@babel/types` 8.0.4, `parse5` 8.0.1, `saxes` 6.0.0, `@xmldom/xmldom` 0.9.12, `yaml` 2.9.0, `smol-toml` 1.9.0, `jsonc-parser` 3.3.1, `plist` 5.0.0, `cborg` 6.1.3, `lossless-json` 4.3.1, `stream-json` 3.7.0, `stream-chain` 4.2.6, `@zip.js/zip.js` 2.15.0, `@electron/asar` 4.2.0, `har-schema` 2.0.0, `evmole` 0.9.3, `@jridgewell/trace-mapping` 0.3.31.
- Git and filesystem: `isomorphic-git` 1.38.7, `ignore` 7.0.6, `write-file-atomic` 7.0.0, `canonicalize` 3.0.0 (canonical JSON digests), `diff` 9.0.0, `semver` 7.8.5, `cross-spawn` 7.0.6.
- Terminal and browser: `@lydell/node-pty` 1.1.0, `@xterm/headless` 6.0.0, `@xterm/addon-serialize` 0.14.0, `playwright-core` 1.58.2, `ws` 8.21.0.
- Logging and text: `pino` 10.4.0, `tokenx` 1.3.0.
- Optional: `frida` 17.23.2 (`optionalDependencies`).

Dev toolchain (not runtime): `typescript` 7.0.2, `typescript-termux` (typescript 5.9.3 alias), `typescript6`, `vitest` 5.0.3, `@stryker-mutator/*` 10.0.0, `turbo` 2.11.7, `oxlint` 1.87.0, `oxfmt` 0.72.0, `knip` 6.39.0, `jscpd` 5.0.12, `rolldown` 1.2.12, `vitepress` 1.6.4, `husky` 9.1.7, `lint-staged` 16.4.0. `engines.node`: `^22.19.0 || ^24.11.0 || >=26.0.0`.

## 8. Changes since 6.4.0 (from `CHANGELOG.md`)

`CHANGELOG.md:3` is the 6.5.0 entry (dated 2026-10-13); `:116` is 6.4.0 (2026-10-11). The prior 6.4.0 learning document was not provided to this run, so this section lists only what the changelog says changed.

Architecture-relevant additions in 6.5.0:
- **JavaScript source selection** — exact application paths analyzed without expanding imports; unselected files keep identity and explicit unknown coverage (`CHANGELOG.md` ~line 19, PR #1944). Code-split recovery across multiple inputs.
- **Retained analysis views** — compact summaries are opt-in for inventory/WASM, managed metadata, Android manifest, Dart AOT, Mach-O and EVM; retained Evidence is paged without rerunning analysis. Implemented via `src/cli/analysisViewCommands.ts`, `src/server/registerAnalysisViewTool.ts`, `src/application/analysisView/`, `src/domain/analysisView/`, and `src/server/retainedSummaryDelivery.ts`.
- **New capture and format families**: packet captures (`src/pcap/`, `src/application/pcap/`, TShark bounded output), recorded signals (`src/signals/`, `src/application/signals/`, `sigrok-cli`, Linux-only), QUIC qlog (`src/captures/` with aioquic 1.5.0 JSON qlog 0.3), Fiddler SAZ (`src/captures/`), SQLite snapshots (`src/sqlite/`, requires Node 24.15+ or 26+ for `DatabaseSync.limits`), WASM inspection with BYO WABT 1.0.42 (`src/wasm/`), Rust cargo-auditable metadata (`src/rust/`), Electron fuses (`src/electron/`).
- **Engine changes**: attached native IDA MCP protocol alongside legacy/headless profiles (`src/ida/IdaConfiguration.ts` `protocol: "native"`); Frida explicit local/remote targeting and caller-supplied scripts (`src/frida/`); Ghidra raw NMOS 6502 and PSP ELF profiles, MIPS32 relocatable and MIPS16 profiles, RISC-V, PowerPC (`bridge/ghidra/ReaGhidraMipsSoftFloat.java`, `ReaGhidraPrepareRaw.java`); Ghidra byte search; Headless IDA procedure lookup.
- **Client setup**: new client registrations (Qoder, Trae, ZCode, DeepSeek, Kimi, Factory Droid, WorkBuddy) through `src/application/Setup*.ts` and `SupportedClients.ts`.
- **Breaking changes** (`CHANGELOG.md:99–115`): null `attached` values in JS/browser/Electron results; null source names in source maps; `--filter-output` emits `null` rather than `{}`; `get_call_graph.normalized_result` is now `{ graph, limitations }`; `binary_session` no longer repeats the tool catalog; MIPS targets with unresolved GNU ABI attributes are refused; saved Hopper databases on macOS are unavailable; ADB install results gain `replace_requested`.

Unchanged in 6.5.0 by the changelog: the composition-root wiring (`src/composition/binary.ts`), the provider registry with no fallback, and the Evidence/Unknown domain model are the same mechanisms described above; the changelog does not describe changes to them.

## 9. Not present / not verified

- `dist/` build output, `node_modules/`, and the compiled Windows addon are absent from the checkout.
- No Windows Hopper bridge (`src/hopper/` is macOS/Linux; Windows is covered by Ghidra and the Windows native addon).
- No Go, Rust or Swift source in `src/` beyond the provider modules listed above; Swift exists only under `bridge/` and `tests/`.
- Upstream IDA (`ida-pro-mcp`) and JADX sources are external; only REA's adapters are in this repo.
