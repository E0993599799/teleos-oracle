# rea (rea-agents 6.5.0) — API and Integration Surface

Source: `morluto/rea`, HEAD `3b79af28e` (`chore(main): release rea-agents 6.5.0 (#1693)`).
Read-only analysis. All paths below are relative to the rea repository root.

Counting note: the tool count below is a static count of contract declarations in
`src/contracts/**` (non-test, non-example files). I attempted a runtime check by
compiling a scratch copy, but executing that compiled code was denied, so no
generated catalog (`.cache/mcp-tool-catalog.json`, absent from the checkout) was
produced. Treat the numbers as source-derived, not runtime-verified. Docs at an
older commit (`docs/client-configuration.md:109`) quote 172 tools for `04089d5be`;
HEAD has more.

## 1. Package surface

- `package.json`: name `rea-agents`, version `6.5.0`, `"type": "module"`,
  `mcpName: "io.github.morluto/rea"`.
- `bin`: `rea` and `rea-agents`, both -> `scripts/rea.mjs`. This is the only
  executable entry point.
- No `exports`, `main`, or `types` field. There is no supported programmatic
  JavaScript API; the public surface is the CLI and the MCP stdio server.
- `imports`: `#javascript-analysis-worker` -> `./dist/composition/javascriptAnalysisWorkerProcess.js`
  (internal, not a public subpath).
- `files` ships `dist`, `install.sh`, `skills`, the bridge sources (Python, Java,
  Swift listed individually), `scripts/rea.mjs` and helpers, third-party READMEs,
  and a Windows native `.node` artifact.
- `engines.node`: `^22.19.0 || ^24.11.0 || >=26.0.0`. SQLite inspection additionally
  needs Node 24.x >=24.15 or 26+ (`CHANGELOG.md`, 6.5.0 "SQLite snapshots").
- `scripts/rea.mjs` routes `mcp` / `--mcp` before importing Incur, so the stdio
  MCP runtime does not depend on the CLI framework.

`server.json` (MCP registry metadata): `name: io.github.morluto/rea`, `version: 6.5.0`,
one package `registryType: npm`, `identifier: rea-agents`, `runtimeHint: npx`,
stdio transport, `packageArguments: [{type: positional, value: "mcp"}]`.

`src/identity.ts:12` sets `cliBinary: "rea"`; `src/identity.ts:15` sets
`skillName: "reverse-engineer-anything"`.

## 2. MCP tool catalog

### 2.1 Contract model and registration

- Single source of truth per tool: `ToolContract` in `src/contracts/toolContractTypes.ts`.
  Fields: `name`, `title`, `description`, `kind`, `inputSchema` (zod), `outputSchema`
  (zod), `effects` (ToolEffects: `mutatesTarget`, `mutatesSession`, `writesFilesystem`,
  `launchesProcess`, `accessesNetwork`, `changesUiState`, `mayDiscardData`,
  `executesForeignCode`, `mutatesDevice`, `idempotent`), `annotations`
  (`readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`), `returnsTargetContent`
  (drives untrusted-content framing), and `examples`.
- MCP annotations are derived from effects (`src/contracts/toolEffects.ts`, `DerivedToolAnnotations`).
- `TOOL_KINDS` (`toolContractTypes.ts`) names 17 adapter families: official-proxy,
  enhanced, native-provider, artifact-provider, managed-provider, android-provider,
  apktool-provider, flutter-provider, jeb-provider, adb-provider, firmware-provider,
  browser-provider, electron-provider, runtime-provider, pcap-provider, application, session.
- Aggregation: `src/contracts/toolContracts.ts` concatenates ~40 family arrays into
  `TOOL_CONTRACTS` ("Complete ordered public inventory used by registration and verification").
- Registration: `src/server/createServer.ts` calls one `register*Tools` per family
  (e.g. `registerBinaryAnalysisTools` line 439, `registerAdbTools` 539, `registerSessionTools` 572).
  The generic path is `src/server/registerOfficialTools.ts:55`: `server.registerTool(contract.name,
  toolRegistrationOptions(contract), handler)`, where the handler goes through
  `withAdmittedAnalysis`. There are 114 `registerTool(` call sites under `src/server/*.ts`.
