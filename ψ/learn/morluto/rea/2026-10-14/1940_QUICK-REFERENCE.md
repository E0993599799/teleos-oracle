# REA (rea-agents 6.5.0): Quick Reference

Source: `morluto/rea` at HEAD `3b79af28e`, package `rea-agents` 6.5.0.
Citations are `file:line` relative to the source root. Full reads:
`docs/installation.md` (1138 lines), `docs/cli.md` (339 lines), `README.md`
(394 lines). Other `docs/` files were read by heading and first paragraph only.

## 1. What it is

REA is a local tool that exposes binary, application and runtime inspection
through a stdio MCP server (`rea mcp`) and a CLI (`rea <command>`). Both use the
same workflows and return Evidence with limitations (README.md:61-63;
cli.md:3-5). Static JavaScript and .NET inspection need no native engine.
Native binary analysis needs an existing Hopper, Ghidra or IDA install
(README.md:65).

Binaries `rea` and `rea-agents` both map to `scripts/rea.mjs` (package.json:40-43).
Node engines: `^22.19.0 || ^24.11.0 || >=26.0.0` (package.json:44-46;
installation.md:1103). Node 23, 25 and prereleases are unsupported (installation.md:1103).

## 2. Installation methods

| Method | Command | Source |
|---|---|---|
| Guided setup (recommended) | `npx rea-agents setup` | README.md:80-82; installation.md:14-18 |
| Pinned one-off run | `npx -y rea-agents@latest <command>` | README.md:107; cli.md:12-14 |
| Bun equivalent | `bunx rea-agents setup` / `bunx rea-agents@latest` | installation.md:1096-1098 |
| Global npm | `npm install --global rea-agents` | README.md:116; installation.md:1117-1121 |
| Global Bun | `bun add --global rea-agents` (update needs Bun 1.2.17+) | README.md:129-135 |
| Curl wrapper (global npm only) | `curl -fsSL https://raw.githubusercontent.com/morluto/rea/main/install.sh \| bash` | installation.md:1123-1127 |
| Curl options | `... \| bash -s -- --dry-run` (also `--version`, `--no-setup`, `--no-prompt`, `--verbose`) | installation.md:1131-1138 |
| Skill only (no MCP, no engines) | `npx skills add morluto/rea --skill reverse-engineer-anything` | installation.md:422-426 |
| MCP Registry | search `io.github.morluto/rea`, pick the npm package | installation.md:1039-1047 |
| Manual MCP JSON | `"command": "npx", "args": ["-y", "rea-agents@6.5.0", "mcp"]` | installation.md:1049-1062 |
| Rollback | `npm exec --yes --package=rea-agents@2.4.0 -- rea setup` | installation.md:1086-1089 |

- A non-global `npm install rea-agents` puts `rea` only in `node_modules/.bin`
  (installation.md:1117-1119).
- Registrations are pinned to the version that ran setup; `@latest` selects the
  npm release, and newer `main` instructions do not update a running server
  (installation.md:392-395).
- The curl wrapper accepts only Darwin and Linux (install.sh:113), requires a
  readable Node version (install.sh:118-123), installs with `--prefix "$HOME/.local"`
  on Linux (install.sh:142-145), and checks the installed version (install.sh:168-170).
  `--version` must be an exact semver without build metadata (install.sh:127-138).

### Per-OS notes

**macOS**
- Hopper: approved setup downloads the official DMG, checks size and digest, and
  installs `~/Applications/Hopper Disassembler.app`; no Homebrew or admin access
  (installation.md:511-515). Launcher search order: system app, `~/Applications`
  copy, then other `Hopper*.app` (installation.md:581-584). Override with
  `HOPPER_LAUNCHER_PATH` (installation.md:591-596).
- Apple Events: allow the launching app under Privacy & Security → Automation
  (installation.md:604-607).
- Saved Hopper `.hop` databases are declined on macOS; analyze the original
  executable instead (installation.md:527-532).
- Ghidra JDK must be native, not Rosetta-emulated (installation.md:721-724).
  Native decompiler may need a manual build: x64 at installation.md:849-873,
  arm64 at installation.md:875-900.
