# Tasks — Ground rules: a project cannot start below the quality bar

> Executable decomposition. `/tasks` GATE passed (machine-checked over `coverage.md`:
> 14 deterministic rows, all with a linked test in 🔴 RED; 2 `📋 case`; 1 `deferred`;
> 0 violations). Each task lists the criteria it turns 🟢.
>
> Order is dependency-driven: the rules exist before anything can read them, the engine before
> the gates that call it, and the harness's own charter last — because bringing it to coverage
> is only meaningful once the check that judges it is real. Re-run `bash tests/run.sh` after
> each. Done when all 14 deterministic criteria are 🟢 and the suite is ≥ **327 PASS / 0 FAIL**
> (the pre-014 baseline).

## T1 — `memory/stack/base/ground-rules.md`: the six
Blocks `### GR<n> — <name>` with `- Question:` and `- Prevents:`, ids `GR1`–`GR6`:

| id | Name | Question |
|----|------|----------|
| `GR1` | Consumption | How does anything outside reach this, and is the core separable from its transport? |
| `GR2` | Persistence & concurrency | What holds state, and how many things write to it at once? |
| `GR3` | Deployment & topology | Where does it run, and in how many instances? |
| `GR4` | Language, runtime & execution | What is it written in, which version, how are dependencies declared, and how is it run? |
| `GR5` | What "verified" means | What does the test command actually run, and what does a green run prove? |
| `GR6` | Failure posture | When it breaks: does it retry, corrupt, alert, or fail silently? |

`Prevents` is load-bearing, not decoration: it is the recorded justification the amended
`frictionless-adoption` signal measures, and `/align` scored the pillar partly on its existence.

**The single most likely way to fail this feature:** a question that smuggles an answer. *"How
are dependencies declared and tasks run?"* is a question. Adding *"ideally one tool does both"*
is an answer wearing a question's clothes, and `no-prescribe.sh` will not catch it — it catches
named tools, not smuggled opinions. Also add the project-layer stub `memory/stack/ground-rules.md`
(`extends: base`, additive only).
- Criteria: **GR-SIX**, **GR-NO-PRESCRIBE**, **GR-FLOOR-NO-SCALE** (the "second floor alongside
  P6, never scales with S0" statement lives here and in `base/README.md`).

## T2 — Engine: `Answers:`, declinations, effective set, `ground-rules`
In `scripts/stack/engine.py`:
- Parse `Answers: GR2, GR4` as an optional list-valued pin field.
- Parse `### GR<n> — n/a` blocks with `Because` + `Falsifier`; they are **not** pins and must
  not enter the pin count or `pin-valid`'s pin rules.
- Assemble the effective rule set from `--rules` (repeatable; defaults to base + project layer),
  and **reject** a layer omitting any base rule.
- `ground-rules <charter>`: one line per rule — `GR<n>: pin <id>` / `n/a` / `uncovered`.
  Exit **0** fully covered, **1** incomplete, **2** malformed, **3** empty charter.
- Exclude `SUPERSEDED` pins from coverage: history is not a rationale.
- **Every rejection must name what it rejected on stderr** (`unknown ground rule GR9`,
  `... missing Falsifier`, `... omits GR6`). Not cosmetic: the contract's assertions require the
  diagnostic precisely because an exit code alone was satisfied by the command not existing.
- Document the new capability and its exit contract in the module docstring — that docstring
  *is* the CLI contract `S2`'s hedge depends on.
- Criteria: **ANSWERS-FIELD**, **NA-FORM**, **GR-COVERAGE**, **SUPERSEDED-NOT-COVERAGE**,
  **GR-ADD-NOT-REMOVE**, **ENGINE-CLI-ONLY**.

## T3 — `/plan`: the `UNCOVERED` verdict
`.claude/commands/plan.md`: add `UNCOVERED` as a fourth outcome, evaluated **first** (coverage is
cheaper than a semantic falsifier read, and a charter below the floor makes the other verdicts
premature). Still exactly one verdict, still never silence. **No grace period, anywhere** — the
contract greps the enforcement surface for one.
- Criteria: **PLAN-UNCOVERED**, **MIGRATION** (the no-grace half).

## T4 — `/stack`: walk the six, migrate in place
`.claude/skills/stack/SKILL.md`: Grill walks `GR1`–`GR6` explicitly by id, so the default path
produces a covered charter instead of one that trips the gate later. Add the migration path: on
a charter below coverage, propose which existing pin answers which rule and ask where an `n/a`
belongs. The migration is what makes the hard gate *justified* friction rather than a wall —
under the amended signal that distinction is now scored, not rhetorical.
- Criteria: **STACK-WALKS-SIX**, **MIGRATION**.

## T5 — Grammar docs
`memory/stack/base/pin-template.md`: `Answers:` field semantics (optional, list-valued, unknown
id rejected) and the declination block form, stated as **not a pin** — no `Buys`/`Forecloses`,
because nothing was bought or foreclosed, and inventing them would be the filler-to-comply the
harness rejects elsewhere. `base/README.md`: the ground rules as the second floor.
- Criteria: supports **NA-FORM**, **ANSWERS-FIELD**, **GR-FLOOR-NO-SCALE**.

## T6 — Bring the harness's own charter to coverage, and sharpen `S1` (D3)
Retrofit `Answers:` onto `S0`–`S4`, then add pins or honest `n/a` blocks until all six resolve.
Expect real gaps: `GR1` (how the harness reaches its users — vendored files and slash commands)
has never been pinned, and `GR6` (failure posture) is genuinely unexamined.

**Do not manufacture coverage.** An `n/a` that is convenient rather than true is the failure mode
`JUDGE-NA-HONEST` exists to catch, and writing one here would be the feature's author defeating
the feature. Where the honest answer is a real pin, write the pin.

Also amend `S1`: its statement *"ships mechanism, never opinions"* no longer describes a harness
that ships six mandatory questions. Narrow it to distinguish a required **question** from a
prescribed **answer**, keeping the `SUPERSEDED` trail so the record shows 014 prompted it.
- Criteria: **CHARTER-COVERED**.

## T7 — Close the RED and re-verify
`bash tests/run.sh`: all 14 deterministic criteria 🟢, suite ≥ 327 PASS / 0 FAIL. Then confirm
the two things 013 taught cannot be assumed:
1. **Each new assertion actually runs** — appears in `run.sh` output, not merely in the file.
2. **Each rejection path is reachable** — the negative fixtures produce the *named* diagnostic,
   not just a non-zero exit.
- Criteria: all 14 → 🟢; sets up `/verify` and `/uat`.

---

## Not in this breakdown

- **The two `📋 case` rows** (`JUDGE-GR-ANSWERED`, `JUDGE-NA-HONEST`) are already present in
  `evals/cases/ground-rules-judge.md` (4 cases) and are exercised at `/verify`, not by an
  implementation task. They stay open past close unless an independent judge scores them — 013's
  precedent, and the same reasoning: the authoring model grading its own output is not evidence.
- **`hermetic-offline`** is `deferred` — 014 reaches no network or remote source.
