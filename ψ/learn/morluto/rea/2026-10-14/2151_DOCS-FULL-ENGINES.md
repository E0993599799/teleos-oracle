# morluto/rea - docs engine summaries (full read)

Source: `SOURCE_DIR/docs/` in `morluto/rea` (package rea-agents 6.5.0, HEAD 3b79af28e).
Method: each of the 19 files below was read in full. Claims are limited to what the file states. Cross-references to `installation.md`, `testing.md`, `mcp-contracts.md`, `apple-application-analysis.md`, and `third_party/` READMEs were not followed; statements that depend on them are unverified here.

## docs/ghidra-provider.md

- Path: `SOURCE_DIR/docs/ghidra-provider.md`. Ephemeral Ghidra database per import; Linux/macOS get read-only analysis plus atomic function-name and entry-comment edits; Windows P0 is read-only; executable bytes unchanged.
- Linux launches need a procps-compatible `ps` on `PATH` (stated in the doc).
- Inventory: one `analyzeHeadless` import gives exactly one Program. Strings are only Ghidra-defined string `Data`; absent terminators are named `present_or_not_required` when the API cannot tell present from not-required.
- Addresses: lowercase `0x`; non-default spaces use `<percent-encoded-space>:0x<hex>`. Overview `image_base` is omitted, not zeroed, when the provider does not report one or segments disagree.
- File offsets: `decompile` / `procedure_pseudo_code` accept `--file-offset=0x...` (or `file-offset:0x...` via MCP). Mapping needs a full original `FileBytes` source whose SHA-256 matches the target. The doc gives an ELF example (entry `0x1013` becomes `0x101013` with base `0x100000`) and says "That example is not a general conversion rule."
- Function analysis: one persistent `DecompInterface`, no fixed native deadline. External or bodyless functions return `null` decompilation. `read_function_instructions` skips the decompiler. P-code dossiers are capped at 3,000 operations, 64 inputs per operation, 12,000 def-use edges, and "does not resolve memory aliasing, call side effects, runtime behavior, persistent state, or business meaning."
- Non-Windows import repair clears no-return flags on `malloc`, `__tls_get_addr`, `memcpy`, `memset`, `strlen`, `__errno_location`. The doc says this "relies on their expected ABI behavior; external implementations are not inspected."
- PDB: the handshake reports Ghidra's PDB attributes and `PDB Loaded` state. The doc says a loaded state is "a Ghidra observation, not an independent PDB identity or complete symbol-coverage attestation." PDB strings share a 4096 UTF-16-unit budget.
- Caveats quoted from the doc: "An empty name search does not establish that a function is absent"; string search "does not cover every text sequence in artifact bytes"; "Hopper byte search remains unavailable until its implementation is verified."
- Verification: `npm run verify:ghidra` against "real Ghidra 12.1.4"; `verify:ghidra:cross-format` needs `clang`, LLD and `lld-link`; `verify:ghidra:windows` covers "all 26 read-only operations."
- Masked `search_bytes`: `??` wildcards, optional equal-length mask, inclusive `start`/`end`, pages of 1-1000 with cursor; skips not-loaded and overlay blocks unless bounded explicitly.

## docs/ghidra-dos.md

- Path: `SOURCE_DIR/docs/ghidra-dos.md`. DOS MZ executables and explicitly selected COM images through the Ghidra adapter. Verification lanes: Linux x64 and macOS arm64, Ghidra 12.1.4, JDK 21.
- Commands: `inspect`, `search`, `instructions`, `function`, `inspect-native-load-image`, `read-bytes`, `address-to-file-offset`. COM needs `--target-format dos-com`; the suffix alone does not admit it.
- COM: 1..65280 bytes; `BinaryLoader`; file offset 0 at `1000:0100` (linear `0x10100`); pre-analysis script seeds CS/DS/ES/SS `0x1000`. Load-image verification checks these settings.
- MZ classifier rejects NE, LE and LX declarations as unsupported. PE stays PE.
- Profile commits `function_body_evidence: complete-inclusive-ranges-v1`, so older length-only snapshots do not satisfy it.
- Caveats quoted: "Static decompilation does not execute the target or emulate BIOS, DOS interrupts, device ports, or self-modifying code"; for COM, "PSP memory, initial stack contents/SP, DOS interrupts and PC-98 devices are not modeled"; "macOS x64 DOS verification remains unverified."
- Packed executables: analysis reaches the unpacking stub unless a separately unpacked copy is analyzed. DOS extenders without an MZ real-mode entry are outside the boundary.
- `annotate_native_function` works on COM and MZ with rollback on failure; the doc says it does not save a project or change ABI or body ranges. Windows P0 does not admit it.
- Verification: `npm run verify:ghidra:dos`, using a source-generated fixture at runtime.

