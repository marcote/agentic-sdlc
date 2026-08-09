# Acceptance — Stack Charter: no load-bearing decision stays mute

> Measurable acceptance criteria in BDD. EACH criterion IS the eval and the UAT step. The
> deterministic portion materialises as a test in `/contract` (`tests/check_92_stack.sh`).
> Fifteen criteria are deterministic and hermetic (own fixtures, no network, no TTY, no branch
> assumptions). Three are non-deterministic — the model-judged verdicts — and become eval cases
> in `evals/cases/stack-charter-judge.md`, following the `north-star-judge.md` precedent.

## Criterion: STACK-CMD  (deterministic)
```gherkin
Given the harness tree
When I inspect .claude/commands/stack.md, .claude/skills/stack/SKILL.md, docs/workflow.md and CLAUDE.md
Then the command and skill exist, the skill documents the seven ordered steps
  (derive S0, Draft, Price, Grill, accept "I don't know", coherence objection, write),
  and both docs show /stack in the loop after seeding the North Star and before the first brief
```

## Criterion: PIN-SHAPE  (deterministic)
```gherkin
Given memory/stack/base/pin-template.md and memory/stack/stack.md
When I parse every "### S<n>" pin block in the charter
Then the template declares Confidence, Because, Buys, Forecloses and Falsifier as required,
  and every pin in the charter carries all five with a non-empty value
```

## Criterion: PROVISIONAL-HEDGE  (deterministic)
```gherkin
Given a charter containing a pin whose Confidence is PROVISIONAL
When the check parses that pin
Then the pin has a non-empty Hedge field, and a fixture charter with a PROVISIONAL pin
  lacking a Hedge is reported as malformed (exit non-zero)
```

## Criterion: STANCE-GUARD  (deterministic)
```gherkin
Given a charter containing a pin marked [stance]
When the check parses that pin and resolves its Guard
Then the pin names both a Guard command and an Injects clause, the named command is
  executable from the repo root, and a fixture stance pin with no Guard is reported as malformed
```

## Criterion: GUARD-RUNS  (deterministic)
```gherkin
Given .claude/skills/verify/SKILL.md and the harness's own charter
When I run the verification contract
Then the skill documents that each [stance] pin's Guard command is executed and must exit 0,
  and the harness's own stance Guard runs inside tests/run.sh and is green
```

## Criterion: PLAN-GATE  (deterministic)
```gherkin
Given .claude/commands/plan.md
When I inspect its gate section
Then it documents a fail-closed guard reading acceptance.md plus the charter, emitting exactly
  one of PASS, UNPINNED or TRIPPED and never staying silent; PASS requires plan.md to cite the
  pins it depends on; and an absent charter yields a "run /stack first" refusal, not a pass
```

## Criterion: PLAN-BOUNCE  (deterministic)
```gherkin
Given .claude/commands/plan.md and .claude/skills/distill/SKILL.md
When UNPINNED mints a pin marked [stance]
Then both documents describe the bounce: coverage.md reopens to receive the pin's Injects rows
  and is re-frozen before /plan resumes, rather than the pin applying only from the next feature
```

## Criterion: TRIPPED-BILL  (deterministic)
```gherkin
Given .claude/commands/plan.md
When I inspect the TRIPPED branch
Then it requires reporting all four of: which criterion invalidated which pin; the reversal
  cost as previously declared rather than re-estimated; whether the Hedge that was paid for
  exists in the code; and the two paths (amend the pin, or narrow the criterion)
```

## Criterion: S0-PIN  (deterministic)
```gherkin
Given the harness's own charter
When I parse the S0 pin
Then S0 exists as the first pin, records the blast-radius answers it was derived from,
  and carries a Falsifier stating what would raise the tier
```

## Criterion: S0-SCOPE-ONLY  (deterministic)
```gherkin
Given memory/stack/base/README.md and .claude/skills/stack/SKILL.md
When I inspect what S0 is documented to scale
Then both state that S0 varies the number of pins elicited and criteria produced only, that
  the /contract RED gate and 100% coverage apply identically at every tier, and that
  base/principles.md P6 plus secret-scan.sh do not scale with S0
```

## Criterion: NO-PRESCRIBE  (deterministic, invariant tied to the deliverable)
```gherkin
Given memory/stack/base/ exists
When I scan its files for tool, language, runtime and vendor names outside code fences
Then no such name appears as a required default in prose; names appearing inside fenced
  example pins are ignored, using the code-span-aware idiom that fixed check_90 in e6bc658
```

