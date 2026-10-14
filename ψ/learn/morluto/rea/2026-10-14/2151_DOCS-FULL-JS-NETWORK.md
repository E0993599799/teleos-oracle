# morluto/rea docs: JavaScript and network surfaces (full read)

Target: `morluto/rea`, package `rea-agents` 6.5.0, HEAD `3b79af28e`.
Source root: `royal-master-oracle/github.com/morluto/rea` (read-only). Every claim below is from a file under `docs/`. Quoted phrases are the doc's own caveats or version pins.

## docs/javascript-application-graph.md

- Covers the provider-neutral JavaScript Application Graph: a pure, side-effect-free domain model (node/edge/observation IDs, RFC 8785 canonical JSON, parse-time integrity checks). It is "not an extractor or a new CLI/MCP tool" and performs no filesystem or CDP I/O.
- Defines the stored record shape (`schema`, `graph_id`, `root_node_ids`, `nodes`, `edges`, `coverage`, `limitations`), the node and relation vocabularies, and the authority/epistemic-state model (`observed`, `inferred`, `unknown`, `unavailable`).
- Caveat: "`static-relationship-inference` can only produce `inferred` facts"; "exact confidence is reserved for observations"; static `loads`/`exposes`/`invokes`/`handles`/`imports` edges "remain static inferences".
- Breaking change noted: consumers reading `edge.properties.declared_url` "should follow `target_node_id` and select the observation by `declared_url_sha256` instead."
- Identity strategies table (`content-digest`, `source-map-original`, `canonical-path`, `artifact-local-key`, `structural-fingerprint`, `runtime-instance`, `observation-fingerprint`), each with a stated stability scope.
- Caveat: "Structural fingerprints ... never claim exact cross-version identity." Static TS/TSX imports are `compiler-dependent` when compiler options were not retained.
- No version pin. Public domain API: `createJavaScriptApplicationNode`, `createJavaScriptApplicationEdge`, `createJavaScriptApplicationGraph`, `parseJavaScriptApplicationGraph`, `serializeJavaScriptApplicationGraph`, `computeJavaScriptApplicationGraphSha256`.

## docs/javascript-application-workflows.md

- Covers cross-layer workflows over authenticated graph Evidence. MCP tools: `inspect_analysis_view`, `trace_application_feature`, `trace_javascript_semantics`, `compare_application_versions`, `compare_source_to_bundle`, `compare_javascript_export_shapes`. CLI equivalents use hyphens. The workflows do not read artifacts or execute code.
- Feature tracing: literal seeds only (node ID, route, string, API, IPC channel, module, native export). Native handoffs "never start or switch a provider implicitly".
- Semantic tracing: the doc lists extractor coverage and states "a missing relation is never reported as proven behavioral absence." It also says "`resolved` means the static target identity was unique ... it does not mean the path executed."
- Version comparison pairs entities only on a unique candidate per tier. Caveat: "Module ordinals, stable minified names, and fuzzy text similarity are not persistent identities."
- Version pin: "Versions before 4.1.0 accept full inline Evidence only; installing newer skill instructions does not change that schema." Semantic wire format changed to a required `evidence_contexts` table, described as "a breaking representation change."
- Export-shape comparison does not execute JavaScript. Its verifier is `npm run verify:application-workflows` (operator-supplied left/right paths). The doc closes with: "Static graph workflows do not execute recovered code ... Those observations do not prove behavior in an unobserved app version."

## docs/javascript-artifact-reconstruction.md

