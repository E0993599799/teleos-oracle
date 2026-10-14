# rea docs/ platform summaries (13 files, read in full)

Source: `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/morluto/rea/docs/`
Package under analysis: rea-agents 6.5.0, HEAD 3b79af28e (per task brief). Every claim below is cited from the named doc.

## docs/android-analysis.md

- Covers static APK analysis through an unmodified, commit-pinned JADX wrapper in `src/android/` (CLI and MCP share the workflow). Tools: `inspect_android_package`, `search_android_classes`, `inspect_android_class`, `inspect_android_method`, `trace_android_references`, plus `project_android_application_graph` (execution-free projection).
- Pinned engine: `jadx-headless-mcp 0.7.1`, SHA-256 `6e5eacf5...ff75`, set via `REA_JADX_MCP_JAR`. Requires a full JDK 17+ (with `jdk.compiler`); optional `JAVA_HOME`, `REA_JADX_HEAP_MIB`, `REA_JADX_ACTIVE_PROCESSOR_COUNT`.
- Linux needs a procps-compatible `ps` on `PATH`. Windows x64 uses a Job Object; Windows arm64 is outside the native boundary.
- Limits: 120 s whole-operation deadline, 90 s upstream decompile, 1 MiB manifest/method text budget, 8 MiB frame cap, 32 MiB stdout/stderr per operation; sessions expire after 60 s idle.
- Explicit caveats: "The current metadata bridge is verified on macOS arm64 with OpenJDK 21 ... the new bridge has not yet undergone real verification on Linux/JDK 25." Windows verification "uses JDK 21 and the pinned JADX 0.7.1 JAR."
- Stated non-coverage: no split APK/AAB handling, no signature validation (`not_performed`), no native-library analysis, no runtime capture; `.aab` is "a ZIP archive, not an APK."
- Other caveats: overload indices "are tied to the current artifact and engine, not stable across builds"; direct-invoke lists "do not establish complete call-site coverage"; reference relationships "are not observed runtime calls."
- Version note: the doc says the feature "is present on repository main and in npm 4.1.0" and points to a released-package boundary. This differs from the 6.5.0 package version in the brief (see Cross-doc notes).

## docs/adb-device-analysis.md

- Covers `adb`-driven device inspection, acquisition and lifecycle. REA never installs the SDK, emulator or platform tools; it uses `REA_ADB_PATH` or `PATH`.
- Read operations: `inspect_adb_client`, `list_adb_devices`, `inspect_adb_device` (getprop whitelist), `list_adb_packages`, `resolve_adb_packages`, `pull_adb_package` (complete split APK set, digested), `pull_adb_file`, `capture_adb_screen`, `collect_adb_bugreport`, and others.
- Mutating operations, explicitly flagged `mutatesTarget`: `push_adb_file` (existence check is "not atomic"), `install_adb_package`, `uninstall_adb_package`, `start_adb_app`, `start_adb_activity`, `stop_adb_app`.
- `install_adb_package` leaves `replaced` as `null`; the doc says the success response does not indicate fresh install versus replacement.
- Budgets: 10–20 s client/device calls, 20–60 s shell reads, 600 s transfers. Pull and capture outputs are additive and refuse existing destinations.
- Real verification: "verified with adb 34.0.5 on Linux against an Android 14 (API 34) x86_64 emulator" (224 packages, 287 services, 92 features, 1.3 MB screen capture, byte-exact two-APK split pull).
- Explicit non-coverage: UI interaction, monkey fuzzing, screen recording, and network `adb connect` "are not exposed yet."

## docs/apple-application-analysis.md