- Prompts: `src/contracts/promptContracts.ts`, registered by `src/server/registerPrompts.ts`
  via `server.registerPrompt`. Six prompts: `investigate_feature`, `compare_application_versions`,
  `verify_reconstruction`, `trace_crash`, `audit_residual_unknowns`, `prepare_bounded_process_capture`.

### 2.2 Naming and schema conventions

- Tool names are snake_case verbs over objects (`inspect_*`, `list_*`, `compare_*`,
  `trace_*`, `start_*`/`close_*`, `*_session_status`). Families carry a provider prefix
  where the provider is the object (`*_adb_*`, `*_jeb_*`, `*_frida_*`, `*_gdb_*`).
- Input schemas are `z.strictObject` (unknown keys rejected). Output schemas are wrapped
  with `evidenceResultOf(...)` for Evidence-producing tools (`src/contracts/toolOutputSchemaPrimitives.ts`).
- `compactInputSchema.ts` / `inputSchemaPresentation.ts` provide a compact advertised-schema
  profile (env `REA_MCP_INPUT_SCHEMA_PROFILE=compact`, per `docs/client-configuration.md`).

### 2.3 catalogIdentity.ts

`src/catalogIdentity.ts` computes a stable identity used for stale-process detection:

- `counts`: `cli_commands` (`CLI_COMMAND_NAMES.length`), `mcp_tools` (`TOOL_CONTRACTS` length),
  `mcp_prompts` (`PROMPT_CONTRACTS` length).
- `digests` (lazy, canonical JSON via `canonicalize`, SHA-256): `tools_sha256` (name, title,
  surface/kind, description, effects, `returns_target_content`, annotations, input and output
  JSON Schema), `prompts_sha256`, and `combined_sha256` (CLI names + tools + prompts).
- Includes compact-presentation budget when selected, so differently configured servers do not
  digest as aligned.
- `scripts/generate-mcp-tool-catalog.mjs` writes `.cache/mcp-tool-catalog.json` (run via
  `npm run mcp-catalog:generate`); `mcp-catalog:check` verifies it. Not present in this checkout.

### 2.4 Tool families (static counts, unique names, 207 total)

Counts are unique tool names declared per contract file; `compare_application_versions`
appears in both `applicationToolContracts.ts` and `promptContracts.ts` and is counted once
as a tool.