- Largest JS doc. Covers static, non-executing inspection of a local Electron/JavaScript directory or ASAR via `analyze_javascript_application` / `rea analyze-javascript-application` (and generic `rea analyze`). Returns graph, static Electron observations, statistics, limitations, coverage.
- Key options: `--integrity-policy fail|record-and-continue` (default `fail`); `--source-path` / `source_paths` for selective analysis; `detail: "summary"` for retained-Evidence paging; `--max-heap-mb` (default 1024 MiB V8 old-space) and `--analysis-timeout-ms` (default 300000 ms per source); `--max-semantic-nodes` (default 100000 total, 20000 per file, each 1 to 1000000). `rea_progress` JSON goes to stderr.
- Safety: "The reconstruction path never uses `eval`, `Function`, `vm.runInContext`, a DOM, bundle `push` handlers, or application bootstrap code." Native add-ons are "represented by metadata only."
- Caveats quoted from the doc: "Missing findings do not establish that an application has no Electron boundary usage." "Syntax does not prove runtime execution." Inline `<script>` bodies in local HTML are not analyzed (`parse-html-inline-scripts` unknown scope).
- Authority: an ".node" member name means "requested by JavaScript syntax"; "A resolved add-on path does not convert them into verified native exports."
- Fingerprint: `babel-ast-v2` now; "retained `babel-ast-v1` fingerprints cannot match these new fingerprints. Re-analyze both snapshots."
- Verification boundary, quoted: the source-owned fixtures "do not replace the later operator-supplied real-application benchmark." Verifiers: `npm run verify:javascript:digests`, `npm run verify:javascript:output`.
- Platform specifics: on Windows the analyzer's Job Object caps committed memory at `max_heap_mb` + 512 MiB (1536 MiB default). Bun ignores V8 heap flags and reports `worker_heap_limit_bytes` as null.
- Bounds are "internal resource safeguards ... not caller-selectable output budgets." Graph has no aggregate node/edge cap.

## docs/javascript-recovery.md

- Covers `recover_javascript_sources` / `recover-javascript-sources`, which derives readable modules from selected UTF-8 JS bundles via an external Wakaru engine. Recovered code is never executed. No network fetch.
- Version pins: REA accepts Wakaru "**^1.13.0** on Linux x64"; "The report parser is verified with Wakaru **1.14.0**." Other releases in the range are accepted with a limitation that the parser was not verified against them.
- Source pinned in `third_party/wakaru` at `8219bf5016a063d7fb215101a8c45d5959ec733f` (v1.14.0, Apache-2.0). Doc gives the release binary SHA-256 `664fa06782a61eda7ed15885134b52525fd565dd77607e642062ceb6cd927c38`.
- Requires `REA_WAKARU_COMMAND` (absolute path, platform binary not the npm shim) and util-linux `prlimit` (`REA_JAVASCRIPT_PRLIMIT_COMMAND`). REA installs neither.
- Limits: 1 GiB address-space ceiling, 120 s deadline, 64 MiB total input, up to 16 additional files, 128 MiB / 10000 staged entries.
- Caveats quoted: "Evidence confidence is `derived`." "Original variable names and arbitrary runtime equivalence remain unknown." "Other host platforms and Bun/Vue recovery are not claimed by this adapter." Engine identity: "`executed_source_revision: null`", because "a version string cannot prove which source produced a caller-supplied binary."

## docs/javascript-runtime-observation.md

- Covers passive attach to an already-running Node.js or Electron V8 Inspector target via `list_javascript_runtime_targets` / `observe_javascript_runtime` (and CLI equivalents). Loopback endpoint only.
- Protocol boundary: "The provider sends exactly two protocol commands: `Runtime.enable`, `Debugger.enable`." It never sends `Runtime.evaluate`, reads script source, or sends `Runtime.runIfWaitingForDebugger`. Use `--inspect`, not `--inspect-brk`.
- Caveat: Electron ignores `--inspect` when fuse `EnableNodeCliInspectArguments` is disabled or removed. The doc points to `inspect_electron_fuses` (outside this scope; not read).
- Role authority: `caller-declared-unverified`. "Inspector does not authenticate the operating-system PID or distinguish an Electron role."
- `attached` is nullable: Node `/json/list` omits attachment state, so REA reports `null`.
- Budgets: 8 MiB aggregate retained metadata, 16 MiB per CDP message. Output is deterministic (wall-clock and protocol script IDs excluded).
- Gaps quoted: "Absence from the observation window never proves that a script or behavior does not occur." The protocol does not expose require/import callers, EventEmitter, IPC, or unload events.
- Discovery of `file://` paths is best-effort: Windows and ambiguous underscore paths become `unresolved` with `reason: "unverifiable-file-location"`.

## docs/javascript-runtime-reconciliation.md