- Covers an execution-free Apple application inventory projection from authenticated `inventory_artifact` Evidence for IPA, macOS `.app`, ZIP or DMG. Tool: `project_apple_application_graph`.
- Framework hints match complete path segments only (`React.framework`, `ReactNative.framework`, `hermes.framework`, `Flutter.framework`, `UnityFramework.framework`). "A generic `App.framework` also does not identify Flutter by itself."
- Bundle layouts: `macos-deep`, `versioned-framework`, `shallow`. Roles are path conventions (`role_basis: "path-convention"`) such as `app-extension`, `xpc-service`, `framework`, `login-item`, `helper-application`.
- Also lists `privileged_helpers` (LaunchServices), `launchd_plists` (LaunchAgents/LaunchDaemons), and `helpers`. AppleDouble `._*` and `__MACOSX/` sidecars are excluded from roots and anatomy.
- Trace command: `rea trace-dylib-resolution MyApp.app --json`, which parses Mach-O/FAT load commands in TypeScript. Edge statuses: `resolved`, `conditional`, `unresolved`, `undetermined`. Findings are "derived, not observed."
- Explicit limits: the projection "does not parse plist or CMS semantics"; "Use `inspect_plist`" and "`inspect_signature`" are separate tools. Absolute system dylibs are `outside-target` and "REA does not check them against the host" on macOS 11+ (shared cache).
- Verification: `verify:macos-bundle` compares the parser to `otool -l` and `DYLD_PRINT_LIBRARIES`. The doc gives no explicit platform/version pin for this lane beyond that script name.
- DMG child inventory "needs the native macOS mounting adapter"; without it the projection is `partial`.

## docs/electron-fuses.md

- Covers `inspect_electron_fuses` / `inspect-electron-fuses`, a static read of the fuse wire in the Electron binary. No launch, no byte modification, no network.
- Version 1 fuse table: `RunAsNode`, `EnableCookieEncryption`, `EnableNodeOptionsEnvironmentVariable`, `EnableNodeCliInspectArguments`, `EnableEmbeddedAsarIntegrityValidation`, `OnlyLoadAppFromAsar`, `LoadBrowserProcessSpecificV8Snapshot`, `GrantFileProtocolExtraPrivileges`, `WasmTrapHandlers`. Other wire versions keep `name: null`.
- Byte mapping: `0x30` disabled, `0x31` enabled, `0x72` removed, anything else `unknown`. Removed means "not enabled."
- Caveat: "Electron compiles that validation only on macOS and Windows. On a Linux ELF executable the observed byte is preserved and the enforcement outcome is `unknown`."
- Caveat: "No sentinel means the fuse state is unknown. It does not mean the fuses are disabled." Multiple sentinels are all reported.
- Caveat: fuse bytes "do not prove that the application enables Inspector some other way, for example through `app.commandLine`."
- Limits: 1 GiB admission, 256 KiB search windows, max 32 sentinels per slice. No specific Electron version is pinned for this doc.

## docs/electron-observation.md

- Covers passive CDP observation of existing `file://` renderer pages (`list_electron_targets`, `inspect_electron_page`), plus an active scenario lane (`capture_electron_scenario`) that launches the app through the Playwright Electron API.
- Endpoint must be a literal-port loopback HTTP endpoint. Passive inspection runs no JavaScript, navigates nothing, and clicks nothing. ASAR-served pages are resolved to archive members.
- Script sources are excluded by default; `include_script_sources` opts in. Worker, service-worker and shared-worker targets are inventoried via passive metadata, not attached.
- Active lane: "This operation actively launches and interacts with the selected target. It is not a passive CDP observation." The owned process "keeps normal host filesystem and network privileges, so lifecycle ownership does not make it a sandbox."
- Preload caveat: the descriptor "is verified on Electron 44.7.0; runtimes that expose neither representation retain an unavailable path. A configured path or working IPC handler does not prove preload execution."
- Verification: `REA_ELECTRON_EXECUTABLE=... npm run verify:electron` with an operator-supplied Electron runtime. Cleanup failure "keeps the full lane failed."
- Relation to other docs: links to `javascript-artifact-reconstruction.md` and `javascript-runtime-reconciliation.md`, which are not among the 13 files read here.

## docs/flutter-analysis.md

- Covers pure-parsing Flutter build identification from an APK: Dart snapshot hash, per-ABI `libflutter` digests, GNU build-ids, labeled version strings. No engine, no external lookup. Tools: `identify_flutter_build`, `inspect_dart_aot`.
- Snapshot hash = bytes 20 after magic `f5 f5 dc dc`. Conflicting hashes are kept in `snapshot_hash_candidates` with `snapshot_hash: null`.
- Structural coverage "currently requires kind 3, the FullAOT value in the supported Dart 2.14 layout" (link pinned to `dart-lang/sdk/blob/2.14.0`). Other kind values are preserved as partial.
- Explicit boundary: "REA performs no hash-to-SDK lookup." The string pool is "a byte-pattern projection, not deserialized cluster semantics"; `class_like_tokens` include incidental matches.
- Verification record: Flutter Gallery 2.9.2 (112 MB, three ABIs), agreeing snapshot hash `65817c30a78bb44c3dc3771876b6010a`. Also "all 147 focused Flutter tests" on macOS Sonoma 14.8.9 x86-64 and Windows 11 build 26300.9457, Node 24.18.0.
- Caveat: "Other APKs need their own expectations file ... otherwise those facets are reported unverified."

