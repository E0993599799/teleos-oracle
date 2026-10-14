# REA (rea-agents) Quick Reference

Source: `morluto/rea` at package version 6.4.0 (`package.json:4`). Every claim below cites a file under the source repo. Items not confirmed from the files listed here are marked "not verified".

## What it does

- REA ("Reverse Engineer Anything") is a local MCP server plus CLI for reverse-engineering binaries, applications and runtime behavior. Your agent calls it through MCP; the same workflows are available from the terminal (`README.md:50-52`, `README.md:137-140`).
- Analysis runs locally. Tool results go to your agent, and the model provider has its own data policy (`README.md:279-283`).
- Targets it covers (table at `README.md:153-176`), with the required external tool for each:
  - Native binaries: needs Hopper, Ghidra or IDA.
  - JavaScript / Electron, .NET assemblies, Flutter APK parsing, Go binaries, SQLite, EVM bytecode, WASM, packet captures: no native engine needed for the static parts (`README.md:178-180`, `README.md:243-244`).
  - Websites (Chrome-family browser), Android APKs (JADX + JDK), Android devices (adb), firmware (Binwalk/Unblob), process capture (Linux/macOS PTY). See the table for per-target requirements.
- Static JavaScript and .NET inspection read files without running the app. Runtime capture runs or interacts with the target under your user permissions (`README.md:178-180`).

## Requirements

- Node.js `^22.19.0 || ^24.11.0 || >=26.0.0` (`package.json:40-42`; `README.md:150`). `install.sh` enforces the same floor (`install.sh:116-122`, `install.sh:55-66`).
- npm (`install.sh:114`).
- `curl` for the install script (`install.sh:112`).
- Host OS for `install.sh`: macOS or Linux only; it stops with "REA supports macOS and selected 64-bit Linux distributions" otherwise (`install.sh:110-111`). Windows-specific pieces exist in the package (`package.json:76-78`) but the install script does not cover Windows.

## Installation methods

| Method | Command | Source |
|---|---|---|
| Agent setup (recommended) | `npx rea-agents setup` | `README.md:24`, `README.md:64-70` |
| Global CLI | `npm install --global rea-agents` then `rea --help` | `README.md:97-102` |
| Bun global | `bun add --global rea-agents` (Bun 1.2.17+ for `rea update`) | `README.md:113-119` |
| Install script | `curl`-piped `install.sh`, flags below | `install.sh:1-2`, `install.sh:70-75` |
| One-off, no install | `npx -y rea-agents@latest <command>` or `bunx rea-agents@latest <command>` | `README.md:91`, `README.md:131-133` |
| Skill only | skills.sh listing; use `npx rea-agents setup` to register the MCP server too | `README.md:260-265` |

