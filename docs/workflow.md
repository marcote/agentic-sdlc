# Workflow end-to-end

```
/constitution → (brief.md) → /align → /distill → /plan → /contract → /tasks → implement → /verify → /uat → /retro
```

| Command | Input | Output | Verification |
|---|---|---|---|
| `/constitution` | — | `memory/constitution/` | seed + filter |
| (intake) | objective | `brief.md` | success metrics |
| `/align` | `brief.md` + `north-star.md` | `alignment.md` | **Measurability Gate**: scores the brief against the North Star; only `aligned` advances |
| `/distill` | `brief.md` + `alignment.md` | `spec` + `acceptance` + `coverage` | grilling loop, zero orphan rows; Step 0 requires `aligned` |
| `/plan` | `spec` | `plan.md` | grounded in constitution |
| `/contract` | `acceptance` | tests 🔴 + eval cases 📋 | proves it is RED |
| `/tasks` | `coverage` | `tasks.md` | GATE: refuses if RED contract is missing |
| implement | `tasks` | code | inner loop 🔴→🟢 (budget → ESCALATE) |
| `/verify` | code | `verification/reports/…` | output + trajectory eval |
| `/uat` | report | full report | against objective; gap → `/distill` |
| `/retro` | `alignment.md` + `verification/reports/…` | `retro.md` | closes the prediction from `/align` (Mission Face) + derives WoW signals (Method Face) |
| `/wow-report` | all `retro.md` | `verification/wow-report.md` | aggregates the ledger: drift per pillar, re-checks, method health, theater smells (observes, does not gate) |

## Three loops
1. **Grilling** (in `/distill`): closes specification gaps before coding.
2. **Inner loop** (implementation, per task): auto-corrects 🔴→🟢; escalates to
   human after 2 identical failures or 3 attempts (tuneable in the constitution).
3. **Feedback** (`/verify`+`/uat`): verify failure → implementation; UAT failure → product → `/distill`.

## Two layers: governance vs execution-runtime
The flow has two layers with distinct owners:
- **Governance (the harness):** the commands + deterministic gates + the **constitution**
  (how to build) + the **North Star** (why the product exists). Versioned,
  reviewed, the same for every adopter.
- **Execution-runtime (chosen by the adopter):** the steps that are **not** commands —
  intake→`brief.md`, the implementation between `/tasks` and `/verify`, and the finish. The
  harness does not name any runtime as mandatory; any one works as long as it respects
  the governance layer's artifacts and gates. See `README.md` (§ "Two layers") and
  `memory/north-star/base/README.md` (contract in the template, engine per-stack).

## Close condition
`feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅`.