## docs/harmony-analysis.md

- Covers static HarmonyOS package inventory (`.hap`, `.hsp`, App Pack `.app`) via the shared ZIP reader, projected by `project_harmony_application_graph`. Described as "the first increment of the HarmonyOS roadmap (#1431)."
- Packaging hint: Stage only from `module.json`, FA only from `config.json`, else `unknown`. Native bridge hypotheses are path-based between Ark bytecode and `libs/<abi>` libraries.
- `.har` is intentionally not classified by suffix; it is deferred because `.har` also names HTTP Archive JSON.
- Explicit scope limit: "Every claim is path-presence only." Manifest semantics, Ark bytecode contents, resource resolution, signing verification and native boundaries "stay in the projection's `limitations` array."
- Verification fixture: 1.0.1 HAP from `ohosvscode/harmony-next-pipeline`, SHA-256 pinned, downloaded into ignored `_reference/`; `npm run fixtures:harmony`, then `npm run verify:harmony`.
- Caveats: "The release artifact's compiler/SDK versions and reproducible source build have not been independently established." It "does not verify Ark decoding or signatures" and does not complete the pinned toolchain acceptance in #1431.
- The fixture has no META-INF entries, which "does not establish whether the package is signed."

## docs/managed-code-analysis.md

- Scope: .NET PE/CLI inspection without loading or executing code. Seven shipped tools: `inspect_managed_artifact`, `inspect_managed_members`, `inspect_managed_native_boundaries`, `compare_managed_members`, `verify_managed_native_boundaries`, `import_managed_reconstruction`, `project_managed_application_graph`. Each has a CLI twin (`rea inspect-managed-artifact`, etc.).
- Summary/view delivery: `detail: "summary"` retains complete Evidence and returns a linked `inspect_analysis_view` overview. Views page `references`, `resources`, `attributes` (artifact) and `types`, `methods`, `call_edges`, `user_strings`, etc. (members).
- Resource admission: 128 MiB input file limit; 64 MiB representation budget for metadata/CIL/projection. These are "inspection resource policies, not PE format limits."
- Native boundary: "Native-body bridge mapping and managed runtime execution are outside the current tool set." Metadata tokens "are not native addresses." Name/module matches "do not establish that a call executed."
- NativeAOT: the built-in parser covers "x64 PE/RTR 9.1 metadata" (no `ILSpy` or Ghidra version is pinned in the doc for the optional adapters). The optional Ghidra adapter needs a locally built `REA_GHIDRA_NATIVEAOT_JAR`. "Linking those types to native function addresses requires verified provider evidence."
- Decoded-CIL fingerprint: `il_sha256` covers raw CIL bytes; `normalized_il_sha256` is a decoded-tuple digest and "not a canonical semantic CIL identity." Worked vector `nop; ret` = `5e5fad77...0636`.
- Verification: `npm run verify:managed` runs a source-owned self-test; optional `REA_ILSPY_CMD_PATH` enables an ILSpy oracle; optional `REA_MANAGED_APP_MANIFEST_PATH` runs an operator-local osu! benchmark. "The benchmark may prove that REA reproduces selected facts for that exact local build. It cannot establish general support on its own."
- Runtime boundary: "Managed inspection does not execute assemblies or observe CLR internals." Metadata `ExtraData` (HeapSizes `0x40`) is skipped by a fixed four-byte word; this is "not specified by ECMA-335."
- Cross-build comparison matches methods by exact CIL/signature identity, then raw signature, then structural body shape; "Tokens are always remapped through observed structure."
- Platform: "Target platform is not host support." Pinned Windows oracle jobs "do not claim that the REA application itself supports Windows."

## docs/evm-bytecode.md

