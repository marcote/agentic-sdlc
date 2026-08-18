# Verification Report — 022-mutation-coverage @ 5193356

spec: `specs/022-mutation-coverage/spec.md` · date: 2026-08-16 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

13 deterministic criteria, all 🟢 green. 1 row `📋 case`, unscorable before the next feature.
3 rows `deferred` with reasons in `coverage.md`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=541 FAIL=0**. Baseline before this feature: 523. (537 at
implementation; the retro and this report add four more criteria under `check_90`'s DONE gate.)

### The gate this feature ships, run against this feature (`D4`)

```
$ bash scripts/mutate.sh coverage --tests tests --spec specs/022-mutation-coverage
coverage: specs/022-mutation-coverage/coverage.md — 13 obliged, 0 undeclared, 9 excluded,
          0 unresolvable — total elapsed 0.08s          # exit 0
```

**What this verdict does not prove, stated because it would otherwise read as evidence.** I wrote
the thirteen declarations, then the gate confirmed I wrote them. `D4` requires a bootstrapping gate
be *run* against itself; it does not make that run evidence that obliging works. The claim under
test — that the obligation surfaces a criterion its author would not have declared — needs a feature
that closes *under* the gate rather than *shipping* it. That is `JUDGE-OBLIGATION-CAUGHT-ONE`,
deliberately unscorable, and it is why `alignment.md` scored mission advancement 4 rather than 5.

### The standing debt, re-derived rather than stored

```
$ bash scripts/mutate.sh coverage --tests tests --all
…
TOTAL over specs/*/coverage.md: 192 obliged, 137 undeclared, 100 excluded, 0 unresolvable
                                — total elapsed 1.29s   # exit 0
```

| | 002 → 017 | 018 → 022 |
|---|---|---|
| features | 12 | 5 |
| obliged | 137 | 55 |
| **undeclared** | **137** | **0** |

The forward-only boundary was not chosen; it fell out of the data. Every feature since the runner
existed is complete, so no baseline list, exemption marker or known-anomalies file is needed —
which matters, because `B4` is this repository's standing evidence that a permanent warning trains
its reader to skip warnings.

The figure is stored nowhere. `--all` re-derives it at whatever ref it runs, so a report carries the
number that was true when it was written and cannot silently go stale.

### Declared mutations

```
$ bash scripts/mutate.sh run --tests tests
…
mutate: 60 mutation(s) under tests, 0 not proved, total elapsed 93.49s   # exit 0
```

**14 of 14 new declarations proved failable**, on the second attempt. The first is in §2.1.

### Cost, measured rather than estimated (`R8`)

| | |
|---|---|
| `coverage --spec`, one feature | **0.08s** |
| `coverage --all`, 18 matrices / 192 obliged rows | **1.29s** |
| `check_97` inside the suite | 2.14s |
| the 13 added declarations, inside `mutate.sh run` | ~27s of the 93.49s total |

The gate a feature actually pays at `/verify` is **0.08s**. Everything else is the sweep and the
runner, both of which already ran.

**A number I could not obtain, and it is not this feature's.** `bash tests/run.sh` reported
541/0 after **2923s** of wall clock, while timing every check inside a single process sums to
**~22s**. The same run on `main` had not finished after 10 minutes. It is pre-existing, it is
intermittent — the suite completed twice inside a 120s call earlier the same day — and it is filed
as `B18` with the evidence and a hypothesis rather than a diagnosis. The suite's **verdict** is not
in doubt; its wall clock is, and 022 is not the cause.

### Guards (`S1`) and meta-checks

`guards` → `bash scripts/guards/no-prescribe.sh`, exit 0. `nvc.sh traceability` 0 · `duplicates` 0
· `selfscan` 0 · `prose.sh` 0. `amendment-gate.sh --range main...HEAD` → not applicable, no change
to `pillars`/`scope`.

## 2.1 Four defects, three found by the mechanism against itself

**1. Exclusion was a silence, and the criterion written to catch that caught it.** The first
predicate filtered `[given]`, `📋 case` and `deferred` rows inside awk, before anything counted
them. Against a fixture holding three, the gate reported `0 excluded`. `COV-NOT-OBLIGED-COUNTED`
failed on it. Excluded rows are now emitted with a bucket tag and counted; filtering happens after,
never during, the read.

**2. The predicate's third condition produced a smaller, cleaner, wrong number — twice.** Requiring
the literal `tests/check_` counted **47** undeclared where the true figure is **137**, silently
dropping every feature before 015 because those matrices write `check_92_stack.sh` with no
directory. This is `B11` reached by walking into it, and `R3` exists because of it. Resolution is
now by extraction, and non-resolution exits 2 with the row named.

**3. `{3,}` is silently ignored by BSD awk.** The label pattern `^[A-Z][A-Z0-9-]{3,}$` matched
nothing on macOS, so the first sweep returned **one row per feature** and read as though the
matrices were nearly empty. Same family as the GNU-only `0,/re/` sed address that cost two features.
Spelled out as repeated character classes.

**4. Five of fourteen mutations broke nothing, and none of the five indicated a vacuous criterion.**
Diagnosed individually before any was rewritten, because reaching for *"the mutation was too weak"*
without saying why is how this becomes a rubber stamp:

| Criterion | Why it survived | Class |
|---|---|---|
| `COV-OBLIGED-PREDICATE` | `\$6` inside single quotes stays literal; sed matched nothing | editing error |
| `COV-CLEAN-PASSES` | `^COV_OK_MSG=` anchored at column 0; the assignment is indented | editing error |
| `COV-ALL-REPORTS-DEBT` | same anchor, same cause | editing error |
| `COV-NO-GIT` | anchored on `COV_NEEDS_NO_GIT`, a variable I never wrote | editing error |
| `COV-TYPO-NOT-EXEMPTION` | a global rename renames the definition **and** its use, so the branch kept working | **wrong mutation design** |

**Counts reported separately: 0 criteria found vacuous, 5 mutations found weak** — 4 editing
errors, 1 design error. The fifth is the interesting one: an edit that reads destructive and is
inert. It now deletes the branch, with a pattern ending in a quote so it misses the definition line.

A sixth was caught before it could rot: the replacement first used the line address `174d`, a number
in a file that changes. Rewritten to bind to a pattern.

**The sandbox lesson from 020 repeated exactly.** All fourteen first reported `emitted no result`,
because `check_97` and its fixtures were untracked and `git ls-files` never handed them to the
sandbox. 020 shipped both replay fixtures broken this way. The runner's diagnostic was right and I
had to read it twice to believe it.

## 3. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | Every figure in `spec.md` was derived at `/distill` by running the predicate, not estimated. Three of them were wrong on the way — 157, 47, 137 — and each correction is recorded rather than only the final number. |
| Skipped steps | ✅ | brief → align → distill → plan → **tasks** → contract (RED at 13 FAIL) → implement → verify. `/tasks` written before implementation, as 020 established and 018/019 did not. |
| Hallucination | 0 | Nothing asserted about the gate's behaviour that was not first observed in its output. |

**The RED state was real but not total:** 13 FAIL, **1 PASS**. `COV-DEPFREE` was green by
construction — it asserts `scripts/mutate.sh` invokes no toolchain, and the file already existed and
already did not. Recorded rather than dressed up: 020 was the first feature here with no
green-by-construction exception, and this one does not match it.

## 4. UAT — 2026-08-16

Walked criterion by criterion against `acceptance.md`. All 13 deterministic scenarios executed as
written.

### Does each criterion move the brief's success metrics?

| Brief metric | Moved by | Evidence |
|---|---|---|
| computed from `coverage.md`, no branch ref | `COV-OBLIGED-PREDICATE`, `COV-NO-GIT` | identical verdict in a tree with no `.git` |
| an unresolvable row is reported, never skipped | `COV-UNRESOLVABLE-REPORTED`, `COV-TYPO-NOT-EXEMPTION` | exit 2 on both, each naming the row |
| excluded by rule, not by exception | `COV-NOT-OBLIGED-COUNTED`, `COV-IDEM-RESOLVED` | `3 excluded` printed; the idem row stays obliged |
| this feature passes its own gate | `COV-SELF` | 13 obliged, 0 undeclared, exit 0 |
| the debt is a figure, where it is read again | `COV-ALL-REPORTS-DEBT` | 137, re-derived; the `/verify` skill requires recording it |
| green, hermetic, cost measured | `HERMETIC-ENV-97`, `COV-DEPFREE`, `COV-COST-REPORTED` | 537/0; 1.29s for the full sweep |

### What this feature does not prove

The gate binds the feature being verified and nothing else. **137 criteria across twelve closed
features remain undeclared**, and this feature deliberately does not close them — that is a separate
decision about which closed features are worth re-proving, now visible as a number instead of an
impression.

`[mut$ true $]` satisfies this gate. `mutate.sh run` is what rejects it. The pair closes the
loophole; saying so here means no later reader mistakes the division for an oversight.

No product gap found. Nothing routed to `/distill`.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/022-mutation-coverage/retro.md`.
Gaps routed: none.
