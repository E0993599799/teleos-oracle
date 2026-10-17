# HANDOFF.md — teleos-oracle

Living handoff doc for `AGENT_MEMORY_BOOTSTRAP_V1`. Update it on any multi-session task per
`~/.claude/RTK.md`'s Pre-Interruption Handoff Protocol, rather than relying on chat history or
`ψ/outbox/` alone. This file is injected into every session start, so keep it short.
Full pre-trim version (2026-10-17, nothing removed from history):
`ψ/memory/handoff-archive/2026-10-17_HANDOFF-before-trim.md`.

## Current state (as of 2026-10-17, verified after `git fetch`)

- Branch: `main`, HEAD `8801b3b`, 0 ahead / 0 behind `origin/main`.
- Session start rule from Aek: always read AGENTS.md, HANDOFF.md, PROJECT.md, README.md.
- Parked by Aek (do not act unless he asks about expiry): ED Project Gmail OAuth refresh token
  expires ~7 days (mission-memory #1408).
- `forge-mcp` CONNECT_TIMEOUT mitigated 2026-10-15 (mission-memory #1490): `env.MCP_TIMEOUT="60000"`
  in `~/.claude/settings.json`. If it recurs at 60s, consider building `forge-mcp-bridge` to JS to skip tsx.
- SessionStart hook (Orca → `agent-memory-bootstrap.sh`) timeout raised 10s → 30s on 2026-10-17
  (median run ~8s, p90 ~15s under load; was timing out ~40% of the time). Orca may overwrite it.
- Governance work is closed: ED Project retrospective shipped (PR #344/#348/#368), `/learn morluto/rea`
  done, `ψ/learn/morluto/` is tracked (Aek's decision 2026-10-14).

## In-flight: BPMP PR #416 CI follow-up (executor = teleos, governor changed — see below)

Lock: `mission-control/ψ/fleet/governor-locks/bpmp-pr416-ci-followup-20261014.md`. Evidence: mission-memory #1483, #1493.
Hard limits: no merge/deploy, no budget change, no paid hosted runner, no workflow edits on master, no self-certify.
State (PR #416 OPEN, #409 draft OPEN — re-verified 2026-10-17):
- Hosted jobs fail with 0 steps ("Actions budget is preventing further use"). `phase0-security` fails because
  `tests/security-hardening.test.mjs:156` wants `cancel-in-progress: false` but master + PR head have `true`
  (pre-existing on master). Open decision (Aek + independent reviewer): fix the test or the workflow.
- Benchmark done 2026-10-15 (n=1, warm cache, host load ~9): `npm install` 4m33s, CPU contention dominates.
  Does NOT explain CI's ~12 min. Report: `mission-control/man-os-library/reports/2026-10-15-bpmp-pr416-ci-followup-evidence.md`
  (commit `af637bc8`, pushed).
- GOVERNOR CHANGED 2026-10-15: `khun-oracle-5a` and `-bf` unreachable; live Khun session is `khun-oracle-5c`
  (unconfirmed it holds governor context). Locks still name old sessions; I edited none (governor's call).
- Sent to `-5c`, queued, NOT confirmed read: `BUDGET_GATE_ACK` (msg `5bb46378-7a94-4888-bdd4-0acbba3c0b4b`, scope = read policy
  and will comply, not a review) and the #659 health-check report (msg `3804b975-4816-45b3-a67d-e5ecbef0b1d3`).
  Earlier `RFL_ACK` (read-and-understood only) went to `-bf` (msg `69ddfdd6-a1ca-4968-820c-d2ca8b5637fa`).
- Still awaiting: (1) Aek + independent reviewer: test-vs-workflow decision; (2) whether to benchmark more
  (cold cache / idle host); (3) independent reviewer (`verity-oracle-af` was blocked/busy); (4) cleanup of worktree
  `/home/marcuz/.worktrees/pharmacy-expiry-system/ci-tune-runner-cache-20261015` (branch `ci/runner-cache-routing-20261015`
  @ `d3b714488`, 816MB `node_modules`) — do NOT delete until Aek says so (still exists 2026-10-17).

## In-flight: mission-control #659 BPMP KPI MTD two-image OCR (assigned 2026-10-15, NOT started)

Lock: `mission-control/ψ/fleet/governor-locks/bpmp-kpi-mtd-ocr-659.md` (names `khun-oracle-bf`). Contract:
`royal-master-oracle/khun-oracle/ψ/inbox/gh-bridge-bpmp-kpi-mtd-ocr-20261012-r2.md`. Executor = teleos.
Delegated by a peer message; I have NOT accepted execution and changed nothing. BLOCKED on missing inputs (checked 2026-10-15 05:39):
the failed run dir `backup/temp-time-load-doc/ocr-kpi-mtd_25691012_075155`, `NN_OCR_KPI_MTD_TWO_IMAGES_v2/v3.ps1`, and the
two source screenshots were not found. Tools OK (`powershell.exe`/`pwsh`, Tesseract).
Rules: no invented values (NO7/Profit/%GP/TX/Thai ADC stay null, never map FR to NO7), no silent zero-coercion, no production
data changes before extraction proof, no force-push, no self-certify, no DONE/OK without proof.
Next: get image/script locations from Aek or Khun, then bootstrap on mission-control, then extraction with per-cell proof.

## Next safe action

- Re-verify PR #416 / #409 with `gh` before acting; do not rely on the facts above if time has passed.
- Otherwise treat prior in-flight tasks as closed unless `ψ/outbox/` or recent commits say otherwise.

## How to update this file

Replace "Current state" and "Next safe action" whenever you're about to lose session context (interruption, `/clear`,
handoff to a peer): what was found, why the route was picked, what failed, evidence (commit/file refs), concrete next step.
Keep it short — this is a pointer, not a diary; detail belongs in `ψ/memory/retrospectives/` or `ψ/outbox/`.

<!-- FLEET_HANDOFF_SCHEMA_V1:START -->
## Fleet handoff schema — evidence-backed audit 2026-10-14

### 1) Findings / evidence
- Agent: `teleos`
- Current state: AVAILABLE แต่ working tree มีการเปลี่ยนแปลง/ไฟล์ค้าง; ยังไม่อนุมานว่างานล่าสุดเสร็จหรือค้างจาก status เพียงอย่างเดียว
- Git: branch `main`, HEAD `470756b61838`, origin `https://github.com/E0993599799/teleos-oracle.git`
- Workspace: `/mnt/d/01 Main Work/Boots/Agentic AI/mission-control/royal-master-oracle/teleos-oracle`
- Fleet audit evidence: `mission-control/tools/logs/handoff-fleet-evidence-20261014.txt`

Recent Git evidence:
- `470756b|2026-10-14T03:15:24+07:00|memory: update rea learning with Windows support and docs coverage`
- `32b3f93|2026-10-14T02:34:02+07:00|memory: record /learn morluto/rea learning and update HANDOFF`
- `0730be0|2026-10-14T02:24:05+07:00|governance: add AGENTS.md, PROJECT.md, HANDOFF.md for AGENT_MEMORY_BOOTSTRAP_V1`
- `3dcab81|2026-10-11T18:58:07+07:00|memory: catch-up retrospective for ED Project production closure (PR #344/#348/#368)`
- `854013d|2026-10-10T05:50:34+07:00|lab: record removal of merged KPI-dedupe worktree`

Current working-tree evidence:
- `M ψ/learn/.origins`
- `?? ψ/learn/morluto/`

Recent inbox evidence:
- `20261001_1121_khun-oracle_clear-disk-space-d-drive.md`
- `20260930_2151_khun-oracle_investigate-popup-terminal-windows.md`
- `20260928_1215_khun-oracle_wp-g-decision-interaction-feedback.md`
- `20260928_khun-oracle_dispatch-warden-for-credential-rotation.md`
- `20260928_khun-oracle_wp-g-branch-decision.md`

Recent outbox evidence:
- `20261007_teleos-oracle_disk-space-d-drive-status.md`
- `20261007_teleos-oracle_popup-terminal-windows-fixed.md`
- `20260928_teleos-oracle_wp-g-pr101-i18n-complete.md`
- `20260928_teleos-oracle_wp-g-pr100-mobile-a11y.md`
- `20260928_teleos-oracle_wp-g-pr99-in-progress.md`

### 2) Why this route
- สร้าง/ปรับ handoff จากหลักฐานบนเครื่อง ณ เวลาตรวจ (Git HEAD/status/log + ψ/psi inbox/outbox + mission-memory gate) เพื่อให้ agent ถัดไปรับช่วงได้โดยไม่อาศัย chat-only context และไม่แต่งประวัติที่หาไม่พบ

### 3) Failed attempts / blockers
- `20260928_khun-oracle_dispatch-warden-for-credential-rotation.md`

### 4) Current status / owner / next action
- Handoff owner: `teleos` oracle workspace; execution/merge/production authority remains governed by Mission Control and the human owner.
- Status: AVAILABLE แต่ working tree มีการเปลี่ยนแปลง/ไฟล์ค้าง; ยังไม่อนุมานว่างานล่าสุดเสร็จหรือค้างจาก status เพียงอย่างเดียว
- Next safe action: รักษา working tree ปัจจุบันไว้ก่อน ตรวจรายการ changes ด้านล่างและ inbox/outbox ล่าสุด แล้วค่อยรับช่วงหลัง memory bootstrap

### 5) Durable references / proof
- `mission-control/tools/logs/handoff-fleet-evidence-20261014.txt`
- `mission-control/tools/logs/handoff-fleet-standardize-20261014-proof.txt`
- Repository HEAD at audit: `470756b61838`
- Latest inbox: `20261001_1121_khun-oracle_clear-disk-space-d-drive.md`
- Latest outbox: `20261007_teleos-oracle_disk-space-d-drive-status.md`

> Rule for the next agent: ถ้าหลักฐานปัจจุบันขัดกับ section นี้ ให้ใช้หลักฐานใหม่กว่า, record conflict/supersession ใน mission-memory, และอัปเดต HANDOFF.md ก่อนส่งต่อ ห้ามเดา.
<!-- FLEET_HANDOFF_SCHEMA_V1:END -->
