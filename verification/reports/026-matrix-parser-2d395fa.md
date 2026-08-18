# Verification Report — 026-matrix-parser @ 2d395fa

spec: `specs/026-matrix-parser/spec.md` · date: 2026-08-18 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

13 deterministic criteria, all 🟢 green. 1 row `📋 case`, with its case file written at `/contract`.
3 rows `deferred` with reasons in `coverage.md`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=572 FAIL=0**. Baseline before this feature: 558.

### The two live defects, before and after

```
$ bash scripts/status.sh 001-example            # before
  non-green: `[given] base/idempotency` (🔴 red)
$ bash scripts/status.sh 001-example            # after
  non-green: idempotency by key (🔴 red)

$ bash scripts/status.sh 022-mutation-coverage  # before
  orphan row (no pillar):
$ bash scripts/status.sh 022-mutation-coverage  # after
  (no gaps)
```

The first was wrong since **008**: `specs/001-example/coverage.md` has six columns and `status.sh`
read `$5`, which is Origin. The second came from `covrows()` taking every line beginning with a
pipe, so 022's trailing **measurement table** became criterion rows and its empty header cell became
an unnamed orphan.

### The invariant: what moved and what did not

`tests/fixtures/matrix/baseline-coverage.txt` was captured from `main` at `1d506c2` **before a line
of the reader was written**, and is stored rather than re-derived — a refactor that re-derives its
own baseline and reports agreement has proved nothing.

| | result |
|---|---|
| `obliged` / `undeclared`, all 19 pre-026 matrices | **byte-identical** |
| `cases.sh` | 16 rows (15 + this feature's own), 16 resolved, **0 orphan** |
| `status.sh`, every feature but the two above | unchanged |
| `excluded` | **moved, upward, on 8 of 19 matrices** |

**`excluded` moved and the old number was the wrong one.** The previous reader dropped a row before
counting it whenever its criterion was prose rather than `UPPER-KEBAB` — `specs/_template`'s
`token < 300ms`, 002's `[given] base/idempotency`. Those rows are in the matrix and are excluded by
rule; **022's own rule is that exclusion must be a counted number and never a silence**, and the old
count was the silence. `alignment.md` gate note 1 said a refactor that changes a number has failed
even if the number looks better, so this is named here rather than found in a diff: the numbers that
decide an exit code did not move, and the diagnostic count became complete.

### Two bugs found by porting, one of them old

**1. `idem` was matched as a prefix, and a real filename begins with it.**
`specs/001-example` links `` `idempotency.feature` ``. Both `mutate.sh` and `cases.sh` shipped
`~ /idem/` — *contains* — so that cell silently inherited the row above and resolved to
`audit.feature`. Now an exact match. **Neither tool's output changed**, because nothing downstream
read that cell for that file; it was a wrong answer nobody had asked for yet.

**2. `read` with `IFS=$'\t'` strips leading tabs.** Tab is IFS *whitespace*, so an empty first field
silently shifts every column in the consumer. The first interface put `PILLAR` first and `PILLAR` is
empty for six-column matrices. Fixed by ordering `LABEL` first — never empty, because rows without
one are skipped — and `PILLAR` last.

### The interface grew during the third port, as the plan predicted

`plan.md` risk 3: *"if the third port needs an interface change, the first two must be re-run
against their baselines rather than assumed still correct."* It did. `status.sh`'s orphan test is
*a row with no pillar*, and against a six-column matrix that flags every row — so `matrix_header`
gained a seventh field reporting the pillar column as `0` when absent. `cases.sh` and
`mutate.sh coverage` were re-run against their baselines afterwards, not assumed.

### Cost, measured rather than estimated (`R6`)

| | |
|---|---|
| all three tools, one pass each | **1.84s** |
| `cases.sh` alone | 0.24s |
| `mutate.sh coverage --all` | ~1.4s |
| `check_91` inside the suite | ~1s |

### Guards (`S1`) and meta-checks

`guards` → `bash scripts/guards/no-prescribe.sh`, exit 0. `nvc.sh traceability` 0 · `duplicates` 0
· `selfscan` 0 · `prose.sh` 0. `cases.sh` exit 0. `mutate.sh coverage --spec` → 13 obliged,
0 undeclared.

## 3. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | The three defects were demonstrated by running the tools on real files before any design, and the baseline was stored as a fixture before the first line. |
| Skipped steps | ✅ | brief → align → distill → plan → **tasks** → contract (13 FAIL) → implement → verify. Fourth consecutive feature with `/tasks` before implementation. |
| Hallucination | 0 | Nothing asserted that was not first observed. |

**RED at `/contract`: 13 FAIL, 1 PASS.** `HERMETIC-ENV-91` was green by construction, as in 022 and
023 — it asserts the check's own file carries no ambient dependency, true from the moment it existed.
Three features running; it is a property of that criterion's shape, not of these features, and is
worth naming as such rather than recorded fresh each time.

## 4. UAT — 2026-08-18

Walked criterion by criterion against `acceptance.md`. All 13 deterministic scenarios executed.

| Brief metric | Moved by | Evidence |
|---|---|---|
| one parser, three tools | `MTX-SINGLE-READER` | 3 of 3 source it; 0 split the matrix themselves |
| the right criterion on six columns | `STATUS-NAMES-CRITERION`, `MTX-SIX-AND-SEVEN` | `idempotency by key` |
| an unreadable header is reported | `MTX-NO-TABLE-REPORTED` | non-zero and silent |
| nothing else moves | `MTX-COVERAGE-UNCHANGED`, `MTX-CASES-UNCHANGED` | 19 matrices identical on the deciding fields |
| green, hermetic, cost measured | `HERMETIC-ENV-91`, `MTX-DEPFREE`, `MTX-COST-REPORTED` | 572/0; 1.84s |

### What this feature does not prove

**One user-visible defect was fixed** — `status.sh`'s criterion name — plus one phantom row nobody
had noticed. The rest is structure. `alignment.md` scored mission advancement **3**, at threshold,
and that stands.

`MTX-SINGLE-READER` guards the **three tools named in it**. A fourth consumer that splits a line
inline would not be seen, which is why `JUDGE-ONE-READER-HELD` exists and why its case file says so.

No product gap found. Nothing routed to `/distill`.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/026-matrix-parser/retro.md`.
Gaps routed: none.
