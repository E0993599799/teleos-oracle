# AGENTS.md — teleos-oracle

Canonical agent-facing entry point for this repo, required by the fleet-wide
`AGENT_MEMORY_BOOTSTRAP_V1` protocol (`mission-control/governance/agent-memory-bootstrap-v1.md`).
This file existed nowhere in `mission-control` before 2026-10-13 — it was missing
fleet-wide, not just here (also missing on `khun-oracle`; `serra-oracle` got its
copy the same day) — so this is a minimal first version, not a restore of lost
content. Expand it as real gaps are found; don't treat it as finished.

## What this repo is

Teleos — Oracle แห่งความสำเร็จและการปรึกษาการ Deploy (Vercel / Supabase /
infrastructure). Full identity, role, principles, and golden rules live in this
repo's own `CLAUDE.md` (loaded automatically by Claude Code) and in `PROJECT.md`
/ `README.md`. This file does not duplicate those — read them.

## Mandatory bootstrap order (any agent, any tool)

1. Resolve repo root + branch (`rtk git status --short`, `rtk git branch --show-current`).
2. Load mission-memory MCP bootstrap/current context (`memory_bootstrap` or `memory_current`).
3. Read, in this repo root: `AGENTS.md` (this file), `PROJECT.md`, `HANDOFF.md`, `README.md`.
4. Read `ψ/INDEX.md` (this repo's own memory index).
5. Run `memory_search` for the specific task before planning or changing anything.
6. Only then plan, delegate, review, or change code.

Fail-closed: if mission-memory MCP is unreachable, stop and report
`MEMORY_GATE_UNAVAILABLE`. If any file in step 3 is absent, stop and report
`MEMORY_BOOTSTRAP_BLOCKED` rather than proceeding on chat history alone.

## Where things live

- `ψ/memory/` — resonance, learnings, retrospectives, session logs, network traces.
- `ψ/inbox/` — dispatches/assignments from other oracles.
- `ψ/outbox/` — reports sent out.
- `ψ/lab/` — working/experimental records (worktree archives, etc.).
- `ψ/learn/` — `/learn` codebase-exploration output (external repos studied).
- `ψ/writing/`, `ψ/active/`, `ψ/archive/` — see each dir as needed.

## Language

Thai is the primary response language for this Oracle — see `CLAUDE.md`'s
"LANGUAGE RULE". Don't duplicate that here; it is the authority.