- CI needs Hopper's first-run dialog completed in the same user session
  (installation.md:702-705).

**Linux**
- A procps-compatible `ps` on `PATH` is required for owned-process checks used by
  Ghidra, JADX, firmware tools and static JS/Electron analysis (installation.md:333-346;
  README.md:71-74).
- Hopper automated install: Ubuntu 24.04+, Fedora 41+, Nobara 44+, 64-bit Arch,
  CachyOS, Omarchy (installation.md:504-507). Setup verifies the official `.deb`,
  `.rpm` or Arch package and runs the demo on a private Xvfb display
  (installation.md:541-545). Unattended package installs need `--yes --install-hopper`
  (installation.md:545-546). Demo needs Xvfb, Python 3, X11 and XTEST (installation.md:623-625).
- Missing libraries for a launcher: `ldd <launcher> | grep 'not found'` (installation.md:617-621).
- Ghidra: Linux x64/arm64; ARM64 needs the `linux_arm_64` native decompiler
  (installation.md:716; 728-730).

**Windows (native)**
- No curl installer (install.sh:113). Use `npx rea-agents setup` or a global npm
  install from PowerShell.
- Setup wraps package-runner commands in `cmd.exe /d /c` (installation.md:1098-1100).
- Hopper is unavailable on Windows (installation.md:781). Setup never installs
  Ghidra, Java or Python (installation.md:781-782).
- Ghidra: experimental x64 P0, read-only. Admits x86 and x86-64 PE, plus explicit
  raw NMOS 6502 images on fixed local NTFS; other raw CPUs are unsupported
  (installation.md:717; 751-754). Set `GHIDRA_INSTALL_DIR` and `JAVA_HOME` in
  PowerShell (installation.md:769-776).
- Historical source import returns `unsupported_host` on native Windows; use WSL
  (cli.md:286-288).

## 3. Provider and engine prerequisites

| Target / engine | Requirement | Source |
|---|---|---|
| Hopper | Commercial, own license; demo optional | installation.md:500-502 |
| Ghidra | Install of 12.1.x; 64-bit full JDK 21+ within `application.java.min/max`; native decompiler for host arch | installation.md:716-735 |
| IDA | Existing IDA MCP server; optional native bridge (IDA Pro/Free) | ida-provider.md:5 |
| JADX (Android) | Headless JADX jar 0.7.1 and full JDK | android-analysis.md:58; README.md:183 |
| Apktool | 2.7.0+ launcher | apktool-resource-analysis.md:11, 17 |
| adb | Platform-tools adb (verified 34.0.5) | adb-device-analysis.md:16, 21 |
| JEB | Bring-your-own; REA never installs or launches it | jeb-analysis.md:9 |
| Binwalk 3.1.x / Unblob 26.6.x | Linux; caller-supplied | firmware-analysis.md:4-7, 21-22 |
| Wakaru ^1.13.0 | Linux x64 | javascript-recovery.md:10 |
| WABT 1.0.42 | `REA_WABT_BIN_DIRECTORY` | wasm-artifacts.md:21 |
| pwntools | Caller-supplied venv (Linux x64) | recorded-crashes.md:10; README.md:172 |
| TShark 4.x, capinfos, prlimit | Linux packet tools | packet-captures.md:16; README.md:189-190 |
| sigrok-cli 0.7.2 | Linux | signal-recordings.md:12; README.md:191 |
| Chrome-family browser | `REA_BROWSER_EXECUTABLE` | web-runtime.md:55; README.md:180 |
| GNU objdump, GDB, Rizin | Caller-supplied; REA does not install or update them | reverse-engineering-tools.md:3-4, 79 |
| Frida | Optional Node binding, loaded only when a Frida op runs | frida-instrumentation.md:11 |

REA itself installs nothing else. Setup can install Hopper only after approval
(installation.md:65).

## 4. Setup flags and MCP client configuration

```bash
npx rea-agents setup                                   # interactive; approve the plan first
rea setup --client codex --client cursor --skill=false --dry-run
rea setup --yes --all-detected --install-hopper --json
rea setup --skill-client claude_code --yes --json      # refresh skill only
```