| Family (contract file)                                                 | Tools | Examples |
| ---------------------------------------------------------------------- | ----: | -------- |
| official (`officialToolContracts.ts`)                                  |    38 | `list_procedures`, `procedure_pseudo_code`, `xrefs`, `set_comment`, `read_function_instructions` |
| hopper memory (`hopperMemoryContracts.ts`, mapped into official)       |     3 | `search_bytes`, `read_bytes`, `address_to_file_offset` |
| enhanced (`enhancedToolContracts.ts`)                                  |    12 | `binary_overview`, `batch_decompile`, `get_call_graph`, `find_xrefs_to_name`, `trace_native_values` |
| function workflow (`functionWorkflowToolContracts.ts`)                 |     2 | function-level workflow tools |
| native (`native/nativeToolContracts.ts`)                               |     8 | `analyze_function`-adjacent native tools |
| binary diagnostics (`native/binaryDiagnosticsToolContracts.ts`)        |     3 | `inspect_binary_layout` family |
| artifact (`artifactToolContracts.ts`)                                  |     6 | `inspect_artifact`, `extract_artifact`, `inspect_keyed_archive`, `inspect_asset_catalog`, `decode_interface_builder` |
| session (`sessionToolContracts.ts`)                                    |    21 | `open_binary`, `close_binary`, `binary_session`, `get_evidence_bundle`, `export_evidence_bundle`, `import_evidence_bundle`, `list_unknowns`, `record_unknown`, `update_unknown`, `verify_unknown_resolution`, `compare_functions`, `build_call_path`, `correlate_static_and_runtime` |
| analysis view (`analysisViewToolContracts.ts`)                         |     1 | `inspect_analysis_view` |
| application (`applicationToolContracts.ts`)                            |    10 | `trace_application_feature`, `compare_source_to_bundle`, `project_apple_application_graph`, `build_reconstruction_obligation_ledger` |
| ADB (`adb/adbToolContracts.ts`)                                        |    24 | `list_adb_devices`, `pull_adb_package`, `start_adb_app`, `install_adb_package` |
| Android (`android/androidToolContracts.ts`)                            |     5 | APK package and class inspection |
| apktool (`apktool/`)                                                   |     2 | resource analysis |
| Flutter (`flutter/`)                                                   |     2 | AOT inspection |
| JEB (`jeb/`)                                                           |     4 | `open_jeb_project` family |
| firmware (`firmware/`)                                                 |     2 | `inspect_firmware_regions`, `extract_firmware` |
| managed (`managed/managedToolContracts.ts`)                            |     3 | `inspect_managed_artifact`, `inspect_managed_members` |
| managed workflow (`managed/managedWorkflowToolContracts.ts`)           |     4 | `project_managed_application_graph` family |
| Electron (`javascript/electronToolContracts.ts`)                       |     6 | `inspect_electron_fuses`, `list_electron_targets` |
| JS runtime observation (`javascript/javascriptRuntimeObservationToolContracts.ts`) | 2 | runtime observation |
| JS recovery (`javascript/javascriptRecoveryToolContracts.ts`)          |     1 | `analyze_javascript_application` family |
| browser (`browserToolContracts.ts`)                                    |     8 | `list_browser_targets`, `observe_web_session`, `discover_webmcp_tools`, `capture_web_screenshot` |
| browser scenario (`browserScenarioToolContracts.ts`)                   |     1 | `capture_browser_scenario` |
| web script (`webScriptToolContracts.ts`)                               |     3 | script export |
| web runtime (`webRuntimeToolContracts.ts`)                             |     2 | runtime capture |
| web network capture (`webNetworkCaptureToolContracts.ts`)              |     1 | `inspect_web_network_capture` |
| pcap (`pcap/pcapToolContracts.ts`)                                     |     2 | `inspect_pcap_capture`, `inspect_packet_fields` |
| signals (`signals/signalToolContracts.ts`)                             |     2 | `decode_signal_recording`, `inspect_signal_decoders` |
| captures (`captures/captureToolContracts.ts`)                          |     2 | process capture |
| SQLite (`sqlite/`)                                                     |     1 | `inspect_sqlite_database` |
| WASM (`wasm/wasmToolContracts.ts`)                                     |     1 | `inspect_wasm_artifact` |
| WASM comparison (`wasm/wasmComparisonContracts.ts`)                    |     1 | `compare_wasm_interfaces` |
| EVM (`evm/`)                                                           |     1 | `inspect_evm_interface` |
| Go (`go/`)                                                             |     1 | `inspect_go_binary` |
| Rust (`rust/`)                                                         |     1 | `inspect_rust_binary` |
| Cutter (`cutterToolContracts.ts`)                                      |     2 | `list_cutter_sessions` family |
| reverse engineering (`reverseEngineeringToolContracts.ts`)             |     2 | `analyze`/`decompile`-style entry tools |
| GDB (`gdbToolContracts.ts`)                                            |     4 | `start_gdb_session`, `gdb_session_status`, `close_gdb_session` |
| Rizin debug (`rizinDebugToolContracts.ts`)                             |     4 | `start_rizin_debug_session` family |
| Frida (`fridaToolContracts.ts`)                                        |     9 | `start_frida_session`, `resume_frida_session`, `frida_session_status`, `close_frida_session` |
| **Total tools**                                                        | **207** | |

Plus 6 MCP prompts (Section 2.1). The CLI-side count is in Section 3.

## 3. CLI surface