Agents supported by setup: Claude Code, Codex, Cursor, Gemini CLI, Grok Build, and others listed in `docs/installation.md#supported-agents` (`README.md:72-73`). Manual MCP registration is covered in `docs/installation.md` (not in this doc's scope).

### install.sh options

Source: `install.sh:68-76` (usage), `install.sh:78-104` (parsing).

- `--version VERSION`: exact semver to install. Also settable via env `REA_VERSION` (`install.sh:18`). Without it, the script resolves the latest GitHub release of `morluto/rea` (`install.sh:127-131`).
- `--dry-run`: prints the install plan and exits without changes (`install.sh:158-161`).
- `--no-setup` or `--no-prompt`: skip the interactive `rea setup` after install (`install.sh:90-93`, `install.sh:170-175`).
- `--verbose`: enables `set -x` (`install.sh:106-108`).
- `--help` / `-h`: usage (`install.sh:98-101`).

Install location: on Linux, `npm install --global --prefix ~/.local`, binary at `~/.local/bin/rea`; on macOS, the npm global prefix (`install.sh:139-147`). The script refuses versions with build metadata (`install.sh:135-137`).

## Usage and commands

Commands shown in the files reviewed:

```bash
npx rea-agents setup                                  # register MCP + install workflow instructions (restart agent after)
npx -y rea-agents@latest analyze-javascript-application /absolute/path/to/app --json   # README.md:91
npm install --global rea-agents && rea --help         # README.md:100-101
rea update                                            # global installs; README.md:116
npx rea-agents@latest setup                           # refresh agent registrations after update; README.md:128
```

- The MCP server is started with `rea mcp` (package script `start`: `node scripts/rea.mjs mcp`, `package.json:130`). `server.json:17-27` registers it as an npm stdio package with `npx` and positional argument `mcp`.
- Bins: `rea` and `rea-agents`, both mapped to `scripts/rea.mjs` (`package.json:36-39`).
- Full command list, provider selection, snapshots and exit codes are in `docs/cli.md`, which is not in this doc's source set. Not verified here.

## Key features

- Multi-target analysis with evidence and limitations attached to each finding (`README.md:52`).
- MCP tool surface plus CLI with the same workflows (`README.md:140`).
- Provider model for native analysis: Hopper, Ghidra, IDA; optional Hopper install after approval (`README.md:54`, `README.md:243-245`).
- Agent-skill instructions installed alongside the MCP registration (`README.md:54`, `README.md:263-265`).
- Built-in MCP metadata for the MCP registry (`server.json`, `package.json:3` `mcpName`).
- Showcases (DX-Ball, Notion, TH04) listed in `README.md:197-222`.

## Configuration

Environment variables named in the files reviewed:

| Variable | Purpose | Source |
|---|---|---|
| `REA_VERSION` | Version to install in `install.sh` | `install.sh:18` |
| `REA_GHIDRA_STARTUP_TIMEOUT_MS` | Raise Ghidra startup deadline for large binaries | `README.md:189-190` |
| `REA_HOPPER_STARTUP_TIMEOUT_MS` | Raise Hopper startup deadline | `README.md:189-190` |
| `REA_JEB_MCP_URL` | Select a caller-started JEB MCP client | `README.md:168` |
| `GHIDRA_INSTALL_DIR` | User-managed Ghidra install path; setup may write it to client config after approval | `SECURITY.md:45-47` |
| `JAVA_HOME` (optional) | User-managed Java path, same approval rule | `SECURITY.md:45-47` |

Other configuration:

- Provider selection: see `docs/cli.md#choose-a-provider` (linked at `README.md:191`; not in this doc's source set).
- Hopper and Ghidra setup: `docs/installation.md#hopper` (`README.md:184-185`).
- Setup writes agent configs with backups of existing configuration; restart the agent afterward (`README.md:68-70`).
- Hopper on macOS may show a first-run dialog (demo or license). Complete it in the same user session before the first operation (`README.md:249-256`).

## Security notes

From `SECURITY.md`:

- Report vulnerabilities privately through the repo's GitHub Security tab, not public issues (`SECURITY.md:9-13`).
- Security fixes apply to the latest published version only (`SECURITY.md:3-5`).
- Bridges to Hopper and Ghidra use per-session random capability tokens over current-user Unix sockets (POSIX) or authenticated loopback TCP with a private NTFS runtime (Windows Ghidra) (`SECURITY.md:27-32`).
- REA is not a sandbox. Opening an untrusted binary runs parsing and analysis in the selected provider with your user permissions (`SECURITY.md:33-36`). Ghidra temp projects are deleted on session close, but Ghidra is not sandboxed either (`SECURITY.md:38-43`).
- On Linux, Hopper package downloads are HTTPS-only, origin-restricted, size-bounded, and checked against Hopper's SHA-1. The SHA-1 is a corruption check, not a signature (`SECURITY.md:49-50`).
- Dependency installs go through `apt-get`, `dnf` or `pacman`, directly or via `pkexec`. REA never invokes `sudo` (`SECURITY.md:50`).
- REA does not download or modify Ghidra or Java (`SECURITY.md:45-48`).

## License

- MIT, "Copyright (c) 2026 morluto" (`LICENSE:1-21`; `package.json:6`).
- REA-authored code is MIT. Third-party material keeps its own licenses; see `THIRD_PARTY_NOTICES.md` (`README.md:357-364`).
- Commercial tools (IDA Pro / Hex-Rays, Hopper, JEB) must be legally obtained by you. REA grants no license, key or activation entitlement. Cracked copies, stolen keys and license bypass are not authorized (`README.md:366-372`; `DISCLAIMER.md:80-86`).

## Disclaimers a user should know

From `DISCLAIMER.md`:

- **Intended use**: lawful analysis only. Excluded uses include DRM or license-check circumvention, game cheats, bypassing access controls on systems you are not authorized to test, copying proprietary software, evading AI provider usage policies, and reselling AI access (`DISCLAIMER.md:3-19`). Requests for these are closed without response (`DISCLAIMER.md:26-27`).
- **User responsibility**: you are responsible for authorization, legal compliance and for any commands or agent-generated actions you direct (`DISCLAIMER.md:29-43`).
- **Runtime effects**: running, attaching, intercepting, or interacting with a target can change application state, files, accounts, devices or services. Authorization to inspect does not imply authorization to execute or intercept. Use an isolated environment for untrusted targets (`DISCLAIMER.md:45-59`).
- **Output accuracy**: decompilation and AI-assisted results may be incomplete or wrong; verify consequential conclusions (`DISCLAIMER.md:61-66`). Generated output does not grant rights to the original program (`DISCLAIMER.md:68-71`).
- **Warranty**: AS IS, per the MIT license (`DISCLAIMER.md:88-95`).
- **No endorsement**: mentions of NSA or vendors do not imply endorsement (`DISCLAIMER.md:106-113`).

## Other notes

- Node version floors in README, package.json and install.sh are kept in sync by comment (`install.sh:53-54`).
- Dev and verification scripts are numerous in `package.json:95-290`. Only install-relevant ones are summarized above.
- Discord and issue links: `README.md:16`, `README.md:304-305`.
