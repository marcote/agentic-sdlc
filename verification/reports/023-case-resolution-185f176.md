# Verification Report — 023-case-resolution @ 185f176

spec: `specs/023-case-resolution/spec.md` · date: 2026-08-18 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

13 deterministic criteria, all 🟢 green. 1 row `📋 case`, with its case file written at `/contract`
as `evals/README.md` requires. 3 rows `deferred` with reasons in `coverage.md`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=553 FAIL=0**. Baseline before this feature: 541.

### The gate this feature ships

```
$ bash scripts/cases.sh
…
cases: 15 case rows, 15 resolved, 0 unresolved, 0 missing, 0 orphan — elapsed 0.17s   # exit 0
```

Before the fixes: **14 rows, 11 resolved, 2 missing, 1 unresolved, 0 orphan.**

### 022's gate, run on this feature — and it is evidence against 022

```
$ bash scripts/mutate.sh coverage --tests tests --spec specs/023-case-resolution
coverage: … 13 obliged, 0 undeclared, 10 excluded, 0 unresolvable — total elapsed 0.08s   # exit 0
```

**023 is the first feature to close *under* 022's obligation rather than shipping it**, which is the
trigger 022's `pending-observation` verdict named. The result is `0 undeclared` on the first run.

`evals/cases/obligation-caught-one.md` states the refuting condition as *three consecutive features
reporting 0 undeclared on the first run*. **This is the first of those three.** It is one data point
and it does not settle anything, but it points the wrong way for 022 and recording it here is the
only reason the eventual judgment will be honest.

### Declared mutations

```
$ bash scripts/mutate.sh run --tests tests
…
mutate: 74 mutation(s) under tests, 0 not proved, total elapsed 109.42s   # exit 0
```

**14 of 14 new declarations proved failable**, on the second attempt. §2.1.

### Cost, measured rather than estimated (`R7`)

| | |
|---|---|
| `cases.sh`, whole repository, 19 matrices | **0.17s** |
| `cases.sh`, one matrix | 0.03s |
| `check_93` inside the suite | ~1s |
| the 14 added declarations | ~13s of the 109.42s total |

### Guards (`S1`) and meta-checks

`guards` → `bash scripts/guards/no-prescribe.sh`, exit 0. `nvc.sh traceability` 0 · `duplicates` 0
· `selfscan` 0 · `prose.sh` 0.

## 2.1 Four defects, and where each was caught

**1. `B14`'s premise was wrong by 7×.** It claimed 32 `📋 case` rows with 21 unresolvable; the true
figures were **14** and **1**. The 32 came from `grep -c '📋 case'`, which counts the status-legend
line present in all 19 matrices. Found by counting properly at `/distill`, before writing anything.
**The entry describing claims that point at nothing carried a count from a loose grep** — `B10`'s
family, one level up. The corrected entry ships with this feature.

**2. A fixed-index matrix reader does not fail on a six-column matrix — it reads the wrong column.**
`specs/001-example/coverage.md` has six columns; its criterion column parsed as `project` during the
first measurement. Splitting on the pipe yields the same field count either way, so nothing errors.
`R3` and header-driven resolution exist because of this. Filed as `B19`, because `status.sh` and
`mutate.sh coverage` still index by position.

**3. The label was stripped, not trimmed — and only the real matrix caught it.** Every criterion in
this harness is `UPPER-KEBAB` with no spaces, so deleting spaces looked equivalent to trimming.
`001-example`'s criterion is the prose *"message clarity"*. The binding check reported `UNBOUND`
against a case file that was correct. **All seven fixtures use spaceless labels; none of them could
have caught this.** The fixture set was built from the shapes I expected, and the repository
supplied the one I did not.

**4. Three of fourteen mutations broke nothing.** Diagnosed individually before rewriting:

| Criterion | Why it survived | Class |
|---|---|---|
| `CASE-COLUMNS-BY-HEADER` | forced the criterion index to **4**, which *is* correct for the six-column layout — the mutation asserted the right answer | **wrong mutation design** |
| `CASE-LEGEND-NOT-COUNTED` | the table-only grep is redundant; three independent guards protect the count and one edit could not break it | **redundant target** |
| `CASE-MULTI-ROW-FILE` | the assertion grepped `good.md.*orphan`; the output reads `ORPHAN … good.md`, so it could never match | assertion error |

**0 criteria found vacuous, 3 mutations found weak.** The second is the interesting one: the edit
was aimed at defence-in-depth rather than at the load-bearing guard, so the criterion held for a
reason that had nothing to do with what the mutation claimed to test. It now targets the status
being read from its **column**, and the fixture gained a `🟢 green` row whose prose names `📋 case` —
so the criterion proves the marker is not matched line-wise.

## 3. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | The gap was measured in both directions at `/distill` and the backlog's figure was checked rather than inherited. The correction is the feature's main finding. |
| Skipped steps | ✅ | brief → align → distill → plan → **tasks** → contract (13 FAIL) → implement → verify. `/tasks` before implementation, third feature running. |
| Hallucination | 0 | Nothing asserted about the gate that was not first observed in its output. |

**RED at `/contract`: 13 FAIL, 1 PASS.** `HERMETIC-ENV-93` was green by construction — it asserts
the check's own file carries no ambient dependency, which was true the moment the file existed.
Same class as 022's `COV-DEPFREE`, recorded rather than dressed up.

## 4. UAT — 2026-08-18

Walked criterion by criterion against `acceptance.md`. All 13 deterministic scenarios executed.

### Does each criterion move the brief's success metrics?

| Brief metric | Moved by | Evidence |
|---|---|---|
| every row resolves; the three broken ones fixed | `CASE-REPO-CLEAN` | 15/15 resolved, exit 0 |
| a row naming no path is reported | `CASE-NO-PATH` | exit 1 naming `FIX-PROMISE` |
| an uncited case file is reported | `CASE-ORPHAN-FILE-REPORTED` | `lonely.md` named; `0 orphan` printed when zero |
| the count is derived, never grepped | `CASE-LEGEND-NOT-COUNTED` | 1 case row in a matrix with two marker traps |
| the gate runs where the others run | `CASE-WIRED` | skill + CI; absent from `tests/run.sh` |
| green, hermetic, cost measured | `HERMETIC-ENV-93`, `CASE-DEPFREE`, `CASE-COST-REPORTED` | 553/0; 0.17s |

### What this feature does not prove

**The gap was 3 rows of 14, not the 21 of 32 the backlog advertised**, and the feature's value is the
gate rather than the cleanup. `alignment.md` scored mission advancement **3** — at threshold — for
exactly this reason, and that score is the honest one.

`JUDGE-CASES-NOW-COUNTABLE` asks whether knowing the count was ever the obstacle to `B2`. It is
blocked on the same judge `B2` is blocked on, which is uncomfortable and correct.

Existence is not quality: a one-line case file passes this gate.

No product gap found. Nothing routed to `/distill`.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/023-case-resolution/retro.md`.
Gaps routed: none.
