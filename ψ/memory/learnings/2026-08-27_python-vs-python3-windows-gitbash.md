---
pattern: On Windows/Git-Bash, use `python` not `python3` — python3 resolves to the Microsoft Store app-execution-alias stub even when a real interpreter exists; also convert /c/... paths to C:\... before handing them to native Windows Python
date: 2026-08-27
source: rrr: teleos-oracle
concepts: [windows, git-bash, python, path-translation, tooling]
---

# python vs python3 on Windows/Git-Bash

On this machine, `python3` resolves to `/c/Users/User/AppData/Local/Microsoft/WindowsApps/python3`
— a Windows App Execution Alias stub that prints "Python was not found; run without
arguments to install from the Microsoft Store" and exits non-zero. The real interpreter
(3.11.15) is reachable as plain `python`.

Separately, a path gathered inside Git Bash in MSYS form (`/c/Users/User/...`) is not
resolvable by a native Windows-built Python process — `open()` raises `FileNotFoundError`
even though the file demonstrably exists. It must be converted to native Windows form
(`C:\Users\User\...`) first.

**Rule for other Oracles**: before running any one-off Python invocation from a bash tool
on Windows, try `python --version` first, not `python3`. If a script needs to open a path
that bash produced, convert `/c/...` → `C:\...` (or use `cygpath -w` if available) before
passing it to Python.