- Covers offline interface inference from one local EVM bytecode carrier (`inspect_evm_interface` / `inspect-evm-interface`), using bundled EVMole 0.9.3 in a worker. Input is raw or UTF-8 hex (`encoding` required).
- Pinned: "unchanged bundled EVMole 0.9.3." EF00 EOF containers return `unsupported_target`.
- Platform caveat: "Initial real verification covers flat legacy bytecode on Linux x64." The host must provide util-linux `prlimit` (`/usr/bin/prlimit` or `REA_EVM_PRLIMIT_COMMAND`); REA installs nothing.
- Metadata: `bytecode.metadata` interprets the CBOR trailer; "An unavailable trailer does not prove metadata absence or Solidity origin." Compiler version bytes are "metadata declarations, not verified compiler ... identity."
- Selectors, argument strings and mutability are "inferences"; "Empty candidates do not prove no callable interface." Function names are not looked up.
- Limits: 4 MiB input, 16 MiB reply, 256 MiB JS heap, 3 GiB virtual address space, 30 s deadline. The doc notes "Virtual address space differs from resident memory."
- Separate verifier: `REA_VERIFY_SOLC_MODULE=... npm run verify:solidity:metadata` (solc 0.8.30). "This lane does not establish the complete Linux EVM provider's CLI/MCP, resource-limit or cleanup behavior."

## docs/wasm-artifacts.md

- Covers offline WebAssembly core-module inspection (`inspect_wasm_artifact`) using caller-supplied WABT 1.0.42 binaries (`wasm-validate`, `wasm-objdump`, `wasm2wat`) via `REA_WABT_BIN_DIRECTORY`. Also `compare_wasm_interfaces` for import/export comparison.
- `open_binary` on a WASM v1 header returns `target_unavailable` (`wasm_requires_static_inspection`). A recognized header "is not validation of the complete module."
- Limits: 8 MiB input; 30 s per subprocess; 32 MiB combined output. Tool identity is recorded but "version and digest recording are not publisher authentication or an OS sandbox."
- Optional JS glue scanning (Babel AST) yields "literal associations, not proven data flow, runtime loading or URL-to-file identity."
- Platform caveat: "The real-tool profile has been exercised on macOS arm64; other hosts require their own verification." PR #2117 cost measurements are cited for warm "Linux x64 WABT 1.0.42" workflows, and "Agent token usage and truly cold workflows remain unmeasured."
- Interface comparison: "Static type equality does not establish runtime compatibility, ABI compatibility or linking success." Components are out of scope.

## docs/sqlite-databases.md

- Covers read-only inspection of a quiescent SQLite database plus WAL copy (`inspect_sqlite_database`). Schema scopes: `inventory` (default), `selected_table`, `database`. Optional row samples with `table`, `columns`, `row_limit` (default 20).
- Runtime requirement: "Node.js 24.x >=24.15 or 26+ with the native `DatabaseSync.limits` API." Other REA features keep Node 22.x, 24.x or 26+. Unsupported runtimes report `availability_code: "unsupported_version"`.
- Snapshot caveat: "A file copy of a live pair does not establish an atomic SQLite snapshot, even if no change is detected during inspection."
- Limits: database plus WAL up to 256 MiB; SQLite values, SQL and reply each 16 MiB; 256 MiB JS heap; 30 s deadline; at most two concurrent inspections.
- Explicit non-coverage: "Encrypted databases, database repair, arbitrary SQL, cross-database queries and live capture are outside this inspection's coverage." Views, virtual and shadow tables are not row-readable.
- Value encoding: integers are decimal strings for 64-bit safety; `"Infinity"`, `"-Infinity"`, `"-0"` tagged explicitly.
- Verification: `npm run test:sqlite`; CI matrix covers Node 22.x unavailable-runtime diagnostics, 24.15.0, latest 24.x and 26.x. "Compatibility checks detect regressions, but cannot guarantee ... future upstream change remains compatible."

## docs/website-module-trace.md

