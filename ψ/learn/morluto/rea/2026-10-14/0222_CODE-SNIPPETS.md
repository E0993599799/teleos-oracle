# rea: Code Snippets

Source: `morluto/rea` (read-only). Snippets are verbatim from the git tree at `HEAD` (`df3d96da8`), read with `git show HEAD:<path>`. Line numbers refer to that tree.

**Source note.** The working tree under `SOURCE_DIR/src/` is partial: only `adb/`, `android/`, `apktool/`, `application/`, `artifacts/`, and `browser/` are present on disk. `git ls-tree HEAD src/` lists 1,756 files across about 40 directories, so every `src/` citation below comes from `HEAD`. The `.agents/` deletions in the working tree were not used.

---

## 1. Entry points

### 1.1 Launcher: `scripts/rea.mjs` (lines 14-16, 52-56)

```js
const isMcpMode =
  args.length === 1 && (args[0] === "--mcp" || args[0] === "mcp");
const isMcpDoctorMode = args[0] === "mcp" && args[1] === "doctor";
```

The `bin` entries `rea` and `rea-agents` both point here (`package.json`, `bin` block). `--mcp` / `mcp` routes to the compiled MCP runtime; everything else routes to the CLI runtime. The launcher checks that `dist/` exists before importing it.

```js
const runtimeFiles = isMcpMode
  ? ["dist/mcp/main.js"]
  : isMcpDoctorMode
    ? ["dist/mcp/main.js", "dist/cli-runtime/mcpDoctor.js"]
    : [
        "dist/cli-runtime/cli.js",
        "dist/cli-runtime/cliOutput.js",
        "dist/cli-runtime/cliResultOutput.js",
      ];
```

### 1.2 MCP server: `src/main.ts` (lines 24-30, 50-69)

```ts
const runtimeDependencies = (): RuntimeDependencies => ({
  env: process.env,
  serve: serveStdio,
  writeStderr: (text) => process.stderr.write(text),
```

`serveStdio` comes from `@modelcontextprotocol/server/stdio` (line 7). It is injected as `dependencies.serve`, so tests can replace the transport.

```ts
export const run = async (
  dependencies: RuntimeDependencies = runtimeDependencies(),
): Promise<number> => {
  const environment = snapshotEnvironment(dependencies.env);
  const config = parseConfig(environment);
  ...
  const session = createBinarySession(config.value, logger, environment);
  const opened = await openInitialTarget(
```

`run()` snapshots the environment, parses config, creates one `BinarySession` for the process lifetime, and opens the initial target. The MCP transport is started after that (`src/main.ts` line 69).

### 1.3 Executable boundary: `src/main.ts` (lines 94-110)

```ts
export const runEntrypoint = async (
  start: () => Promise<number> = () => run(),
  ...
): Promise<void> => {
  try {
    setExitCode(await start());
  } catch (cause: unknown) {
    // Intentionally redact the startup cause from caller-visible output;
    // unexpected failures must not leak internal details.
    void cause;
    writeStderr(`${SERVER_START_FAILED}\n`);
    setExitCode(1);
  }
};
```

Unexpected startup errors are replaced with a fixed message, and the cause is discarded on purpose.

---

## 2. Tool contracts (the public inventory)

### 2.1 Aggregated inventory: `src/contracts/toolContracts.ts` (lines 33-66, abridged)

```ts
/** Complete ordered public inventory used by registration and verification. */
export const TOOL_CONTRACTS = [
  ...OFFICIAL_TOOL_CONTRACTS,
  ...ENHANCED_TOOL_CONTRACTS,
  ...NATIVE_TOOL_CONTRACTS,
  ...BINARY_DIAGNOSTICS_TOOL_CONTRACTS,
  ...ANALYSIS_VIEW_TOOL_CONTRACTS,
  ...ARTIFACT_TOOL_CONTRACTS,
  ...EVM_TOOL_CONTRACTS,
  ...GO_TOOL_CONTRACTS,
  // ... about 30 more domain contract arrays, in the same form ...
  ...SESSION_TOOL_CONTRACTS,
  ...FRIDA_TOOL_CONTRACTS,
] as const;
```

