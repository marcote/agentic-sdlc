# Technical plan — Ground rules: a project cannot start below the quality bar

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Stack gate — first real run of 013's `/plan` guard

Inputs: `specs/014-ground-rules/acceptance.md` × `memory/stack/stack.md` (5 pins, valid, not
empty). **Verdict: `PASS`**, with two strains recorded rather than waved through.

**Pins this plan rests on** (the `PASS` citation requirement):

| Pin | What this plan takes from it |
| --- | --- |
| `S4` charter format | The `Answers:` field and the `n/a` block are grammar extensions inside a line-oriented markdown file (D1–D3). |
| `S2` py3 reference engine | The `ground-rules` capability is a subcommand of the existing reference engine, not a new tool (D4). |
| `S3` shell + coreutils baseline | `check_94` adds no dependency; `no-prescribe.sh` gains a path, not a runtime (D10–D11). |
| `S1` impose no runtime | The ground rules name questions only; `GR-NO-PRESCRIBE` is `S1`'s own `Injects` applied to this feature's deliverable (D11). |

**No `TRIPPED`.** No criterion matches a declared `Falsifier`. Two near-misses, both recorded
because a gate that only reports the clean answer is not worth running:

- **`S1` is strained by this feature's whole premise, and its wording is now imprecise.** `S1`
  reads *"the harness ships mechanism, never opinions"*, and 014 ships six mandatory questions
  inherited by every adopter — which is, in plain language, an opinion about what a project must
  consider. It does **not** trip the `Falsifier` (that requires targeting one ecosystem, and a
  ground rule names none). The distinction that saves it is precisely this feature's thesis: **a
  question is mechanism, an answer is opinion.** But `S1` does not say that, so its statement is
  sharpened as part of this work (D9) rather than left to be re-argued next time.
- **`S2` is strained for the second time.** 013 shipped a second reference engine; 014 adds a
  subcommand to it, widening again the surface an interpreter-less adopter cannot run. Still not
  tripped — the `Falsifier` requires an adopter *reporting* the harness "needs" it, or the intake
  gate scoring **the hosting** against the runtime predicate. `/align` scored `scopeCompliance: 3`
  against the *ground rules being universal*, not against the engines. The hedge holds: the new
  capability stays shell-CLI-only (`ENGINE-CLI-ONLY`, D4). **A third strain should be read as the
  falsifier arriving, not as another near-miss.**

**No `UNPINNED`.** Every load-bearing decision this plan makes rests on a pin above. The
harness's own charter *does* currently fail the new floor — that is `CHARTER-COVERED` (FR-12),
this feature's deliverable, not a missing pin blocking its plan.

## Technical decisions

- **D1 — Ground rule grammar mirrors the pin grammar.** `memory/stack/base/ground-rules.md`
  holds blocks: `### GR<n> — <name>`, then `- Question:` and `- Prevents:`. `Prevents` is not
  decoration — it is the recorded justification the amended `frictionless-adoption` signal
  measures, so a ground rule that cannot say what it prevents has no business being mandatory.
  Constrained by: `GR-SIX`, `S4`.

- **D2 — `Answers: GR2, GR4` is an optional, list-valued pin field.** Comma-separated ids;
  splitting is lossless because ids are bare tokens. Optional because not every pin answers a
  ground rule. **An id outside the effective set is rejected, never ignored** — silently dropping
  a typo would report `uncovered` for the real rule while the author believes it is answered,
  which is exactly the accepted-then-never-executed failure `SUBSTRATE-GUARD` taught in 013.
  Constrained by: `ANSWERS-FIELD`, `S4`.

- **D3 — A declination is a block, not a pin.** `### GR<n> — n/a` with `- Because:` and
  `- Falsifier:`. It carries no `Buys`/`Forecloses` because nothing was bought or foreclosed;
  forcing those fields would be filler-to-comply, which the harness rejects elsewhere. The
  `Falsifier` is what makes a decline **expire**: an `n/a` written in week one stops being valid
  when the project crosses the stated line, instead of silently outliving it.
  Constrained by: `NA-FORM`, `[given] base/audit-logging`.

- **D4 — `engine.py ground-rules <charter>`**, one line per rule: `GR<n>: pin <id>` / `GR<n>:
  n/a` / `GR<n>: uncovered`. Exit contract extends the existing one: **0** = fully covered,
  **1** = incomplete (uncovered rules on stderr), **2** = malformed, **3** = empty charter.
  Shell-CLI only, no importable API — `S2`'s hedge applies to every new capability, not only to
  the ones that existed when it was written. Constrained by: `GR-COVERAGE`, `ENGINE-CLI-ONLY`.

- **D5 — `SUPERSEDED` pins are excluded from coverage.** History is not a rationale. If a
  superseded pin still counted, amending a pin would silently drop the project below the bar —
  the exact class of invisible regression this feature exists to stop.
  Constrained by: `SUPERSEDED-NOT-COVERAGE`.

- **D6 — Effective set = base ∪ project, additive only.** `memory/stack/ground-rules.md` (project
  layer, `extends: base`) may add rules; the engine **rejects** an effective set missing any base
  rule. Third instance of the inheritance idiom already used by `constitution.md` and
  `north-star.md` — no new concept. Removal is prohibited because the escape hatch already exists
  and is auditable: `n/a` with a reason. Constrained by: `GR-ADD-NOT-REMOVE`.

