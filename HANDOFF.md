# HANDOFF.md — teleos-oracle

Living handoff doc for `AGENT_MEMORY_BOOTSTRAP_V1`. Created 2026-10-13 — this file
did not exist before (fleet-wide gap, not specific to this repo; see `serra-oracle`
and `khun-oracle` for the same gap). Update it on any multi-session task per
`~/.claude/RTK.md`'s Pre-Interruption Handoff Protocol, rather than relying on
chat history or `ψ/outbox/` alone to carry state forward.

## Current state (as of 2026-10-14 23:50, verified by /recap after `git fetch`)

- Branch: `main`, HEAD `0ccad44`, in sync with `origin/main` (0 ahead / 0 behind after
  fetch). `1f02f8a` is already on `origin/main` — the earlier "unpushed" note below is superseded.
- `forge-mcp` FAILS to connect in the 2026-10-14 23:09 session (`CONNECT_TIMEOUT` 30s).
  `pnpm` and the bridge dir exist and `start:dev` stays alive for 10s without crashing, so
  it is not a missing-PATH failure; likely slow startup (`node --import tsx` on `/mnt/d`)
  or no initialize reply within 30s. Cause NOT confirmed — a timing probe was inconclusive.
- Stale mission-memory items (work shipped via PR #344/#348/#368): blocker #1339 and
  next-action #1322 are obsolete.
- Older state (2026-10-14 19:30): `ψ/learn/morluto/` is now TRACKED (Aek's
  decision 2026-10-14, like `imxv`/`mattpocock`) and indexed in `ψ/INDEX.md`;
  rea was re-learned with `--deep` at 6.5.0 (`3b79af28e`), docs in `ψ/learn/morluto/rea/`.
- `forge-mcp` works again in this session (`project_status` PASS); the old
  "pnpm not in PATH" failure did not reproduce — likely a launch-time PATH issue.
- Parked by Aek (do not act unless he asks about expiry): ED Project Gmail OAuth
  refresh token expires ~7 days (mission-memory #1408).
- Session start rule from Aek: always read AGENTS.md, HANDOFF.md, PROJECT.md, README.md.
- No open thread, blocker, or next-action found in mission-memory (bootstrap +
  `memory_search`); treat prior work as closed.

### Historical notes (2026-10-13 session start)

- Branch: `main`, working tree clean at session start.
- Most recent work (from `git log`): backlog catch-up and lab-archival commits —
  `3dcab81` (ED Project production closure retrospective, PR #344/#348/#368),
  `854013d`/`c8d61ef` (worktree archival/removal), `0f568f0` (popup-terminal-windows
  closure + disk-space status + ED-project/KPI-dedupe pivot), `f23dced` (PowerShell
  cleanup-script permission config).
- This session's own work (not yet written to `ψ/`): cleaned up a `cms-arigeo`
  duplicate clone and legacy Next.js scaffold under
  `mission-control/cms-arigeo` (separate repo, not this one) — deleted stale
  `node_modules` in several places, discovered and repaired local git object
  corruption there via a fresh clone + swap, committed and pushed
  (`33853b0` on `fix/admin-nav-wiring-and-perf`). Also deleted a stray
  `node_modules` in an unrelated `pharmacy-expiry-system` hermes worktree.
  None of this touches teleos-oracle's own repo.
- This session's trigger for creating `AGENTS.md`/`PROJECT.md`/`HANDOFF.md`:
  invoking `/learn https://github.com/morluto/rea` hit the mandatory bootstrap
  gate (`MEMORY_BOOTSTRAP_BLOCKED` — these three files were missing). User chose
  to have the missing governance files created rather than skip or bypass the gate.

## In-flight: BPMP PR #416 CI follow-up (2026-10-15, executor = teleos, governor = khun-oracle-5a)

Brief/lock: `mission-control/ψ/fleet/governor-locks/bpmp-pr416-ci-followup-20261014.md`.
Evidence: mission-memory #1483 (scope `bpmp-pr416-ci-followup-20261014`). Hard limits: no merge/deploy,
no budget change, no paid hosted runner, no workflow edits on master, no self-certify (independent reviewer needed).

- Hosted proof jobs fail with 0 steps: "Actions budget is preventing further use" (jobs 115976164579, 115975887700).
- `phase0-security` on #416 (job 115976366842) fails at step 12: `tests/security-hardening.test.mjs:156` wants
  `cancel-in-progress: false`, master + PR head have `true` (commit `10d54158d`). Pre-existing on master, not from #416.
  Open decision (Aek + independent reviewer): fix the test or the workflow.
- Draft PR #409 already migrates 22 workflows to `[self-hosted, Linux, X64, marcuz-linux]`. Its 5 "failed" jobs were
  timeout cancellations: one runner carries that label, jobs serialized, `npm install` ~12 min of a 15 min cap.
- No lockfile in the repo, so `setup-node` cache is unusable; runners share one 4-core/5.9 GB host with swap in use,
  so routing to `bpmp-ci` adds no capacity. Root cause of slow install is a hypothesis (RAM/swap), not measured.
- Nothing changed in `pharmacy-expiry-system`. Clean worktree left at
  `/home/marcuz/.worktrees/pharmacy-expiry-system/ci-tune-runner-cache-20261015` (branch `ci/runner-cache-routing-20261015`
  @ `d3b714488`); remove it if Aek declines the benchmark.
- Awaiting Aek: (1) allow `npm install` benchmark on runner host, (2) test-vs-workflow decision, (3) evidence report under
  `man-os-library/reports/`, (4) whether to send `RFL_ACK` for REPEAT_FAILURE_LEARNING_GATE_V1 (NOT sent; policy file not
  yet read), (5) final report to khun-oracle-5a is still owed.
- Also open: `forge-mcp` CONNECT_TIMEOUT (mission-memory #1481, cause unconfirmed).
- Longer handoff (temp, may vanish): `/tmp/claude-1000/-mnt-d-01-Main-Work-Boots-Agentic-AI-mission-control-royal-master-oracle-teleos-oracle/560114ff-3515-46db-ac8b-9c87334cd534/scratchpad/handoff-teleos-pr416-ci-20261015.md`.

## Next safe action

- Re-verify PR #416 / #409 with `gh` before acting; do not rely on the facts above if time has passed.
- `/learn https://github.com/morluto/rea` is DONE (2026-10-14): 3 docs + hub in
  `ψ/learn/morluto/rea/`, learning in `ψ/memory/learnings/2026-10-14_learn-morluto-rea.md`.
  Learning file committed (`32b3f93`, `470756b`); `ψ/learn/morluto/` stays uncommitted
  (`ψ/learn/` is disposable per fleet hygiene; the learning file is the durable part).
- Governance files committed + pushed as `0730be0`.
- `ψ/learn/.origins` cleanup DONE (committed `1f02f8a`); push to origin pending Aek's OK.
- No other pending thread is known; treat any prior in-flight task as closed
  unless `ψ/outbox/` or recent commits say otherwise.

## How to update this file

Replace "Current state" and "Next safe action" above whenever you're about to
lose session context (interruption, `/clear`, handoff to a peer) with: what was
found, why the chosen route was picked, what failed, evidence (commit/file
refs), and the concrete next step. Keep it short — this is a pointer, not a diary;
full detail belongs in `ψ/memory/retrospectives/` or `ψ/outbox/`.

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