- Entry: `src/cli.ts` builds the program with `Cli.create(PRODUCT_IDENTITY.cliBinary, ...)`
  (line 88) using the `incur` library, then calls 38 `register*Commands(...)` functions
  (e.g. `src/cli/coreAnalysisCommands.ts`, `src/cli/sqliteCommands.ts`, `src/cli/setupCommands.ts`).
- Command names: `src/cliCommandNames.ts`, `CLI_COMMANDS` object with 153 primary
  entries (`CLI_COMMAND_NAMES = Object.values(CLI_COMMANDS)`). Kebab-case, e.g.
  `inspect-analysis-view`, `inspect-evidence-bundle`, `inspect-packet-capture`, `doctor`, `setup`.
- Aliases: `CLI_COMMAND_ALIASES = ["compare-bundles"]`, and `CLI_COMMAND_TOOL_ALIASES`
  maps commands onto MCP tools (e.g. `analyze` and `inspect` -> `binary_overview`,
  `decompile` -> `procedure_pseudo_code`).
- `MCP_TOOLS_WITHOUT_DEDICATED_CLI`: 65 MCP operations have no dedicated CLI command or
  direct alias (e.g. `current_address`, `goto_address`, `set_bookmark`, `procedure_callers`).
  The CLI is therefore a subset of the MCP surface, not a mirror.
- Output: `src/cliOutput.ts`, `src/cli/jsonOutput.ts`, `src/cli/cliResultOutput.ts`
  (`--json` for machine output; the 6.5.0 changelog notes complete JSON streams without a
  single MCP frame).
- Setup/diagnostics commands: `setup`, `doctor`, `uninstall`, `update`, `capabilities`,
  `providers` (`CLI_COMMANDS`). Setup writes client registrations under a scoped plan with
  `--dry-run --json` (per the bundled skill).

## 4. Bridge protocols (engine-side IPC)

Each engine has an adapter in `src/<engine>/` and a sidecar under `bridge/`. Verified from source:

| Engine / feature | Bridge file(s) | Launch / transport (source-cited) |
| ---------------- | -------------- | --------------------------------- |
| Hopper           | `bridge/hopper_bridge.py` (50.9K) | `src/hopper/BridgeLauncher.ts` starts Hopper with an `exec(compile(...))` of the bridge, passing `REA_SOCKET`, `REA_TOKEN`, `REA_RUN_ID`, `REA_TARGET_PATH` in env (lines ~403-409) and `--owner-stdin` (line 463). Messages: `_write_message` emits one compact JSON object per line (`json.dumps(..., separators=(",", ":")) + "\n"`, flushed). |
| Ghidra           | `bridge/ghidra/*.java` (9 files: `ReaGhidraBridge`, `ReaGhidraExtensions`, `ReaGhidraPrepareRaw`, `ReaGhidraApplySeeds`, `ReaGhidraAnalysisOptions`, `ReaGhidraNoReturnFix`, `ReaGhidraMipsSoftFloat`, ...) | `src/ghidra/GhidraProviderClient.ts:591` loads `bridge/ghidra/ReaGhidraBridge.java`. Bridge writes JSON over a socket with a per-record byte budget (`ReaGhidraBridge.java:119`, 24 KiB after escaping). |
| Cutter           | `bridge/cutter/rea_bridge.py` | Experimental Cutter plugin. Loopback socket, per-process random token in a user-only descriptor file, `MAX_FRAME_BYTES = 16 MiB`, 20 s socket timeout (file header and constants). Documented as REA-owned IPC, not an upstream Cutter transport. |
| NativeAOT (.NET) | `bridge/nativeaot/*.java` (4 files) | Ghidra extension sources for managed-metadata recovery (`docs/ghidra-nativeaot.md`). |
| Android (JADX)   | `bridge/android/ReaJadxBridge.java` | JADX-backed package inspection (`docs/android-analysis.md`). |
| Native UI / LLDB | `bridge/native/ReaNativeUI.swift`, `NativeUIChildren.swift`, `rea_lldb_tracer.py` | Swift accessibility bridge and LLDB tracer; Python unit test `test_rea_lldb_tracer.py`. |
| Process run token | `bridge/process/ProcessRunTokenReader*.swift` | Swift helper reading run tokens. |
| mitmproxy        | `bridge/mitmproxy/capture.py` | Capture sidecar for web network captures. |
| pwntools / pwndbg | `bridge/pwntools/{layout,layout_impl,recorded_crash,recorded_crash_impl,decoder_runtime}.py`, `bridge/pwndbg/{launch,launch_impl,core_context}.py` | Offline ELF layout and recorded-crash helpers; `package.json` `files` lists them. |