- **D7 — `/plan` gains `UNCOVERED`, ordered before the other three.** Coverage is cheaper to
  evaluate than a semantic falsifier read, and a charter below the floor makes the other verdicts
  premature. Still exactly one verdict, still never silence.
  Constrained by: `PLAN-UNCOVERED`.

- **D8 — `/stack` walks the six in Grill, and migrates a pre-existing charter in place.** On a
  charter below coverage it proposes which existing pin answers which rule and asks where an
  `n/a` belongs. **The gate does not soften**: no grace period exists anywhere in the
  implementation, because a warning that does not block is a mute assumption with extra steps.
  The migration is what makes the hard gate *justified* friction under the amended signal — it
  states what it prevents and hands over the fix. Constrained by: `STACK-WALKS-SIX`, `MIGRATION`.

- **D9 — Bring the harness's own charter to coverage, and sharpen `S1` while doing it.**
  Retrofit `Answers:` onto `S0`–`S4`, add pins or honest `n/a` blocks for the rules they leave
  open, and amend `S1`'s statement from *"ships mechanism, never opinions"* to language that
  distinguishes a required **question** from a prescribed **answer**. The amendment is
  deliberate, not falsifier-driven, and carries its `SUPERSEDED` trail like any other.
  Constrained by: `CHARTER-COVERED`, D3 of the constitution.

- **D10 — Every assertion ships a negative fixture, built in its own block.** `GR-SIX` fails on
  a seven-rule fixture; `ANSWERS-FIELD` on an unknown id; `NA-FORM` on a missing `Falsifier`;
  `GR-ADD-NOT-REMOVE` on a layer omitting a base rule; `SUPERSEDED-NOT-COVERAGE` on a charter
  whose only answering pin is superseded. **Fixtures are created in the block that uses them** —
  013's fifth vacuous assertion borrowed one from another block, silently checked a missing file
  and recorded neither PASS nor FAIL. And each new check is confirmed to actually appear in what
  `run.sh` executes, per the `SUBSTRATE-GUARD` lesson. Constrained by: principle 2.

- **D11 — `GR-NO-PRESCRIBE` reuses `prose_only` and extends the guard's reach.**
  `ground-rules.md` lives under `memory/stack/base/`, so `no-prescribe.sh` already covers it by
  path — no new scan, no second denylist to drift. The ground rules will necessarily illustrate
  concrete answers, so every example goes inside a fence. Constrained by: `GR-NO-PRESCRIBE`,
  `S1`.

## Components / modules

- **`memory/stack/base/ground-rules.md`** → the six, with `Question` + `Prevents` (D1).
- **`memory/stack/ground-rules.md`** → project layer stub, `extends: base`, additive only (D6).
- **`memory/stack/base/pin-template.md`** → `Answers:` field semantics; the `n/a` block form.
- **`memory/stack/base/README.md`** → the floor does not scale with `S0`; second floor alongside
  `P6`.
- **`scripts/stack/engine.py`** → `ground-rules` subcommand; `Answers:` parsing with unknown-id
  rejection; `SUPERSEDED` exclusion; effective-set assembly (D2, D4, D5, D6).
- **`memory/stack/stack.md`** → `Answers:` on `S0`–`S4`, new pins / `n/a` blocks to reach full
  coverage, `S1` sharpened (D9).
- **`.claude/commands/plan.md`** → the `UNCOVERED` verdict (D7).
- **`.claude/skills/stack/SKILL.md`** → the six in Grill + guided migration (D8).
- **`tests/check_94_ground_rules.sh`** → 14 deterministic criteria with negative fixtures (D10).
- **`evals/cases/ground-rules-judge.md`** → the two honesty cases.

## Risks

- **The floor becomes a checkbox.** `Answers: GR6` on an unrelated pin reports coverage that is
  not there — and the engine cannot tell, by construction. → Mitigation: named as the blind spot
  it is, with `JUDGE-GR-ANSWERED` and `JUDGE-NA-HONEST` covering it as eval cases rather than
  pretending a script can settle it. This risk does not go away; it is bounded and disclosed.
- **Six becomes seven, then fifteen.** → Mitigation: the cap is **asserted in the suite**, not
  documented. Growth fails loudly. `/align` also scored `frictionless-adoption` partly on the
  bound, so raising it invalidates that score.
- **`ground-rules.md` smuggles an answer inside a question.** *"How do you declare dependencies
  and run tasks?"* is a question; adding *"a single tool should do both"* is an answer wearing a
  question's clothes. `no-prescribe.sh` catches named tools, not smuggled opinions. → Mitigation:
  `/uat` judges this against the shipped artifact, and `alignment.md` already records that
  `scopeCompliance: 3` sits one point above rejection.
- **The hard gate reads as hostile to an existing adopter.** → Mitigation: D8's guided
  migration. Under the amended signal this is the difference between justified and unjustified
  friction, and it is the first feature that has to earn that distinction rather than assert it.
- **`S1`'s amendment looks like convenience.** Sharpening a pin that this feature strains is
  exactly what a self-serving amendment would look like. → Mitigation: the change narrows the
  claim (mechanism *and a floor of questions*, never answers) rather than widening it, and the
  `SUPERSEDED` trail records that 014 prompted it. `/retro` should challenge it, alongside the
  same question already open about ADR `0004`.
