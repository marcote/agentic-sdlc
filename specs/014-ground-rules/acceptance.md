# Acceptance — Ground rules: a project cannot start below the quality bar

> Measurable acceptance criteria in BDD. EACH criterion IS the eval and the UAT step. The
> deterministic portion materialises as a test in `/contract` (`tests/check_94_ground_rules.sh`).
> Thirteen are deterministic and hermetic; two are non-deterministic and become eval cases in
> `evals/cases/ground-rules-judge.md` — both cover the same blind spot, that the engine can
> verify a ground rule *is claimed* but never that the claim is *honest*.

## Criterion: GR-SIX  (deterministic)
```gherkin
Given memory/stack/base/ground-rules.md
When I parse its ground rule blocks
Then there are exactly six, with ids GR1 through GR6, each stating a question and what it
  prevents, and a fixture file carrying a seventh is reported as over the cap
```

## Criterion: ANSWERS-FIELD  (deterministic)
```gherkin
Given a charter whose pin declares "Answers: GR2"
When the engine parses it
Then the claim is recorded against GR2; a pin with no Answers field is still valid; and a pin
  declaring an id that is not in the effective ground rule set is rejected, never ignored
```

## Criterion: NA-FORM  (deterministic)  ·  `[given] base/audit-logging`
```gherkin
Given a charter declining a ground rule
When the engine parses that declination
Then it carries both Because and Falsifier, is not treated as a pin, and a declination missing
  either field is rejected — so a decline records why it was made and when it expires
```

## Criterion: GR-COVERAGE  (deterministic)
```gherkin
Given a charter with some ground rules answered by pins, some declined, and some untouched
When I run `engine.py ground-rules <charter>` twice
Then it emits one line per ground rule reading "pin <id>", "n/a" or "uncovered", the two runs
  are byte-identical, and the exit code distinguishes full coverage from incomplete coverage
```

## Criterion: SUPERSEDED-NOT-COVERAGE  (deterministic)
```gherkin
Given a charter whose only pin answering GR2 is marked SUPERSEDED
When coverage is computed
Then GR2 reads "uncovered", because history is not a rationale — otherwise amending a pin would
  silently drop the project below the bar
```

## Criterion: PLAN-UNCOVERED  (deterministic)
```gherkin
Given .claude/commands/plan.md
When I inspect its gate section
Then UNCOVERED is documented as a fourth verdict alongside PASS, UNPINNED and TRIPPED; the gate
  still emits exactly one and never stays silent; and UNCOVERED refuses to proceed while any
  ground rule lacks a verdict
```

## Criterion: STACK-WALKS-SIX  (deterministic)
```gherkin
Given .claude/skills/stack/SKILL.md
When I inspect the Grill step
Then it walks all six ground rules explicitly, so the default path produces a covered charter
  rather than one that trips the gate at /plan
```

## Criterion: MIGRATION  (deterministic)
```gherkin
Given a charter that predates the ground rules and covers none of them
When /stack is documented for that case
Then it detects the shortfall, proposes which existing pin answers which ground rule, and asks
  where an n/a belongs — while the gate itself stays hard, with no grace period documented
  anywhere
```

## Criterion: GR-FLOOR-NO-SCALE  (deterministic)
```gherkin
Given memory/stack/base/ground-rules.md and memory/stack/base/README.md
When I inspect what S0 is documented to affect
Then both state that S0 scales how deep an answer goes and how many pins exist beyond the floor,
  never whether a ground rule is answered, naming this the second floor alongside P6
```

## Criterion: GR-ADD-NOT-REMOVE  (deterministic)
```gherkin
Given a project ground rule layer
When it adds a rule, and separately when it omits one of the six base rules
Then the addition is accepted into the effective set, and the omission is rejected — the floor
  is additive only, and the escape hatch is n/a with a reason, never removal
```

## Criterion: CHARTER-COVERED  (deterministic)  ·  D3 reflexive dogfood
```gherkin
Given the harness's own memory/stack/stack.md after this feature
When I run `engine.py ground-rules` against it
Then all six resolve — each to a pin carrying Answers, or to an honest n/a — and the command
  reports full coverage
```

## Criterion: ENGINE-CLI-ONLY  (deterministic)  ·  `[given]` from charter pin `S2` (Hedge)
```gherkin
Given the new ground-rules capability in scripts/stack/engine.py
When I inspect how it is reachable
Then it is a shell-level subcommand with a documented exit contract and no importable API, so a
  reimplementation in another stack stays drop-in and the S2 hedge is not quietly spent
```

## Criterion: GR-NO-PRESCRIBE  (deterministic)  ·  `[given]` from charter pin `S1` (Injects)
```gherkin
Given memory/stack/base/ground-rules.md
When no-prescribe.sh scans it
Then no tool, language, runtime or vendor is named as a default in prose; concrete names appear
  only inside fenced examples, so the ground rules stay questions rather than answers
```

## Criterion: HERMETIC-ENV  (deterministic)  ·  `[given] base/hermetic-tests`
```gherkin
Given a detached-HEAD checkout with no controlling terminal
When I run tests/check_94_ground_rules.sh
Then it builds its own fixtures, assumes no local main branch, no writable well-known path, no
  locale and no clock, and passes
```

---

## Criterion: JUDGE-GR-ANSWERED  (non-deterministic → eval case)

The engine can verify that a pin **claims** a ground rule; it cannot verify the claim is
**honest**. The eval presents a pin declaring `Answers: GR6` (failure posture) whose content is
about a logging library — related in topic, silent on what happens when the system breaks — and
requires the judge to reject it as not answering the rule. It pairs this with a pin that
genuinely answers `GR6` and must be accepted. A judge that accepts on topical overlap turns
coverage into a checkbox, which is worse than no coverage: it reports a floor that is not there.
→ `evals/cases/ground-rules-judge.md`

## Criterion: JUDGE-NA-HONEST  (non-deterministic → eval case)

An `n/a` can be false rather than merely convenient. The eval presents a project that writes
files declining `GR2` (persistence) as *"no persistence"*, and requires the judge to reject the
decline and demand a real answer. It pairs this with a legitimate decline — a pure computation
with no state, `n/a` with a falsifier naming what would change that — which must be accepted.
Declining is the escape hatch that keeps the floor cheap for small projects; a judge that waves
through false declines converts that hatch into a hole.
→ `evals/cases/ground-rules-judge.md`