- Covers `trace_web_module_imports` / `rea trace-web-module-imports`: static and literal dynamic ES import/re-export resolution for one script from an exported capture, using `import.meta.resolve` in a caller-supplied Chromium (`REA_BROWSER_EXECUTABLE`).
- Inputs: manifest path, `script_index` (zero-based), optional `importer_url`, optional `import_map` (path and base URL). Import map presence "does not prove the map was installed in the captured page."
- Execution: "Every relationship reports execution as unknown." The application is "parsed as data and is never executed by this trace." No website asset is downloaded.
- Caveat: computed dynamic imports stay `computed-specifier` unknown; "Missing/lazy targets can resolve successfully with no captured candidate."
- Limits: manifest 32 MiB, source 16 MiB, import map 4 MiB; 20 s native resolution deadline. "There is no aggregate host memory-limit claim."
- Platform: "Real verification covers Linux x64; other hosts have not received this feature's real workflow verification."
- `REA_BROWSER_NO_SANDBOX=true` only passes the Chromium flag; "it does not enable an REA security boundary."

## docs/website-script-export.md

- Covers `export_web_scripts` / `rea export-web-scripts`: converts a saved `inspect_web_page` or `capture_browser_scenario` capture into a verified local script directory plus `manifest.json`, with `analysis_input` for `analyze_javascript_application`.
- Inputs: the capture must set `include_script_sources: true` (passive) or `capture.network.response_body: true` (scenario). Destination must not already exist; partial output is rolled back.
- Caveat for scenario sources: "Playwright may load the request URL again with credentials when CDP has no response body, so transaction and event references do not verify that exported bytes came from the original network transaction."
- Interpretation: "Export does not fetch URLs or execute JavaScript." Declared redaction "can change JavaScript syntax; passive captures do not report a byte-redaction flag, so that value remains unknown."
- Analyzer limits: "does not implement browser import maps, root-relative URL loading, remote imports, or runtime behavior"; source maps are "not fetched or reconstructed during export."
- Verification: `npm run verify:browser:scripts` (real browser, CLI and stdio MCP), needs `REA_BROWSER_EXECUTABLE`; `npm run verify:browser` also covers passive `inspect_web_page`.

## Cross-doc notes

- **Version pin mismatch (android-analysis.md):** the doc says the feature "is present on repository main and in npm 4.1.0." The task brief identifies the package as rea-agents 6.5.0. Either the doc is stale or the "npm 4.1.0" reference is a historical boundary; this was not resolved by reading package metadata, since scope was docs only.
- **Stale-looking pins:** `flutter-analysis.md` ties structural checks to the "Dart 2.14 layout" (link to `dart-lang/sdk/blob/2.14.0`) and says kind numbers "vary across Dart releases." `managed-code-analysis.md` names only "x64 PE/RTR 9.1" for NativeAOT and does not pin an ILSpy or Ghidra version.
- **JDK requirement vs. verification:** `android-analysis.md` says "full JDK 17 or newer," but the only recorded bridge verification is OpenJDK 21 on macOS arm64, and Linux/JDK 25 is explicitly unverified. The JDK 17 floor is therefore not backed by a recorded run in this doc.
- **Platform verification is uneven across docs:** `evm-bytecode.md` (Linux x64, requires `prlimit`), `wasm-artifacts.md` (real tools on macOS arm64; PR #2117 costs on Linux x64), `website-module-trace.md` (Linux x64 only), `android-analysis.md` (macOS arm64 for bridge; Windows x64 lane), `adb-device-analysis.md` (Linux with an Android 14 emulator). `flutter-analysis.md` lists macOS and Windows runs. No single platform matrix is stated across the 13 docs.
- **Node version floors differ by feature:** `sqlite-databases.md` requires Node 24.15+ or 26+ for its own operation, while the general runtime floor is 22.x, 24.x or 26+. This is consistent, but a caller on Node 22 gets only an "unsupported_version" result for SQLite.
- **Consistent across docs:** execution-free claims (static Android, Apple, Harmony, managed, WASM, SQLite, website export, EVM) do not contradict one another. The electron docs correctly separate passive CDP observation from the active Playwright scenario lane, which `electron-observation.md` states explicitly.
- **Unverified or unpinned items the docs themselves flag:** Harmony compiler/SDK versions and signing are not established; Linux JDK 25 for the Android bridge is not verified; Windows arm64 is out of scope for Android; Electron preload descriptor verified only on 44.7.0; WABT agent-token cost and cold workflows are unmeasured.
