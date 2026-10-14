# rea (rea-agents 6.5.0) - Code Snippets

Source: `morluto/rea` at HEAD `3b79af28e`, package `rea-agents` 6.5.0.
Every excerpt below is copied verbatim from a file under the source repo. Line
numbers are from that checkout. Excerpts are trimmed where noted with `// ...`.

## 1. Main entry point: MCP startup (`src/main.ts:51-68`)

```ts
export const run = async (
  dependencies: RuntimeDependencies = runtimeDependencies(),
): Promise<number> => {
  const environment = snapshotEnvironment(dependencies.env);
  const config = parseConfig(environment);
  if (!config.ok) {
    dependencies.writeStderr(`${projectAnalysisError(config.error).message}\n`);
    return 1;
  }
  const logger = createLogger("mcp", config.value.logLevel);
  const serverLogger = logger.child({ layer: "server" });
  const session = createBinarySession(config.value, logger, environment);
  const opened = await openInitialTarget(
```

The long-lived MCP adapter. It snapshots the environment, parses config, and
builds one `BinarySession` for the process lifetime. Config errors are
reported on stderr and return exit code 1.

## 2. Executable boundary with redacted startup failures (`src/main.ts:95-111`)

```ts
export const runEntrypoint = async (
  start: () => Promise<number> = () => run(),
  writeStderr: (text: string) => void = (text) => process.stderr.write(text),
  setExitCode: (code: number) => void = (code) => {
    process.exitCode = code;
  },
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

Any unexpected startup throw becomes one fixed message. The cause is dropped on
purpose, so internal details stay out of caller-visible output.

## 3. CLI composition (`src/cli.ts:70-84`)

```ts
export const createCli = (
  selectedEnvironment: Readonly<
    Record<string, string | undefined>
  > = process.env,
  resultOutput?: CliResultOutput,
  fridaInstrumentation?: FridaInstrumentationPort,
): CliInstance => {
  const environment = snapshotEnvironment(selectedEnvironment);
  const analysis = createDirectAnalysis(environment);
  // The executable reports an invalid level through cliConfigurationError.
  const level =
    environment.REA_LOG_LEVEL === undefined
      ? undefined
      : parseLogLevel(environment.REA_LOG_LEVEL);
```

The one-shot CLI builds on the `incur` framework. It takes the same environment
snapshot and the direct-analysis composition that the MCP path uses.

## 4. Composition root (`src/composition/binary.ts:19-37`)

```ts
export const createBinarySession = (
  config: AppConfig,
  logger: Logger,
  selectedEnvironment: Readonly<NodeJS.ProcessEnv>,
): BinarySession => {
  const environment = snapshotEnvironment(selectedEnvironment);
  const hopper = new HopperProvider(config, logger, environment);
  const ghidra = new GhidraProvider(config, logger, environment);
  const ida = new IdaProvider(config, environment);
  return composeBinarySession(
    new AnalysisProviderRegistry(
      [hopper, ghidra, ida],
      config.analysisProvider,
    ),
    auxiliaryAnalysisProviderDeclarations(environment).map(
      (declaration) => new LazyAnalysisProvider(declaration),
    ),
  );
};
```

The file's own doc comment calls this "the sole production wiring point", so CLI
and MCP share provider selection and Evidence semantics. Auxiliary providers are
wrapped in `LazyAnalysisProvider`.

## 5. Evidence type (`src/domain/evidence.ts:183-188`)

```ts
/** Complete observation whose normalized payload retains its operation-specific type. */
type EvidenceSchemaValue = z.infer<typeof evidenceSchema>;
export type Evidence<Result extends JsonValue = JsonValue> =
  EvidenceSchemaValue & {
    readonly normalized_result: Result;
  };
```

Evidence is a zod-derived record. `normalized_result` is generic over the
operation's result type.

## 6. Content-addressed Evidence ID (`src/domain/evidence.ts:275-276`)

```ts
/** Hash semantic content, including raw results and excluding display-subject fields. */
const computeEvidenceId = (evidence: EvidenceWithoutId): string =>
  `ev_${digestCanonicalValue(semanticProjection(evidence), "Evidence")}`;
```

The ID is `ev_` plus a SHA-256 over canonical JSON of the semantic projection.
The projection covers provider, operation, parameters, results, and limitations,
and excludes display-only subject fields. Parsing re-computes the ID and rejects
a mismatch (`src/domain/evidence.ts:174`).

## 7. Evidence constructor (`src/domain/evidence.ts:340-356`)

```ts
/** Build deterministic Evidence from an immutable artifact subject. */
export const createEvidence = (
  target: EvidenceSubjectTarget | BinaryTarget | undefined,
  provider: EvidenceProvider,
  observation: EvidenceObservation,
): Evidence => {
  const { normalized, sharedResult } = normalizeEvidenceObservation(
    target,
    provider,
    observation,
  );
  const evidence = {
    ...normalized,
    evidence_id: computeEvidenceId(normalized),
  };
```

`createEvidence` normalizes the observation and then attaches the computed ID.
The same input yields the same ID. A `sharedResult` is kept in an immutable
snapshot cache.

## 8. Unknown (residual unknown) identity (`src/domain/residualUnknown.ts:23-40`)

```ts
const stableUnknownId = (
  question: string,
  domain: string,
  scopeDigest: string | null,
  comparisonConclusionScope?: z.infer<typeof comparisonConclusionScopeSchema>,
): string =>
  `unk_${createHash("sha256")
    .update(
      canonicalJson({
        domain: domain.trim(),
        question: question.replace(/\s+/gu, " ").trim(),
        scope_digest: scopeDigest,
        ...(comparisonConclusionScope === undefined
          ? {}
          : { comparison_conclusion_scope: comparisonConclusionScope }),
      }),
    )
    .digest("hex")}`;
```

Unknowns are a separate record type with a `unk_` prefix. The ID hashes the
normalized question, domain, and scope, so it stays stable across revisions.
Revisions are chained through `previous_revision_digest`.

## 9. Unknown mutations are recorded as Evidence (`src/application/investigation/UnknownEvidence.ts:24-28`)

```ts
/** Create immutable evidence for one approved residual-unknown mutation. */
export const unknownMutationEvidence = (
  target: BinaryTarget | undefined,
  mutation: UnknownMutation,
): Evidence =>
  createEvidence(target, UNKNOWN_REGISTRY_PROVIDER, {
```

Every change to an unknown is itself an Evidence record. The provider is the
internal `rea-unknown-registry`. Its limitation text says it records analyst
intent, not proof of the answer.

## 10. Cutter bridge: client-side mutual HMAC handshake (`src/cutter/CutterBridgeClient.ts:833-847`)

```ts
              const expected = createHmac("sha256", descriptor.token)
                .update(
                  `rea-cutter-server-v2:${descriptor.session_id}:${clientNonce}:${challenge.nonce}`,
                )
                .digest();
              if (
                !timingSafeEqual(expected, Buffer.from(challenge.proof, "hex"))
              )
                throw new Error("peer proof failed");
              onAuthenticated?.(connectionOrdinal);
              const proof = createHmac("sha256", descriptor.token)
                .update(
                  `rea-cutter-client-v2:${descriptor.session_id}:${clientNonce}:${challenge.nonce}:${requestBytes}`,
                )
                .digest("hex");
```

The socket bridge to Cutter is on loopback only (`host: z.literal("127.0.0.1")`
in `descriptorSchema` near the top of the file). Both sides prove knowledge of the per-session
`descriptor.token` with HMAC-SHA256 over fresh 32-byte nonces. The client checks
the server's proof with `timingSafeEqual` before it sends the request. The
client-side proof covers the exact request bytes.

## 11. Cutter bridge: server-side proof (`bridge/cutter/rea_bridge.py:550-555`)

```python
if not isinstance(hello, dict) or hello.get("kind") != "rea-auth-v2" or not isinstance(hello.get("nonce"), str) or len(hello["nonce"]) != 64:
...
server_proof = hmac.new(self.token.encode(), f"rea-cutter-server-v2:{self.session_id}:{client_nonce}:{server_nonce}".encode(), hashlib.sha256).hexdigest()
```

The Python bridge is the other end of the same `rea-auth-v2` handshake. The
two sides use the same labels, so the wire format matches.

## 12. Partial Evidence survives cancellation (`src/application/ProviderOperationExecution.ts:66-75`)

```ts
  // A provider that cannot observe the signal may finish its work after the
  // caller cancelled, so re-check rather than reporting a completed operation
  // the caller no longer wants. The observation it completed is still this
  // provider's Evidence, so the cancellation carries it as the partial
  // observation instead of discarding a finished result.
  if (options?.signal?.aborted)
    return err(
      new AnalysisCancelledError(operation, { partialObservation: evidence }),
    );
  return ok(evidence);
```

Errors are returned as `Result` values. A cancelled operation that already
produced Evidence keeps it on the error as `partialObservation`. It is not
thrown away.

## 13. Cancellation error carries the partial record (`src/domain/analysisErrorCore.ts:139-148`)

```ts
export class AnalysisCancelledError extends AnalysisError {
  readonly _tag = "AnalysisCancelledError";

  constructor(
    readonly operation: string,
    options?: AnalysisErrorOptions,
  ) {
    super(`Analysis operation was cancelled: ${operation}`, options);
  }
}
```

The error is typed by `_tag`. Its `options` argument is where `partialObservation`
travels. Other error classes add their own fields, for example `remediationAction`.

## 14. Retained Evidence paging (`src/domain/analysisView/analysisView.ts:154-159` and `:260-266`)

```ts
const pageViewSchema = z.strictObject({
  kind: z.literal("page"),
  collection: z.enum(["sections", "symbols", "modules"]),
  offset: z.number().int().nonnegative(),
  limit: z.number().int().positive(),
});
```

```ts
const coverageSchema = z.strictObject({
  status: z.enum(["complete-within-view", "page", "empty"]),
  examined: z.number().int().nonnegative(),
  total: z.number().int().nonnegative(),
  next_offset: z.number().int().nonnegative().nullable(),
  exhausted: z.boolean(),
});
```

This is the 6.5.0 "retained analysis views" feature. Pages are read from
already-recorded Evidence with a strict `offset`/`limit`. Each page reports its
own coverage, including `next_offset`. The contract text (`src/contracts/analysisViewToolContracts.ts:19`) says paging "never reopens the source or reruns the decoder".

## 15. JavaScript source selection schema (`src/domain/javascript/javascriptSourceSelection.ts:4-15`)

```ts
export const javaScriptSourcePathsSchema = z
  .array(z.string().min(1))
  .min(1)
  .describe(
    "Exact relevant file paths from the artifact inventory, relative to the application root, analyzed in first-request order before unselected scopes; no globs or implicit dependencies. Omit to analyze all sources.",
  );

/** Caller scope retained independently of analysis success or completeness. */
export const javaScriptSourceSelectionSchema = z.strictObject({
  requested_paths: javaScriptSourcePathsSchema,
  unselected_files: z.number().int().min(0),
});
```

The new 6.5.0 selection takes exact paths only. There are no globs and no
import expansion. The schema keeps `unselected_files` as a count, so unselected
files stay visible in coverage.

## 16. JavaScript source selection in analysis (`src/application/javascript/JavaScriptArtifactAnalysis.ts:143-144`)

```ts
  const selectedFileCount =
    fileSet.files.length - (fileSet.source_selection?.unselected_files ?? 0);
```

The analysis loop works over `fileSet.files` and subtracts the unselected count
to report how many files were actually analyzed. Unselected files are kept as
explicit coverage gaps, not silently dropped.

## 17. Java bridge: typed input failures (`bridge/android/ReaJadxBridge.java:34-37` and `:333-335`)

```java
  private static final class InputFailure extends IllegalArgumentException {
    final String field;
    InputFailure(String field, String message) { super(message); this.field = field; }
  }
```

```java
        catch (InputFailure error) { return text(JSON.toJson(Map.of(
            "kind", "invalid-input", "field", error.field, "message", error.getMessage())), true); }
        catch (IllegalArgumentException error) { return text(error.getMessage(), true); }
```

This is the Java (jadx) handler for the Android path. It wraps the unmodified
`jadx-headless-mcp` JAR. Bad input is mapped to a structured
`invalid-input` JSON result that names the failing field. Other
`IllegalArgumentException`s are returned as plain text errors.

## 18. Swift helper: process run-token and identity reader (`bridge/process/ProcessRunTokenReaderMain.swift:12-35`)

```swift
@main
struct ProcessRunTokenReaderMain {
  static func main() {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let identityMode = arguments.first == "--identities"
    let pidArguments = identityMode ? Array(arguments.dropFirst()) : arguments
    let pids = pidArguments.compactMap(Int32.init)
    guard pids.count == pidArguments.count else {
      fputs("invalid process ID input\n", stderr)
      exit(64)
    }
    do {
      let output: Data
      if identityMode {
        output = try JSONEncoder().encode(ProcessIdentityResponse(results: readProcessIdentities(pids: pids)))
      } else {
        output = try JSONEncoder().encode(RunTokenResponse(results: readRunTokens(pids: pids)))
      }
      FileHandle.standardOutput.write(output)
    } catch {
      fputs("could not encode process token observations\n", stderr)
      exit(70)
    }
  }
}
```

A small standalone Swift executable. It reads process run tokens or identities
for given PIDs through `sysctl`, and writes JSON to stdout. Exit code 64 means
bad input, and 70 means an encoding failure. This is a process observation tool,
not the Cutter socket authentication.

## Not found or not verified

- The token-over-socket handshake I verified is the Cutter bridge (snippets 10
  and 11). I did not check the Java or Swift bridges for an equivalent handshake.
- I did not trace the Hopper or Ghidra bridge auth paths.
