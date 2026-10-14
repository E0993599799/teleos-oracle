# rea Learning Index

## Source
- **Origin**: ./origin/ (symlink → ghq clone, gitignored)
- **GitHub**: https://github.com/morluto/rea
- **Learned at**: latest = HEAD `3b79af28e` (rea-agents 6.5.0, fresh full ghq clone, 2026-10-14 19:40). Earlier pass = `df3d96da8` (6.4.0). The old ghq clone was gone (the `origin` symlink was dangling), so the deep pass re-cloned instead of reading the stale one.

## Explorations

### 2026-10-14 2151 (docs full read, 4 agents, rea-agents 6.5.0) — closes the "~67 docs/*.md unread" gap from the 1940 pass
- [[2026-10-14/2151_DOCS-FULL-ENGINES|Docs: Engine Providers]] — 19 files, ~3,077 lines read: all Ghidra variants (provider, DOS, MIPS, NativeAOT, PPC, PSP, RISC-V), IDA, JEB, Apktool, Frida, native-investigation, Go/Rust/raw binaries, firmware, binary-diagnostics, windows-ghidra-p0
- [[2026-10-14/2151_DOCS-FULL-PLATFORMS|Docs: Platform Analysis]] — 13 files, 2,462 lines read: Android, ADB, Apple application, Electron (fuses + observation), Flutter, Harmony, managed code (.NET), EVM bytecode, WASM, SQLite, website module trace/script export
- [[2026-10-14/2151_DOCS-FULL-JS-NETWORK|Docs: JavaScript & Network Capture]] — 17 files, all read in full: JS application graph/workflows/artifact-reconstruction/recovery/runtime-observation/reconciliation, browser observation + scenario contract, web-network-captures, web-runtime, web-source-location, HTTP/3 lab, packet captures, pcap analysis, signal recordings, process capture, recorded crashes
- [[2026-10-14/2151_DOCS-FULL-PROTOCOL-META|Docs: Protocol, Meta & Specs]] — 22 files: index, client-configuration, client-verification, mcp-contracts, mcp-prompts, migration-6.2, reconstruction ledgers/readiness, releasing, roadmap, tool-design, error-contract.schema.json, user-visible-errors.csv, architecture.mermaid, and both `docs/specs/` feature folders (2356-wasm-interface-comparison, solidity/cbor-metadata), each spec/plan/tasks/verification quad

**Key findings from the full docs pass** (spot-checked against source, all confirmed):
- **Version mismatch, unresolved**: `docs/android-analysis.md:8` says the feature is "present on repository main and in npm 4.1.0" — the package is 6.5.0 now; not clear if the doc is stale or npm 4.1.0 is a different distribution channel.
- **Platform-coverage contradiction between two capture docs**: `docs/packet-captures.md:22` calls macOS capture inspection "a capability gap"; `docs/pcap-analysis.md:107-109` frames macOS/Windows TShark execution as "unverified here" after a Linux-only recorded check. Confirmed both wordings exist; the docs may cover different tools without saying so.
- **WorkBuddy client claims verification with no corresponding lane**: `docs/client-configuration.md:287` says "through WorkBuddy are verified," but `docs/client-verification.md` has no WorkBuddy section — confirmed by grep (zero hits).
- **Malformed CSV row**: `docs/user-visible-errors.csv` row `harm_rank=26` has an unquoted comma inside a field ("Removed fixed byte, entry, depth, and path limits.") that shifts its later columns — confirmed by direct read.
- **Index gap**: `docs/index.md`'s guide table has no entry for GDB, Rizin, objdump or pwntools, though `docs/architecture.mermaid` lists them as providers — confirmed by grep (zero hits in index.md).
- Many version pins across the engine docs (JEB 5.48.0, Frida Core 17.23.2, Binwalk 3.1.0, Apktool 2.7.0, aioquic 1.2.0 vs 1.5.0 depending on doc, Chrome 153 vs 154 depending on doc) carry no re-verification date — "last verified by the doc," not confirmed current.
- Two `docs/specs/` feature folders look internally complete (`tasks.md` fully checked) but `solidity/cbor-metadata/verification.md` itself says a final correction was never re-run — treat as in-progress, not shipped, until confirmed otherwise.

**Still not read even after this pass**: `third_party/` READMEs (vendored upstream docs), `.vitepress/` site config, `docs/assets/`, and the 18 translated `docs/readme/README_*.md` files (not distinct content, skipped intentionally). Nothing was executed; all claims above are static reads.

