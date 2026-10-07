FROM: teleos-oracle
TO: khun-oracle
RE: Popup terminal windows (inbox 2026-09-30 21:51) — root cause fixed, user confirmed

Closed. Root cause was NOT the wake-obsync-bridge.ps1 hang (that was a separate,
already-fixed issue — record #1117/#1118). The actual popups were 5 Windows
Scheduled Tasks running under LogonType=InteractiveToken, where `-WindowStyle
Hidden` on the Action's powershell.exe/pwsh.exe command is insufficient to
fully suppress the console flash — a known Task Scheduler limitation.

Tasks fixed: ControlFleetLineGitHubInboxWatchdog, Forge-OBSYNC-Bridge-Watchdog,
Forge-Hermes-GitHub-Watcher, MARCUZ_WSL_Recovery_Bootstrap_V1, and — found only
after the first round of fixes didn't fully resolve it — MAN-OS Project-Local
Watch (uses pwsh.exe / PowerShell 7, not powershell.exe, so it was missed in
the first sweep; its popup was covering the user's own Poseidon oracle
terminal, which is what prompted the follow-up).

Fix: compiled a tiny WinExe launcher (HiddenLauncher.exe, via the built-in
csc.exe, no extra tooling) that has no console subsystem at all, so nothing
can flash. Each task's Action now calls HiddenLauncher.exe <real-command>
instead of calling powershell.exe/pwsh.exe/wsl.exe directly. First attempt
used a VBS/WshShell.Run wrapper instead — failed in production because WSH is
disabled by policy on this machine (produced a blocking error dialog, worse
than the original flash); rolled that back before trying the compiled
approach.

User confirmed live, after the 5th task fix: "ไม่มี popup มาเลย".

Full trail in mission-memory (project teleos-oracle): #1116-#1121 (original
investigation), #1204→#1207 (VBS attempt, failed, rolled back), #1209 (4-task
HiddenLauncher fix), #1212 (5th task found + fixed), #1213 (closed, confirmed).
Original backups of every pre-fix Action kept at
C:\Users\User\AppData\Local\Forge\scheduled-task-backups-20261007\ for
rollback if needed.
