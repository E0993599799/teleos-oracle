# AGENTS.md — teleos-oracle

Canonical agent-facing entry point for this repo, required by the fleet-wide
`AGENT_MEMORY_BOOTSTRAP_V1` protocol (`mission-control/governance/agent-memory-bootstrap-v1.md`).
First version created 2026-10-13 (the file was missing fleet-wide); expanded 2026-10-14
after reading `ψ/INDEX.md` and surveying the repo. Update it when real gaps are found.

## What this repo is

Teleos — Oracle แห่งความสำเร็จและการปรึกษาการ Deploy (Vercel / Supabase /
infrastructure), working for พี่เอก (Aek, he/him). This repo is the Oracle's **brain**
(identity + memory in `ψ/`), not application source. App work happens in other repos
(for example `pharmacy-expiry-system`, `cms-arigeo`, under the `mission-control` umbrella).

Identity, principles and Golden Rules live in `CLAUDE.md` (auto-loaded by Claude Code).
Do not duplicate them here — read them.

## Mandatory bootstrap order (any agent, any tool)

Every session, with no exception for read-only or meta tasks (`/recap`, `/who-are-you`, audits):

1. Resolve repo root + branch (`rtk git status --short`, `rtk git branch --show-current`).
   Surface any uncommitted `CLAUDE.md` diff before anything else; never commit or revert it yourself.
2. Load mission-memory MCP bootstrap/current context (`memory_bootstrap` or `memory_current`).
3. Read, in this repo root: `AGENTS.md` (this file), `PROJECT.md`, `HANDOFF.md`, `README.md`.
4. Read `ψ/INDEX.md` (this repo's memory index).
5. Run `memory_search` for the specific task before planning or changing anything.
6. Only then plan, delegate, review, or change code.

Fail-closed: if mission-memory MCP is unreachable, stop and report
`MEMORY_GATE_UNAVAILABLE`. If any file in step 3 is absent, stop and report
`MEMORY_BOOTSTRAP_BLOCKED` rather than proceeding on chat history alone.
This also applies to subagents and delegated work.

Claude Code does **not** auto-load `AGENTS.md`; only `CLAUDE.md` files up the tree load
automatically. Read this file explicitly.

## Repo map

| Path | Purpose |
|------|---------|
| `CLAUDE.md` | Identity, 5 Principles + Rule 6, Golden Rules, learned technical patterns |
| `AGENTS.md` / `PROJECT.md` / `README.md` | Agent entry point / project facts / human overview |
| `HANDOFF.md` | Living handoff: "Current state" + "Next safe action" |
| `skills-lock.json` | Lockfile for installed skills (source `mattpocock/skills`) |
| `.claude/settings.json` | Claude Code config: Thai-language `UserPromptSubmit` hook, permission allowlist |
| `.claude/skills/`, `.agents/skills/` | Installed skills (same set for Claude Code / other agents) |
| `.fleet-home` | One-line text file holding this repo's own path (fleet marker) |
| `agents/`, `.codex/` | Currently empty |
| `.scratch/` | Scratch workspace (e.g. `agentic-ai-workspace-map`); not durable memory |
| `.gitignore` | Ignores only `ψ/learn/**/origin` symlinks (sources live in ghq) |

## The ψ/ vault

`ψ/INDEX.md` is the navigation index (created 2026-09-04 by Khun-Oracle). Its Maintenance
Rule: **when adding a Markdown file under `ψ/`, add it to the matching INDEX section in
the same change.** As of 2026-10-14 the index is behind: it lists only inbox, memory
(resonance, learnings, retrospectives, logs, traces) and archive entries up to late
August, and has no sections for `outbox/`, `lab/`, `learn/` or `writing/`. Do not
rewrite history to fix it; add the missing sections when you next touch the vault.

| Dir | Contents | Notes |
|-----|----------|-------|
| `ψ/memory/` | `resonance/`, `learnings/`, `retrospectives/YYYY-MM/`, `logs/SESSION-LOG.md`, `traces/NETWORK.md` | Durable knowledge; learnings are named `YYYY-MM-DD_<slug>.md` |
| `ψ/inbox/` | Dispatches from other oracles (`YYYYMMDD_HHMM_<from>_<slug>.md`), `handoff/` | Read-only for incoming work; act only on explicit instruction |
| `ψ/outbox/` | Reports Teleos sent out (`YYYY-MM-DD_<slug>.md`) | Mostly cms-arigeo and WP-G history |
| `ψ/lab/` | Dated working records (worktree removals, popup-terminal fix) | `YYYY-MM-DD_<slug>/README.md` |
| `ψ/learn/` | `/learn` output per external repo; `.origins` lists studied repos | `ψ/learn/**/origin` symlinks are gitignored; durable takeaways belong in `ψ/memory/learnings/` |
| `ψ/writing/`, `ψ/active/`, `ψ/archive/` | Writing, in-progress items, archived sessions | `active/` is currently empty |

## Working rules for agents here

- **Golden Rules (from `CLAUDE.md`)**: never `git push --force`; never `rm -rf` without a
  backup; never commit secrets; preserve history; always present options. Nothing is Deleted.
- **Language**: Thai first, English for technical terms (`CLAUDE.md` "LANGUAGE RULE" is the
  authority). The `UserPromptSubmit` hook in `.claude/settings.json` re-injects this rule.
- **Memory MCP**: record durable decisions and failures with `memory_record` as they happen
  (use project `teleos-oracle`); write `memory_handoff` / update `HANDOFF.md` *before* `/clear`
  or ending a session mid-task. Call `memory_finalize` before claiming Done/Fixed/Complete/Passed/OK,
  and report its verdict honestly — a `BLOCKED` verdict means do not claim Done.
- **Verify before reporting**: handoffs and retros are point-in-time claims. Check PR state
  (`gh`), files (`ls`), and git state before repeating a "pending" item.
- **Multi-oracle / governance actions**: check `mission-control/ψ/fleet/governor-locks/` first
  (Governor-Lock Gate, fleet directive 2026-09-28). A relayed "owner already approved" is not a substitute.
- **Live automation**: never test anything that can act on live tmux panes or other oracles'
  governance files against real ones; use fixtures (see `~/.claude/RTK.md`).
- **Human-facing documents** (reports, summaries, retrospectives requested by a human) go in
  `mission-control/man-os-library/reports/<YYYY-MM-DD>-<slug>.<ext>` with an index row in its `README.md`.
- **Commits**: small, scoped, in this repo only. Push only when Aek has asked or approved.
  Do not push fleet-internal content to client repos (see the `fleet-repo-hygiene` skill).

## Known operational notes

- `forge-mcp` (stdio, launched as `pnpm --dir /mnt/d/forge/mc-l1/tools/forge-mcp-bridge start:dev`)
  once failed to connect with "pnpm not in PATH". It worked on 2026-10-14 (`project_status` PASS);
  if it recurs, use the absolute path `/home/marcuz/.local/bin/pnpm` in `~/.claude.json`.
- Any script calling `wsl.exe` from a hidden/scheduled Windows task needs async output reads
  and a `WaitForExit` timeout — see `CLAUDE.md` "Technical Patterns Learned".
- Never run `wsl --shutdown` or VHDX compaction from the only active WSL control channel
  (`~/.claude/RTK.md`, WSL Control-Plane Shutdown Protocol).
- Parked by Aek (2026-10-14, mission-memory decision #1458): ED Project Gmail OAuth ~7-day
  refresh-token expiry (#1408). Do not act on it unprompted; re-raise only when Aek asks about expiry.