### 2026-10-14 1940 (--deep, 5 agents, rea-agents 6.5.0) — supersedes the 0222 pass on facts
- [[2026-10-14/1940_ARCHITECTURE|Architecture]] — layout, all entry points, composition root, every engine bridge and its auth, Swift/Java helpers, 6.4.0→6.5.0 changes
- [[2026-10-14/1940_CODE-SNIPPETS|Code Snippets]] — 18 verbatim excerpts with path:line
- [[2026-10-14/1940_QUICK-REFERENCE|Quick Reference]] — full read of `docs/installation.md`, `docs/cli.md`, README; per-OS install, provider prerequisites, CLI families, env vars, inventory of the 70 `docs/` files
- [[2026-10-14/1940_TESTING|Testing]] — Vitest 5.0.3, 814 + 460 test files, Stryker mutation, coverage thresholds, real-engine verification records
- [[2026-10-14/1940_API-SURFACE|API Surface]] — 207 MCP tools (static count), 153 CLI commands, Evidence/Unknown contract, retained-analysis paging, extension points

**Key insights (1940)**:
- 6.5.0 is a big step from 6.4.0: JavaScript source selection, retained analysis views with paging, offline packet/signal/QUIC/Fiddler/SQLite/WASM/Rust/Electron-fuse inspection.
- Public surface is only the bin (`rea`, `rea-agents` → `scripts/rea.mjs`) and stdio MCP; the package has no `exports`/`main`. Adding a provider needs a maintainer scope decision (`CONTRIBUTING.md:158`).
- Verification is scoped per provider/OS and the docs say so: Ghidra bridge verified on 12.1.4 + JDK 21, Hopper on 6.1.0-demo, IDA on Linux/Windows x64 not macOS, CI tests Node not Bun.

**Caveats found in this pass** (spot-checked against source unless noted):
- The 207-tool count is a static count of contract declarations, **not runtime-verified** (the agent could not run compiled code). `docs/client-configuration.md` still quotes 172 tools at an older commit.
- `docs/windows-ghidra-p0.md:3-8` still cites npm 4.1.0/5.0.0 — stale version pointers upstream.
- `REA_LOG_LEVEL` is read in `src/cli.ts` but not documented in `docs/`.
- CODE-SNIPPETS cites `CutterBridgeClient.ts:833-847` for the handshake; the `rea-auth-v2` hello is actually at line 814 and the HMAC checks run ~line 833-848, so the range is a sub-range, not the whole handshake.
- Only headings and first paragraphs of the other ~67 `docs/*.md` were read, not full bodies; `install.sh` was not read in depth; Windows Hopper "absent" was not exhaustively searched.
- Checked and confirmed: test file counts (814/460), `install.sh:113` OS gate, `bin` entries, `ev_`/`unk_` ID prefixes, Vitest 5.0.3, doc sizes.

**Remaining gaps**: ~67 `docs/*.md` bodies, per-tool Java handler internals, runtime behaviour (nothing was executed), the 6.4.0→6.5.0 diff beyond what `CHANGELOG.md` states.

### Earlier pass

### 2026-10-14 0222 (default, 3 agents)
- [[2026-10-14/0222_ARCHITECTURE|Architecture]]
- [[2026-10-14/0222_CODE-SNIPPETS|Code Snippets]]
- [[2026-10-14/0222_QUICK-REFERENCE|Quick Reference]]
- [[2026-10-14/0222_DOCS-ADDENDUM|Docs Addendum]] — closes the docs/.agents/Windows gaps; **corrects the Windows claim in Quick Reference** (Windows is supported, experimentally, for Ghidra x64 P0)

**Key insights**:
- REA is a TypeScript/Node CLI + stdio MCP server that drives external RE engines (Hopper, Ghidra, IDA) and returns Evidence-backed results; both entry points (`src/main.ts`, `src/cli.ts`) share one wiring point, `src/composition/binary.ts`.
- Results carry content-addressed Evidence IDs plus explicit residual Unknowns (observed/derived/inferred confidence) — uncertainty is a first-class type, not prose.
- Bridges authenticate with per-session tokens (Hopper: 32-byte token + 0600 Unix socket; Ghidra: same pattern); REA is explicitly not a sandbox. License MIT; user must hold their own IDA/Hopper/JEB licenses.

**Remaining gaps** (after the addendum): rest of `docs/installation.md` and `docs/cli.md`, ~60 other `docs/*.md` guides, 2 of 4 `.agents` skills; Swift helpers and per-tool Java handlers not read; `src/` working tree is partial, so snippets were read via `git show HEAD:<path>`.