- Covers `reconcile_javascript_runtime` / `rea reconcile-javascript-runtime`, which joins a static JS Application Graph with browser, Electron, or V8 Inspector runtime Evidence. Performs no filesystem, browser, or Electron I/O. Accepts only semantically verified Evidence from specific operations.
- Input: exactly one `application` static layer, optional `cache`/`assets` layers, and `runtime_mappings` (`url-prefix` or `file-root`). Mappings "cannot add CDP origins, broaden Electron roots, read files, or authorize source-map access."
- Verifier: `npm run verify:javascript-runtime` with `--application`, `--cache`, `--runtime-evidence`, `--mapping`.
- Match rules: content+location, unique exact digest, unique mapped path (medium confidence), and ambiguous candidates with no `observed_as` edge. A path never overrides a digest disagreement.
- Load states: `loaded`, `resident-in-loaded-asset`, `not-observed-in-capture`, `unknown`. Caveat quoted: "`not-observed-in-capture` never means globally unloaded." None of the states proves execution, initialization order, or causality.
- Source-map declarations are "reported in `source_map_authority` but never used as primary runtime byte matches."
- Non-goals: does not replace `correlate_static_and_runtime`. The doc references `electron-observation.md` (not read here).

## docs/browser-observation.md

- Covers passive CDP attach to a user-owned Chrome-family browser: `list_browser_targets`, `inspect_web_page`, `analyze_web_bundle`, `observe_web_session`, `discover_webmcp_tools`, `compare_web_captures`, `capture_web_screenshot`, `compare_web_screenshots`. Explicitly "not general browser automation." REA never sends generic CDP commands or `Runtime.evaluate`.
- Launch with `--remote-debugging-port=9222 --user-data-dir=...`. Browser-socket endpoints (`ws://127.0.0.1:PORT/devtools/browser/ID`) are supported for browsers without HTTP discovery.
- Version-specific caveats (quoted or paraphrased from the doc):
  - Chrome 136+: "`--remote-debugging-port` is ignored for the default profile."
  - Chrome 144+: browser-socket-only mode via `chrome://inspect/#remote-debugging`.
  - Linux containers: DevTools port may not open until GLES/EGL/Mesa packages are installed. A locked keyring can stall Chrome; the doc suggests `--password-store=basic` for a dedicated profile.
- WebMCP caveat: "Chrome 154 specifically (one tested version)." The doc marks the trial/flag effect as inference: "that the token did not enroll the first-party document is consistent with this but is an inference, not a measured Chrome behavior." Also: "an unattributed zero-tool result should be read as registration state only after domain availability is confirmed."
- Data minimization: default excludes text, storage values, and script contents; each is opt-in. "Accessibility text, script content, query values ... may contain application secrets."
- Limits: 500 ms default window; 64 MiB per CDP message; 256 MiB screenshot-compare memory budget (an estimate, "not a promise a bound on total process memory"); source maps fetched only when selected, 30 s deadline and 64 MiB streamed budget.
- Caveat: "`prior_activity_available` is always `false`; absence from these arrays is not evidence that an event never occurred."
- Gaps: "This feature is not a browser sandbox or network containment mechanism."

## docs/browser-scenario-contract.md

- Covers `capture_browser_scenario` / `capture-browser-scenario INPUT_JSON`: a declarative, fixed-vocabulary browser scenario with launch or attach (loopback CDP) modes, explicit HTTP(S) targets, storage seeds, secret declarations, and per-artifact captures (`dom`, `accessibility`, `screenshot`, `url`, `history`, `storage`, `events`).
- Minimal example uses `browser.mode: "launch"` with `executable_path`. Launch always uses a provider-owned temp profile and deletes it.
- Caveats quoted: "A schema-valid scenario does not prove that the executable or target is available on the host." "An artifact you did not request is `not_requested`, which means REA did not look, not that the page had nothing to show." "Capture completeness also does not assert that the page's background work has finished."
- Service workers: default is blocked (`environment.service_workers`). "Navigation can run destination code before a newly discovered worker is rejected; that rejection does not roll back browser effects."
- Popups: "Playwright reports new popup Pages after their first navigation has committed ... the pinned API cannot recover every earlier frame, worker, WebSocket, or download event." Such a family gap disables equality eligibility.
- Network: `request_body`, `response_body`, `header_values` default `false`. Response bodies "may satisfy that API with a credentialed follow-up load of the request URL ... These bytes are not the compressed wire representation." Unfinished requests get `request-unfinished`.
- Comparison: steps align by exact unique `step_id`. Normalization commitments and SHA-256 digest are recorded.
- No version pin in this doc (the Playwright pin 1.58.2 appears in `web-network-captures.md`).