Each domain contributes a `*_TOOL_CONTRACTS` array. The same array is used for registration and for verification. The one-line `toolContract(name)` lookup at lines 69-84 throws `Missing tool contract` when a name is absent.

### 2.2 A single contract: `src/contracts/sessionToolContracts.ts` (lines 81-84)

```ts
  session(
    "binary_session",
    "Report the complete current target, provider, capability availability, client-feature, analysis, and server-identity status without starting analysis.",
    binarySessionInputSchema,
  ),
```

A contract is a name, a description, and a Zod input schema. The description is the text an agent sees. Output shapes are declared elsewhere (for example `src/contracts/toolOutputSchemaPrimitives.ts`).

---

## 3. Tool registration and dispatch

### 3.1 Registering a session tool: `src/server/registerSessionStatusTool.ts` (lines 46-49)

```ts
  server.registerTool(
    contract.name,
    toolRegistrationOptions(contract),
    async (input, context) => {
```

The tool name and options come from the contract, so the registered name cannot drift from the inventory.

### 3.2 Generic evidence-tool loop: `src/server/registerEvidenceTools.ts` (lines 59-66, 88-96)

```ts
  for (const contract of contracts) {
    server.registerTool(
      contract.name,
      toolRegistrationOptions(contract),
      async (input, context) => {
        const ready = options.preflight?.(
          contract.name,
          jsonObjectSchema.parse(input),
        );
```

```ts
            const execution = await logToolExecution(
              options.logger,
              contract.name,
              () =>
                analysis.execute(contract.name, executionParameters, {
                  signal: context.mcpReq.signal,
                  progress,
                }),
            );
```

Each provider-backed contract is one loop iteration. Preflight runs before admission, so an unsatisfiable request is refused before any analysis starts. Dispatch goes through `analysis.execute(name, params, { signal, progress })`, and the MCP abort signal is passed through.

### 3.3 Per-domain wiring: `src/server/registerNativeTools.ts` (lines 41-53)

```ts
  registerEvidenceTools(server, NATIVE_TOOL_CONTRACTS, {
    ...options,
    parametersForExecution: withoutDelivery,
    parametersForEvidence: withoutDelivery,
    preflight: (operation, parameters) =>
      operation === "inspect_macho" && parameters.detail === "summary"
        ? requireAnalysisViewRetention(operation, retention)
        : ok(null),
```

A domain registers its contracts through the shared loop and supplies hooks. Here, a delivery-only `detail` parameter is removed before execution and before Evidence identity is computed, so it does not change the Evidence ID.

### 3.4 Server wrapper: `src/server/EvidenceMcpServer.ts` (lines 87-103, 117-123)

```ts
  override registerTool<
    OutputArgs extends StandardSchemaWithJSON,
    InputArgs extends StandardSchemaWithJSON | undefined = undefined,
  >(
    name: string,
    config: {
      title?: string;
      description?: string;
      inputSchema?: InputArgs;
```

```ts
    return super.registerTool(
      name,
      (inputSchema === undefined
        ? config
        : { ...config, inputSchema }) as never,
      callback as never,
    );
```

`EvidenceMcpServer` extends the MCP SDK `McpServer`. It only rewrites the advertised input JSON Schema when a compact profile is active. The canonical schema and the parser are unchanged.

---

## 4. Evidence and uncertainty

### 4.1 Evidence construction: `src/server/registerEvidenceTools.ts` (lines 109-111, 140-145)

```ts
            const evidence = createEvidence(
              execution.value.subject ?? options.activeTarget?.(),
              execution.value.provider,
```

```ts
            const recorded = options.recordEvidence?.(projected.value);
            return server.delivery.toEvidenceToolResult(
              projected.value,
              contract,
              recorded,
            );
```

Every successful provider call becomes an `Evidence` record. It carries the operation, parameters, result, limitations, locations, and evidence links. The record is written to the session ledger before the response is returned.

### 4.2 Content-addressed ID: `src/domain/evidence.ts` (lines 274-276)

```ts
/** Hash semantic content, including raw results and excluding display-subject fields. */
const computeEvidenceId = (evidence: EvidenceWithoutId): string =>
  `ev_${digestCanonicalValue(semanticProjection(evidence), "Evidence")}`;
```