## Criterion: DISTILL-STANCE  (deterministic)
```gherkin
Given .claude/skills/distill/SKILL.md
When I inspect step 1
Then it reads [stance] pins from the charter and injects their Injects rows as coverage rows,
  alongside the existing base/patterns/*.md injection
```

## Criterion: VENDOR-STACK  (deterministic)
```gherkin
Given a temp target directory
When I run scripts/vendor.sh --apply against it
Then memory/stack/base/ is present (KEEP), memory/stack/stack.md is a seeded stub carrying no
  harness pin, and the generated CLAUDE.md "## Stack" section points at the charter
```

## Criterion: WOW-HEALTH  (deterministic)
```gherkin
Given .claude/skills/wow-report/SKILL.md
When I inspect its aggregation section
Then it emits two charter-health signals: pins that tripped, and decisions that caused rework
  with no pin covering them
```

## Criterion: CHARTER-SEED  (deterministic)
```gherkin
Given memory/stack/stack.md after /stack has been run on the harness itself
When I parse its pins
Then the decisions live today are pinned — the py3 reference engine (006), the bash-only
  dependency-free baseline, and the impose-no-runtime stance — each well-formed per PIN-SHAPE
```

## Criterion: RERUN-IDEMPOTENT  (deterministic)  ·  `[given] base/idempotency`
```gherkin
Given a charter with N pins including one SUPERSEDED entry
When /stack's write step is applied a second time with the same inputs
Then the charter still has N pins, none duplicated or silently dropped, and the SUPERSEDED
  history is preserved verbatim
```

## Criterion: AMEND-TRAIL  (deterministic)  ·  `[given] base/audit-logging`
```gherkin
Given a pin that has been amended
When I inspect its SUPERSEDED entry
Then it records the date, the reason, and what tripped it
```

## Criterion: EMPTY-CHARTER  (deterministic)
```gherkin
Given a freshly vendored target whose memory/stack/stack.md is the seeded stub with zero pins
When the engine validates it, emits its guards and computes its exposure, and /plan reads it
Then "empty" is reported distinctly from "malformed": pin-valid exits 3 with a "run /stack"
  message and not the malformed code 2; guards emits nothing and exits 0, because having no
  stance pin is not an error; exposure reports zero pins and exits 0; and /plan's gate
  documents refusing on an empty charter exactly as it refuses on an absent one
```

## Criterion: HERMETIC-ENV  (deterministic)  ·  `[given] base/hermetic-tests`
```gherkin
Given a detached-HEAD checkout with no controlling terminal
When I run tests/check_92_stack.sh
Then it builds its own fixtures, assumes no local main branch, no writable well-known path,
  no locale and no clock, and passes
```

---

## Criterion: JUDGE-TRIPPED  (non-deterministic → eval case)

The `TRIPPED` classification is model-judged, not string-matched. The eval presents a charter
plus a feature's acceptance criteria and checks the judge **fires on a real match and stays
silent on a superficial one**: a criterion requiring concurrent writers must trip a
single-writer datastore pin, while a criterion merely *mentioning* the datastore without
straining its declared `Falsifier` must not. A judge that trips on keyword overlap is a FAIL —
false `TRIPPED` verdicts make the gate noise, and a gate that cries wolf gets ignored.
→ `evals/cases/stack-charter-judge.md`

## Criterion: JUDGE-COHERENCE  (non-deterministic → eval case)

The coherence objection (step 5 of `/stack`) must raise an explicit objection on an incoherent
set — the *API-first in Assembler* shape, where each pin is individually defensible — and must
return an explicit "coherent" verdict, not silence, on a sound set. Silence on either is a
FAIL: the forcing function is that the model must **pronounce on the set**.
→ `evals/cases/stack-charter-judge.md`

## Criterion: JUDGE-HEDGE-COST  (non-deterministic → eval case)

The hedge admission test must reject a hedge that costs real design work as premature
abstraction, and accept one that costs ~nothing. Presented with a `PROVISIONAL` pin on a
throwaway script whose proposed hedge is a full ports-and-adapters layer, the judge must
reject and offer the two honest alternatives (pin firmly accepting the declared reversal cost,
or resolve the uncertainty first). A judge that accepts every hedge turns the mechanism into
the problem it was designed to avoid.
→ `evals/cases/stack-charter-judge.md`