## docs/web-network-captures.md

- Largest web doc. Covers offline inspection of retained network-capture producer evidence through `inspect_web_network_capture` / `rea inspect-web-network-capture`. Formats: HAR 1.2, native mitmproxy (`.mitm`), Fiddler `.saz`, and aioquic qlog 0.3. Recorded URLs are never fetched and no listener starts.
- HAR pins: `har-schema@2.0.0` draft-06, `ajv@8.20.0`, `ajv-formats@3.0.1`, `jsonc-parser@3.3.1`, `lossless-json@4.3.1` (npm lockfile). "Only the HAR 1.2 profile is supported." Producer profiles observed: mitmproxy 12.2.3 `SaveHar` and Playwright 1.58.2 bracketed IPv6.
- Native mitmproxy: requires `REA_MITMDUMP_COMMAND` pointing to mitmdump 12.2.3 on Linux, source tag `v12.2.3` commit `6c09d56e4c29a92f5ad01b03199977584b8ea14f`. "other native tool versions return an explicit unsupported-profile diagnostic."
- SAZ caveats: "Their exporting product versions are not authenticated. An interactive export from a current Fiddler Everywhere installation and its live MCP server remain unverified. Support here is the bounded documented raw HTTP/XML SAZ layout, not every product/version profile." Corpora: FOREST Mattermost captures, Fiddler "Encodings.saz", and synthetic fixtures.
- qlog: "**aioquic 1.5.0, JSON qlog 0.3**" only. "JSON-SEQ, JSONL, columnar array events and other versions are unsupported." Clock assumed Unix-epoch milliseconds, which the doc says is verified against aioquic 1.5.0 source. "`recovery:packet_lost` does not prove actual network loss." Lab command: `npm run verify:web:qlog`. "The report ... contains no keys or captured credential values. It is a fixture-specific verification, not a general loss detector."
- Historical evidence "does not prove runtime attribution, execution or deployment authenticity." Mitmproxy messages are "upstream-assembled messages, not recovered wire fragments."
- Derived API surface view (`api-surface`): groups by method/origin/path template with `numeric`, `uuid`, `hex`, `iso-date` rules, marked `basis: "inferred"`. "The view makes no handler-identity, schema or causality claim."
- Budgets: 32 MiB input, 96 MiB decoder reply, 64-level nesting; HAR/SAZ/qlog run in a 192 MiB Node old-generation heap (fixed; not raisable via `NODE_OPTIONS`); mitmproxy has 768 MiB address-space, 30 s CPU, 30 s wall. On Bun/Windows the Job Object cap is 704 MiB.

## docs/web-runtime.md

- Covers attach-only V8 precise coverage and execution attribution: `observe_web_execution` / `rea observe-web-execution`, and `inspect_web_event_listeners` / `rea inspect-web-event-listeners` (CSS selector, first match in main document).
- Caveat quoted: "Starting precise coverage resets counters and prevents optimized execution until REA stops it. This changes timing/JIT behavior."
- Caveat quoted: "If `is_block_coverage` is false, the function-only ranges are observed and branch execution remains unknown."
- Verified platform: "Linux x64 / Chrome 153 / Node 24. Other browser engines and host workflows remain unverified." Verifier: `npm run verify:browser:runtime` (needs `REA_BROWSER_EXECUTABLE`).
- Listener inspection never invokes a listener or dispatches an event. Delegated ancestor listeners, descendants, closed shadow roots and framework registries are not enumerated.
- Limits: 64 MiB per protocol message; 8 MiB script/request metadata; 32 MiB retained source; 20 s per command and inspection; 5 s cleanup.
- Unverified: "Child frames, workers, service workers, WebAssembly, chronological execution order and framework-specific causal interpretation are outside this operation."

## docs/web-source-location.md

