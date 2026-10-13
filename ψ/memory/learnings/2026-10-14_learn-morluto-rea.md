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
- **Caveat**: learned at HEAD `df3d96da8`, behind upstream `cddf31d55`; `docs/` and `.agents/` unread. Docs: `ψ/learn/morluto/rea/rea.md`.
