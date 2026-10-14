---
pattern: "Learned rea: MCP/CLI for reverse engineering; one composition root, Evidence + Unknowns as first-class types, token-authenticated engine bridges"
date: 2026-10-14
source: learn: morluto/rea
concepts: ["learn", "codebase", "mcp", "reverse-engineering", "evidence", "typescript"]
---

# Learned rea

- **What**: `rea-agents` 6.4.0 — TypeScript/Node CLI and stdio MCP server driving Hopper, Ghidra and IDA; entry points `src/main.ts` / `src/cli.ts` share `src/composition/binary.ts`.
- **Pattern worth reusing**: results are Evidence with content-addressed IDs plus residual Unknowns tagged by required confidence (observed/derived/inferred), so uncertainty travels with the answer.
- **Security shape**: per-session capability tokens over 0600 Unix sockets for bridges; explicitly not a sandbox; MIT license, lawful-use disclaimer.
- **Windows**: experimental, Ghidra-only (x64 PE + raw 6502, 25 read-only ops); `install.sh` is macOS/Linux only, use `npx rea-agents setup` on Windows.
- **Caveat (first pass)**: learned at HEAD `df3d96da8` (6.4.0), behind upstream; partial docs read.

## Update — /learn --deep, 2026-10-14 19:40

- **Re-learned at** HEAD `3b79af28e` = `rea-agents` 6.5.0 from a fresh clone (the old ghq clone had vanished, leaving `origin` dangling). 5 docs in `ψ/learn/morluto/rea/2026-10-14/1940_*.md`; hub `ψ/learn/morluto/rea/rea.md`.
- **New in 6.5.0**: JavaScript source selection (exact paths, no globs), retained analysis views with paging (`inspect_analysis_view`), offline packet/signal/QUIC/Fiddler/SQLite/WASM/Rust/Electron-fuse inspection.
- **Surface**: public API is only the bin + stdio MCP; ~207 MCP tools (static count, not runtime-verified) and 153 CLI commands; adding a provider needs a maintainer scope decision.
- **Testing**: Vitest 5.0.3, 814 + 460 test files, Stryker mutation (non-blocking), per-provider recorded verification in `docs/testing.md`.
- **Lesson**: a `/learn` target's ghq clone can disappear between sessions; check `readlink origin` resolves before trusting a "learned" claim, and a count from static reading is a claim to label as unverified.
- **Still not read**: ~67 `docs/*.md` bodies; nothing was executed.