The ID is a digest of the semantic projection, so the same observation gets the same ID. `parseEvidence` (lines 279-) rejects a record whose stored ID does not match its content.

### 4.3 Provider limitations as data: `src/hopper/HopperProvider.ts` (lines 274-282)

```ts
        limitations: [
          ...(preparedImage === undefined
            ? []
            : [
                "REA loaded a verified thin Mach-O slice from the original FAT64 source. Identity and file offsets refer to the original file. The owned temporary image and its Hopper document close together, including on MCP shutdown.",
              ]),
          ...(CAPABILITIES.find(
            (descriptor) => descriptor.operation === operation,
          )?.limitations ?? []),
```

Known gaps are attached to each observation as text (`limitations`). They are not silently dropped. The same file (lines 283-292) adds per-operation notes, for example that `read_bytes` returns a readable prefix with `complete=false` when a range crosses a segment end.

### 4.4 Residual unknowns: `src/domain/residualUnknown.ts` (lines 94-119)

```ts
  status: z.enum([
    "open",
    "investigating",
    "blocked",
    "contradicted",
    "resolved",
  ]),
  severity: z.enum(["low", "medium", "high", "critical"]),
  domain: text,
  ...
  required_confidence: z.enum(["observed", "derived", "inferred"]),
```

An open question is a durable record with a status lifecycle, a required confidence level (`observed`, `derived`, or `inferred`), and supporting and contradicting Evidence IDs. A resolution must cite at least one Evidence ID when `disposition` is `verified` (lines 67-72). `unk_` IDs are derived from the question text and scope (lines 23-40).

### 4.5 Relationship coverage: `src/application/AnalysisProvider.ts` (lines 51-59)

```ts
  /** Provider-owned completeness assessment for caller/callee observations. */
  readonly relationshipCoverage?: RelationshipCoverage;
  /**
   * Whether the provider capped an `xrefs` read: true when it reported a
   * truncation, false when it explicitly reported none. Absent when it reports
   * nothing, which is not a completeness claim. Never part of Evidence or tool
   * output.
   */
  readonly referencesTruncated?: boolean;
```

The provider contract distinguishes "reported as complete", "reported as truncated", and "not reported". Absence is explicitly not treated as a completeness claim.

---

## 5. Error handling

### 5.1 Result type: `src/domain/result.ts` (lines 1-10)

```ts
/** A typed channel for expected success or failure. */
export type Result<T, E> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

/** Construct a successful result. */
export const ok = <T>(value: T): Result<T, never> => ({ ok: true, value });
```

Expected failures are returned as values. Tool handlers branch on `ok`, and the error is handed to `server.delivery.toCallToolResult(...)`.

### 5.2 Typed resource errors: `src/domain/analysisErrorCore.ts` (lines 23-47, abridged)

```ts
/** An analysis or transport resource failure, distinct from malformed input or unsupported coverage. */
export const ANALYSIS_RESOURCE_KINDS = [
  "memory",
  "cpu",
  "file-size",
  "transport",
  "capacity",
] as const;

/** A measured resource constraint or bounded admission refusal. */
export class AnalysisResourceConstraintError extends AnalysisError {
  readonly _tag = "AnalysisResourceConstraintError";
  readonly remediationAction: string | undefined;
```

Errors have a `_tag` discriminator and are separated by cause: unsupported target, resource constraint, protocol error, and input error. Each class can carry a `remediationAction`.

### 5.3 Cancellation is distinct from failure: `src/server/registerSessionStatusTool.ts` (lines 59-64)

```ts
      } catch (cause) {
        if (!context.mcpReq.signal.aborted) throw cause;
        return server.delivery.toCallToolResult(
          err(new AnalysisCancelledError("binary_session")),
          contract,
        );
      }
```

A thrown error is only converted to cancellation when the MCP request was actually aborted. Other exceptions propagate.

---

## 6. Native bridges

### 6.1 Hopper: launcher-side token and socket (`src/hopper/HopperClient.ts`, lines 362-363 and 806-809)

