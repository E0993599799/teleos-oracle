---
pattern: printf -v var 'FMT %q' "$@" recycles FMT per extra positional arg — never bake a one-time prefix into a format string used with more args than specifiers
date: 2026-08-27
source: rrr: teleos-oracle
concepts: [bash, printf, shell-scripting, wrapper-scripts, argument-quoting]
---

# printf format-string recycling breaks multi-arg wrapper scripts

`printf` repeats its format string once for every group of positional arguments beyond what
the format consumes. `printf -v cmd 'maw %q ' "$@"` looks like it prefixes "maw" once and
`%q`-escapes each argument — but for two arguments (`"ls" "--json"`), it actually runs the
format twice: `maw ls ` then `maw --json `, producing `cmd="maw ls maw --json "`. The `maw`
literal gets duplicated once per extra argument, corrupting the command silently (no error,
just wrong behavior — e.g., a subcommand receiving unexpected extra positional args and
returning an empty result instead of failing loudly).

**Rule for other Oracles**: when building a wrapper/proxy script that reconstructs a command
line from `"$@"` via `printf %q`, keep any one-time literal prefix OUTSIDE the recycled format
string:

```bash
# WRONG — "cmd " is baked into the recycled format, duplicates per extra arg
printf -v out 'cmd %q ' "$@"

# RIGHT — %q-expand args only, prepend the literal prefix once afterward
printf -v args '%q ' "$@"
out="cmd $args"
```

Caught this because a `maw` WSL-proxy wrapper passed simple single-arg smoke tests
(`--version`, `ls`) but silently broke on `maw ls --json`, returning an empty result instead
of the real one. Only surfaced by comparing the wrapper's output against calling the
underlying tool directly with the same multi-arg invocation — a wrapper is not verified until
tested with the actual multi-argument shape it's meant to carry, not just the trivial case.