- `--client <id>` (repeatable) skips the picker; `--all-detected` covers every
  detected client (installation.md:87-89). `--yes` without a scope only touches
  existing REA registrations (installation.md:107-110).
- `--skill=false` omits the bundled workflow (installation.md:39-40, 89-90).
- `--dry-run` returns `planned`, exit 0 (installation.md:90-91; cli.md:328).
- `--json` returns the plan and a doctor projection without applying (installation.md:104-106).
- `--accessible` and `NO_COLOR=1` for prompts (installation.md:97-100).
- Writes preserve unrelated entries, create backups, replace atomically and verify
  (installation.md:58-65). Valid env overrides in the server entry are kept
  (installation.md:66-68).
- Client IDs (installation.md:457-482): `claude_code`, `claude_desktop`, `codex`,
  `cursor`, `gemini_cli`, `windsurf`, `devin`, `opencode`, `antigravity`,
  `copilot_cli`, `commandcode`, `qwen_code`, `kimi`, `vscode`, `grok_build`, `omp`,
  `pi`, `hermes`, `qoder`, `droid`, `trae`, `workbuddy`, `zcode`, `dsh`.
  `dsh`, `kimi`, `workbuddy` need a release that contains them (installation.md:484-485).
  Grok Bot is a manual hosted connector (installation.md:454-455).

Profiles and scope (installation.md:152-294):
- Default Claude Code setup writes `mcpServers.rea` to `~/.claude.json` and the
  skill to `~/.claude/skills`, visible to every project (installation.md:154-156).
- Separate profile: `CLAUDE_CONFIG_DIR=~/.claude-rea npx rea-agents setup --client claude_code`
  (installation.md:182-185). Use the same prefix for every later check or removal.
- One project: `claude mcp add --scope local rea -- npx -y rea-agents@6.5.0 mcp`
  (installation.md:257-263). Avoid `--scope project` (installation.md:276-277).
  `rea update` and `rea uninstall` do not manage local-scope entries (installation.md:277-280).
- Scope limits discovery only: shell, filesystem and network stay available to
  agents under the same OS account (installation.md:159-166).

Client specifics (client-configuration.md):
- Claude Code with a non-first-party `ANTHROPIC_BASE_URL` disables tool search;
  the 172-tool catalog then costs about 496 KB by default and 290 KB with `compact`.
  Remedy: `"REA_MCP_INPUT_SCHEMA_PROFILE": "compact"` in the `env` of `mcpServers.rea`
  (Claude Code section). Clients whose stdio reader rejects the catalog frame can
  set `"REA_MCP_OUTPUT_SCHEMA_PROFILE": "off"` (Claude Code section; mcp-contracts.md:681-685).
- Claude Desktop: macOS `~/Library/Application Support/Claude`; Linux
  `$XDG_CONFIG_HOME/Claude`; Windows may use the MSIX-private copy under
  `%LOCALAPPDATA%\Packages` (Claude Desktop section). Quit the app fully before approving setup (installation.md:23-25).
- Copilot CLI, DeepSeek Harness, OpenCode, Grok Build, others: client-configuration.md
  sections at lines 15, 313 and 363.

## 5. CLI command families

Canonical names are in `src/cliCommandNames.ts` (about 150 entries). Use
`rea --help` for arguments (cli.md:115-116).

