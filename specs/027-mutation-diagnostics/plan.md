# Plan — 027-mutation-diagnostics

> HOW it is built. Fail-closed against `memory/stack/stack.md` before any decision is taken.

## Charter gate

`python3 scripts/stack/engine.py exposure memory/stack/stack.md` → `10 pins · 8 PINNED ·
2 PROVISIONAL`, exposure on `S2` and `S9`.

| Decision | Pin | Verdict |
|---|---|---|
| staleness detected by content hash, in shell | `S3` dependency-free baseline | **PASS** |
| the pre-flight refuses and writes nothing | `S8` fail closed, never partially apply | **PASS** |
| the runner judges this repository's own checks | `S7` green proves this repository's harness | **PASS** |
| a new outcome added, its cost predicted and then measured | `S0` rigor tier: high | **PASS** |

**No `UNPINNED`, no `TRIPPED`.** `S2`'s exposure is unchanged: the timing call already existed.

## Decisions

### D-1 — Content hash, not mtime
`sed -i.bak` rewrites its target and creates the backup **even when nothing matches** — verified at
`/distill`. mtime moves on every declaration, so it would report every mutation as a change and
detect nothing. `*.bak` is excluded because the backup's existence is an artifact of the edit tool,
not of the edit.

### D-2 — Untracked is a pre-flight refusal, not a per-declaration outcome
020 and 022 each had **every** declaration in a new file misreported. The failure is not about one
declaration, so reporting it per declaration would print the same wrong thing many times. One
refusal, naming the files, before the first sandbox.

### D-3 — Scoped to `--tests`
`B17` proposed exactly this. Widening it — to every path any declaration might touch — means
guessing what an arbitrary shell command reads. Both known instances were under `tests/`. Stated as
a limit in `spec.md` edge 6 rather than left as an assumption.

### D-4 — `check_89`, before the bootstrap check
Free number, and it puts the runner's diagnostics ahead of the checks that depend on the runner.

## Sequence

1. `tests/check_89_mutation_diagnostics.sh`, 12 criteria — **RED before implementation**.
2. Fixtures under `tests/fixtures/diagnostics/`: a stale declaration, a weak one, a failing one, an
   untracked file, and 026's real declaration with the code as it stood.
   **`git add` before the first run** — `B17` is one of the three items this feature closes, and
   shipping it while tripping over it would be its own kind of comedy.
3. `mutate.sh`: pre-flight, then hash-before / hash-after around the edit.
4. A `[mut$ … $]` per criterion, then `mutate.sh coverage --spec` → 0.
5. **Full `mutate.sh run` before pushing** — `B22`, and the reason CI caught 026 and I did not.
6. The outcomes stated in `base/patterns/non-vacuous-checks.md`.
7. `/verify` → `/uat` → `/retro`.

## Risks

- **The cost prediction is 2%.** If `/verify` measures materially more, the design is wrong and the
  report says so rather than accepting whatever it finds.
- **This feature cannot show its own value.** Every declaration it ships knows the outcome exists.
  `JUDGE-STALE-READ-FIRST-TIME` is deliberately unscorable.
- **The hash runs twice per declaration.** A criterion that is slow already gets slower; the per-hash
  figure is 0.018s and the report states the total, not an average.
