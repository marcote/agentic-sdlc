# Technical plan — 020-executable-mutations

> HOW it is built. Produced by `/plan`, behind the fail-closed stack-charter gate.

## Stack gate

```
$ python3 scripts/stack/engine.py ground-rules memory/stack/stack.md   # exit 0, all six covered
$ python3 scripts/stack/engine.py pin-valid    memory/stack/stack.md   # exit 0
```

**Verdict: `PASS`.** Ten pins, every ground rule answered. The one decision that looked
load-bearing — where the sandbox comes from — is already settled by `S6` (state is versioned files)
and `S3` (bash, coreutils, python3). Nothing new to pin.

### Criteria read against each declared `Falsifier`

| Pin | Reading |
|---|---|
| `S3` | The closest call. The runner must not need a mutation-testing framework, and `MUT-DEPFREE` is `S3` as a criterion. `git ls-files`, `tar`, `mktemp` and `bash` only. Not tripped. |
| `S7` | Every assertion is about this repository's own machinery. The runner never runs an application's tests. Not tripped. |
| `S6` | The sandbox is a copy of tracked files; the mutation is a file edit; the revert is a discard. This pin is the reason a sandbox beats an in-place revert. Relied on, not tripped. |
| `S8` | A mutation that cannot be applied aborts that mutation and reports, rather than continuing against a half-mutated tree. `MUT-APPLY-ERROR-DISTINCT`. |
| `S2`, `S4`, `S9` | No engine capability, no charter format change, no vendoring. |

## Gate bootstrap (`D4`) — declared before implementation

This feature ships a gate that judges criteria, and its own assertions are criteria. **The
exemption is from being blocked, never from being run**, and all four conditions apply:

1. **Declared here**, before implementation, as this named gate note.
2. **The gate runs retroactively against this feature's own criteria and must emit a real verdict.**
   `MUT-SELF-APPLIED` is that condition, and a trivial pass does not discharge it: every criterion
   in `check_99` declares a mutation and must be proved failable by it.
3. **Task ordering brings the feature into compliance before the final verify** — the runner is
   built, then turned on itself, then the suite closes.
4. **Every subsequent feature is subject, without exception**, for any criterion that declares a
   mutation. Declaring is opt-in by `G-e`; being run once declared is not.

## Technical decisions

**D1 — The sandbox is `git ls-files -z | tar` from the working tree, not `git archive HEAD`.**
Measured at 0.15s for 287 files. `HEAD` would prove the last commit rather than the code being
written, which is backwards for a check that runs during development. It also touches no ref, which
is what `hermetic-env` requires — 019 broke exactly that with `git show main:…` and CI caught it.

**D2 — The runner re-runs only the owning check file.** Measured: 24.68s for the suite against
0.84–3.53s for one file. `B7` already tracks the one nested run this repository has, and
multiplying it per mutation is what `G-c` refuses.

**D3 — A criterion is "proved failable" only when the label emits `FAIL` and emits no `PASS`.**
Not "some FAIL": a criterion that emits from a loop can do both. Absent is its own outcome and is
reported as not proved, never as proved — `MUT-SILENCE-IS-NOT-FAILURE`.

**D4 — The parser strips heredocs before scanning for `$]`**, reusing the approach `nvc.sh` already
carries. A mutation is usually a small script and will contain the terminator inside its body
otherwise.

**D5 — The runner is a separate script, not a subcommand of `nvc.sh`.** `nvc.sh` is static — it
reads files and never executes anything. This one executes arbitrary declared commands. Merging a
read-only scanner with an executor would put both behind one name and one trust level.

**D6 — The two replays live in `tests/fixtures/mutations/` as standalone check-shaped files.** They
carry the shipped text of 018's and 019's criteria. `nvc.sh` scans `tests/check_*.sh` only, so
fixtures under `tests/fixtures/` do not manufacture phantom criteria — the blind spot 015 measured
at 110 declarations instead of 78.

## Components / modules

| Unit | Responsibility | Interface |
|---|---|---|
| `scripts/mutate.sh` | parse, sandbox, apply, run, judge, report | `mutate.sh list --tests DIR` · `mutate.sh run --tests DIR` |
| `tests/check_99_mutations.sh` | the runner's contract, including its own negative | `_pass` / `_fail` |
| `tests/fixtures/mutations/` | the two historical criteria, verbatim | check-shaped files |
| `base/patterns/non-vacuous-checks.md` | `check-can-fail` gains its executable form | prose the adopter inherits |

## Risks

**This feature is itself the highest vacuity risk shipped so far.** A runner reporting *"all
criteria proved failable"* while never applying a mutation is indistinguishable from one that
works. `MUT-CATCHES-VACUOUS` is the negative that makes the difference observable, and it is not
optional.

**The replays could be softened into passing.** The temptation is to reconstruct 018's and 019's
criteria in a form that is easier to catch. `MUT-REPLAY-*` uses the shipped text; `git show` of the
pre-fix commits is the source, and the fixtures cite those SHAs.

**Opt-in means the mechanism can sit unused.** Stated in `G-e` rather than mitigated. The
`/uat` judgment `JUDGE-PREVENTS-THE-SIXTH` is deliberately left unanswerable until the next feature.

**Cost creep.** Every declared mutation costs about a second forever. `MUT-COST-REPORTED` makes the
bill visible on every run rather than at the point someone wonders why the suite got slow.