```bash
# Setup and maintenance
rea doctor --json                          # installation.md:296-331
rea doctor --client codex --json           # one registration
rea doctor --skill --json                  # installed skill
rea doctor --provider ghidra --json        # one engine (cli.md:156-158)
rea mcp doctor --json                      # MCP child startup (cli.md:308-314)
rea update ; rea uninstall [--purge-data]  # installation.md:348-365

# Static JavaScript / Electron (no engine)
npx -y rea-agents@latest analyze-javascript-application /abs/app --json > app.json
rea inspect-analysis-view app-view.json    # summary or page views (cli.md:27-35)

# .NET, SQLite, Go, Rust (no engine)
rea inspect-managed-artifact Assembly.dll --json        # cli.md:48
rea inspect-managed-members Assembly.dll --type Example.Parser --json   # cli.md:50
rea inspect-sqlite-database app.db --table NAME --row-limit 20 --json   # cli.md:67-68
rea inspect-go-binary ./prog --json                     # cli.md:79
rea inspect-rust-binary ./prog --json                   # cli.md:90

# Native (needs a provider)
rea analyze   /abs/prog --provider ghidra --json        # cli.md:103
rea search    /abs/prog "text" --provider ghidra --json # cli.md:104
rea function  /abs/prog main --provider ghidra --json   # cli.md:105
rea decompile /abs/prog 0x1000 --provider ghidra --json # cli.md:106
rea xrefs     /abs/prog 0x1000 --provider ghidra --json # cli.md:107
rea trace     /abs/prog "text" --provider ghidra --json # cli.md:108
rea providers --json ; rea capabilities --json          # cli.md:126-129

# Snapshots and Evidence
rea analyze /abs/prog --provider ghidra --snapshot /abs/analysis/prog.json   # cli.md:187-191
rea evidence-import|evidence-export|compare ...          # cli.md:215-219

# Historical source
rea import-reference-source /abs/src --detail summary --outline-depth 2 --json  # cli.md:232-233
```

- `analyze` and `inspect` share the overview; `function` gives a dossier;
  `decompile` gives pseudocode; `instructions` gives assembly only (cli.md:111-113).
- Provider choice: automatic when one provider fits; otherwise `--provider`,
  `REA_ANALYSIS_PROVIDER`, or `provider_id` in MCP `open_binary` (cli.md:135-150).
- Snapshot reuse is exact-match on bytes, operation, parameters, provider and
  settings; mutations and cursor-dependent calls are never cached (cli.md:170-175).
  A metadata write invalidates the session cache even if its reply fails (cli.md:177-179).
- Runtime capture guides (browser, Electron, Node/Electron Inspector, process
  capture) are listed at cli.md:294-304.
- Other offline families from `src/cliCommandNames.ts`: `inspect-artifact`,
  `extract-artifact`, `inspect-binary-layout`, `inspect-firmware-regions`,
  `extract-firmware`, `inspect-pcap-capture`, `identify-flutter-build`,
  `inspect-apktool-client`, `decode-android-resources`, `inspect-adb-device`,
  `inspect-wasm-artifact`, `inspect-evm-interface`, `inspect-recorded-crash`,
  `list-frida-devices`, `instrument-with-frida`.
- Exit codes: `0` completed (may include partial evidence); `1` could not
  complete; `128+N` signal N (cli.md:322-326). Setup exits `1` for
  `needs_confirmation` or `needs_human`; doctor exits `1` only for failing
  required checks in its scope (cli.md:328-331).
- Output is TOON by default; use `--json` for scripts. Use `set -o pipefail` before `jq` (cli.md:316-339).

## 6. MCP server

- Launch: stdio `rea mcp`, registered as `npx -y rea-agents@<ver> mcp` or
  `bunx rea-agents@<ver> mcp` (installation.md:1096-1101).
- Call `binary_session` with `{}` first; it works before any target and reports
  per-operation availability (installation.md:303-310).
- `open_binary` accepts `provider_id`, and `snapshot_path` to import a snapshot
  (cli.md:143-150; 196-200). `close_binary` accepts `snapshot_path` and
  `overwrite: true` (cli.md:196-200).
- `cleanup_incomplete` marks resources whose shutdown could not be verified
  (cli.md:163-168).

## 7. Configuration and environment variables

Set these in the environment that starts the CLI or MCP server; changing a shell
later does not reconfigure a running server or JVM (installation.md:966-967).

