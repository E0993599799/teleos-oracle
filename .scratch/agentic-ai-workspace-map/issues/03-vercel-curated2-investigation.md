Type: research
Status: resolved

## Question

`mission-control-vercel-curated2` is the one Marcuzx-Forge-named sibling directory with its own real, separate `.git` (an embedded repo nested inside the Workspace repo), also remoted at `brtstore4340-glitch/Marcuzx-Forge`. Its siblings (`mission-control-vercel-curated`, `mission-control-vercel-deploy`) turned out to be plain subdirectories, not repos — this one is different.

Investigate: what does this checkout actually contain (read its commit log, any README/notes), when/why was it created (check reflog, mtimes), and is it an accidental nested clone (safe-to-remove candidate, same family as the dead git-init artifacts) or something intentional. Read-only investigation — resolve by calling the Skill tool with "research".

See [CONTEXT.md](../CONTEXT.md), "mission-control-vercel-curated2".

## Answer

**Verdict: the CONTEXT.md premise is wrong. `mission-control-vercel-curated2/.git` is not a functional embedded repo with its own real history — it's a broken/gutted `.git` leftover, most likely from an interrupted copy operation. The directory's *working tree* content, however, is real and looks intentional (a separate Vercel deployment).**

### Evidence: the `.git` has no object database

Direct inspection of `mission-control-vercel-curated2/.git` (via `rtk proxy ls -la`, unfiltered, and confirmed again with the Read tool directly on the files, bypassing all shell/hook involvement) shows it contains **only two files, 8KB total**:

```
-rwxrwxrwx  49B  HEAD
-rwxrwxrwx 5.4K  config
```

There is no `objects/`, `refs/`, `logs/`, `index`, `hooks/`, `info/`, or `packed-refs` — none of the pieces a git repo needs to actually store or look up history. `HEAD` contains `ref: refs/heads/feat/phase-10c-emergent-autonomy` — a dangling ref to a branch this `.git` has no object for.

### Evidence: git commands run "inside" it silently resolve to the outer Workspace repo instead

Because there's no object database, git does not treat this `.git` as valid and walks up the directory tree — exactly the same trap already documented for `Omega` in CONTEXT.md, just harder to spot here because a `.git` *directory* genuinely exists (so naive `ls`/`find -name .git` checks wrongly flag it as "has its own repo").

Confirmed decisively with the raw system git binary (no `rtk`, no hook rewriting):

```
$ /usr/bin/git -C ".../mission-control-vercel-curated2" rev-parse --absolute-git-dir
/mnt/d/01 Main Work/Boots/Agentic AI/.git
```

That's the **outer Workspace repo's** `.git`, not curated2's own. Every `git log` / `git branch -a` / `git reflog` I ran "inside" curated2 before catching this was actually reading the **Workspace/Marcuzx-Forge repo's real history** — confirmed because the top commit it returned, `c87102f4 "fix: remove stale mission-control submodule gitlink"`, is word-for-word the same commit CONTEXT.md already identifies as the Workspace repo's own last commit. The 100+ `claude/*`/`codex/*`/`alpha/*` branches, the Oracle submodule declarations (tham-oracle, luxi-oracle, khun-ram-oracle, aeimathes-oracle, llm-wiki, thclaws-oracle), and the aborted `pull --rebase --autostash` in the reflog all belong to the Workspace root, not to this subdirectory.

### What the leftover `config` file tells us about origin

The 5.4KB `config` left behind is not a fresh `git init` template — it's clearly a **snapshot of the real, lived-in Workspace repo config**: dozens of `[branch "..."]` blocks with `vscode-merge-base` markers, `github-pr-owner-number` annotations referencing actual PRs (`Marcuzx-Forge#18`, `Marcuzx-Forge#23`), the same Oracle submodule blocks, and `[advice] addEmbeddedRepo = false` (the setting that silences git's warning when a directory containing a nested `.git` gets staged from a parent repo — telling, since someone clearly hit that warning before). `core.hooksPath` even points at `.../mission-control/.git/hooks` (the sibling arigeo-hr repo's hooks dir), which only makes sense as an inherited/copied value, not something a fresh checkout would set.

Only 2 of the ~8 standard top-level `.git` entries are present. The most likely explanation: someone attempted to copy (`cp -r`, not `git clone`/`git worktree add`) the Workspace repo's `.git` into this subdirectory — maybe while trying to turn this into a worktree or give it real version control — and the copy was interrupted (Ctrl+C, crash, or an I/O hiccup, plausible given this is all on the `/mnt/d` WSL-over-NTFS mount) after only `HEAD` and `config` landed.

### The outer repo doesn't track it specially either

From the Workspace root: `git status --porcelain -- mission-control-vercel-curated2` → `?? mission-control-vercel-curated2/` (plain untracked directory). `git ls-files -s -- mission-control-vercel-curated2` returns nothing (not a `160000` gitlink/submodule entry). Not in `.gitignore` (none exists at the Workspace root currently). So the outer repo has no special/gitlink relationship to this path — it's just an ordinary untracked directory to it, same as its `-curated`/`-vercel-deploy` siblings.

### But the working-tree content is real and looks intentional

Separately from the broken `.git`, the files actually in the directory are a genuine, scoped Next.js feature checkout:
- `src/app/salary-certificate`, `src/components/salary-certificate`, `src/lib/salary-certificate` — a "salary certificate" feature, not a full copy of mission-control.
- Its own `.vercel/project.json`: `{"projectId":"prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq","orgId":"team_okNwqr3o8ikdFxEEpcckhPlC","projectName":"mission-control"}` — a **different Vercel project AND a different Vercel team/org** than mission-control root's own link (`prj_hfdIL1BYKitpZTxpH5EixAputdzQ` / `team_OS8nENECHPCuieeZsEhya9sF`), despite sharing the display name "mission-control" in Vercel's UI.
- mtime: the directory and its `.git` share the identical timestamp `2026-06-11 19:14:33` (created together, one operation), 36 minutes after the sibling `mission-control-vercel-curated` (no-git, mtime `2026-06-11 18:38:03` same day) — consistent with someone building the plain `-curated` checkout first, then shortly after building this `-curated2` variant and this time also attempting to carry real version control along with it (hence the `.git` attempt that got cut short).

### Conclusion / recommendation

This is not a case of "accidental nested clone with real independent history to worry about losing" — there is no independent history here; the `.git` is inert. It belongs to the same family as the Omega walk-up trap and the stray git-init artifacts, just with two leftover files instead of zero. **Safe to remove specifically `mission-control-vercel-curated2/.git`** (just the 8KB `HEAD`+`config`) with no history loss — nothing is stored there that isn't already safely present in the real Workspace repo. That would make this directory a plain subdir, consistent with its `-curated`/`-vercel-deploy` siblings.

The **working tree itself should not be deleted outright**, though: it's the only known copy of a "salary-certificate" feature linked to a distinct, real Vercel project/team (`prj_cDTDRatZHXSthMwJ4g3AXBL4Rxyq` / `team_okNwqr3o8ikdFxEEpcckhPlC`) that may still be live. If consolidating, that content needs to be reconciled into a properly version-controlled location (e.g., committed for real into a clone of its actual source repo, or folded into mission-control root) rather than just deleted — deleting it blind could orphan the source for a live Vercel deployment. Recommend flagging it to พี่เอก as a decision point (which per Oracle's "External Brain, Not Command" principle is the right call anyway) rather than acting unilaterally.
