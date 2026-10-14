# morluto/rea docs: full protocol and meta read (package 6.5.0)

Source: `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/github.com/morluto/rea/docs/`
Read-only analysis. Every claim below cites a file under that directory. Quoted caveats are verbatim from the doc.

## docs/index.md

Source: `docs/index.md`. VitePress home page for REA ("Reverse Engineer Anything"), a CLI and MCP server. It lists the install entry (`npx rea-agents setup`), a first-result command (`npx -y rea-agents@latest analyze-javascript-application /absolute/path/to/app --json`), and a topic table that routes each analysis area to its guide (native, JavaScript/Electron, .NET/Android/firmware/WASM/EVM, browser, website source, process capture, CLI/MCP). It has no caveats of its own. It points to the Frida guide for runtime instrumentation. Gap: the table links no guide for GDB, Rizin, objdump, pwntools/pwndbg or reference-source, which `architecture.mermaid` shows as components. No matching `.md` exists in `docs/`.

## docs/client-configuration.md

Source: `docs/client-configuration.md`. Per-client setup and troubleshooting for about 25 agents and hosts: Claude Desktop (MSIX vs `%APPDATA%` paths), Claude Code, Copilot CLI, Kimi, Pi, Qwen, Antigravity, Gemini CLI, Codex/Devin, OMP, Hermes, Qoder, Factory Droid, Trae, WorkBuddy, ZCode, DeepSeek Harness, OpenCode, Grok Build and Grok Bot. Key knobs: `REA_MCP_INPUT_SCHEMA_PROFILE=compact` (in the client's `mcpServers.rea.env`), `REA_MCP_OUTPUT_SCHEMA_PROFILE=off`, `ENABLE_TOOL_SEARCH=true`, `CLAUDE_CODE_MAX_CONTEXT_TOKENS`. Caveats quoted: "The versioned verification notes below describe their stated runs; live service acceptance is verified only where explicitly recorded." Also "A live Claude Code session against DeepSeek's API is unverified." and "Uninstall against the real app is unverified." (Claude Desktop). Trae: "loading this registration in Trae remains unverified." Grok Bot: setup writes no file; the user must add the connector in the Bot chat. Claude Code sizing (172 tools, about 496 KB default, about 290 KB compact) is pinned to "main at 04089d5be", which may not match HEAD.

## docs/client-verification.md

Source: `docs/client-verification.md`. The largest verification record. It covers optional native-client lanes (`verify:qwen-client`, `verify:pi-client`, `verify:hermes-client`, `verify:gemini-client`, `verify:opencode-client`, `verify:claude-client`, `verify:copilot-client`, `verify:grok-client`, `verify:commandcode-client`, `verify:omp-client`, `verify:deepseek-client`). Each lane uses a loopback or synthetic model fixture. Pinned client versions include Gemini CLI 0.63.0, Claude Code 2.1.296, Copilot 1.0.95, OpenCode 1.18.35, Grok Build 1.0.50, OMP 18.8.7, DeepSeek Harness 0.2.0-rc.2 and Command Code 1.79.2. Also covers Hopper lanes (`verify:hopper`, `:linux`, `:fat`, `:fat64`, `:deadlines`), browser lanes, setup, Apple/keyed-archive lanes, and an agent-evaluation lane (`npm run verify:agent`, which uses a real local Codex CLI). Report schema version is 4. Caveats quoted: "a native-client run with a loopback model does not establish live model-service acceptance." Also: "live Google API compatibility remains unverified", "Live model APIs and native Windows are also unverified", and for Copilot "effective capacity and live API acceptance remain unknown." Qwen Windows: a Node 24.18.0 run "remains a failure, not a compatibility claim." Hopper Linux: decoded-object coverage for the 4,119-byte literal "remains explicitly unverified on Linux even when recognized." Synthetic token usage is repeatedly disclaimed.

## docs/mcp-contracts.md

Source: `docs/mcp-contracts.md`. The authoritative runtime-behaviour reference for MCP calls (about 790 lines). Key contract points:
- Evidence-producing tools return the full record as `structuredContent` (`normalized_result`, `evidence_id`, `analysis_profile` always present). Errors use `isError: true` with `{ "error": ... }` JSON in text content and no `structuredContent`.
- Untrusted target content is marked `_meta.provenance.untrusted_content: true` on marked tools.
- Response budget: 10 MiB pinned-client buffer. `REA_MCP_MAX_RESPONSE_BYTES` must be at least 10485760. Oversized results return `resource_constraint`.
- Ghidra first-query deadline is 330,000 ms by default (`REA_GHIDRA_STARTUP_TIMEOUT_MS`). Hopper is 120,000 ms. The pinned client SDK 2.3.1 defaults to 60,000 ms per call.
- `REA_MCP_INPUT_SCHEMA_PROFILE=compact` has a 13,312-byte budget (Moonshot cap).
- `REA_MCP_OUTPUT_SCHEMA_PROFILE=off` drops `outputSchema`.
- `inspect_analysis_view` pages and summary detail exist for several tools.
Caveats quoted: "Compact advertisements can reduce nested schema constraints; REA still validates complete canonical inputs." Measured Ghidra example: a 1,024-byte fixture; "so the longer request setting remains an example, not a guarantee for larger targets. No macOS cold-start recovery was exercised." Moonshot: "local captures do not establish Moonshot acceptance." Compatibility "depends on the selected gateway and model."

## docs/mcp-prompts.md

Source: `docs/mcp-prompts.md`. Six guided MCP prompts (`investigate_feature`, `compare_application_versions`, `verify_reconstruction`, `trace_crash`, `audit_residual_unknowns`, `prepare_bounded_process_capture`). The server advertises `prompts.listChanged: true`. `completion/complete` covers only prompt arguments (document, procedure, provider, Evidence, process capture, artifact manifest/occurrence, residual unknown), not arbitrary tool arguments. Caveat quoted: "An empty completion list does not establish that the target has no procedures." Completion reads only a ready provider and does not start analysis. Prompt arguments are "untrusted selection data, not instructions or authorization."

## docs/migration-6.2.md

Source: `docs/migration-6.2.md`. Upgrade guide from 6.1 to 6.2, a historical reference. Breaking changes:
- The old `{ result, evidence_id, evidence }` wrapper is removed (use `structuredContent` directly).
- `analysis_profile` is required on every Evidence record.
- `binary_session` drops the `provider`/`providers` aliases.
- Artifact occurrences take role/permissions from `occurrences[]`.
- Legacy v3 process captures are no longer converted on import.
- Function dimension `truncated` is removed.
- Source symlinks with unreadable/unknown state require `target: null`.
Caveats quoted: "Records that omitted it cannot be migrated by inserting `null` while retaining the old `evidence_id`." Also "Regenerate old inventories: a merged content node alone cannot recover the per-path facts that were lost." The doc is pinned to 6.2 and is not a checklist for later releases, as `releasing.md` says.

## docs/reconstruction-obligation-ledgers.md

Source: `docs/reconstruction-obligation-ledgers.md`. Describes `build_reconstruction_obligation_ledger` (MCP) and `rea build-reconstruction-obligation-ledger` (CLI). Input is an Evidence bundle, `reviewed_obligations` and a manifest. Gives 5 reviewed-obligation examples (CLI parsing, protocol handler, Electron startup, persistence migration, native ABI) and one full manifest binding. An empty request returns an `unknown` ledger with zero obligations. Closure requires one owner, parser/schema/domain types, all required case fixtures and a passing verifier whose authority matches. Caveats quoted: "A green unit test cannot close a `packaged-process` obligation. A static-only source cannot close a runtime or process claim." "Marking a claim `blocked` or `out-of-scope` records the disposition but does not silently count it as verified." Evidence IDs in the examples are placeholder values (`ev_aaaa...`).

## docs/reconstruction-readiness.md

Source: `docs/reconstruction-readiness.md`. Describes the repo-internal verifier `npm run verify:readiness` (not a public CLI or MCP tool). It runs nine stages: `discover-classify`, `diagnose-environment`, `acquire-authority`, `static-analysis`, `reactive-scenarios`, `compare-authority-candidate`, `preserve-contradictions`, `verify-reconstruction-closure`, `export-replay`. `REA_READINESS_REPORT_PATH` retains the full report, and CI publishes it as the `reconstruction-readiness` artifact. The evaluator fails closed on about 15 rules. Caveat quoted: "The synthetic example is a public typed input, not a global equivalence claim." The doc says the verifier is "not exposed as a public CLI command or MCP tool."

## docs/releasing.md

Source: `docs/releasing.md`. Release process. Release Please runs on pushes to main with `always-bump-minor`, so breaking releases still bump minor. Publishing requires merging the release PR. The optional manual path uses `release/VERSION` branches and `gh workflow run release.yml` with `phase=prepare` and `phase=publish`. The doc sets rules for npm dist-tags (`latest` vs `next`), MCP Registry metadata, changelog contributor credit (`npm run release:notes`), the `rea:release-notes-finalized` label and a 65,536-character PR-body limit. Caveats quoted: "A GitHub tag alone does not establish npm or MCP Registry publication." "Merging still starts publication; a notes edit does not authorize a merge or release by itself." Stale-looking examples: `release/5.0.0`, `rea-agents-5.0.0` and `release/6.1.0`, all predating the 6.5.0 package.

## docs/roadmap.md

Source: `docs/roadmap.md`. Short forward-looking page. Priorities: native architecture/type/indirect-call verification, cross-layer static/runtime correlation, managed-code comparisons, process/protocol/filesystem coverage, and evaluating more providers only when an analyst workflow shows a gap. It links three GitHub trackers (#32 platform, #48 process/Hopper, #39 browser). Admission rule: new capabilities must return evidence via shared CLI/MCP, preserve unknowns, and declare authority. No caveats are stated.

## docs/tool-design.md

Source: `docs/tool-design.md`. Rules for adding MCP tools. Tool shapes are `inspect`, `search/list`, `trace`, `compare`, `workflow`, and `observe/capture`. Primitives are preferred over workflows. Tools use strict inputs. Results must carry source locations, Evidence references and coverage, and missing coverage is `unknown`, not absence. Effects must be declared truthfully. Caveats quoted: "Serialized bytes alone do not establish agent usability." "Schema validity and keyword heuristics do not establish successful tool selection." Discoverability changes need evaluation on the intended host, recording host, model, catalog, selected tools and outcomes.

## docs/error-contract.schema.json

Source: `docs/error-contract.schema.json` (22.7 KB, JSON Schema draft 2020-12). The top level is only `$schema` and `oneOf`, with 20 branches. Each branch is an object with `additionalProperties: false`. Required fields are `code`, `category`, `message`, `retryable`, and `remediation`. The optional field is `details` (an object with free-form values). `code` is a `const` per branch. The 20 codes are: `invalid_request`, `access_denied`, `artifact_changed`, `unreadable_output`, `capability_unavailable`, `unsupported_target`, `provider_unavailable`, `provider_timeout`, `resource_constraint`, `cancelled`, `artifact_integrity_mismatch`, `artifact_operation_failed`, `evidence_integrity_mismatch`, `truncated`, `process_capture_failed`, `cleanup_incomplete`, `revision_conflict`, `configuration_invalid`, `target_unavailable`, `execution_failure`. `category` is a 10-value enum shared by all branches (`invalid_input`, `unsupported_provider`, `unsupported_target`, `integrity_mismatch`, `truncated`, `cancelled`, `timeout`, `resource_constraint`, `unavailable`, `execution_failure`). `message` has `minLength: 1`. `remediation` is `{ action }` with `minLength: 1`. The schema states no caveats.

## docs/user-visible-errors.csv

Source: `docs/user-visible-errors.csv` (32.7 KB, about 103 data rows, one header). Columns: `harm_rank` (numeric sort key, sometimes decimal such as 24.5 or 90.6), `location` (file and symbol), `trigger`, `current_copy` (the message as shipped), `user_risk`, `proposed_replacement`, `implementation_status`, `verification_result`. Status counts: 72 `implemented`, 23 `unchanged`, 7 `removed`, and 1 malformed row. Examples:
- `1, src/domain/errors.ts:AnalysisCapabilityUnavailableError`: proposed replacement "This analysis is unavailable for the current target. Choose another analysis or target." (implemented)
- `2, src/domain/errors.ts:ProviderAdapterError`: proposed replacement tells the user to run `rea doctor` (implemented)
- `90.6, incur:unknown CLI command`: kept framework-generated copy (unchanged)
Caveat: row with `harm_rank` 26 (`ReferenceSourceImportPolicy.ts:invalid-limits`) has unquoted commas, so its status and verification fields shift into the wrong columns. Its `implementation_status` is `" entry"`. Verification text is the usual "focused assertions passed" style, which is not a re-run.

## docs/architecture.mermaid

Source: `docs/architecture.mermaid` (Mermaid `graph TD`, about 165 lines). Layered diagram: entry points (`src/cli.ts`, `src/main.ts`, `scripts/rea.mjs` dispatcher), a composition layer (`src/composition/`), adapters (`src/server/`, the Hopper and Ghidra bridges, installers), an application layer (`src/application/`, `SessionProviderRouter`, `AnalysisProviderRegistry` with "deterministic selection, no fallback", `EvidenceLedger`), provider layers (Hopper, Ghidra, IDA via external `ida-pro-mcp`, WASM via caller-supplied WABT, EVM worker, PWNTOOLS/pwndbg, GDB, Rizin, objdump, firmware Binwalk/Unblob, Android/JADX, browser CDP/Playwright, V8 inspector, .NET, source-map codec), a process foundation (`src/process/`, `src/windows/`, a Node-API native module), contracts, a pure domain layer, and config. It has no caveats. Several providers (GDB, Rizin, objdump, pwntools) have no matching doc in `docs/`.

## docs/specs/2356-wasm-interface-comparison/spec.md

Source: `docs/specs/2356-wasm-interface-comparison/spec.md`. Scope: an Evidence-only comparison of two `inspect_wasm_artifact` records, with `scope: imports | exports | both`. No module is fetched or executed. Groups imports by module/name and exports by name. Duplicate keys yield `unknown`. Caveat quoted: "Exact static equality is not runtime compatibility, ABI compatibility, linking success or source identity." Resource note: "Token usage and peak process-family memory remain unmeasured." The spec notes overlap with open PR #2406 (head 86865035) and says its component parser is "not required or duplicated here."

## docs/specs/2356-wasm-interface-comparison/plan.md

Source: `docs/specs/2356-wasm-interface-comparison/plan.md`. Six-step plan: check issue/timeline and PR overlap (review #2406), extend core-module WABT inspection in an isolated worktree, add optional typed interface facts, add the shared comparator and strict contracts, register CLI/MCP and docs, then validate original-module, malformed, unknown and cancellation cases. No caveats of its own.

## docs/specs/2356-wasm-interface-comparison/tasks.md

Source: `docs/specs/2356-wasm-interface-comparison/tasks.md`. Six tasks, all checked `[x]`. Last item: "Resolve independent review findings and rerun relevant checks."

## docs/specs/2356-wasm-interface-comparison/verification.md

Source: `docs/specs/2356-wasm-interface-comparison/verification.md`. Verified base `a2d8b94`. Focused tests: 8 files and 56 tests passed. `npm run check`, `docs:generate`, `docs:check` and `verify:test-discovery` passed. Real WABT 1.0.42 via compiled CLI and stdio MCP. Independent review found three issues, now fixed (memory page size, shared signature expansion, partial singleton uniqueness). Caveats quoted: "Real-tool verification covers macOS arm64 only; Linux/Windows remain unverified." "No module was instantiated/executed and no source was fetched." The verification record says the 1000-params/10000-exports case reduced from 61,824,014 bytes of JSON to 12,046,676 bytes with an explicit capacity issue.

## docs/specs/solidity/cbor-metadata/spec.md

Source: `docs/specs/solidity/cbor-metadata/spec.md`. Tracks issue #2388. Adds terminal CBOR metadata facts to the existing EVM interface operation: trailer ranges, a root-map candidate kept separate from proof of Solidity origin, scalar keys/values decoded losslessly (integers as decimal strings), and solc version representations from observed entries only. Does not fetch metadata or contact RPC. Deferred: "Binding a supplied metadata JSON to IPFS/Swarm commitments is a later independent increment of #2388."

## docs/specs/solidity/cbor-metadata/plan.md

Source: `docs/specs/solidity/cbor-metadata/plan.md`. Plan: use cborg 6.1.3 (Apache-2.0) as a pinned decoder with a bounded tokenizer. Add a portable schema in `src/domain/evm/` and `src/evm/SolidityMetadata.ts`. Compute facts in `EvmoleInterfaceWorker`. Parser bounds: nesting 64 levels, collection growth bounded by the terminal payload's byte count. Caveat: the plan says it "is not a new execution provider"; the Linux CLI/MCP verifier and CI matrix are steps 6–7.

## docs/specs/solidity/cbor-metadata/tasks.md

Source: `docs/specs/solidity/cbor-metadata/tasks.md`. Six tasks, all checked `[x]`. The last one is "Run relevant repository checks and prepare a separately scoped PR." No PR number is recorded.

## docs/specs/solidity/cbor-metadata/verification.md

Source: `docs/specs/solidity/cbor-metadata/verification.md`. After integrating upstream `c462a4ebd`: 47 tests passed across parser, domain contract, service, compiled worker and MCP boundary. Test discovery found 1004 files. The CI-planner selection passed 85 tests. A real solc 0.8.30 fixture was used. Caveats quoted: "Compiled worker tests exercise unchanged EVMole WASM on this macOS host. ... The full Linux-only provider CLI/MCP, resource-limit and cleanup lane remains unverified here." "Tests and provider reruns for that correction were skipped at the maintainer's request; the earlier runs above do not validate the changed head." Metadata JSON commitment binding is deferred under #2388.

## Cross-doc notes

**Contradictions and gaps**
- `client-configuration.md` says loading and real tool calls through WorkBuddy "are verified." `client-verification.md` has no WorkBuddy lane, so the evidence cited for that claim is not in the docs I read. It may live in `testing.md`, which was outside this assignment.
- `docs/specs/solidity/cbor-metadata/verification.md` says the final head was not re-verified. Its `tasks.md` still marks everything complete. These two read as inconsistent.
- The guide table in `index.md` omits GDB, Rizin, objdump, pwntools and reference-source. `architecture.mermaid` shows all of them as providers, and `docs/` has no dedicated page for any of them.
- `user-visible-errors.csv` has one malformed row (harm_rank 26), so a strict CSV parser will misread that row's status and verification columns.

**Stale-looking version numbers**
- `releasing.md` uses `release/5.0.0`, `rea-agents-5.0.0`, and `release/6.1.0` as examples, all behind the 6.5.0 package. The doc states these are examples, so they are not claims about the current release.
- `migration-6.2.md` is historical by design. `releasing.md` says it is not the compatibility checklist for later releases.
- `client-configuration.md` pins its Claude Code payload measurements to "main at 04089d5be." That commit may differ from the current HEAD (3b79af28e). Not checked against git.
- Pinned client and engine versions: SDK 2.3.1, Ghidra 12.1.4, Hopper 6.1.0-demo (6.4.2 for the Linux ELF loader), Copilot 1.0.95 and Claude Code 2.1.296. These are dated test pins, not current-version claims.

**Shipped or in progress**
- `specs/2356-wasm-interface-comparison`: every task is `[x]` and the verification record is complete, with real-tool runs on macOS arm64 only. Reads as implemented and locally verified. I found no merge or PR number for #2356 itself, so merge status is not confirmed from these files.
- `specs/solidity/cbor-metadata`: every task is `[x]`, but the verification record says the final correction was not re-run and no PR is recorded. Reads as implemented but not fully verified on the final head, so treat it as in progress until the PR CI shows the changed head passing.
