# morluto/rea: Testing and Quality

Source: `royal-master-oracle/github.com/morluto/rea` (rea-agents 6.5.0). Every claim below cites a file under that tree. Counts come from `find`/`grep` at read time.

## 1. Inventory

| Location | Count (`*.test.ts`) | Source of count |
|---|---|---|
| `tests/acceptance/` | 91 | `find tests/acceptance -name '*.test.ts'` |
| `tests/boundary/` | 643 | `find tests/boundary -name '*.test.ts'` |
| `tests/composition/` | 21 | same method |
| `tests/conformance/` | 22 | same method |
| `tests/evaluation/` | 13 | same method |
| `tests/process-global/` | 24 | same method |
| `tests/` total | 814 | sum of the above |
| `src/**/*.test.ts` (colocated) | 460 | `find src -name '*.test.ts'` |
| Whole repo (excl. `node_modules`) | 1282 | includes 8 under `third_party/` |

Helper and fixture files are separate: `tests/fixtures/` holds 102 files, `tests/support/` holds 23 files (including `cli/`, `mcp/`, `process/`, `workspace/` subdirectories), and 24 `src/**/*.fixture.ts` files sit beside production owners.

## 2. Test layout and depth model

`docs/testing.md` (lines 190-200) defines seven depths, each mapped to a directory:

- Module (`src/**/*.test.ts`): one domain, service, or adapter through its narrow public surface.
- Composition (`tests/composition/**`): provider-neutral session and registry wiring.
- Boundary (`tests/boundary/**`): exactly one production filesystem, process, network, browser, CLI, or provider boundary.
- MCP boundary (`tests/boundary/mcp/**`).
- Acceptance (`tests/acceptance/**`): a compiled CLI or MCP journey. An injected provider still counts as integration.
- Conformance (`tests/conformance/**`): shared provider contracts, parameterized by declared capabilities.
- Evaluation (`tests/evaluation/**`): deterministic evaluator parsing, scoring, and report generation.

Lines 202-209 restrict what each depth may import or start. Colocated domain tests must not construct sessions, servers, subprocesses, or listeners. Only acceptance tests assemble the complete runtime.

`tests/process-global/**` is reserved for cases with a demonstrated dependency on process-global state, and runs in isolated forks (`docs/testing.md` lines 216-224). The CLI module mocks live there (line 95).

## 3. Runner configuration

Runner: Vitest. `package.json` devDependencies pin `vitest` 5.0.3 and `@vitest/coverage-v8` 5.0.3.

`vitest.config.ts` builds one Vitest project per entry in `scripts/lib/test-projects.mjs`. That file is the canonical ownership table, shared by Vitest, CI grouping, and dev-test preparation. Its source group is `domain`, `services`, `adapters`, `composition`, `conformance`, and `evaluation`. Its built group is `boundary`, `cli-boundary`, `process-boundary`, `mcp-boundary`, `acceptance`, and `process-global`. A helper `projectForTest()` throws unless each test path has exactly one owning project.

Per-project policy in `vitest.config.ts` (lines 45-120):

- `domain`, `services`, `composition`, `mcp-boundary`, `conformance`, `evaluation`: threads pool, `isolate: false`, with a comment justifying shared module graphs.
- `cli-boundary`: forks pool, `isolate: false`, `execArgv: ["--max-old-space-size=384"]`.
- `adapters`, `boundary`, `acceptance`, `process-global`: forks pool with per-file isolation.
- `process-boundary`: forks pool, `fileParallelism: false`, `groupOrder: 1` (serial).

Global settings: `MAX_TEST_WORKERS = min(2, availableParallelism())`, `retry: 0`, `testTimeout` 30 s (60 s with coverage), `env.TMPDIR` pinned to the canonical temp directory.

Package scripts (`package.json` "scripts"): `test:run` = `vitest run`; `test:local` / `test:changed` / `test:focused` use `scripts/run-development-tests.mjs`; `test:fast` = source projects; `test:boundary`, `test:mcp`, `test:acceptance`, `test:integration`, `test:coverage`, `test:ci`, `test:ci:shard`, `test:ci:merge`, `test:python` (`python3 -m unittest` on `bridge/native/test_rea_lldb_tracer.py`, `bridge/mitmproxy/test_capture.py`, and `experiments/analysis-efficiency`), and `test:sqlite`.