| Variable | Purpose | Source |
|---|---|---|
| `REA_ANALYSIS_PROVIDER` | Standing provider preference; `--provider` overrides | cli.md:142 |
| `REA_HOPPER_STARTUP_TIMEOUT_MS` | Hopper deadline; default 120000 ms | installation.md:598-602; mcp-contracts.md:518 |
| `REA_GHIDRA_STARTUP_TIMEOUT_MS` | Ghidra import/analysis deadline; default 330000 ms | installation.md:826-831; mcp-contracts.md:519 |
| `GHIDRA_INSTALL_DIR` | Ghidra root; PATH discovery if unset | installation.md:760-764; 785-791 |
| `JAVA_HOME` | JDK for Ghidra; optional if `java`/`javac` on PATH | installation.md:764 |
| `GHIDRA_HEADLESS_MAXMEM` / `GHIDRA_MAXMEM` | JVM `-Xmx`; default `2G` | installation.md:944-952 |
| `REA_GHIDRA_LANGUAGE_ID`, `REA_GHIDRA_COMPILER_SPEC_ID` | Language and compiler spec override | installation.md:902-911 |
| `REA_GHIDRA_SEED_FILE` | TSV of function/code/label seeds | installation.md:913-921 |
| `REA_GHIDRA_DISABLED_ANALYZERS` | Exact analyzer names to disable | installation.md:923-942 |
| `REA_SWIFTC_COMPILE_TIMEOUT_MS` | Darwin helper compile timeout; default 120000 | installation.md:1009-1011 |
| `HOPPER_LAUNCHER_PATH` | Explicit Hopper launcher | installation.md:591-596 |
| `REA_MCP_INPUT_SCHEMA_PROFILE` / `REA_MCP_OUTPUT_SCHEMA_PROFILE` | Schema size profiles (`compact`, `off`) | installation.md:66-68; client-configuration.md (Claude Code) |
| `REA_MCP_MAX_RESPONSE_BYTES` | MCP response budget; default 10 MiB | mcp-contracts.md:147; reverse-engineering-tools.md:81 |
| `REA_REFERENCE_SECRET_PATTERNS_JSON` | Ignore patterns marked sensitive during source import | cli.md:275-277 |
| `REA_LOG_LEVEL` | Log level. Not in `docs/`; read in source only | src/cli.ts:59, 81-83 |
| `REA_IDA_MCP_CONFIG` | Upstream IDA MCP registration file | ida-provider.md:36-37 |
| `REA_JEB_MCP_URL` | JEB MCP endpoint; default `http://127.0.0.1:8425/mcp` | jeb-analysis.md:9 |
| `REA_JADX_MCP_JAR`, `REA_APKTOOL_COMMAND`, `REA_ADB_PATH` | Android tool paths | android-analysis.md:58; apktool-resource-analysis.md:17; adb-device-analysis.md:21 |
| `REA_BINWALK_COMMAND`, `REA_UNBLOB_COMMAND` | Firmware tool paths | firmware-analysis.md:21-22 |
| `REA_TSHARK_COMMAND`, `REA_SIGROK_COMMAND`, `REA_WABT_BIN_DIRECTORY` | Packet, signal and WASM tool paths | packet-captures.md:16; signal-recordings.md:12; wasm-artifacts.md:21 |
| `REA_PWNTOOLS_PYTHON` | Python with pwntools | recorded-crashes.md:10 |
| `REA_OBJDUMP_COMMAND`, `REA_GDB_COMMAND`, `REA_RIZIN_COMMAND` | Tool names or paths; else PATH | reverse-engineering-tools.md:79 |
| `REA_BROWSER_EXECUTABLE` | Chrome-family executable | web-runtime.md:55 |

`REA_VERIFY_*`, `REA_AGENT_EVAL_*` and `REA_NATIVEAOT_*` are maintainer lane
settings (testing.md; client-verification.md), not normal-use configuration.

## 8. Doctor and diagnostics

- `rea doctor` is read-only (installation.md:296-301, 348-350). Without options it
  audits every detected registration, the skill and optional engines. The overall
  `healthy` can be false while your task works (installation.md:298-301).
- Scoped runs report `scope.mode: "explicit"`; `scope_checks` decide `healthy` and
  exit status, while `informational_checks` do not (installation.md:321-325).
- Skill fields: `identity.skill.state`, `installed_version`, `installed_tool_count`;
  catalog identity is at `identity.catalog` (installation.md:142-146).
