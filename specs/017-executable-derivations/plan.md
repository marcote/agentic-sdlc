# Technical plan — Executable derivations

> HOW it is built. Produced by `/plan` over the frozen `spec.md`.

## Stack gate — verdict: `PASS`

`UNCOVERED` first: `ground-rules` exit 0, all six covered. `pin-valid` exit 0, 9 pins. No
`Falsifier` tripped.

### Pins this plan rests on

| Decision | Pin |
|---|---|
| The check is shell, no new engine | `S3` |
| It refuses rather than guessing, and names what it ran | `S8` |
| It asserts about the harness's own artifacts | `S7` |
| Derivations live in versioned markdown | `S6` |

`S2` is untouched: no engine is added, so its `Hedge` stays deferred.

### The one decision that deserved a pin and did not get one

**Executing commands read from a markdown file.** Real surface, real blast radius. It is not a new
decision: the charter's `Guard` field already does exactly this, and `/verify` runs those commands
by name without inspecting them.

The pin that would cover it is `S8` plus the existing `Guard` grammar. Minting a second pin for the
same posture would be charter bloat, which `wow-report` §6 already flags as the mirror failure of a
gap. Recorded here instead.

## Decisions

- **D1 — `[deriv$ <cmd>]` for numeric claims, `[deriv: <prose>]` for everything else.** Which form
  is required follows the claim, not the field name. Constrained by `DERIV-PROSE-KEPT`.
- **D2 — The bracket is the delimiter and a command may not contain `]`.** Measured: all 48
  existing derivations are bracket-clean, so the constraint costs nothing today. Violations are
  rejected by name. Constrained by `DERIV-BRACKET`.
- **D3-impl — One derivation per number, several per line allowed.** Measured: 10 lines state two
  numbers. A combined format would need a parser. Constrained by `DERIV-MULTI`.
- **D4-impl — Broken command and wrong number are different failures.** Reporting them alike sends
  the reader to the wrong problem, which is the confident-false-verdict shape recorded twice on
  2026-08-09. Constrained by `DERIV-BROKEN-CMD`, `DERIV-NON-INTEGER`.
- **D5-impl — The check asserts it executed a minimum count.** A migration that silently skips every
  field passes forever. Constrained by `DERIV-NON-VACUOUS`.

## Components

| Unit | Responsibility | Interface |
|---|---|---|
| `tests/check_90_retro.sh` | parse, execute, compare, report | sourced by `run.sh` |
| `specs/_template/retro.md` | the form, and what it means when a closed retro goes red | template |
| `.claude/skills/retro/SKILL.md` | derive with a command, not a description | prose contract |
| the nine closed retros | migrated numeric fields | data |

## Risks

| Risk | Mitigation |
|---|---|
| A command is written to match a number already decided | `JUDGE-DERIV-HONEST`, an eval case; not mechanisable |
| A closed retro goes red after its spec is edited | Correct behaviour; the template says what it means |
| The check silently executes nothing | `DERIV-NON-VACUOUS` asserts a minimum |
| Command execution surface | Bounded to `specs/*/retro.md`; same trust level as the charter `Guard`, named so both can be objected to at once |