- Covers `trace_web_source_location` / `rea trace-web-source-location`: maps one generated position in a script retained by `export_web_scripts` through one caller-paired local source map. No browser, no URL fetch, no execution.
- Adapter: locked `@jridgewell/trace-mapping` **0.3.31**. Caveat: "This is a defined decoder profile, not a claim to implement every current source-map extension." External section URLs return an unsupported-profile error.
- Lines are one-based and columns zero-based UTF-16 (ECMA-426 GetOriginalPositions). "A point result does not establish coverage of a source range, execution or UI causality."
- Codec: one owned Node subprocess with 192 MiB old-generation heap, 8 MiB semi-space, 20 s deadline. Bun ignores these flags. Windows Job Object cap of 704 MiB.
- Limits: 4 MiB map, 32 MiB codec reply, 262144 decoded rows/segments, 64 nested section levels.
- Verification: optional `verify:browser:source-maps` (isolated esbuild **0.25.10** plus Chromium). Doc: "Linux x64 is the real workflow covered by the dedicated CI job; other host workflows remain unverified."
- Embedded `sourcesContent` hashes cover the decoded string's UTF-8 bytes "They do not identify an independently captured original file."

## docs/http3-capture-lab.md

- Optional Linux laboratory procedure for native mitmproxy HTTP/3 captures through the public CLI and MCP. `npm run verify:web:http3`, with `--inspect-existing` for re-inspection. "It changes no runtime contracts or adapters."
- Pinned guest and tools: Omarchy **4.0.4 build 440** qcow2 (SHA-256 `43412b896fe3d730e373a51a8acf99343d7c3e6dee78aa9f9bd7fca181127264`). mitmproxy **12.2.3** archive (SHA-256 `2e95286b…bdb5c5`). cURL **8.22.0** with OpenSSL 3.6.4, ngtcp2 1.25.0, nghttp3 1.18.0, nghttp2 1.70.0. Python **3.14.7**. Required guest ports 18443/19443.
- Pinned aioquic **1.2.0** for the negotiated-version check. Note this differs from the aioquic **1.5.0** used by the qlog doc (see Cross-doc notes).
- Caveat quoted: "Mitmproxy 12.2.3's `QUICv1` label alone does not prove negotiation: the fixture checks the negotiated `_quic._version` in pinned aioquic 1.2.0."
- Lock caveat: "The verifier has per-command deadlines, but no overall run deadline; a live stalled lock owner can therefore delay publication until it exits."
- Unverified: "Local/WireGuard, browsers, QUIC v2, migration, 0-RTT, mTLS, replay, sustained load and loss tolerance remain unverified by this profile. Passing it does not establish general HTTP/3 support in REA."
- Native capture only in "Linux reverse mode, QUIC v1 and these clients." Empty bodies, cancellations, resets, certificate failures, HAR, qlog are "separate increments".

## docs/packet-captures.md

- Covers the pcap/pcapng summary family: `inspect_pcap_client` (no file read), `inspect_pcap_capture` (tshark + capinfos). Addresses, DNS, SNI, protocol stacks, URI inventory. Does not fetch recorded targets.
- Platform rules: capture inspection requires Linux (util-linux `prlimit`) or Windows (owned Job Objects). "macOS capture inspection returns a capability gap." Client inspection works everywhere.
- Version pins: "Current follow-up verification uses Linux/Node 24.18.0 and Wireshark **4.0.17**." Earlier: "Linux 4.6.6, macOS/Windows 4.6.9" (in the original proposal).
- Caveat quoted: "Those reports do not verify the new final memory boundary. Actual Windows/Bun Wireshark execution is unverified here; macOS capture support needs a separate enforceable-bound decision."
- Interpretation caveats: "Recorded fields do not establish decrypted payloads, causality, process identity, absence of unrecorded traffic or current deployments." TLS SNI "is recorded handshake metadata, not process identity."
- Limits: 2 GiB disk budget for snapshot; 1 GiB address space; 64 MiB per file; 300 CPU seconds; 8 MiB TShark output; 64 KiB capinfos output; 300 s / 60 s / 20 s deadlines.
- Verifier: `npm run verify:pcap -- --pcap /absolute/saved-capture.pcapng`. Without `--pcap`, capture inspection is "reported as unverified."

## docs/pcap-analysis.md

