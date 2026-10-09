---
pattern: "When hunting for \"which automated process is causing X,\" enumerate every plausible binary/interpreter in the first search pass, not iteratively per round — narrowing to the first culprit's shell flavor costs a full extra investigation cycle."
date: 2026-10-08
source: "rrr: teleos-oracle"
concepts: ["diagnostics", "process-investigation", "scope-enumeration", "windows-scheduled-tasks"]
---

# Enumerate every plausible binary up front, not iteratively

While fixing recurring popup terminal windows, two Scheduled Tasks using
`powershell.exe`/`wsl.exe` were found and fixed first. The user reported popups
still happening twice more before a screenshot revealed the real remaining
culprit used `pwsh.exe` (PowerShell 7) — a different binary never grepped for
because the investigation had implicitly anchored on "whatever shell the first
culprit used."

The fix: when searching a system for "what's producing symptom X," the first
search pass should enumerate the full plausible set of mechanisms (here: every
shell/interpreter binary a Scheduled Task's Action could invoke —
`powershell.exe`, `pwsh.exe`, `cmd.exe`, `wscript.exe`/`cscript.exe`) rather
than searching for one and expanding only after a fix proves incomplete. A
single broader grep at the start costs almost nothing; each later expansion
costs a full round of user back-and-forth.

A related, compounding lesson from the same session: a diagnostic script that
repeatedly re-invokes an external process to sample system state can become
the dominant source of the very signal it's hunting for (a polling loop's own
`powershell.exe`+`conhost.exe` spawns were briefly mistaken for the real
recurring popup). Prefer one long-lived, self-contained sampling process over
a shell loop of repeated external invocations when investigating "what's
creating new processes."