- Linked or non-directory skill paths report `unmanaged`; unreadable identity is `unknown` (installation.md:131-134).
- Failure kinds: `capability_unavailable`, `provider_unavailable`, `execution_failure`;
  `details.selection_reason` distinguishes `ambiguous` (choose from
  `details.candidate_ids`) from `provider_unavailable` (installation.md:326-346; cli.md:156-161).
- Ghidra doctor checks platform, arch, Ghidra 12.1.x, `analyzeHeadless`, Java range,
  64-bit JDK, `javac`, and the JVM `os.arch`/`os.name` (installation.md:793-800).
- Hopper doctor reports launch strategy and mount facts (installation.md:549-551).

## 9. Platform support matrix and verification caveats

### 9.1 CI runners (testing.md:1040-1046)

| Host | Runner | Baseline coverage |
|---|---|---|
| Linux x64 | `ubuntu-latest` | Installed package, real Node Inspector CLI/MCP |
| Linux arm64 | `ubuntu-24.04-arm` | Same |
| macOS 15 arm64 | `macos-15` | Same |
| macOS 15 x64 | `macos-15-intel` | Same; hourly, dispatch, release and `ci:full` only |
| Windows x64 | `windows-latest` | Curated capabilities, native controls, installed package, Inspector |

CI tests Node.js only (installation.md:1113-1115). Ghidra verification lanes
need a host C compiler, Ghidra 12.1.4 and full JDK 21 (testing.md:450-457).

### 9.2 Per-capability hosts documented

| Capability | Documented hosts | Source |
|---|---|---|
| Hopper | macOS 12+; listed Linux distros (auto); other Linux with existing launcher; Windows unavailable | installation.md:504-508, 781 |
| Ghidra | Linux x64/arm64, macOS x64/arm64 | installation.md:716-717 |
| Ghidra Windows P0 | Windows x64, read-only | installation.md:717; windows-ghidra-p0.md |
| Firmware, Wakaru, packets, signals | Linux (Linux x64 for Binwalk/Unblob and Wakaru) | firmware-analysis.md:7; javascript-recovery.md:10; README.md:189-191 |
| Process capture | Linux and macOS with native PTY | README.md:193 |
| Static .NET, Flutter, SQLite, Go, Rust | Platform-independent reads | README.md:173-187 |

### 9.3 Verification caveats recorded in the docs

- The npm release checked on 2026-10-11 was 6.4.0. That check does not establish
  6.5.0 publication or live DeepSeek integration; `dsh` is absent from 6.4.0
  (installation.md:397-403).
- Ghidra bridge verified with 12.1.4 and JDK 21 (installation.md:726). macOS arm64
  native decompiler build verified on macOS 15.6 with Apple clang 17 (installation.md:893-897).
- A 512 MiB Java heap was verified only with small native fixtures (installation.md:966-968).
- Ghidra DOS on macOS x64: unverified (ghidra-dos.md:160). IDA: Linux x64 with
  IDA Free 9.4 and Windows x64 with IDA Pro 9.3; macOS x64 unverified (testing.md:806, 817).
- Hopper lanes verified on Hopper 6.1.0-demo (client-verification.md:361).
- Packet analysis on Windows/Bun: Wireshark execution unverified (pcap-analysis.md:109).
- Copilot CLI live model API and Windows unverified (client-configuration.md:34).
  Claude Code with DeepSeek API unverified (client-configuration.md:130).
- Client acceptance is recorded only where stated (client-configuration.md:5-7).
- Stale version pointers: `windows-ghidra-p0.md:3-8` cites npm 4.1.0 and 5.0.0;
  the package is 6.5.0 (package.json:4). Check installation.md:390-420 first.
- Bun: `rea doctor` passes on the declared Node compatibility version; CI does not test Bun
  (installation.md:1105-1115).

## 10. Documentation inventory (docs/)

Read in full: `installation.md`, `cli.md`. Other entries were read by heading and
first paragraph. Counts are from `find docs -type f` (99 files).