`npm run check` runs `typecheck lint:built format:check knip metadata:check` plus `verify:architecture-guards`. `check:pr` adds `test:run`, `test:python`, `docs:check`, `jscpd`, and `scan:todos` (`package.json`).

## 4. CI sequencer and process-ownership runner

`tests/ciTestSequencer.ts` (121 lines): a `BaseSequencer` subclass. It only activates when `REA_CI_TEST_HISTORY` and a Vitest `--shard` are both set (`shard()` method). It reads a JSON timing report (`version: 1`, `success: true`, `files[]` with `name` and `durationMs`), then distributes files across shards longest-first using `allocateByDuration()`. Files without history get the median weight. Every discovered file still lands in exactly one shard. Without history it falls back to `super.shard()`. The sequencer is wired in `vitest.config.ts` (line 141) only when `REA_CI_TEST_HISTORY` is set.

`tests/processOwnershipRunner.ts` (18 lines): a custom `TestRunner`. In `onBeforeRunFiles()` it registers `systemProcessOwnershipHost.close` via `onCleanupWorkerContext`, so each isolated graph's native process-inspector cache is retired when its worker stops. It is referenced as `runner:` in all three Vitest configs. `docs/testing.md` (lines 181-184) states why teardown is per worker, not per file.

## 5. Coverage

- Tool: V8 provider (`vitest.config.ts` `coverage.provider`). `coverage.enabled` is `false` by default, so coverage runs only through `test:coverage`, `test:ci`, or `--coverage` flags.
- `include: ["src/**"]`; reporters `text` and `text-summary`.
- Global thresholds (non-shard): statements 65, branches 60, functions 60, lines 68.
- `src/domain/**`: 80 / 75 / 75 / 80.
- `src/contracts/**`: 85 / 80 / 80 / 85.
- In shard mode (`--shard=` present) all thresholds are zeroed (`ZERO_COVERAGE_THRESHOLDS`), so partial shards do not fail.
- `docs/testing.md` line 262: thresholds are glob-specific and "never updated automatically". Line 263: coverage "does not replace named boundary or real-provider scenarios".
- `vitest.reverse-tools.config.ts` runs its own V8 coverage with `reportsDirectory: "coverage/reverse-tools"` and no percentage requirement (`docs/testing.md` lines 265-267).

## 6. Mutation testing

Two Stryker configurations, both Stryker 10.0.0 (`package.json` devDependencies).

`stryker.config.mjs`:
- `testRunner: "vitest"`, `vitest.configFile: "vitest.reverse-tools.config.ts"`, `related: true`.
- `coverageAnalysis: "perTest"`, checker `typescript`, `tsconfigFile: "tsconfig.reverse-tools-mutation.json"`.
- `thresholds: { break: null }`, so the score is informational.
- `mutate` ranges come from `scripts/lib/reverse-tools-mutation-targets.mjs` via `mutationRanges()`. Targets are resolved from TypeScript syntax (method owners, guards, declarations, callbacks), not from line numbers. Targets cover `ReverseEngineeringService`, `ExecFileOutput`, `providerEnvironment`, `GdbSessionManager`, `ownedDebuggerSession`, `RizinDebugSessionManager`, `reverseEngineeringCommands`, and `CutterBridgeClient`.

`stryker.semantics.config.mjs`:
- `testRunner: "command"`, running `npx vitest run --config vitest.reverse-tools-semantics.config.ts`, `coverageAnalysis: "off"`.
- Exhaustive second pass over Cutter `current_file` checks and Rizin timeout-evidence declarations.

Config tree: `vitest.reverse-tools.config.ts` lists about 40 focused test files plus `src/process/ExecFileOutput.test.ts` and uses `pool: "forks"`, `maxWorkers: 2`. `vitest.reverse-tools-semantics.config.ts` lists three Cutter/Rizin timeout test files.

