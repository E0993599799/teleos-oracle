# rea — Docs Addendum (closes gaps in the first pass)

Read directly by the main agent via `git show HEAD:<path>` at `df3d96da8` (rea-agents 6.4.0).
Read in full or in part as noted; nothing executed. Files read: `docs/cli.md` (first ~220 of the file, 13.8 KB total),
`docs/installation.md` (headings + lines 14-30 and 538-560; 49.6 KB total, rest NOT read),
`docs/windows-ghidra-p0.md` (first 60 lines), `.agents/skills/reverse-engineer-anything/SKILL.md` (first 90 lines),
`.agents/skills/rea-tool-design/SKILL.md` (first 30 lines).

## Correction to 0222_QUICK-REFERENCE.md (Windows)

The quick reference said the Windows story was "partial / unverified". Verified now:
- **Windows is supported, experimentally, for Ghidra only** — "experimental Windows x64 support for the read-only P0 boundary"
  (`docs/windows-ghidra-p0.md`). Needs Windows 10+ x64, fixed local NTFS, Node 22.19+/24.11+/26+,
  operator-installed Ghidra 12.1.x (verified 12.1.4) and a 64-bit full JDK (21+).
- Admits native x86/x86-64 PE apps/DLLs and raw NMOS 6502 images; 25 read-only Ghidra operations; no GUI state, no annotations,
  no Hopper-only operations. Windows native bundle is shipped in the npm package (npm 4.1.0+); x86 32-bit PE is on repository main,
  npm through 5.0.0 admits x86-64 PE only.
- `install.sh` remains macOS/Linux only (from first pass); on Windows use `npx rea-agents setup`. Hopper install is unavailable on Windows.
  Setup wraps `npx`/`bunx` registrations in `cmd.exe /d /c` (`docs/installation.md`, "Package runners" section).
- Windows config (PowerShell): set `GHIDRA_INSTALL_DIR` and `JAVA_HOME`, then `rea doctor --json` and `rea providers --json`.
  REA never installs Ghidra, Java, Python or Node.

## CLI (docs/cli.md)

- Each CLI invocation is a separate process; save results to a file for later commands. Same workflows/Evidence contracts as the MCP server.
- Without install: `npx -y rea-agents@latest analyze-javascript-application /abs/path --json`.
  `rea analyze PATH` picks the JS workflow for directories and `.asar` when no `--provider`/`--snapshot` is given.
- Full Evidence for a real app can be hundreds of MB (a 334 MB Obsidian example → ~10 KB summary view). Pattern: save JSON, project a view with
  `rea inspect-analysis-view` (summary / modules page / one module).
- No-engine commands: `inspect-managed-artifact`, `inspect-managed-members [--type X]` (.NET metadata/CIL, no execution; does not unpack single-file hosts or IL2CPP),
  `inspect-sqlite-database PATH [--table N --row-limit 20]`, `inspect-go-binary`.
- Native commands (need Hopper/Ghidra/IDA): `analyze`, `search`, `function`, `decompile`, `xrefs`, `trace`, `instructions`.
- Provider choice: `rea providers --json`, `rea capabilities --json`; auto-select only if exactly one provider supports the target, else `--provider`;
  `REA_ANALYSIS_PROVIDER` for a standing preference; `rea doctor --provider ID --json` for `provider_unavailable`.
- Snapshots (`--snapshot PATH`): exact-match result reuse (target bytes + operation + params + provider + settings); owner-only permissions;
  metadata writes invalidate the cache. Evidence tools: `evidence-import`, `evidence-export` (no overwrite without `--overwrite`), `compare`, `import-reference-source`.
- Rest of cli.md (after ~line 220) not read.

## Agent skills (.agents/skills/)

- 4 skills at HEAD: `reverse-engineer-anything` (+6 reference files), `rea-tool-design`, `rea-ci-tests-audit`, `rea-changelog-update`.
- `reverse-engineer-anything` routes by target type (ASAR/JS tree → `analyze_javascript_application`; APK → `inspect_android_package`; .NET → `inspect_managed_artifact`;
  firmware → `inspect_firmware_regions`; pcap/HAR/SAZ → inspect_* capture tools). It says to prefer an existing `rea` CLI, fall back to `npx -y rea-agents@latest`,
  not to run setup/diagnostics before every investigation, and to skip REA for ordinary source-repo analysis. Setup never installs Node, Java, Ghidra, IDA, etc.
- `rea-tool-design` defers to `docs/tool-design.md`, `docs/testing.md`, `CONTRIBUTING.md`. Only first 30 lines read.
- Remaining skills and references: NOT read.

## Still not verified
- Rest of `docs/installation.md` (Hopper/Ghidra/IDA setup details, CI), rest of `docs/cli.md`, the ~60 other `docs/*.md` guides, `rea-ci-tests-audit`, `rea-changelog-update`.
- Anything newer than `df3d96da8` (upstream was at `cddf31d55` when checked).