- Covers `inspect_packet_capture` / `rea inspect-packet-capture`: selected fields, display filters, decode-as, two-pass reassembly, and paged output. Also `inspect_packet_fields` / `rea inspect-packet-fields` for protocol and field discovery. Does not acquire traffic or control devices.
- Requires TShark **4.x** "on Linux" plus `prlimit`. "Unsupported hosts, including macOS and Windows, are refused before inspection." (Compare with the packet-captures doc on Windows; see Cross-doc notes.)
- Caveat: "An empty result does not prove absence of traffic outside the selected recording, filter or read range." Dissector results "are observations, not independently verified device behavior."
- `packet_limit` caveat: "A limit of 1 can therefore yield zero matching packets even when later frames match." `frame.number <= 2000` in a filter still reads the whole capture.
- Limits: 32 MiB input; 30 s per command; 4 MiB combined stdout/stderr; 1 GiB address space, 64 MiB per file, 30 CPU s. Field selectors: 1024 fields, 1024 decode-as rules, 32 KiB argv.
- Discovery: `tshark -G fields` output up to 32 MiB; 8 MiB representation budget. TShark 4.6.9 full glossary measured at 22,303,197 bytes.
- Verification: "Other formats (including PCAPNG), USB, BLE ATT and actual physical capture are not established by these fixtures." The macOS check "does not establish the current bounded integration."

## docs/signal-recordings.md

- Covers `decode_signal_recording` / `rea decode-signal-recording`: runs caller-supplied **sigrok-cli 0.7.2** with libsigrokdecode against an existing recording and returns decoder annotations as producer text. `inspect_signal_decoders` lists the installed catalog.
- Linux only, with `prlimit` (`REA_SIGROK_PRLIMIT_COMMAND`). macOS and Windows are refused. No hardware or acquisition.
- Caveat quoted: "`1104-1938 uart-1: 52` is producer display text over a sample range, not a timestamp or an independently verified protocol fact." "Empty output does not establish absence of traffic."
- Limits: 32 MiB input, 30 s deadline, 4 MiB output, 1 GiB address space, 64 MiB per file, 30 CPU s. Discovery output is capped at 65,535 lines.
- Verification: the synthetic 9600-baud UART VCD fixture only. "Other formats, decoders and physical acquisition are not established by the UART fixture."
- Caveat: "Caller-supplied tools and their libraries/decoder modules are trusted, and hashes identify bytes rather than publisher authenticity." Catalog output hashes only the executable, "not a digest of the complete installation."

## docs/process-capture.md

- Largest process doc. Covers `capture-process` / `compare-process-captures`: runs one caller-selected command under a PTY and records terminal frames, scheduled interactions, process-tree samples, exit/settlement, and optional filesystem snapshots (`files_before`/`files_after`) with hashes. Also trace-spec comparison.
- Host support: capture requires Linux or macOS with a working native PTY. "Native Windows capture is unavailable because the PTY adapter does not yet verify descendant cleanup." macOS also needs `xcrun swiftc` (or `REA_DARWIN_SWIFTC_PATH` plus `SDKROOT`) and `REA_DARWIN_MODULE_CACHE_PATH` for sandboxed runs.
- Not a sandbox: "The command runs with the current user's permissions and inherits the host environment." Inherited environment "is not recorded, so its influence may remain unknown."
- Caveats quoted: filesystem "bounded snapshots, not a syscall trace; short-lived changes between snapshots may be missed." "sampling cannot prove that every short-lived or detached descendant was seen." "`after_settlement` names a filesystem checkpoint, not a guarantee that an application finished successfully."
- Finalization (`finalization_ms`): `SIGTERM` then one `SIGKILL`. `exit.code` is `null` on every deadline exit. "a `SIGKILL` from a scenario event next to the escalation cannot be told apart from it." Delivery states: `signaled`, `gone`, `identity-changed`, `unverified`.
- Terminal budget: `columns × (rows + scrollback) ≤ 1,000,000`. Port normalization is "version" pinned. Captures commit `pattern_normalization_version: "literal-replacements-v1"`. Cross-version comparison is rejected.
- Truncation: each capture has `truncation_details` (raw_terminal, normalized_terminal, rendered_terminal, filesystem_before/after, process). Captures missing it are rejected on import.
- macOS caveat: setting `process.title` can make a Node child's run token unreadable, which "can prevent verified cleanup." Sandboxes must allow `/bin/ps`, or cleanup can be `cleanup_incomplete`.
- Node version cited: v24.18.0 (in the `process.title` doc link).
- Verification: the doc does not cite a verifier script, so the doc gives no verification claim.

