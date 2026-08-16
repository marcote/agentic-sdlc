# Verification Report — 021-mutation-audit @ bf5c909

spec: `specs/021-mutation-audit/spec.md` · date: 2026-08-16 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

6 deterministic criteria + 4 inherited `[given]` rows, all 🟢 green. 1 row `📋 case`. 3 `deferred`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=518 FAIL=0**. Baseline before this feature: 512.

## 3. The audit — the deliverable

```
$ bash scripts/mutate.sh run --tests tests
mutate: 46 mutation(s) under tests, 0 not proved, total elapsed 60.90s     # exit 0
```

46 declarations: 26 audited from 018 and 019, 14 from 020, 6 from this feature.

### Validity — 18 of 19 recorded mutations reproduce

| Feature | Recorded | Reproduce |
|---|---|---|
| 018 | 11 | **11** |
| 019 | 8 | **7** |

The one that does not is 019's M7 (`AMEND-PROVENANCE-QUIET`), and **it was valid when it ran**. At
`babac0a` the criterion read the previous North Star with `git show main:…`, so a mutated working
tree really did differ from the `old` side. CI rejected that ref-dependence and 019's own fix
reconstructs `old` **from** `new` — after which the same edit lands on both sides.

The mutation did not decay because it was weak. **The criterion changed underneath it**, inside the
same feature, and a prose table cannot notice that.

### Coverage — 018 recorded 11 mutations against 16 criteria

Seven had none. §2 of that report reads as though failability was established for the feature; it
was established for two thirds of it. 019's 8 cover its 8 completely.

**All 26 now declare one**, including two freed by splitting a combined header.

### The prediction was wrong, in the good direction

`alignment.md` predicted **7 or 8 failures** from 020's 6-of-14 rate. The result is **1 of 19**.

020's rate was an artifact of its own circumstances: those mutations were written against a tool
still being built, so the target moved under them. 018's and 019's were written against finished
checks and were genuinely run at the time. **The two reports were more solid than the audit
expected**, and that is the finding, not a disappointment.

## 4. Three defects, all in 020, all found by using it

**A multi-label criterion header was invisible.** `check_98` carried one header naming two
criteria. `nvc.sh` reads both labels; `mutate.sh` read neither, so both vanished from the coverage
count and neither could carry a mutation. Now rejected by name, exit 2.

**A self-scanning criterion detects its own declaration.** A `[mut$ … $]` declaration is a comment
line inside the file it mutates. `ADOPT-GUARD-BY-NAME` and `HERMETIC-ENV-98` went red the moment
their declarations were written, because the declarations contain exactly the literals those scans
forbid. Both now strip comments. **Neither criterion was wrong** — the scans were reading
scaffolding as code.

**I re-entered the recursion 020's own plan named.** `AUDIT-ALL-PROVED` first ran
`mutate.sh run --tests tests` from inside the suite. The runner re-runs `check_99` once per
declaration, and `check_99` then ran the whole audit again: 40 × 40. The suite hung. The criterion
now asserts that the **result was recorded**, the way a `Guard`'s result is, and the run stays at
`/verify` and in CI.

## 5. Survivors, diagnosed rather than re-mutated (`D1`)

**0 criteria found vacuous · 4 mutations found weak.** Each diagnosed before rewriting:

| Criterion | Why it survived | Kind |
|---|---|---|
| `ADOPT-GUARD-CLEAN` | `exit 1` appended **after** the guard's own `exit $bad` — unreachable | weak mutation |
| `AMEND-PROVENANCE-QUIET` | moved a pillar statement, but `old` is reconstructed **from** `new` | weak mutation |
| `AUDIT-COVERAGE-COMPLETE` | `0,/re/` is a **GNU sed** address; BSD sed ignores it silently | weak mutation |
| `MUT-MULTILABEL-REJECTED` | renamed the message, not the detection; the check's other alternative still matched | weak mutation |

Two of the four are portability or reachability mistakes in the edit itself, which is what makes
the separate counts worth keeping: none of them says anything about the criterion.

### Guards and meta-checks

`guards` → `no-prescribe.sh`, exit 0. `nvc.sh traceability` 0 · `duplicates` 0 · `selfscan` 0 ·
`prose.sh` 0.

## 6. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | Both audit numbers were measured at `/distill` before the spec claimed them. |
| Skipped steps | ✅ | brief → align → distill → plan → tasks → contract (RED at 6) → implement → verify. |
| Hallucination | 0 | The claim that 019's M7 was valid when run was verified against `git show babac0a:` before being written. |

**Cost, measured:** 46 declarations take **60.90s** at `/verify` and in CI, against 13.02s for 14.
It stays out of `tests/run.sh` for the reason §4 makes concrete.

## 7. UAT — 2026-08-16

All 6 deterministic scenarios executed as written. Both required counts are reported separately —
**0 criteria vacuous, 4 mutations weak** — which `alignment.md` gate note 2 made the condition for
this not being a rubber stamp.

The audited reports are corrected in place and neither feature is reopened.

No product gap. Nothing routed to `/distill`.

## 8. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/021-mutation-audit/retro.md`.
Gaps routed: none.