## docs/ghidra-mips.md

- Path: `SOURCE_DIR/docs/ghidra-mips.md`. ELF `EM_MIPS` retained as family `mips`. Advances the generic-MIPS part of #718; PSP is separate (#1330). Does not execute MIPS code or rehost firmware.
- Executable lane: ELF32 `ET_EXEC`, LE or BE, explicit o32 and `EF_MIPS_ARCH_32R2`, no machine or ASE encoding flags. ELF64, n32/n64, microMIPS, PSP PRX, and other shared or compressed images are refused (MIPS16 shared has its own profile).
- Recordless legacy admission (#1620): o32 is "an analysis assumption derived from the ELF32/ET_EXEC structure, recorded as `mips_abi_basis` ... never a declared fact; floating-point ABI semantics stay unverified."
- Pinned `-processor MIPS:<LE|BE>:32:default` because Ghidra's header auto-selection picks a 64-bit language for these files. `REA_GHIDRA_LANGUAGE_ID` overrides it; combining the pin with an override is a typed refusal.
- ABI flags record (`PT_MIPS_ABIFLAGS` / `SHT_MIPS_ABIFLAGS`) and GNU Object Attributes are parsed; `EF_MIPS_FP64` and `EF_MIPS_NAN2008` declarations are refused.
- MIPS16 `ET_DYN` profile verifies only `R_MIPS_NONE` and symbol-index-zero `R_MIPS_REL32`. Symbol-bearing MIPS16 function pointers are refused because Ghidra "can normalize ... to an even address, losing the source mode tag."
- Soft-float: policy `o32-soft-float-prototype-v1`, script `ReaGhidraMipsSoftFloat.java`; the script fails if any float stays in an FPU register.
- `ET_REL` (kernel modules): lane `elf32-rel-o32-arch32r2-standard-v1`; HI16 relocations report `PARTIAL`.
- Caveats quoted: "delay-slot semantics are supplied by Ghidra, not reconstructed by REA's ELF parser"; "Floating-point behavior of compressed functions is not established by these integer controls"; "Pseudocode presence is a liveness check, not proof of semantic equivalence."
- Verification: `GHIDRA_INSTALL_DIR=... npm run verify:ghidra:mips`, plus `verify:ghidra:mips-shared` (needs GNU MIPS cross-binutils) and `verify:ghidra:mips-relocatable`. Windows P0 does not admit MIPS.

## docs/ghidra-nativeaot.md

- Path: `SOURCE_DIR/docs/ghidra-nativeaot.md`. Built-in read-only parser for x64 PE32+ with .NET 8 RTR 9.1 metadata. It builds an in-memory overlay and does not define Ghidra DataTypes, labels, functions, or memory bytes.
- Hydration semantics are adapted from `Washi1337/ghidra-nativeaot` at `effeb734fc570c32650f88b159608979dc7b423e` (MIT), cross-checked against .NET `MethodTable.h` at runtime commit `a3b2d40328be0be3f8dd43f0e5cc925b8827b044`. Notice file: `licenses/nativeaot-parser-MIT.txt`.
- Optional headless adapter: `git submodule update --init third_party/ghidra-nativeaot`, `npm run build:ghidra:nativeaot`, then `REA_GHIDRA_NATIVEAOT_JAR`. The doc warns "JARs execute within Ghidra; supply a build you trust"; the loader accepts JARs up to 8 MiB.
- Commands: `inspect-native-load-image`, `inspect-native-data-type --address <MethodTable>`, `function`. Frozen strings come from `metadata_recovery.frozen_strings`, not `search_strings`.
- Limits: 128 MiB captured PE, 64 MiB-equivalent parser work, 64 MiB overlay/index buffers, 4 MiB report JSON.
- Caveats quoted: "Generated address identities do not claim original managed names"; "Pseudocode is recovered native logic, not original C# source"; the upstream `__thiscall` assignment "is not treated as x64 ABI authority."
- Windows P0 check was manual: "non-elevated, Ghidra 12.1.4, JDK 21, no JAR" on Windows 11 x64. The doc says "No CI lane repeats this check." The real MCP lane runs only on Linux x64 with the adapter.

## docs/ghidra-ppc.md

- Path: `SOURCE_DIR/docs/ghidra-ppc.md`. ELF32 big-endian `ET_EXEC` with `EM_PPC` (20), family `powerpc`. First milestone of #1741. GameCube/Wii DOL, PPC64, other variants are follow-ups. Does not execute PowerPC code.
- Refused: ELF64, little-endian, relocatable, shared, and `EF_PPC_EMB` (embedded variant). `EM_PPC64` (21) is not this family.
- Pinned `PowerPC:BE:32:default` (`language_selection: "provider-pinned-v1"`) because Ghidra picks `PowerPC:BE:32:e500:default` for a plain header with `e_flags` 0. The doc says e500 "misinterprets ordinary 750-family code. Nothing in the header distinguishes the two." `REA_GHIDRA_LANGUAGE_ID` can select `PowerPC:BE:32:e500` for real e500 code.
- Verification: `GHIDRA_INSTALL_DIR=... npm run verify:ghidra:ppc`, Clang `-mcpu=750` via `REA_PPC_CLANG`, GNU readelf via `REA_PPC_READELF`. An e500 import fails the lane.
- Caveats quoted: "Pseudocode presence is a liveness check, not proof of semantic equivalence"; "Instruction decoding and reader agreement do not establish runtime or complete floating-point semantics." Windows P0 remains PE x86/x86-64 only.

## docs/ghidra-psp.md

- Path: `SOURCE_DIR/docs/ghidra-psp.md`. Static ELF analysis for PSP/Allegrex, layered on the generic MIPS lane (#1330). Initial profile: Linux x64, little-endian ELF32 `ET_EXEC`, `EM_MIPS`, `e_flags=0x10a23001`, plus a version-0 MIPS ABI flags record with `fpAbi=2` (single-precision hard float) and `flags1=1`, `flags2=0`. Profile revision is v2.
- Requires an external extension installed at `$GHIDRA_INSTALL_DIR/Ghidra/Extensions/ghidra-allegrex`. REA "never downloads, installs, rebuilds or vendors the extension." Missing extension returns `PSP_EXTENSION_UNAVAILABLE` with a remedy, with no fallback.
- Loader `PspElfLoader`, language `Allegrex:LE:32:default`, compiler `default`.
- Historical compatibility experiment: Ghidra **12.1.3**, extension **v21.4**, PSPDEV **v20261001**, JDK 21. The doc says "New public-provider results must be reported separately from that historical bridge experiment."
- Out of scope: PRX, relocatable/shared, PBP/ISO/CSO, runtime emulation, live overlays. Caveat quoted: "The extension does not model VFPU prefix effects completely; nonempty decompiled code is not proof of correct vector behavior."
- Verification: `node scripts/verify-real-ghidra-mips.mjs --psp` and `--psp-missing-extension`; generic `npm run verify:ghidra:mips` must stay generic. Requires caller-supplied `psp-gcc`, `psp-readelf`, `psp-objdump`, PSPDEV.

## docs/ghidra-riscv.md

- Path: `SOURCE_DIR/docs/ghidra-riscv.md`. `EM_RISCV` (243), family `riscv`. Issue #2063. Does not execute code, emulate boot, or rehost firmware.
- Admitted: little-endian ELF32/ELF64 `ET_EXEC` declaring `EF_RISCV_FLOAT_ABI_DOUBLE`, with no RVE, TSO, or unknown bits. Big-endian is refused ("Ghidra 12.1.4 ships no big-endian RISC-V language"); `ET_REL`, `ET_DYN` refused; soft, single, and quad float ABIs refused.
- Pinned `RISCV:LE:32:default` / `RISCV:LE:64:default` with `gcc` because (measured against the 12.1.4 tree) an RV32 image without an Andes declaration auto-selects `RISCV:LE:32:AndeStar_v5:gcc`.
- Lane identity `elf32-exec-le-double-float-generic-v1` / `elf64-...`. The `riscv_elf` evidence fields are declarations only.
- Caveats quoted: a fixed-address `ET_EXEC` "does **not** establish static linkage"; "the generic language pin remains an analysis convention"; call-graph completeness, string inventories, dynamic linkage, Andes/RVE/TSO images, and big-endian targets "are **not** established by this lane."
- Verification: `npm run verify:ghidra:riscv` with Ghidra 12.1.4 PUBLIC, JDK 21+, and RISC-V-capable Clang, LLD and llvm-readelf (`REA_RISCV_CLANG`, `REA_RISCV_LLD`, `REA_RISCV_READELF`). On macOS the release tree ships no host decompiler binary.

## docs/ida-provider.md

- Path: `SOURCE_DIR/docs/ida-provider.md`. REA adapts an existing IDA MCP server. Upstream is `mrexodia/ida-pro-mcp`; an optional native bridge is `0xshlomil/ida-free-mcp`. REA "does not install, upgrade, activate, or license them." Selected via `REA_IDA_MCP_CONFIG` plus `REA_ANALYSIS_PROVIDER=ida` or `--provider ida`. Discovery does not start IDA.
- Attached (GUI) mode: the profile requires legacy GUI tool names. Upstream 2.0.0 renamed them and REA "fails closed." Known working: `1.4.0`. Input must be the original binary, with SHA-256 matching IDA's input hash. REA never saves or closes the GUI database.
- Native bridge: `protocol: "native"` with a loopback URL. Caveat quoted: the native MCP 1.1.2 release "binds `0.0.0.0` without a listen-address setting." Native mode has no direct callers ("native code/data xref labels do not prove call edges"). Decompilation moves GUI focus, and `effects.may_show_ui: true` is reported. Native 1.1.2 can navigate the wrong tab; the doc says upstream 1.1.3 is "not verified by that run."
- Headless mode: upstream database-supervisor API (`idb_open`, `idb_list`, `idb_close`), snapshot `c133c385`. REA copies the input to a private temp directory, requests an owned worker, and closes with `save: false`. The doc says "Abruptly terminating REA, its proxy, or the supervisor does not establish worker release" and "does not claim Windows Job Object containment."
- Timeouts: `timeoutMs` defaults to 300000; a busy worker is polled every 100 ms.
- Coverage unknowns: complete body ranges, typed reference edges, CFG, comment kinds, and database revision are unavailable. Empty unsupported facets mean "unknown, not observed absence."
- Verification: `npm run verify:ida -- --target ... --procedure main`. Real workflows: Windows GUI legacy profile; Windows x64 headless supervisor with IDA 9.3; macOS arm64 headless with IDA Professional 9.1 (build 9.1.250226) at `c133c385`; native Windows IDA Pro 9.3 at upstream `c9d15d98` (with a loopback-listener change). Doc says "a real IDA HTTP-supervisor workflow remains unverified" and Linux headless engine operation is unverified.

## docs/jeb-analysis.md

- Path: `SOURCE_DIR/docs/jeb-analysis.md`. JEB-backed project, unit, and decompilation inspection, served by JEB's own MCP. Bring-your-own; REA does not install, launch, or open JEB project databases.
- Endpoint default `http://127.0.0.1:8425/mcp`; override with `REA_JEB_MCP_URL`, which must use literal `127.0.0.1` or `[::1]`. Redirects, remote hosts, credentials, query strings, and fragments are rejected.
- Verified against "JEB 5.48.0 (Linux x64, licensed build) serving `jeb-mcp-server` 1.3.0 over streamable HTTP."
- Tools: `inspect_jeb_client`, `open_jeb_project`, `list_jeb_units`, `decompile_jeb_item`. Only `open_jeb_project` changes engine-side state. Renames, comments, `save_project`, `close_project` are "intentionally not exposed yet."
- Caveat: JEB 5.48.0 headless instances do not advertise `open_project`; `open_jeb_project` works only on builds that advertise it (for example GUI clients).
- Unit pages cap at 100 and report `coverage: "partial"` when full. Omitted `unit_path` yields `unit_path: null`. The doc says "mock transport tests do not establish real-engine compatibility."

## docs/apktool-resource-analysis.md

- Path: `SOURCE_DIR/docs/apktool-resource-analysis.md`. Decodes Android resource tables and the binary manifest through a caller-supplied Apktool. Java/Kotlin source recovery belongs to the JADX family; engine decompilation to JEB.
- Requires Apktool 2.7.0 or newer ("verified with 2.7.0") and a Java runtime. `REA_APKTOOL_COMMAND` selects the launcher, otherwise PATH. Probe: `rea inspect-apktool-client`.
- Commands: `rea decode-android-resources <apk> [--locale de] [--no-strings]`; MCP `decode_android_resources`.
- Smali is skipped by design (`apktool d --no-src`). Resource smali edits and rebuild are "a follow-up lane with mutation authority."
- Limits: 600 s deadline, 4 MiB output capture, manifest 512 KiB, strings XML 8 MiB, default strings table 2000 entries, 100,000 decoded files.
- Windows: `.bat`/`.cmd` launchers run via `cmd.exe /d /s /c`; paths with `" % ^ ! & | < >` are `not_configured`.
- Caveats: entries with nested markup are "counted as unparsed rather than flattened."
- Verification record: `apktool 2.7.0-dirty (Debian packaging)` on Linux with OpenJDK 25, one signed aapt2-built probe APK with two locales. Command: `npm run verify:apktool -- --apk PATH`.

## docs/frida-instrumentation.md

- Path: `SOURCE_DIR/docs/frida-instrumentation.md` (13 lines). Device and process discovery, attach or spawn, and caller-authored JavaScript through CLI and MCP. Node bindings are an optional package loaded only when used; REA does not install Frida server on targets.
- Remote hosts use `host[:port]`; keepalive is in seconds "matching Frida Core 17.23.2."
- MCP tools: `list_frida_devices`, `list_frida_processes`, `start_frida_session`, `load_frida_script`, `resume_frida_session`, `unload_frida_script`, `frida_session_status`, `close_frida_session`. Spawned processes start paused; REA resumes only after cleanup confirms release and "never kills the target."
- CLI `instrument-with-frida` takes one inline or file script, captures messages for a bounded time, and stores path and SHA-256 but not script source. Message capture is capped at 16 MiB.
- Caveat quoted: scripts run "with that process's memory, filesystem, and network authority." Auth values are excluded from Evidence.
- Verification: `npm run verify:frida` on Linux with a local Node fixture; remote lane via `-- --address HOST:PORT --pid PID`. Doc says "Mock tests do not establish real device/server compatibility."

## docs/reverse-engineering-tools.md

- Path: `SOURCE_DIR/docs/reverse-engineering-tools.md`. Caller-supplied GNU objdump, GDB, Rizin, and a Cutter bridge. REA does not install them. Env: `REA_OBJDUMP_COMMAND`, `REA_GDB_COMMAND`, `REA_RIZIN_COMMAND`.
- objdump operations: `file_headers`, `section_headers`, `symbols`, `relocations`, `dwarf`, `disassemble`, `disassemble_all`, plus `architectures` (`-i`). Debug links are not followed unless `follow_debug_links` (`-WK`); `DEBUGINFOD_URLS` is cleared.
- GDB persistent sessions and the one-shot CLI are Linux-only. "Windows is also unsupported because owned Job Object cleanup can terminate debugger inferiors." One-shot needs `--inferior-tty`. Closing with a live inferior detaches it, which "can resume execution."
- Rizin: `inferior_tty` required on Linux; `dbg.exitkills=false`; persistent sessions unavailable off Linux.
- Shared MCP server: unrestricted Rizin/Cutter/GDB console commands retire the active binary session; the doc says "A successful command response alone does not prove that background writers have stopped."
- Cutter: protocol v2 handshake; 16 MiB frame limit; at most 256 descriptor candidates.
- Caveat quoted: "Provider versions and capabilities remain unknown until observed." Captured output is capped at 16 MiB per command; default MCP response budget is 10 MiB (`REA_MCP_MAX_RESPONSE_BYTES`).

## docs/native-investigation.md

- Path: `SOURCE_DIR/docs/native-investigation.md` (584 lines). Native discovery and analysis guide: functions, instructions, pseudocode, references, types, bounded traces, static inspection, desktop and call observation. Provider choice follows `installation.md#hopper`.
- Exact CLI selectors: `--procedure=`, `--address=`, `--pattern=`, `--query=` to preserve leading-dash names (for example `'--procedure=-[REAWidget delegate]'`).
- Ghidra name resolution: an exact database symbol beats a bare hex address; a function renamed to `dead` stays selectable by name. Overloads return every entry address on ambiguity.
- Function references cover the full body AddressSet; `procedure_references` returns internal and external edges. Regex stack exhaustion returns a resource constraint, not a partial result. Cancelling an active request "terminates the ephemeral database and discards its annotations."
- Snapshot semantics: a concurrent successful edit rejects the snapshot save; after metadata edits snapshots are unavailable in that session; use `export_evidence_bundle`.
- Source-change detection: `artifact_changed` with both digests. Ghidra imports keep their captured bytes if the source later changes.
- Profile versioning: incoming-reference facet is unavailable in older snapshots ("Reopen the target ... and save a fresh snapshot"); the decoder classification change yields a profile mismatch. `batch_decompile` labels `procedure.status: "unknown"` for identity failures.
- Traces: `trace_native_values` (8 MiB node payload, 32 MiB serialized); jump tables keep `mappings`, `default_targets`, `data_sources` separate; AArch64 jump tables verified on ELF and ARM64 Mach-O.
- Static inspection (not all Ghidra): Mach-O slice offsets; `trace_dylib_resolution`; `inspect_asset_catalog` via `assetutil`; `inspect_keyed_archive` (64 MiB, 200,000 objects); `decode_interface_builder` (32 MiB input; XLD.app 6.7 MB, "about 2M tokens"); `inspect_native_dispatch_metadata` (Objective-C and simple Swift).
- Xcode-command deadline 60 s and 64 MiB output; desktop capture needs macOS 14+ and Screen Recording/Accessibility permissions; scenario waits capped at 180 s.
- `observe_native_calls` uses LLDB on a process REA launched. Hardened targets without `com.apple.security.get-task-allow` fail with `debugger-attach-denied`. Caveat quoted: "Only entries are observed: return values, floating-point and stack arguments, and inlined or `objc_direct` calls are not."
- Ghidra platform: "Linux x64/arm64 and macOS x64/arm64"; Windows x64 P0 (issue #527). "macOS ARM64 is the real host verified"; "Admission of macOS Intel does not claim an Intel verification run."
- Lanes: `verify:ghidra`, `verify:ghidra:aarch64-jump-table`, `verify:apple-dispatch`, `verify:native-ui`, `verify:native-ui:permissions` (which reports `positive_e2e: false` when denied).
- Caveats quoted: "Empty static references do not prove that the address is unused at runtime"; call resolution "does not establish runtime execution"; "UI actions may change application data or trigger network activity."
- Hopper behavior is also covered in this file (regex 5 s deadline, unavailable byte search); not part of the Ghidra scope.

## docs/go-binaries.md

- Path: `SOURCE_DIR/docs/go-binaries.md`. `inspect_go_binary` / `inspect-go-binary` reads embedded Go build info (compiler version, modules, replacements, build settings) without running the binary. No Go installation needed.
- Supported containers: ELF, PE, thin Mach-O. Fat Mach-O is not interpreted as one architecture. Inline and historical pointer build-info encodings are handled; moduleless historical binaries are handled only under narrow conditions.
- Output includes `go_version` (or `null` if not UTF-8), `go_version_bytes_base64`, `module_text` / `module_bytes_base64`, `module.main`, `module.dependencies`, `module.settings`, `module.unparsed_lines`, `module.complete`.
- Limits: 256 MiB file, 1 MiB embedded strings, 16 MiB structural tables, 8 MiB report.
- Caveats quoted: `build_info: null` "does not prove that the binary is not Go"; embedded metadata "does not authenticate a compiler, dependency, commit or supply chain."
- Verification: `npm run verify:go:binary`, comparing with Go's `debug/buildinfo`; requires Go for that lane only. The doc states no Go version pin.

## docs/rust-binaries.md

- Path: `SOURCE_DIR/docs/rust-binaries.md` (72 lines). `inspect_rust_binary` / `inspect-rust-binary` reads cargo-auditable `.dep-v0` metadata from ELF, PE, or thin Mach-O without running the file.
- Output: `packages` (name, version, source, kind, dependencies, root), `root_package_index`, `dependency_edges`, `cyclic_dependency_indices`, `format_version`, and `rustc_commit` (from a `/rustc/<40-hex>/` path, `evidence_kind: inferred`).
- Limits: 256 MiB file, 1 MiB compressed section, inflated JSON capped at the smaller of 8 MiB and 64x compressed, 8 MiB report.
- Caveats quoted: unknown embedded format revisions use "the highest known preceding revision ... the particular revision has not been independently verified"; absence of `.dep-v0` "does not mean the binary has no dependencies." Universal Mach-O is unsupported.
- No verification command is named in this doc.

## docs/raw-binary.md

- Path: `SOURCE_DIR/docs/raw-binary.md` (119 lines). Headerless executables admitted only with caller-supplied `architecture` (`x86`, `x86_64`, `arm`, `arm64`, `6502`) and `entry_point` (`0x...`), via `--target-format raw-binary`.
- Languages: x86 `x86:LE:32:default`/gcc; x86_64 `x86:LE:64:default`/gcc; arm `ARM:LE:32:v7`/default; arm64 `AARCH64:LE:64:v8A`/default; 6502 `6502:LE:16:default`/default. Loader `BinaryLoader`. Profile commits `language_selection: caller-supplied-v1`.
- ARM/AArch64 entries must be 4-byte aligned; 6502 image must fit in `0x0000..0xffff`.
- Hopper and IDA refuse raw targets. Windows Ghidra P0 admits raw NMOS 6502 only.
- Caveats quoted: "Headers are not discovered from file bytes"; "This increment does not guess load addresses, vector tables, or memory maps." Big-endian, Thumb-only, Cortex-M unsupported; reset vectors and I/O not emulated.
- Verification: `npm run verify:ghidra:6502` with `ca65`/`ld65` from cc65 tag `V2.19` (tools report `V2.18`).

## docs/firmware-analysis.md

- Path: `SOURCE_DIR/docs/firmware-analysis.md` (213 lines). Binwalk for region inspection (`3.1.x`, parser verified with 3.1.0) and Unblob for explicit extraction (`26.6.x`, parser verified with 26.6.4). Other builds on those lines are accepted with a version limitation. Verified on Linux x64 only.
- Env: `REA_BINWALK_COMMAND`, `REA_UNBLOB_COMMAND`, `REA_FIRMWARE_PRLIMIT_COMMAND` (util-linux `prlimit`). Commands: `inspect-firmware-regions`, `extract-firmware [--offset --length --max-depth]`; MCP equivalents.
- Limits: 128 MiB input; 120 s deadline; 1 GiB address space and 120 CPU seconds per process; staging 256 MiB and 10,000 entries; depth 1-10 (default 3); reports 8 MiB.
- Output: `partial` vs `complete`; `extraction_gaps` with `continuation_id`. Caveat quoted: "`complete` ... does not establish complete firmware reconstruction." Decompressed children have "unknown original byte ranges."
- Caveats: "Binwalk can replace unknown lengths with the next signature or EOF"; "Neither a signature nor its confidence byte proves a valid partition."
- Unverified per doc: "The gap ownership claims remain unverified against real Unblob until that lane runs"; SquashFS, UBIFS, proprietary firmware, other hosts/architectures.
- Verification: `npm run fixtures:firmware`, `npm run verify:firmware`; optional `REA_FIRMWARE_VERIFY_EXT4=1` and `REA_FIRMWARE_VERIFY_GHIDRA=1`.

## docs/binary-diagnostics.md

- Path: `SOURCE_DIR/docs/binary-diagnostics.md` (194 lines). Offline `inspect_binary_layout` (sections, segments, symbols, relocations, linkage, mitigations) with no active target. Initial verification: Linux x64, ELF64 x86-64 little-endian EXEC/DYN/REL.
- Requires `REA_PWNTOOLS_PYTHON` pointing to an isolated env with "unchanged pwntools 4.15.0, pyelftools 0.33 and Unicorn 2.1.2."
- Limits: 32 MiB input, 64 MiB reply, 1 MiB diagnostics, 30 s deadline; `REA_PWNTOOLS_MAX_INPUT_BYTES` raises input to at most 1 GiB. Python lowers virtual address space to at most 3 GiB.
- Caveats quoted: "Canary, PIE, NX, executable-stack and RELRO are static inferences"; "Upstream RELRO/canary heuristics ... can be incomplete" for sectionless images; PLT outputs "are static candidates."
- Also covers `inspect_analysis_view` (paging with required `limit`), `detail: "summary"`, and `inspect_pe_resources` (PE32/PE32+; default 64 MiB file, 16384 entries; max 512 MiB and 65536).
- Core files, GDB, pwndbg are "tracked by #969"; the doc says this "makes no real support claim for those features."
- Delivery: pinned MCP SDK default 10 MiB receive buffer; large results need `maxBufferSize` on the client.

## docs/windows-ghidra-p0.md

- Path: `SOURCE_DIR/docs/windows-ghidra-p0.md` (220 lines). Experimental Windows x64 read-only P0 boundary. Version marker in doc: "npm 4.1.0 includes the Windows native bundle"; "npm releases through 5.0.0 admit x86-64 PE"; native x86 "on repository main."
- Supported: Windows 10+ x64 on fixed local NTFS; Node 22.19+, 24.11+, or 26+; Ghidra 12.1.x (verified 12.1.4); JDK 21 or newer; native PE x86/x86-64 applications and DLLs; raw NMOS 6502 images; 26 read-only operations.
- Commands: `npm install --global rea-agents`, `rea doctor --json`, `rea providers --json`, `rea inspect ... --provider ghidra`. Native controls: DACLs, handle-based path admission, Job Object ownership.
- Caveats quoted: "REA does not claim a separate SUBST detector"; "Abrupt owner death kills the job but can leave private runtime files; crash-time transactional deletion is not claimed"; "Broader hostile-target, concurrently mutable-path, extraction, and IPC-security claims require their own acceptance."
- Not on Windows: GUI state, annotations, other architectures, Hopper-only operations. PE load-image returns an explicit unsupported attestation status.
- Verification: `npm run verify:windows-native`, `verify:ghidra:windows` (with `--x86`, `--dll`), `verify:ghidra:windows:package` (non-elevated user).

## Cross-doc notes

1. **Ambiguous DOS/COM on Windows.** `windows-ghidra-p0.md` (lines 19-22 and 27-28) lists the admitted Windows targets as native PE and raw NMOS 6502, yet its verification sentence says "Independent verification covers admitted DOS MZ, explicit COM, and explicit raw-binary imports on their supported hosts." `ghidra-dos.md` says DOS is "outside the Windows native PE P0 boundary." Reading that favors the narrower claim: DOS and COM are verified on Linux/macOS, not Windows. The Windows doc should say so explicitly.
2. **Mixed Ghidra version pins.** Most Ghidra docs pin Ghidra 12.1.4 (JDK 21). `ghidra-psp.md` records a separate historical experiment on 12.1.3 with extension v21.4 and says new results must be reported separately. This is intentional, not a contradiction, but a reader can mistake 12.1.3 for the current pin.
3. **Multiple IDA upstream pins.** `ida-provider.md` uses three different upstream references: headless `c133c385`, native Windows `c9d15d98` (with a local loopback change), and attached legacy 1.4.0. The native plugin is at 1.1.2, while 1.1.3 is "not verified by that run." Platform IDA versions also differ (Windows 9.3, macOS arm64 9.1).
4. **Versions that look dated but are not checked here.** JEB 5.48.0 / jeb-mcp-server 1.3.0, Frida Core 17.23.2, Binwalk 3.1.0, Unblob 26.6.4, PSPDEV v20261001, and Apktool 2.7.0 are all pinned by their docs. None of the docs states when those pins were verified, and this review did not check upstream release dates. Treat them as "last verified by the doc," not current.
5. **Windows NativeAOT check is manual.** `ghidra-nativeaot.md` says its Windows 11 check "No CI lane repeats this check." Windows-side NativeAOT claims therefore rest on one manual run, unlike the other verification lanes.
6. **Platform scope of Ghidra.** `ghidra-provider.md` and `native-investigation.md` describe Ghidra analysis as Linux and macOS (x64/arm64) plus Windows x64 P0. macOS verification is only explicit for ARM64 in `native-investigation.md`; macOS Intel is "admission ... does not claim an Intel verification run." DOS on macOS x64 is "unverified" per `ghidra-dos.md`.
7. **Missing documents for cited rules.** Several files point to `installation.md`, `testing.md`, `mcp-contracts.md`, `apple-application-analysis.md`, and third-party READMEs for release boundaries, verification lanes, and response budgets. Those were not in this review's scope, so claims that depend on them are unverified here.
8. **No verification lane named for some docs.** `rust-binaries.md`, `go-binaries.md` (has one), and `frida-instrumentation.md` (has one) differ: `rust-binaries.md` names no verification command at all.
