# Coverage — Ground rules: a project cannot start below the quality bar

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** via the mapping in `alignment.md` (`aligned`, 4/3/3).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution **or charter**) ·
`deferred` (justified gap)

Seeding — **first `/distill` run under the amended step 1, which reads the charter as well as
the constitution:**

- **`base/audit-logging`** applies: a declined ground rule is a recorded state, and must leave a
  trail (`NA-FORM`).
- **`base/hermetic-tests`** applies for `hermetic-env`; its `hermetic-offline` criterion is
  `deferred` — 014 reaches no network or remote source.
- **`base/idempotency`** and **`base/rate-limiting`** do not apply: no repeatable write beyond
  what 013 already covers, no network-exposed surface.
- **Charter pin `S1` `[stance]`** injected `GR-NO-PRESCRIBE` — which is *exactly* the risk
  `/align` flagged at `scopeCompliance: 3`. The charter surfaced it without anyone remembering.
- **Charter pin `S2` `PROVISIONAL`** injected `ENGINE-CLI-ONLY` — the hedge that keeps the
  reference engine reimplementable applies to the subcommand this feature adds.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `agnostic-portability` · `frictionless-adoption` | O2 six universal rules, questions not answers | Exactly six ground rules ship, ids GR1–GR6, cap asserted | GR-SIX | project | `check_94_ground_rules.sh` | ✅ uat |
| `real-enforcement` | O3 coverage mechanically reportable | A pin may declare `Answers: GRn`; an unknown id is rejected | ANSWERS-FIELD | project | `check_94_ground_rules.sh` | ✅ uat |
| `real-enforcement` · `frictionless-adoption` | O1 · O4 declining stays cheap but expires | `n/a` carries `Because` + `Falsifier`, is not a pin | NA-FORM | `[given] base/audit-logging` | `check_94_ground_rules.sh` | ✅ uat |
| `real-enforcement` | O3 coverage mechanically reportable | `engine.py ground-rules` emits pin / n/a / uncovered, stable | GR-COVERAGE | project | `check_94_ground_rules.sh` | ✅ uat |
| `real-enforcement` | O1 a project cannot start below the bar | A `SUPERSEDED` pin does not count as coverage | SUPERSEDED-NOT-COVERAGE | project | `check_94_ground_rules.sh` | ✅ uat |
| `real-enforcement` · `measurable-impact` | O1 a project cannot start below the bar | `/plan` emits `UNCOVERED` as a fourth verdict, never silence | PLAN-UNCOVERED | project | `check_94_ground_rules.sh` | ✅ uat |
| `frictionless-adoption` | O2 friction bounded and justified | `/stack` walks all six in Grill | STACK-WALKS-SIX | project | `check_94_ground_rules.sh` | ✅ uat |
| `frictionless-adoption` · `real-enforcement` | O1 · O2 hard gate, guided fix | Pre-existing charter gets guided migration; no grace period | MIGRATION | project | `check_94_ground_rules.sh` | ✅ uat |
| `real-enforcement` | O4 floor independent of the rigor tier | `S0` never affects whether a ground rule is answered | GR-FLOOR-NO-SCALE | project | `check_94_ground_rules.sh` | ✅ uat |
| `agnostic-portability` | O4 the floor is additive only | A project layer may add; omitting a base rule is rejected | GR-ADD-NOT-REMOVE | project | `check_94_ground_rules.sh` | ✅ uat |
| `real-enforcement` · `measurable-impact` | O5 reflexive dogfood | The harness's own charter resolves all six | CHARTER-COVERED | project | `check_94_ground_rules.sh` | ✅ uat |
| — | — | The new capability is shell-CLI only, no importable API | ENGINE-CLI-ONLY | `[given]` charter `S2` Hedge | `check_94_ground_rules.sh` | ✅ uat |
| — | — | `ground-rules.md` names no tool/runtime/vendor in prose | GR-NO-PRESCRIBE | `[given]` charter `S1` Injects | `check_94_ground_rules.sh` + `no-prescribe.sh` | ✅ uat |
| — | — | Suite builds own fixtures; passes detached-HEAD, no-TTY | HERMETIC-ENV | `[given] base/hermetic-tests` | `check_94_ground_rules.sh` | ✅ uat |
| — | — | External dependency behind an override seam | (hermetic-offline) | `[given] base/hermetic-tests` | — | `deferred` — 014 reaches no network |
| `real-enforcement` | O3 coverage must mean something | Judge rejects a pin claiming a ground rule it does not answer | JUDGE-GR-ANSWERED | project | `evals/cases/ground-rules-judge.md` | 📋 case |
| `measurable-impact` | O1 the escape hatch must not become a hole | Judge rejects a false `n/a`, accepts a legitimate one | JUDGE-NA-HONEST | project | `evals/cases/ground-rules-judge.md` | 📋 case |