CI: `.github/workflows/mutation.yml` runs both configs as a matrix (lines 29-31) under a `mutation-${{ github.ref }}` group. `docs/testing.md` (lines 292-308) says the sweep runs daily and on manual dispatch, is outside the PR and release gates, and writes JSON and HTML reports under `reports/mutation/`. Preflights with `--dryRunOnly` are required in the PR gate (lines 283-290).

## 7. Static analysis tied to tests

- `knip.json`: `project` globs cover `src/**/*.ts`, `tests/**/*.ts`, `scripts/**/*.mjs`. Entries include `tests/processOwnershipRunner.ts`. All rules are `"error"`, including `files`, `dependencies`, `devDependencies`, `unlisted`, `exports`, `duplicates`. `ignoreDependencies` covers `@stryker-mutator/command-runner`, `electron`, `esbuild`, `webpack`.
- `.jscpd.json` and the `jscpd` script: duplication over `src/` and `tests/` with a 3% limit (`docs/testing.md` lines 75-76).
- `tsconfig.json`: typechecks `src/**` and `tests/**` together. Options include `strict`, `exactOptionalPropertyTypes`, `noUncheckedIndexedAccess`, `noImplicitReturns`, `verbatimModuleSyntax`, `module: NodeNext`.
- `tsconfig.build.json`: extends the base, `rootDir: src`, excludes `src/**/*.test.ts`, `src/**/*.fixture.ts`, and `tests`. This is the package build config.
- `tsconfig.frida-verification.json`: `noEmit`, `files` limited to `src/frida/frida-bindings.d.ts` and `scripts/verify/fridaBindingsCompatibility.ts`. Used by `verify:frida:bindings`.
- `tsconfig.reverse-tools-mutation.json`: an explicit `include` list of mutation targets plus the reverse-tools test files, used by the Stryker TypeScript checker.
- Lint: `oxlint` (`.oxlintrc.json`) and `oxfmt` (`.oxfmtrc.json`). Not test-specific.

## 8. Fixtures, fakes, and mocking

Fixture locations:
- `tests/fixtures/**`: immutable source artifacts and runtime or provider fixtures (ELF, APK, HAR, Java class files, firmware, Go, EVM, Electron applications, etc.). Some are generated by `scripts/build-conformance-fixtures.mjs` and `scripts/fixtures/*`.
- `tests/support/**`: reusable test-scoped helpers. Examples: `reverseEngineeringMcpHarness.ts`, `hostCleanup.ts`, `holdFirstFileRead.ts`, `workflowGit.ts`.
- `src/**/*.fixture.ts` (24 files): "focused immutable builders and recording ports shared by one test family" (`docs/testing.md` lines 211-214). Examples: `src/application/Setup.fixture.ts`, `src/domain/analysisSnapshot.fixture.ts`, `src/process/ProcessOwnership.fixture.ts`.

Fake engines and providers live under `tests/fixtures/`:
- `fakeGhidra.mjs`, `fakeHopper.mjs`, `fakeLauncher.mjs`.
- `fakeCdpBrowser.ts` with `fakeCdpBrowserEvents.ts`, `fakeCdpBrowserResults.ts`, `fakeCdpBrowserTargets.ts`, `fakeCdpBrowserTypes.ts` (CDP browser double).
- `localToolsMcp.ts`, `mcpDoctorExit.mjs`, `mcpDoctorHang.mjs`, `mcpDoctorReply.mjs` (MCP doctor doubles).

Mocking:
- `vi.mock(...)` appears in 41 `.ts` files under `tests/` and `src/`.
- Most-mocked modules (by occurrence): `node:fs/promises` (29), `node:fs` (3), `node:child_process` (2), `src/process/ExecFileOutput.js` (2). Single mocks include `write-file-atomic`, `playwright-core`, `node:buffer`, and `src/windows/WindowsNativeLoader.js`.
- `docs/testing.md` (lines 95, 216-219) keeps CLI module mocks in `tests/process-global/` so they stay per-file isolated.

Recording ports: `docs/testing.md` lines 202-207 and 270-281 say module and application tests use "explicit ports and recording adapters". Conformance tests use "recording providers" per the `conformance` policy comment in `vitest.config.ts`; `docs/testing.md` line 199 describes conformance as "parameterized by declared capabilities and explicit opt-outs".

