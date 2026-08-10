# Brief — Executable derivations: a number in an artifact must be reproducible by command

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Make precision a property the harness enforces, not a habit someone has to keep.

Today a retro's Face B field carries `[deriv: <prose>]` — a sentence describing where the number
came from. Prose cannot be re-run. This feature replaces it, for numeric claims, with a locator
that **is a command**. The check runs the command and compares its output to the number written.

## Why / motivation

Three claims in one session were precise and wrong. Each was a count written from memory rather
than derived when written.

| claimed | actual |
|---|---|
| "3 of 5 rows mechanised" | 2 |
| `AMEND-PROV-ONLY` catches the wrong implementation | false |
| 013: "12 gaps caught by /distill" | 8 |

None was vague. Sentence length was not the cause, and the 35-word cap would not have caught any of
them.

**The existing mechanism is close but not sufficient.** `[deriv:]` is required in five Face B
fields, and 013's wrong number **had one**. The locator said "bullets in `spec.md`" — a description
that sounded verified and reproduced nothing. 014 fixed its own version by scoping the derivation
to a section, which is the same insight one step short of mechanising it.

**Measured before proposing.** Expressing the existing Face B counts as commands: 014 reproduces
(7), 015 reproduces (11), 016 reproduces (12). **013 does not** — its command yields 10 against a
claimed 8. The feature whose number was already corrected once is the one that still does not
reproduce, and no human noticed until a command was run.

## Success metrics

- **A numeric Face B claim carries an executable derivation**, and the suite runs it.
- **A number that disagrees with its command fails the suite**, naming the field, the claim and the
  command's output.
- **The check is run against every closed retro**, and whatever it flags is fixed or explained. A
  check whose first real run is left for someone else has proved a fixture.
- **A non-numeric derivation stays valid in prose** — a state history or a commit trail is not a
  count, and forcing it into a command would be filler-to-comply.
- **The command surface is bounded and stated**: what may run, where, and why that is the same
  trust level the charter's `Guard` field already carries.
- **The suite stays green and hermetic**, and adding this costs one line per numeric field.

## Out of scope

- **Deriving prose claims.** "The mechanical half missed the defect" is a judgment, not a count. It
  stays prose and stays with review.
- **Retrofitting non-retro artifacts.** Plans, alignments and reports also carry numbers. This
  feature proves the mechanism on retros first; widening it is a later decision with its own
  evidence.
- **A general expression language.** The derivation is a shell command that prints one integer.
  Anything more is a parser nobody asked for.
- **Detecting that a number is *missing*.** This checks the numbers that are claimed, not the ones
  that were never written down.

## Dependency

`specs/_template/retro.md`, `tests/check_90_retro.sh`, the `retro` skill. No new engine.

**`D3` (reflexive dogfood) applies:** the check must run against this feature's own retro and every
closed one before it closes. **`D4` does not** — this feature ships no gate that would block itself.