| Group | Files and one-line purpose |
|---|---|
| Install and clients | `installation.md` setup and maintenance; `client-configuration.md` per-client paths and limits; `client-verification.md` optional client lanes; `migration-6.2.md` 6.1→6.2 upgrade notes |
| Project and release | `testing.md` test lanes and CI matrix (1387 lines); `releasing.md` Release Please and publish gates; `roadmap.md` planned work; `index.md` docs landing page; `releases/6.4.0.contributions.json`, `releases/6.5.0.contributions.json` release records |
| CLI and MCP contracts | `cli.md` commands, providers, snapshots, exit codes; `mcp-contracts.md` results, sessions, deadlines, generated catalog (788 lines); `mcp-prompts.md` six guided prompts; `tool-design.md` tool design rules; `error-contract.schema.json` error schema; `user-visible-errors.csv` error catalog; `architecture.mermaid` project map; `browser-scenario-contract.md` browser action contract |
| Native engines | `native-investigation.md` native workflow; `ghidra-provider.md` Ghidra semantics and cleanup; `ghidra-dos.md` DOS MZ/COM; `ghidra-mips.md` MIPS ELF; `ghidra-ppc.md` big-endian PowerPC; `ghidra-psp.md` PSP ELF; `ghidra-riscv.md` RISC-V ELF; `ghidra-nativeaot.md` NativeAOT metadata; `windows-ghidra-p0.md` Windows P0; `raw-binary.md` headerless images; `ida-provider.md` IDA MCP adapter; `reverse-engineering-tools.md` objdump, GDB, Rizin; `binary-diagnostics.md` offline ELF layout; `go-binaries.md`, `rust-binaries.md` embedded build metadata; `recorded-crashes.md` Linux core evidence; `evm-bytecode.md` EVM selectors; `wasm-artifacts.md` WASM via WABT; `sqlite-databases.md` SQLite snapshots; `harmony-analysis.md` HarmonyOS packages; `apple-application-analysis.md` Apple inventory projection |
| Managed, mobile, device, firmware | `managed-code-analysis.md` .NET metadata and CIL; `android-analysis.md` APK via JADX; `apktool-resource-analysis.md` Android resources; `adb-device-analysis.md` devices, packages, transfers; `flutter-analysis.md` Flutter build facts; `jeb-analysis.md` JEB MCP bridge; `firmware-analysis.md` Binwalk and Unblob; `frida-instrumentation.md` Frida sessions and scripts |
| JavaScript, Electron, web | `javascript-application-graph.md` JS domain model; `javascript-application-workflows.md` traces and comparisons; `javascript-artifact-reconstruction.md` directory and ASAR inspection (640 lines); `javascript-recovery.md` Wakaru module recovery; `javascript-runtime-observation.md` passive Inspector observation; `javascript-runtime-reconciliation.md` static/runtime merge; `electron-fuses.md` fuse bytes; `electron-observation.md` file:// renderer pages; `browser-observation.md` CDP page inspection; `browser-scenario-contract.md` declared interactions; `web-runtime.md` source attribution and V8 coverage; `web-source-location.md` captured source locations; `website-module-trace.md` ES import graph; `website-script-export.md` captured scripts; `web-network-captures.md` HAR, SAZ, mitmdump; `http3-capture-lab.md` HTTP/3 capture lab |
| Process, packets, signals | `process-capture.md` run and compare commands (497 lines); `packet-captures.md` TShark field extraction; `pcap-analysis.md` capture summaries; `signal-recordings.md` sigrok decoding |
| Reconstruction | `reconstruction-readiness.md` conformance run; `reconstruction-obligation-ledgers.md` claim ledgers |
| Localized and assets | `readme/README_*.md` (19 translations); `assets/` (three images); `specs/` (`2356-wasm-interface-comparison/`, `solidity/`) |

## 11. Gaps in this reference

- No single cross-platform support table exists in `docs/`; section 9 is assembled
  from the CI table and per-guide hosts.
- Most non-installation docs were read only by heading and first paragraph.
- `docs/readme/` translations were not compared to the English README.
- No `rea` command was executed. Every statement comes from the cited files.