## docs/recorded-crashes.md

- Covers `inspect_recorded_crash` / `rea inspect-recorded-crash`: reads a Linux ELF64 little-endian core dump and interprets notes/registers for x86-64 and AArch64. Other `e_machine` values return `unsupported_target`.
- Pins: "unchanged pwntools **4.15.0**, pyelftools **0.33** and Unicorn **2.1.2**" in the caller's Python (`REA_PWNTOOLS_PYTHON`).
- Optional debugger context (`--debugger-context`): GDB **13.1** and pwndbg **2026.09.15**. Doc: "Initial local verification covers Linux x64, GDB 13.1 and unchanged pwndbg 2026.09.15." The doc does not state separate verification of the AArch64 profile.
- Caveats quoted: "Historical PIDs are metadata. They never select a live process or authorize attach/control." "Missing notes do not establish absence at the crash." Maps: "These maps do not establish page contents or an executable match."
- Limits: 32 MiB input (raisable to 1 GiB via `REA_PWNTOOLS_MAX_INPUT_BYTES`), 64 MiB reply, 1 MiB diagnostics, 30 s wall per stage, 3 GiB address-space soft ceiling, 30 s CPU. Hard limits are not raised.
- Verifier: `npm run verify:recorded:crash` (uses owned fixture generation).

## Cross-doc notes

1. **Windows capture inspection contradicts itself across packet docs (possible inconsistency).** `docs/packet-captures.md` says capture inspection requires "Linux with util-linux `prlimit` or Windows with owned Job Objects" and that macOS is a "capability gap". `docs/pcap-analysis.md` says the TShark inspector is "on Linux" and that "Unsupported hosts, including macOS and Windows, are refused before inspection." These may be intended to differ (the first covers the pcap family with capinfos, the second only `inspect_packet_capture`), but neither doc says so. Confirm before relying on either.
2. **PCAPNG status.** `docs/pcap-analysis.md` lists "Other formats (including PCAPNG)" as "not established by these fixtures," yet its examples use `device.pcapng`. `docs/packet-captures.md` uses `.pcapng` throughout and treats it as the input format for `inspect_pcap_capture`.
3. **Wireshark/TShark version drift (possibly stale).** `docs/packet-captures.md` names Wireshark **4.0.17** as "current follow-up verification." `docs/pcap-analysis.md` says the real lane measured TShark **4.6.9**'s glossary, and cites Linux 4.6.6 and macOS/Windows 4.6.9 elsewhere. The 4.0.17 pin looks stale relative to the other docs. Verify before citing.
4. **aioquic pins differ by purpose.** `docs/http3-capture-lab.md` pins **aioquic 1.2.0** for the negotiated-version check. `docs/web-network-captures.md` pins **aioquic 1.5.0** for qlog. Both are stated and neither is contradictory, but they are different versions in the same product.
5. **Chrome version coverage differs by doc.** `docs/web-runtime.md` verifies "Chrome 153 / Node 24" on Linux x64. `docs/browser-observation.md` says WebMCP behavior was observed on "Chrome 154 specifically (one tested version)." Neither doc claims the other's version as verified.
6. **Version-pin dates.** `docs/javascript-application-workflows.md` says "Versions before 4.1.0 accept full inline Evidence only," but the repository is at 6.5.0. The doc does not say whether the 4.1.0 line is still supported. Nothing else in scope cites a 4.x pin.
7. **Node version references.** `docs/process-capture.md` cites Node **v24.18.0** and `docs/packet-captures.md` cites Node **24.18.0**. `docs/web-runtime.md` says "Node 24." Consistent with each other, but not pinned in one place.
8. **Unverified cross-links.** These docs link to pages outside this scope, which were not read here: `mcp-contracts.md`, `electron-observation.md`, `electron-fuses.md`, `testing.md`, `website-script-export.md`, `website-module-trace.md`. Claims that depend on them are unverified in this pass.
9. **Scope note.** `docs/javascript-artifact-reconstruction.md` and `docs/javascript-application-workflows.md` describe a later "operator-supplied real-application benchmark" and an "operator-provided directories" verifier. No real-application result is reported in any doc in this set.
