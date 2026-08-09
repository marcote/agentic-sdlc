# Coverage — 016-north-star-integrity

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement`, `frictionless-adoption` | O1 unfilled is not valid | R1 exit 3 | NS-UNFILLED | project | `tests/check_80_north_star.sh` | 🔴 red |
| `real-enforcement`, `frictionless-adoption` | O1 unfilled is not valid | R1 names the fields | NS-UNFILLED-PARTIAL | project | idem | 🔴 red |
| `real-enforcement`, `agnostic-portability` | O2 no false positive | G-a byte identity | NS-TODO-NOT-FALSE-POSITIVE | project | idem | 🔴 red |
| `real-enforcement`, `agnostic-portability` | O2 no false positive | G-a single source | NS-SEED-TABLE-SYNC | project | idem | 🔴 red |
| `measurable-impact` | O3 provenance per pillar | R3 required | NS-SINCE-REQUIRED | project | idem | 🔴 red |
| `measurable-impact` | O3 provenance per pillar | R3 resolves | NS-SINCE-RESOLVES | project | idem | 🔴 red |
| `real-enforcement` | O1 · O3 ordering | R1 · R3 (edge 3) | NS-UNFILLED-BEFORE-SINCE | project | idem | 🔴 red |
| `measurable-impact` | O3 harness migrated | R4 · `D3` | NS-OWN-MIGRATED | project | idem | 🔴 red |
| `real-enforcement`, `measurable-impact` | O5 gate requires provenance | R5 blocked | AMEND-PROV-STALE | project | `tests/check_95_amendment_gate.sh` | 🔴 red |
| `real-enforcement`, `measurable-impact` | O5 provenance alone is not an amendment | R5 passes | AMEND-PROV-ONLY | project | idem | 🔴 red |
| `real-enforcement`, `frictionless-adoption` | O1 `/align` fail-closed | R2 | ALIGN-REFUSES-UNFILLED | project | `tests/check_50_skills.sh` | 🔴 red |
| `measurable-impact` | O4 stamp into alignment.md | R6 | ALIGN-STAMPS-PROVENANCE | project | idem | 🔴 red |
| `real-enforcement`, `frictionless-adoption` | O1 against a real target | R7 | NS-VENDORED-STUB-REJECTED | project | `tests/check_84_vendor.sh` | 🔴 red |
| `measurable-impact` | O3 | `S2` Hedge | NS-ENGINE-CLI-ONLY | `[given] stack/S2 Hedge` | `tests/check_80_north_star.sh` | 🔴 red |
| `measurable-impact` | O4 | R6 | JUDGE-PROVENANCE-USEFUL | project | `evals/cases/provenance-judge.md` | 📋 case |
| `agnostic-portability` | — | hermetic under CI conditions | HERMETIC-ENV-80 | `[given] base/hermetic-tests` | `tests/check_80_north_star.sh` | 🟢 green |
| `agnostic-portability` | — | the hermetic scan's own pattern is not vacuous | HERMETIC-ENV-80-SELF | `[given] base/non-vacuous-checks` | `tests/check_80_north_star.sh` | 🟢 green |
| `real-enforcement` | O1 · O3 | each rule has a negative fixture | check-can-fail | `[given] base/non-vacuous-checks` | → NS-* fixtures | 🔴 red |
| `real-enforcement` | O1 · O3 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → NS-SINCE-RESOLVES | 🔴 red |
| `real-enforcement` | O5 | the gate names what it compared | check-names-its-tree | `[given] base/non-vacuous-checks` | → AMEND-PROV-STALE | 🔴 red |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — this feature reaches no network, remote repo or live service.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this feature touches
  `memory/north-star/base/` and `scripts/`. Carried and deferred rather than dropped so the stance
  pin's injection stays auditable; `no-prescribe.sh` still runs at `/verify` as `S1`'s `Guard`.

## Rows this feature does NOT carry, and why

`check-traceable` and `check-no-self-match` are **discharged by `check_96`** under the project
override in `memory/constitution/constitution.md` — the gate covers the whole tree on every run,
which is strictly stronger than a per-feature row. This is the first feature to benefit from that
override, so it is the first evidence that the optimisation actually reduces per-feature cost:
**21 rows here against 015's 37**, with no loss of enforcement.

## UAT

Pending. Filled at `/uat`: every row reaches `✅ uat` except the two `deferred` ones and
`JUDGE-PROVENANCE-USEFUL`, which cannot be scored before the 2026-09-08 sweep.

## RED state (`/contract`)

Suite **414 PASS / 12 FAIL**. Every assertion touching a 016 artifact is 🔴 against an engine that
still accepts a placeholder.

**Three assertions pass at RED, documented here rather than discovered at `/verify`:**

- `NS-TODO-NOT-FALSE-POSITIVE` — a *must-not-reject* criterion. Today's engine accepts everything,
  so it is green by construction. It has no red state and its value is entirely in the future: it
  fails the moment the discriminator becomes the bare word `TODO` instead of byte identity, which
  is the one way this feature could ship something worse than the defect it fixes.
- `HERMETIC-ENV-80` and `HERMETIC-ENV-80-SELF` — a scan and its own non-vacuity self-test, the same
  documented exception 013, 014 and 015 recorded.
- `AMEND-PROV-ONLY` — also a *must-not-block* criterion, green against a gate that does not yet
  know about provenance. Its whole job is to fail if the staleness check is implemented as "block
  anything that touches a pillar", which is the obvious wrong implementation.
