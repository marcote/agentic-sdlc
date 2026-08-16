# Coverage — 019-lifecycle-boundary

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 name the boundary | R1 | NS-LIFECYCLE-PREDICATES | project | `tests/check_80_north_star.sh` | ✅ uat |
| `real-enforcement` | O1 nothing else moves | R1 | NS-BOUNDARY-BOUNDED | project | idem | ✅ uat |
| `real-enforcement` | O5 the predicate is not dead text | R2 | NS-PREDICATE-REACHABLE | project | idem | ✅ uat |
| `real-enforcement` | O2 whose lifecycle | R3 | NS-ADOPTION-STAYS-IN-SCOPE | project | idem | ✅ uat |
| `real-enforcement` | O6 rejects nothing built | R4 | NS-REJECTS-NOTHING-BUILT | project | idem | ✅ uat |
| `real-enforcement` | O3 the protocol is followed | R5 | NS-ADR-0005-COMPLETE | project | idem | ✅ uat |
| `real-enforcement` | O4 the gate judges this diff | R6 · `D3` | AMEND-LIFECYCLE-REFLEXIVE | project | `tests/check_95_amendment_gate.sh` | ✅ uat |
| `real-enforcement` | O4 the gate stays narrow | R6 · edge 7 | AMEND-PROVENANCE-QUIET | project | idem | ✅ uat |
| `real-enforcement` | O5 | deferred half | JUDGE-BOUNDARY-CHANGES-A-VERDICT | project | `evals/cases/lifecycle-boundary-judge.md` | 📋 case |
| `real-enforcement` | O3 | governed write leaves a trail | audit-logging | `[given] base/audit-logging` | → NS-ADR-0005-COMPLETE + the PR | ✅ uat |
| `real-enforcement` | O6 | the corpus run scored something | check-can-fail | `[given] base/non-vacuous-checks` | → NS-REJECTS-NOTHING-BUILT | ✅ uat |
| `real-enforcement` | O4 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → AMEND-LIFECYCLE-REFLEXIVE | ✅ uat |
| `real-enforcement` | O6 | the check names the corpus it read | check-names-its-tree | `[given] base/non-vacuous-checks` | → NS-REJECTS-NOTHING-BUILT | ✅ uat |
| `agnostic-portability` | — | hermetic under CI conditions | HERMETIC-ENV-80 | `[given] base/hermetic-tests` | `tests/check_80_north_star.sh` | `[given]` carried by 016 |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only by CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — this feature reaches no network, remote repo or live service.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this feature touches
  `memory/north-star/`. Carried and deferred so the stance pin's injection stays auditable;
  `no-prescribe.sh` still runs at `/verify` as `S1`'s `Guard`.
- **`S2-HEDGE`** — no engine gains a capability. Every command this feature uses
  (`schema-valid`, `scope-reject`) already exists with its documented exit contract, and no caller
  is added. Deferred rather than claimed: a row asserting an unchanged surface would be green by
  construction.

## Rows this feature does NOT carry, and why

`check-traceable` and `check-no-self-match` are **discharged by `check_96`** under the project
override in `memory/constitution/constitution.md`.

## The corpus is the interesting row

`NS-REJECTS-NOTHING-BUILT` reads every `## Success metrics` bullet of every brief in `specs/`,
which is **101 objectives** today and grows with the repository. It is the immediate half of this
feature's falsification test: a boundary that rejects work the harness already shipped is wrong.

Edge case 4 is why the row carries `check-can-fail` and `check-names-its-tree`: a zero-hit result
and a run that scored nothing are indistinguishable from outside.

## UAT — 2026-08-16

Every row `✅ uat` except the three `deferred` ones and `JUDGE-BOUNDARY-CHANGES-A-VERDICT`, which
cannot be scored before the 2026-09-08 sweep.

**The immediate half of the falsification test passed:** 101 objectives across every brief in
`specs/`, zero hits. A boundary that rejected work already shipped would be wrong.

**What this feature does not prove.** It does not make `/align` reject more briefs. The enforcer is
the judge; what changed is that the judge now has a line to read where before it had nothing.

## RED state (`/contract`)

Suite **481 PASS / 6 FAIL** against a North Star with no lifecycle predicates and an ADR that did
not exist.

**Two assertions passed at RED, recorded here rather than discovered at `/verify`:**

- `NS-ADOPTION-STAYS-IN-SCOPE` — green by construction: with no lifecycle predicates, nothing could
  exclude adoption tooling. A *must-not* criterion has no honest red state. Proved real by mutation
  M3.
- `NS-REJECTS-NOTHING-BUILT` — 101 objectives, 0 hits against the unamended file. The corpus half
  was live at RED (101 ≥ 90), so only the boundary half was green by construction. Proved real by
  M4.

## GREEN state — 2026-08-16

Suite **488 PASS / 0 FAIL** (pre-019 baseline 479). Eight mutations, one at a time, in
`verification/reports/019-lifecycle-boundary-babac0a.md`.

### `NS-PREDICATE-REACHABLE` was vacuous, and mutation proved it

It built its test objective **from the predicate itself**, so the substring was present by
construction. M2 rewrote a predicate as an 18-word sentence — the exact property the criterion
forbids — and nothing failed.

The fix adds a **10-word cap**, derived from the five predicates that predate this feature rather
than invented. Second consecutive feature where a self-satisfying assertion survived until mutation
testing, after 018's `ADOPT-REL-RESOLUTION`.
