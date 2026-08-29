# Handoff: Vercel deploy investigation, fleet checks, and maw fixed for this host

**Date**: 2026-08-27 10:25
📡 Session: b056ea61 | teleos-oracle | ~1h22m

## Context
**Oracle**: Teleos Oracle | **Human**: พี่เอก (he/him)
**Memory**: auto

## What We Did
- Checked all 14 other `royal-master-oracle/*` fleet oracles for the stale Supabase-skills-install
  pattern from the earlier segment — none affected
- Checked `aris-oracle` (broken cross-platform symlinks, informational only, left alone) and
  `serra-oracle` (in-progress uncommitted Zeus→Khun reporting-target rename in `CLAUDE.md`, left
  for its own session) at Boss's request
- Investigated Vercel deploy status for the `mission-control` project (team `omega--project`):
  traced two intermittent `ERROR` builds (`next: command not found`) to a root cause in the
  monorepo root — a stray leftover `next.config.js` plus three competing lockfiles
  (`pnpm-lock.yaml`, `bun.lock`, `package-lock.json` in `control_fleet`) causing Vercel to try
  `next build` at a root where `next` was never a declared dependency. Confirmed `control_fleet`
  itself is unrelated (plain Node webhook, no Next.js, no matching CI workflow)
- Read `PROJECT_REGISTRY.md` (mission-control root) — found it 23 days stale (generated
  2026-08-04); flagged that the whole `royal-master-oracle/*` fleet mis-shows as "cloud-only, no
  local checkout" and that `control_fleet`'s recorded `DETACHED` HEAD state is outdated
- Wrote a findings report to `khun-oracle/ψ/inbox/` (Vercel root cause + registry staleness) —
  written directly since `maw` wasn't reachable from this native-Windows session yet at the time
- Fixed that gap: built a `wsl.exe`-proxy wrapper at `C:\Users\User\.local\bin\maw` so this and
  future native-Windows sessions on this machine can call `maw` directly. Caught and fixed a
  `printf` format-string-recycling bug in the wrapper before trusting it (see lesson learned)
- Ran `maw doctor` (3 issues found) → started `maw serve` (PID 28677, `:3456`) → installed the
  one real fleet plugin found (`arra-oracle-v3/maw-plugin` → `arra@1.0.0`) → doctor now shows only
  1 remaining issue (`maw-js` legacy check, likely moot)
- Ran `/rrr` mid-session — wrote a second retrospective + lesson (printf recycling bug) +
  metrics row

## Pending
- [ ] none — nothing outstanding from this session specifically

## Next Session
- [ ] (Not requested, optional) `maw serve` is running under a WSL process (PID 28677) but has no
      persistence/service setup — will need manual restart after a WSL/machine reboot if that
      matters
- [ ] (Not requested, optional) `maw doctor`'s one remaining issue (`maw-js: checkout not found
      under GHQ_ROOT`) — likely a moot legacy check now that the fleet is on maw-rs, left
      unaddressed
- [ ] (Not requested, optional) The Vercel `mission-control` project misconfiguration was reported
      to `khun-oracle` but not fixed — ownership intentionally left to whoever owns that project

## Key Files
- `D:\...\teleos-oracle\ψ\memory\retrospectives\2026-08\27\10.06_commit-supabase-skills-install.md`
- `D:\...\teleos-oracle\ψ\memory\retrospectives\2026-08\27\10.18_vercel-investigation-and-maw-fleet-fix.md`
- `D:\...\teleos-oracle\ψ\memory\learnings\2026-08-27_python-vs-python3-windows-gitbash.md`
- `D:\...\teleos-oracle\ψ\memory\learnings\2026-08-27_printf-format-string-recycling.md`
- `D:\...\khun-oracle\ψ\inbox\2026-08-27_10-06_teleos_mission-control-vercel-project-misconfigured.md`
- `C:\Users\User\.local\bin\maw` (new WSL-proxy wrapper, now on this session's PATH)