Evidence from a bridge is treated as provider output: each provider's `raw_result` is
kept separate from `normalized_result` (see Section 5).

## 5. Evidence, Unknown and confidence contract

### 5.1 Evidence record (`src/domain/evidence.ts`, `evidenceBaseSchema`, strict)

| Field | Meaning |
| ----- | ------- |
| `evidence_id` | `ev`-prefixed digest; `authenticatedEvidenceSchema` recomputes the semantic id and rejects mismatches. |
| `subject` | Target identity (name, sha256 digest, format, architecture) or null. |
| `provider` | `{id, name, version}`. |
| `analysis_profile` | Concrete profile object or null; participates in identity. A provider-reporting profile must match the provider (`validateAnalysisProfileProvider`). |
| `predicate_type`, `operation` | What was asserted and by which operation. |
| `parameters` | JSON object of the request. |
| `raw_result` | Provider-native payload, or null. |
| `normalized_result` | Operation result (JSON). Callers read this, not `raw_result`. |
| `confidence` | `observed` \| `derived` \| `inferred` (3 values). |
| `authority` | `shipped-artifact` \| `controlled-replay` \| `historical-reference` \| `external-service` \| `analyst-inference` (5 values). |
| `environment` | `{id, platform, architecture, isolation}` with isolation `none` \| `process` \| `container` \| `virtual-machine`, or null. |
| `limitations` | string array of explicit caveats. |
| `relationship_coverage` | Declares whether provider-observed caller/callee/reference sets are complete (`complete` vs `unknown`). |
| `locations` | `address`, `address-range`, `artifact-path`, `file-offset`, `file-offset-range` (discriminated union). |
| `evidence_links` | Other `ev` ids this record derives from. |

Caller-facing contract (per `docs/mcp-contracts.md`): Evidence-producing tools return the full
canonical record in both text and `structuredContent`; `structuredContent.evidence_id` is its identity.
Failures return `isError: true` with JSON `{ "error": ... }` in text content and no `structuredContent`.
Oversized results are retained and can be paged (Section 6). Target-derived text is marked untrusted
(`returnsTargetContent`).

Coverage is explicit, not implied: missing coverage is `unknown` (`docs/mcp-contracts.md`), and
an empty facet is only "observed absent" when the producer declares it available
(`normalized_result.facet_availability`).

### 5.2 Unknowns (`src/domain/residualUnknown.ts`)

Session-level, durable questions that remain open. Tools: `record_unknown`, `update_unknown`,
`list_unknowns`, `verify_unknown_resolution`, `audit_residual_unknowns` (prompt).

- `status`: `open` | `investigating` | `blocked` | `contradicted` | `resolved`.
- `severity`: `low` | `medium` | `high` | `critical`.
- `required_authority`, `required_confidence` (same enums as Evidence), `required_environment`.
- `supporting_evidence_ids`, `contradicting_evidence_ids`, `mutation_evidence_ids` (min 1).
- `relationships`: `depends-on` | `related-to` | `contradicts` edges to other unknowns.
- `resolution`: discriminated on `disposition`: `verified` (requires `evidence_ids` min 1) |
  `withdrawn` | `out-of-scope`.
- Each revision carries a `revision_digest`.

### 5.3 Confidence semantics