**No orphan rows:** every brief objective (O1 cannot start below the bar, O2 six questions not
answers, O3 mechanically reportable, O4 floor independent of `S0` and additive only, O5 dogfood)
maps to ≥1 criterion carrying a pillar. Every criterion has a deterministic test or an eval
case. The one `deferred` row is justified above. **Spec freezable.**

**RED proved (`/contract`, 2026-08-08):** `bash tests/run.sh` → **337 PASS / 23 FAIL**
(327/0 before the contract). All 14 deterministic criteria are 🔴 RED via
`tests/check_94_ground_rules.sh`; the two non-deterministic criteria are 📋 present in
`evals/cases/ground-rules-judge.md` (4 cases). `memory/stack/base/ground-rules.md` and the
`ground-rules` subcommand do not exist.

**Three false passes caught while proving RED — the sixth, seventh and eighth occurrences of
the vacuity family, and they happened *despite* `plan.md` D10 warning about exactly this.**
`argparse` exits **2** for an unknown subcommand, and three assertions of the form *"this must
be rejected"* checked only for exit 2 — so they passed because `ground-rules` **was not
implemented**, not because anything was rejected. Every one of them would have gone green on an
empty implementation. Fixed by requiring the engine's own diagnostic on stderr (`unknown ground
rule`, `falsifier`, `omits`) in addition to the exit code.

*That the plan named this trap and it happened anyway is the strongest evidence yet for the
`non-vacuous-checks` constitution rule: a written warning did not prevent it. Only a mechanical
check will.*

Ten assertions pass at RED **by design**: meta-assertions that a fixture is detectable, the
`PASS`/`UNPINNED`/`TRIPPED` preconditions 013 already left green, and `HERMETIC-ENV`'s
non-vacuity self-tests.

Traps carried forward from 013, all of which bit there and must not bite again:

- **Every assertion needs a negative fixture.** `GR-SIX` must fail on a seven-rule fixture,
  `ANSWERS-FIELD` on an unknown id, `NA-FORM` on a missing `Falsifier`, `GR-ADD-NOT-REMOVE` on a
  layer omitting a base rule. An assertion that only ever sees the good case certifies nothing.
- **Build each fixture in the block that uses it.** 013's fifth vacuous assertion pointed at a
  fixture from another block, silently checked a missing file, and recorded neither PASS nor
  FAIL.
- **Confirm a new check actually runs.** `SUBSTRATE-GUARD` in 013 was a declared check that
  validated and was then never executed — worse than a vacuous one, because nothing looked wrong.
- **`GR-NO-PRESCRIBE` must be code-span aware**, reusing `prose_only` — the ground rules will
  necessarily illustrate real answers inside fences.

**Predictions carried to `/retro`** (from `alignment.md`):

1. **`scopeCompliance: 3` is one point above rejection.** If the shipped `ground-rules.md` names
   a single tool as a default, the feature crosses from mechanism to imposition.
   `GR-NO-PRESCRIBE` makes the letter of it mechanical; whether a *question* smuggles an answer
   is judgment, and belongs to `/uat`.
2. **This is the first brief scored under the amended `frictionless-adoption` signal**, so
   `/retro` must rule on whether ADR `0004` was sound or self-serving. The falsification test:
   did any real friction get **rejected** for lacking justification, or does everything now
   qualify by construction?

**Implementation done (T1–T7).** `bash tests/run.sh` → **365 PASS / 0 FAIL** (327/0 before 014;
337/23 at RED). All 14 deterministic criteria 🟢. The two `📋 case` rows stay open for `/verify`.

**T7 audit — the two things 013 taught cannot be assumed:**

1. **Every criterion emits a traceable result.** Checked by name against `run.sh` output.
   `PLAN-UNCOVERED` initially emitted **nothing traceable**: its assertions used
   `assert_contains`, which reports the path and pattern but not the criterion, so its results
   could not be tied back to a coverage row. Not a dead assertion — an unauditable one, which is
   the same problem one step removed. Relabelled, and a second assertion added proving
   `UNCOVERED` is documented *before* the other verdicts.
2. **Every rejection path is reachable and names what it rejected**, verified by running each
   negative fixture: `unknown ground rule GR9 claimed by pin S1`, `declination GR2 … is missing
   Falsifier`, `… omits base ground rule(s): GR6`, `uncovered ground rule(s): …`.

**Two more vacuity-family defects, occurrences nine and ten:**

- **A fence-blind counter.** `gr_ids` read the example declination inside `ground-rules.md`'s own
  fenced block as a seventh rule, failing `GR-SIX` against a correct file. Same code-span
  blindness as `prose_only` and the engine parser — this time in a *counter* rather than a
  scanner, and failing toward the safe side (a false FAIL, not a false PASS).
- **A pattern that could not tell assertion from denial.** `MIGRATION` grepped for
  `grace period`, and `plan.md` legitimately states *"There is no grace period"* — so the check
  flagged its own fix. Now excludes negated forms, with self-tests proving it still catches a
  real grant and no longer flags a denial.

**D3 reflexive dogfood — the harness answered six questions it had never asked itself.** All six
were `uncovered`. Four new pins were needed and none was manufactured:

| Rule | Resolution |
|---|---|
| `GR1` · `GR3` | **`S5`** — delivery is vendored files executed in place; no deployment, as many instances as clones. One pin answering two rules, the list-valued path working for real. |
| `GR2` | **`S6`** — state is versioned markdown; git is the concurrency control. Never stated before. |
| `GR4` | `S2` + `S3`, retrofitted with `Answers:` — already decided, now linked. |
| `GR5` | **`S7`** — green proves the harness's machinery and **nothing about an adopter's product**. This distinction had been implicit since feature 001. |
| `GR6` | **`S8`** — fail closed, write nothing, never partially apply. Practised since 007/009/013 and never written down. |

`S1` was **sharpened, not superseded**: its text said *"ships mechanism, never opinions"*, which
stopped being true the moment this feature shipped six mandatory questions. `plan.md` D9 called
for a `SUPERSEDED` trail; that was declined here, because superseding claims a decision changed
and this one did not — it was under-specified. The clarification is recorded inline instead, with
its reason. Its `Falsifier` gained a second clause: *any artifact under `base/` stating an answer
rather than a question.*

**UAT (2026-08-09) — no product gap. The objective is demonstrated end to end.**

Walked against the **objective**, not the spec: vendored onto a clean repository and exercised
the adopter's real path.

| Walked | Result |
|---|---|
| Adopter receives the floor | ✅ `base/ground-rules.md` travels as KEEP with the rest of `base/` |
| Day one (empty charter) | ✅ `empty: no pins yet — run /stack`, exit 3 — 013's fix still holds |
| **A one-pin charter no longer passes** | ✅ `pin-valid` says VALID, `ground-rules` reports **GR1–GR6 uncovered, exit 1** → `/plan` returns `UNCOVERED` |
| The extension path is discoverable | ✅ `base/ground-rules.md` documents adding a project layer, additive only |
| A missing project layer is tolerated | ✅ engine works on `base/` alone — exit 1 (incomplete), not a crash |
| No tool named in prose | ✅ `no-prescribe.sh` green on the shipped artifact |

**The exact hole 014 was built to close is closed**, and on a real vendored target rather than
on the harness itself: a charter that the previous feature called *valid* now cannot reach a
technical plan while any aspect of the work has no recorded rationale.

**Human judgment on the scope edge — the thing no check can settle.** `GR-NO-PRESCRIBE` proves
no tool is *named*; it cannot prove a question does not *smuggle an answer*. Audited all six;
five read as neutral. **`GR1` leans**: it asks whether the core is separable from the way it is
reached, and its `Prevents` argues that separating costs nothing now while fusing costs a
rewrite. Two honest readings — an architectural opinion in a question's clothes, or the
`Prevents` field doing exactly its job by naming the asymmetry that motivated the whole design.

**Ruled by the maintainer: it is a question. `GR1` stands as written.** The reasoning: `Prevents`
exists to record what the friction buys — without it, the amended `frictionless-adoption` signal
has nothing to measure — and *"separable or not"* honestly admits *"no, and here is why"*.
The tension is recorded rather than resolved: `GR1` is the rule closest to the scope edge, and
if a future reviewer reads it as prescription, this is where that argument starts.

**14 deterministic criteria ✅ uat · coverage 100%.**

**The two `📋 case` rows stay open**, on 013's precedent and for the same reason: scoring
`JUDGE-GR-ANSWERED` and `JUDGE-NA-HONEST` here would be the authoring model grading its own
output. `pending-observation` for `/retro`, with the trigger inherited from 013 — the first
feature whose gate produces a real verdict against pins that predate it.
