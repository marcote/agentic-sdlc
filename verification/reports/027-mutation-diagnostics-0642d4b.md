# Verification Report — 027-mutation-diagnostics @ 0642d4b

spec: `specs/027-mutation-diagnostics/spec.md` · date: 2026-08-18 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

12 deterministic criteria, all 🟢 green. 1 row `📋 case`, its case file written at `/contract`.
3 rows `deferred` with reasons in `coverage.md`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=589 FAIL=0**. Baseline before this feature: 576.

### The falsification test — passed

`alignment.md` gate note 3 set it before the work: *the replay must use 026's declaration exactly as
it shipped, not a convenient rewrite.*

```
proved      MUT-STALE-REPLAY-026 — 026's real declaration reports STALE, unedited
```

The declaration is `sed -i.bak 's|^_mx_crit=0$|_mx_crit=5|' …`, byte-identical to what 026 shipped,
against a fixture reproducing the awk block as it stood — where that identifier is indented inside a
quoted program, which is why a shell-shaped anchor matched nothing. Before this feature it reported
`survived its own mutation`, which says the criterion is weak. It was not.

### The corpus, run under the new diagnostics

```
$ bash scripts/mutate.sh run --tests tests
mutate: 101 mutation(s) under tests, 0 not proved, 0 stale, total elapsed 169.29s
```

**Zero stale across all 101 declarations.** 026 cleaned the last of them, and this run is the first
evidence that the cleanup held rather than the assertion that it did.

## 2.1 Cost, measured against the prediction

`alignment.md` gate note 1 predicted **~2%** — two 0.018s hashes per declaration over a 147s run.

| | |
|---|---|
| full run **before** (026, 88 declarations) | 146.72s |
| full run **after** (027, 101 declarations) | **169.29s** |
| per declaration, before | 1.667s |
| per declaration, after | **1.676s** |
| **added, per declaration** | **0.009s — about 0.5%** |

**Below the prediction, and the prediction was the right shape.** The estimate assumed two full
hashes per declaration; in practice the second hash reads a page cache the edit just warmed. The
figure is per-declaration because the totals are not comparable — 027 adds 13 declarations of its
own, so the raw totals differ for a reason that has nothing to do with hashing.

## 2.2 What the run found, and one defect of my own from 026

**Four declarations not proved on the first full run**, all in this feature's own check, all
editing errors:

| criterion | why | class |
|---|---|---|
| `MUT-COUNTS-SEPARATE` | the pattern contained `[$]`, whose `$]` collides with the grammar's own terminator | grammar collision |
| `MUT-TRACKED-RUNS` | `MUT_PREFLIGHT=1` disables the pre-flight, which is what the criterion wants preserved — the edit asserted the right answer | wrong mutation design |
| `MUT-STALE-REPLAY-026` | a global rename renamed the assignment **and** its use, so the comparison kept working — the same inert edit 022 shipped | wrong mutation design |
| `MUT-DIAG-COST` | the report did not exist yet | expected |

**0 criteria found vacuous, 3 mutations found weak.**

**A design error of mine from 026, found by this feature tripping over it.**
`MTX-CASES-UNCHANGED` asserted the exact string `16 case rows, 16 resolved`. 027 adds a `📋 case`
row of its own, so the count became 17 and a green criterion went red **for the one reason that is
never a regression**. It would have broken on every future feature, forever. Corrected in place to
assert the invariant — everything resolves, nothing orphaned, count never below the 15 recorded at
baseline — following 021's precedent: fix criteria, not features. 026 stays closed.

### Guards (`S1`) and meta-checks

`guards` → exit 0. `nvc.sh traceability` 0 · `duplicates` 0 · `selfscan` 0 · `prose.sh` 0.
`cases.sh` exit 0. `mutate.sh coverage --spec` → 12 obliged, 0 undeclared.

## 3. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | The cost was predicted at `/align` from a measurement taken at `/distill` (0.018s per hash), then measured against it. `sed -i.bak`'s rewrite-on-no-match was verified before the design depended on it. |
| Skipped steps | ✅ | brief → align → distill → plan → **tasks** → contract → implement → verify. Fifth consecutive feature with `/tasks` before implementation. |
| Hallucination | 0 | Nothing asserted that was not first observed. |

**RED at `/contract`: 7 FAIL, 6 PASS — the weakest RED this repository has recorded, and it is
honest.** Four of the six are **regression guards**: `MUT-WEAK-STILL-SURVIVES`,
`MUT-APPLY-ERROR-STILL-DISTINCT`, `MUT-TRACKED-RUNS` and `MUT-STALE-NOT-PROVED` assert behaviour
that must be *preserved*, so being green before the change is what correctness looks like. Two —
`MUT-DIAG-DEPFREE` and `HERMETIC-ENV-89` — are green by construction, as in 022, 023 and 026.

**One vacuity in my own contract, caught at `/contract`.** `MUT-BAK-NOT-A-CHANGE` asserted
`grep -q 'STALE'` while the fixture's criterion was labelled `STALE-ONE` — the assertion matched the
label, not the outcome. Renamed to `INERT-ONE`, after which it correctly went red. An assertion whose
input guarantees its own outcome, in the feature about diagnosing exactly that.

## 4. UAT — 2026-08-18

| Brief metric | Moved by | Evidence |
|---|---|---|
| an inert edit is its own outcome | `MUT-STALE-NAMED` | `STALE`, never `survived` |
| untracked stops the run | `MUT-UNTRACKED-REFUSED` | exit 2 naming the file, before any sandbox |
| the verdict does not soften | `MUT-STALE-NOT-PROVED` | exit 1, counted in not proved |
| weak and stale counted apart | `MUT-COUNTS-SEPARATE` | `2 not proved, 1 stale` |
| the replay is real | `MUT-STALE-REPLAY-026` | 026's declaration, unedited |
| cost measured against the prediction | `MUT-DIAG-COST` | 0.009s per declaration vs ~2% predicted |

### What this feature does not prove

**It fixes no criterion, closes no vacuity and moves no coverage number.** It changes what the
runner says when something is already wrong. Whether the sharper word changes what an author *does*
is `JUDGE-STALE-READ-FIRST-TIME`, and it is unscorable here because every declaration this feature
ships was written by the person who added the outcome.

`alignment.md` scored mission advancement **3**, at threshold. That stands.

No product gap found. Nothing routed to `/distill`.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/027-mutation-diagnostics/retro.md`.
Gaps routed: none.