`observed` = recorded from the target or provider run; `derived` = computed from observed
records; `inferred` = analyst or heuristic inference. Tool descriptions repeat this split
("Every conclusion must distinguish observations, inferences, and unknowns"; `reverse-engineer-anything/SKILL.md`).

## 6. Retained-analysis paging API (6.5.0)

6.5.0 changelog: "Retained analysis views: opt into compact ... summaries, then page retained
Evidence without rerunning analysis."

- Delivery switch: `src/contracts/analysisDetail.ts` `analysisDetailSchema` = `"complete"` (default)
  | `"summary"`. `summary` retains the complete Evidence in the session and returns a summary whose
  `normalized_result.parent_evidence_id` is then passed to `inspect_analysis_view`.
  `analysisDetailOutputSchemaOf` advertises the union of analysis and summary output.
- `inspect_analysis_view` (`src/contracts/analysisViewToolContracts.ts:15`, CLI `inspect-analysis-view`).
  Source is `{kind: "retained-evidence", evidence_id}` or `{kind: "inline", evidence}` (portable).
  Views (from the tool description):
  - `summary` (layout, JavaScript, inventory, WASM, Mach-O, Interface Builder, EVM, managed, Android, Dart AOT).
  - `inventory` with `collection` (nodes/occurrences/edges/integrity contradictions), `logical_paths`, `offset`, `limit`.
  - `capture` with `detail: preview | complete` (web capture records).
  - `pcap` pages: `endpoints`, `dns-queries`, `tls-sni`, `protocols`, `http-uris`, `unattributed-addresses`.
  - `qlog` pages: `traces`, `streams`, `loss-declarations`, `incomplete-records`, `contributions`, `ranges`, `final-sizes`.
  - `api-surface` (HAR requests grouped by method/origin/path template; templates are inferences).
  - `wasm` facets: `sections`, `imports`, `exports`, `candidates`, `glue`, `wat`, `headers`, `details`, `tool_profile`.
  - `macho` facets; `interface-builder` collections; `evm` facets `functions`, `bytecode_hex`, `stdout`, `stderr`.
  - `managed` and `managed-members` collections; `android` facet `manifest`; `dart-aot` collections.
  - `native` facets (`procedure`, `pseudocode`, `assembly`, `basic blocks`, `comments`, `callers/callees`,
    `references`, `unresolved calls`, `strings/names`, `native API`, `high-pcode`), with `offset`/`limit`
    (defaults 0 and 64; pseudocode counted in UTF-16 units).
  - Module pages address `node_id` for ambiguous paths.
- Paging is stable: offsets follow parent record order, preserve producer ordinals, never reopen the source.
  Page totals count retained facts; exhausting pages does not prove absence where
  `source_complete`/`source_exhaustive` is false.
- `get_evidence_bundle` (session tool) accepts `detail: "summary"` and filters (operation,
  target SHA-256, analysis-profile digest, canonical procedure address) to locate the Evidence id.
- `export_evidence_bundle` writes a complete session bundle to an absolute local path;
  `import_evidence_bundle` loads one; CLI `inspect-evidence-bundle` reads a bundle file with
  `detail: summary` and filters.
- Transport fallback: when an MCP frame is too large, the server returns
  `resource_constraint` with `details.resource: "transport"`; the documented recovery is
  `inspect_analysis_view` on the same-session Evidence, or export.

## 7. Extension points

### 7.1 Adding an MCP tool (from `docs/tool-design.md` and `.agents/skills/rea-tool-design/SKILL.md`)

Source-level steps implied by the repo layout (each verified by the file it names):

1. Decide the shape (`inspect`, `search`/`list`, `trace`, `compare`, `workflow`, `observe`/`capture`).
   `docs/tool-design.md` says extend an existing tool when intent and result contract match.
2. Add a contract under `src/contracts/` (family file, e.g. `applicationToolContracts.ts`) with
   strict zod input, output schema, effects, examples.
