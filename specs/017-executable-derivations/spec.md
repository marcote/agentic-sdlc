# Spec — Executable derivations

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `specs/_template/retro.md` — the `[deriv$ …]` form and when it is required.
- `tests/check_90_retro.sh` — runs the commands and compares.
- `.claude/skills/retro/SKILL.md` — step 1 says derive with a command, not a description.
- The nine closed retros — numeric fields migrated (`D3`).

## Resolved at grilling (3)

### G-a — Two forms, and which one is required is decided by the claim, not the field

`[deriv$ <command>]` is required when the claim **is a number**. `[deriv: <prose>]` stays valid for
everything else. Measured over the nine retros: `Gaps caught`, `Rework post-/verify` and
`Escalations` are counts; `RED→GREEN discipline` is a yes/no with a state history; `Friction`,
`Candidate rules` and `Align calibration` are judgments.

Forcing a commit trail into a command would be filler-to-comply, which is the failure the WoW
rejects elsewhere.

### G-b — One line may carry several claims, each with its own derivation

Measured: **10** Face B lines state two numbers, in the shape `Rework post-/verify: 0 · post-/uat: 1`.
Each number takes its own `[deriv$ …]`. A single command producing a pair would need a format, and
a format is a parser nobody asked for.

### G-c — The command prints one integer, contains no `]`, and is read from the retro

The closing bracket is the delimiter, so a command containing `]` cannot be parsed. Measured: all
**48** existing derivations are already bracket-clean. A command that violates this is rejected by
name rather than mis-parsed.

## Requirements

### R1 — The form
`<number> [deriv$ <command>]` on a Face B line. The number immediately precedes the bracket.

### R2 — The check runs it
`check_90` executes each command from the repository root and compares its trimmed stdout to the
stated number. Disagreement fails, naming the retro, the field, the claim and the output.

### R3 — Failure modes are distinguished
A command that exits non-zero, prints nothing, or prints a non-integer fails **differently** from a
number that disagrees. Reporting them the same way sends the reader to the wrong problem.

### R4 — Prose derivations remain valid
`[deriv: …]` is unchanged and is not executed. A field whose claim is not a number keeps it.

### R5 — Every closed retro is migrated
Nine retros. Whatever the check flags is fixed or explained in place. A check whose first real run
is left for someone else has proved a fixture.

### R6 — The command surface is bounded and stated
Commands run only from `specs/*/retro.md`, only in this repository's suite. The boundary is written
in the template where an author will read it, not only in this spec.

This is the same trust level the charter's `Guard` field already carries: `/verify` runs a named
command out of `stack.md` without inspecting it. The precedent is deliberate and is named so a
reviewer can object to both at once, or to neither.

## Edge cases (`/distill` expansion — 8)

1. **Several claims on one line.** → G-b, one derivation each.
2. **A non-numeric claim.** → R4, prose stays.
3. **A command containing `]`.** → G-c, rejected by name.
4. **A command that fails or prints nothing.** → R3, distinct failure.
5. **A command printing a non-integer.** → R3.
6. **A closed retro going red after its spec is edited.** Correct behaviour: the number no longer
   reproduces. It will read like a regression the first time, so the template says what it means.
7. **A number with no derivation at all.** Already covered by the existing `[deriv:` requirement,
   which stays.
8. **The check finding nothing because no retro uses the new form.** A migration that silently
   skips everything is the vacuity this repository has spent three features on. The check asserts
   it executed a minimum number of commands.

## Non-goals

Deriving prose claims; widening beyond retros; an expression language; detecting numbers that were
never written down.