Golden files: `tests/fixtures/golden/` and `tests/fixtures/binaryDiagnostics/` (directory names only, not inspected in depth).

Real-tool verification is intentionally not mocked (`docs/testing.md` lines 181-184, 226-232): real Hopper, Ghidra, IDA, browser, package, and managed-code claims must run in `npm run verify:*` lanes.

## 9. How real-engine verification is documented

`docs/testing.md` is the primary record. Its sections are "Real-toolchain verification lanes" (lines 423-1127), "Termux Android browser smoke test" (lines 1129-1156), and dedicated lanes for Android, APK, ADB, Flutter, Apktool, Frida, WASM, PCAP, etc. (lines 589-1387).

Each lane entry lists:
- Command (`npm run verify:*`).
- Required host tools and version pins (for example Ghidra 12.1.4 with JDK 21, Rizin 0.7.4, IDA Pro 9.3 on Windows, Wireshark 4.6.6, pwntools 4.15.0).
- Explicit "does not establish" boundaries, such as "Fixtures do not establish real provider behavior" (line 281) and "Linux headless ... remain unverified" (line 800).
- "Record:" paragraphs with observed versions and fixture counts (for example the adb 34.0.5-debian run at lines 701-719, and the Flutter Gallery 2.9.2 record at lines 665-687).

Experiment notes live in `experiments/analysis-efficiency/` (for example `ida-native-windows.md`, `latest-main-audit.md`, `README.md`). `docs/testing.md` links `ida-native-windows.md` for IDA Windows measurements (line 806).

Real-model agent evaluation: `npm run verify:agent` drives a real local Codex CLI (`docs/testing.md` lines 1345-1350). Real model trials are "manual" (line 231).

## 10. CI wiring (summary)

- `.github/workflows/`: 30 files including `ci.yml`, `ci-full-pr.yml`, `mutation.yml`, `ci-timings.yml`, `pr-readiness.yml`, `pr-title.yml`, and ~20 `real-*.yml` provider lanes (for example `real-hopper.yml`, `real-ghidra-windows.yml`, `real-web-runtime.yml`, `real-termux.yml`).
- Test-selection: `docs/testing.md` lines 905-1011. PR classification uses owner scopes in `scripts/ci/scopes.mjs`. Source-only projects run after classification. Six portable shards run the complete suite. Full qualification adds coverage.
- Retries: none. `retry: 0` in `vitest.config.ts` and `docs/testing.md` line 313 ("Neither tier retries tests").
- Sequencing: CI uses `CiTestSequencer` with `test-timings` artifacts from trusted main runs (lines 324-330, 1081-1091).
- Test-selection plan is observational only; "There is no automatic promotion or switch to skip tests" (line 930).

## 11. Repo-local skills about CI, tests, and tool design

- `.agents/skills/rea-ci-tests-audit/SKILL.md` (112 lines): audit procedure. Requires establishing the executed baseline (SHA, toolchain, prerequisites), proving each suspected failure with a reproduction, perturbing suspicious green tests to confirm they catch injected failures, and treating fixture drift as a finding. Points to `references/measurement-and-ci.md` for timing work.
- `.agents/skills/rea-tool-design/SKILL.md` (20 lines): short pointer. For implementation or verification it says to "consult testing for the affected consumer and provider lanes". It contains no test rules of its own.
- `.agents/skills/rea-changelog-update/SKILL.md` (134 lines): release-note workflow. It concerns `scripts/release-notes.mjs` inventory, check, and render, and `docs/releases/VERSION.contributions.json`. Test relevance is limited to one instruction: distinguish simulated-provider checks from real-provider verification in release notes. It has no test-running commands.

## 12. Items with no material (or not present)

- Snapshot testing (`toMatchSnapshot`): not searched in detail. `docs/testing.md` uses "goldens captured from real producers" instead (line 157-158).
- Persistent compile cache for tests: disabled by default; opt-in via `NODE_COMPILE_CACHE` (`docs/testing.md` lines 118-142).
- Property-based testing: `package.json` devDependencies include `@fast-check/vitest` 0.5.0. Usage in tests was not counted, so no further claim is made.
- No separate Jest config found in the repository root listing.