```ts
    const socketPath = join(this.#resources.runtimeRoot.path, "bridge.sock");
    this.#token = randomBytes(32).toString("hex");
```

```ts
    const socket = this.#socket;
    const token = this.#token;
    if (socket === undefined || socket.destroyed || token === undefined) {
      return this.#unavailableRequest(
```

Each Hopper run gets a fresh 32-byte random token and a socket in a private runtime directory. The token is sent to the bridge at launch and is required on every request.

### 6.2 Hopper: in-process Python bridge (`bridge/hopper_bridge.py`, lines 1016-1047, abridged)

```python
def _serve_connection(connection):
    """Serve one capability-authenticated NDJSON connection."""
    file = connection.makefile("rwb")
    ...
            line = file.readline()
            ...
                request = json.loads(line.decode("utf-8"))
                ...
                if not isinstance(request, dict) or set(request) != {"id", "token", "method", "params"}:
                    raise InvalidRequestError("Invalid bridge request shape")
                ...
                if (
                    not isinstance(request["token"], str) or not request["token"].isascii()
                    or not hmac.compare_digest(request["token"], REA_TOKEN)
                ):
                    raise PermissionError("Invalid bridge capability")
```

The bridge runs inside Hopper's Python thread. It reads newline-delimited JSON, rejects any request with an unexpected field set, and compares the token in constant time (`hmac.compare_digest`). The file header notes that Hopper API calls must stay on that thread.

### 6.3 Hopper: socket ownership (`bridge/hopper_bridge.py`, lines 1132-1139)

```python
def _run():
    """Own a permission-restricted, single-client Unix socket for this bridge."""
    if os.path.exists(REA_SOCKET):
        os.unlink(REA_SOCKET)
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(REA_SOCKET)
    os.chmod(REA_SOCKET, 0o600)
    server.listen(1)
```

The socket is a Unix socket with mode `0600` and a single listener.

### 6.4 Ghidra: Java bridge request parsing (`bridge/ghidra/ReaGhidraBridge.java`, lines 4318-4329)

```java
    private static Request parseRequest(String line, String expectedToken) {
        JsonObject object = requireObject(JsonParser.parseString(line), REQUEST_KEYS);
        int id = requireInteger(object, "id");
        if (id <= 0 || !constantTimeEquals(requireString(object, "token"), expectedToken)) {
            throw new IllegalArgumentException("Bridge request authentication failed");
        }
        JsonElement params = object.get("params");
        if (params == null || !params.isJsonObject()) {
            throw new IllegalArgumentException("Bridge request parameters are invalid");
        }
        return new Request(id, requireString(object, "method"), params.getAsJsonObject());
    }
```

The Ghidra side uses the same pattern as Hopper: strict key set, positive integer ID, constant-time token comparison. Methods are dispatched through a `switch` on `request.method` (around line 380).

### 6.5 Native command execution bounds: `src/native/CommandRunner.ts` (lines 20-29)

```ts
/** Maximum wall-clock duration for one native command. */
export const NATIVE_COMMAND_TIMEOUT_MS = 60_000;
/** Retain complete command output up to a bounded aggregate size. */
export const NATIVE_COMMAND_OUTPUT_BUDGET_BYTES = 64 * 1024 * 1024;
/**
 * Failure diagnostics keep only an excerpt of each stream. ...
 */
export const NATIVE_FAILURE_DIAGNOSTIC_BYTES = 64 * 1024;
```

Host tools (for example `otool` and `codesign`) run with a 60-second timeout, a 64 MiB output budget, and a 64 KiB excerpt for failure diagnostics. Each `NativeCommandCapture` records the executable SHA-256 and tool version.

---

## Not verified or not present

- **Decorator-based tool definitions:** not present. Tools are registered with `server.registerTool(...)` from contract objects.
- **Ghidra and Hopper tool-level registration:** only the bridge protocol was read. The per-tool Java handlers and the TypeScript `GhidraProvider` were not excerpted.
- **Swift native UI helper** (`bridge/native/ReaNativeUI.swift`, `bridge/process/*.swift`): present in `HEAD`, not read.
- **Compiled `dist/`:** not in the repo; the launcher expects it to be built.
