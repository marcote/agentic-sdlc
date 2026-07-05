# Coverage — North-Star Governance + Measurability Gate

> Traceability matrix = source of truth for the status of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) ·
`deferred` (justified gap) · `documented contract (deferred)` (per-stack engine,
out of scope of this repo — see `plan.md` decision 2)

**Objective legend (brief → "Success metrics"):** O1 = out-of-scope hard block
· O2 = zero orphan objectives · O3 = Measurability Gate (without a
measurable/aligned North Star, the flow does not run) · O4 = alignment quantified
(score vs rubric) · O5 = drift governed (ADR + PR) · O6 = harness self-check covers
the new layer, template stack-agnostic/dependency-free.

> **Bootstrap:** this feature introduces the harness North Star; the harness itself
> (unlike an adopting project) has no pillars of its own — `north-star.md`
> is a placeholder. That is why the **Pillar** column is `— (bootstrap)` in all
> rows: there is no harness North Star to map against. `/align` is **skipped
> for this feature** (cannot gate itself), just as the original harness bootstrap
> skipped its own gates — see `plan.md` decision 8 and `acceptance.md` criterion
> MEAS-GATE. From the next feature onward, `/align` runs before `/distill`.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked Test/Eval | Status |
|---|---|---|---|---|---|---|
| — (bootstrap) | O3 | North-Star base layer (schema, rubric, protocol, ADR template, README) | NS-BASE | project | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O3 | `north-star.md` placeholder, `extends: base` | NS-PLACEHOLDER | project | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O3 / O4 | Measurable schema form (mission/pillars/scope/alignment) | NS-SCHEMA-CONTRACT | project | documented contract — per-stack engine (`poirot-fe scripts/north-star/schema.mjs`, ref.) | documented contract (deferred) |
| — (bootstrap) | O1 / O2 | `/align` command+skill (3-layer model) | ALIGN-CMD | project | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O1 / O2 / O4 | Verdict semantics (scopeReject/orphan-check/alignVerdict) | ALIGN-VERDICT-CONTRACT | project | documented contract — per-stack engine (`poirot-fe scripts/north-star/align.mjs`, ref.) | documented contract (deferred) |
| — (bootstrap) | O3 | Step 0 — Measurability Gate in `/distill` | MEAS-GATE | project | `tests/check_80_north_star.sh` (grep `alignment.md` + `Measurability Gate` + `aligned`) | 🟢 green |
| — (bootstrap) | O5 | `amendment-protocol.md` + `adr-template.md` (ADR + PR) | AMEND-ADR | `[given] base/audit-logging` | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O6 | Pillar column in `specs/_template/coverage.md` | COVERAGE-PILLAR | project | `tests/check_80_north_star.sh` (grep `Pillar`) | 🟢 green |
| — (bootstrap) | O6 | Two-layer Way-of-Work (governance vs execution-runtime) | WOW-2LAYER | project | UAT (manual reading `README.md` / `docs/workflow.md`) | ✅ uat |
| — (bootstrap) | O6 | Bash self-check covers the new layer | SELFCHECK | project | `tests/check_80_north_star.sh` (via `tests/run.sh`) | 🟢 green |
| — (bootstrap) | O1 / O4 | The judge scores alignment sensibly | JUDGE-ALIGNMENT | project | `evals/cases/north-star-judge.md` (result: `verification/reports/002-north-star-judge.md`) | 📋 case |
| — | (no writes/retries: governance layer in markdown) | — | `[given] base/idempotency` | inherited | — | deferred (no writes/retries) |
| — | (no network surface) | — | `[given] base/rate-limiting` | inherited | — | deferred (no endpoints/network) |

## Notes
- **No orphan rows:** every objective (O1–O6) has ≥1 criterion; every criterion
  maps to a test/eval/UAT or is `deferred`/`documented contract` with explicit
  justification.
- `[given] base/audit-logging` **applies**: a North Star amendment (change of
  `scope`/`pillars`) is a write of governance state → satisfied by AMEND-ADR
  (ADR + PR = the auditable trail `actor`+`timestamp`+`entity`, git-native
  via commit author/date and PR reviewer).
- `[given] base/idempotency` and `[given] base/rate-limiting` → **deferred**: this
  layer has no retries/webhooks/payments or exposed network surface (it is
  markdown + commands/skills read by a local agent).
- The `NS-SCHEMA-CONTRACT` and `ALIGN-VERDICT-CONTRACT` criteria describe the
  deterministic engine (contract-in-template, per-stack engine): they are **documented
  here, not unit-tested in this repo** — the `/tasks` GATE (see `tasks.md`) excludes
  them from the "🔴 red with linked test" requirement because they are not
  *structural* deterministics verifiable by bash; they are semantic contracts
  deferred to each adopter, with `poirot-fe` as the reference implementation already green there.
- `WOW-2LAYER` is prose content (README/docs), not reliably grep-able structural
  form → closed by UAT, not by `check_80`.
- Design: `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`.