3. Add the contract array to `src/contracts/toolContracts.ts` (`TOOL_CONTRACTS`).
4. Register it in the matching `src/server/register*Tools.ts` (or `registerOfficialTools.ts`).
5. Add a CLI command in `src/cli/*Commands.ts` and its name in `src/cliCommandNames.ts`,
   or document why it is MCP-only (`MCP_TOOLS_WITHOUT_DEDICATED_CLI`).
6. Regenerate catalog and docs artifacts (`npm run mcp-catalog:generate`, `docs:generate`)
   so `catalogIdentity` digests and `docs/mcp-contracts.md` stay in sync.
7. Verify per `docs/testing.md`: affected consumer lanes (CLI and MCP), plus the real-provider lane
   when the change touches an engine.

`rea-tool-design/SKILL.md` is a short checklist. Its design output is: proposed boundary,
input/result shape, Evidence semantics, nearest alternative, verification approach. It defers
to `docs/tool-design.md`, `docs/testing.md`, and `CONTRIBUTING.md` (generated-file ownership).

### 7.2 Adding an engine or provider

- `CONTRIBUTING.md:158`: a new provider, or a capability involving target execution,
  injection, mutation, or protection recovery, needs an explicit maintainer scope decision
  before substantial implementation.
- Structure: provider adapters in `src/<engine>/` (e.g. `src/hopper/`, `src/ghidra/`,
  `src/cutter/`), composition in `src/composition/` (`directAnalysis.ts`, `auxiliaryAnalysisProviders.ts`,
  `optionalObservationProviders.ts`) which "construct fresh providers without starting engines"
  (`CONTRIBUTING.md:13-15`), and a sidecar under `bridge/` if the engine needs one.
- Provider identity is carried in Evidence (`provider.id/name/version`) and in
  `analysis_profile`; new providers must populate both.
- Tools stay provider-neutral; per-provider coverage is reported via `limitations`,
  `facet_availability`, and `relationship_coverage`.

### 7.3 Agent-skill extension

- Source: `.agents/skills/` has 4 skills: `reverse-engineer-anything`, `rea-tool-design`,
  `rea-changelog-update`, `rea-ci-tests-audit`.
- `reverse-engineer-anything/SKILL.md` (metadata `version: "42"`) is the only skill packaged for
  users. Its `references/` directory has 6 guides (`connection-and-recovery.md`,
  `native-and-artifacts.md`, `javascript-applications.md`, `android-applications.md`,
  `runtime-observation.md`, `evidence-workflows.md`).
- Its routing section maps target types to first tools (ASAR -> `analyze_javascript_application`,
  APK -> `inspect_android_package`, managed PE -> `inspect_managed_artifact`, firmware ->
  `inspect_firmware_regions`, PCAP -> `inspect_pcap_capture`, HAR/SAZ/qlog -> `inspect_web_network_capture`,
  SQLite -> `inspect_sqlite_database`, etc.). It documents the same paging rules as Section 6.
- Packaging: `scripts/generate-skill-metadata.mjs` copies `.agents/skills/reverse-engineer-anything`
  into `skills/reverse-engineer-anything` (owned output, rebuilt on each run; `--check` mode).
  `package.json` `files` includes `skills`. The `skills/` directory is **not present** in the checkout
  and is generated by `npm run build` / `artifacts:skills`.
- Installation: `setup` writes the skill to client-specific paths (fixture paths in
  `src/application/Setup.planning.test.ts` show `~/.claude/skills/reverse-engineer-anything` and
  `~/.agents/skills/reverse-engineer-anything`). The skill text says installing it does not
  register the MCP server by itself.

## 8. Not present / out of scope for this topic

- No programmatic library export (`exports` field absent).
- No HTTP/REST API; MCP over stdio (`scripts/rea.mjs mcp`, `npm start`) and the CLI are the only
  integration surfaces found in `package.json` and `server.json`.
- No hosted service, webhook, or database schema exposed to callers beyond the SQLite *inspection*
  tool, which reads caller-supplied files.
- Tool-count and per-family numbers are static; a runtime `tools/list` against HEAD was not executed.
