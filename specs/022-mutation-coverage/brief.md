# Brief — A criterion that declares no mutation is invisible, and nothing asks for one

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

020 shipped `scripts/mutate.sh`: a criterion declares the edit that must break it, and the runner
requires it to fail. 021 ran that against the two features whose mutation tables were presented as
evidence and found the real defect was not weak mutations — **18 of 19 reproduced** — but
**coverage**: seven of 018's sixteen criteria had never declared one at all.

Declaring is opt-in. The mechanism therefore proves exactly what its author already suspected, and
a criterion nobody suspected looks identical in the matrix to one proved failable.

**Measured on this branch, not estimated:** across `specs/*/coverage.md` there are **179 criteria
that could declare a mutation** and **137 do not**. Every one renders as `🟢 green` or `✅ uat`.

This makes the obligation derivable and enforces it **for the feature being verified**.

## Why / motivation

**The trigger was the open question, and B15 wrote down two candidates that both fail.**

*By diff* — every criterion added or changed on the branch. 019 shipped a check that read
`git show main:…`; it was green locally and failed in CI, because a shallow detached-HEAD checkout
has neither `main` nor `origin/main`. The same objection kills this candidate.

*By shape* — `nvc.sh` flags a suspect assertion and a flagged one must declare. 021 disposed of
this: the two known vacuous instances have **different shapes**, so one pattern cannot see both,
and the defect it would have to detect is the one nobody suspected.

**The third option is the one the audit pointed at, and it needs no git and no guessing.** A
feature's `coverage.md` already names its criteria, their origin, their status and the check file
that carries them. The obligation is a property of the matrix the feature has already written.

**Why per-feature and not repo-wide.** 137 undeclared criteria at about a second each is not the
cost that matters; authoring 137 honest mutations is. B15 says plainly: *do not resolve this by
requiring a mutation everywhere.* A feature pays for its own criteria — six to sixteen — at
`/verify`, which is where `Guard`s and the mutation run already happen.

**Why the standing debt must still be a number.** A gate that quietly exempts everything written
before it is how 145 criteria become permanently unproven while the suite reads green. The debt is
reported, with its figure, rather than gated.

## Success metrics

- **The obligation is computed from `coverage.md`**, with no branch ref and no network, so it
  behaves the same in a shallow CI checkout as it does locally.
- **A row that looks obliged but cannot be resolved is reported, never silently skipped.** The
  linked-test column is not uniform across features — older ones write `check_95_amendment_gate.sh`
  and newer ones `tests/check_99_mutations.sh` — and a gate that drops what it cannot parse is the
  `B11` family: opted out of by typo, with the failure looking exactly like the success.
- **Rows that genuinely cannot declare are excluded by rule, not by exception.** A `📋 case` row and
  a row judged at `/uat` have no assertion to mutate; 018 has two of the latter.
- **This feature's own criteria pass the gate it ships** (`D4`), and the gate's verdict is recorded
  in its verification report with the count it produced.
- **The standing debt is reported as a figure** — 137 today — and appears where it will be read
  again rather than only in this brief.
- **The suite stays green and hermetic**, and the added cost is measured.

## Out of scope

- **Declaring the 137.** That is the debt this feature makes visible, not the work it does. Closing
  it is a separate decision about which closed features are worth re-proving.
- **Gating closed features.** 021 established the precedent: the audit fixes criteria, not
  features. A feature that has already closed does not re-run `/verify`.
- **Whether a declared mutation is any good.** `mutate.sh run` already answers that. This answers
  only whether one exists.
- **`B14`** — the 32 `📋 case` rows that point at no case file. Same family, different artifact.

## Dependency

`scripts/mutate.sh` and its declaration grammar (020), the `coverage.md` matrix format, and the
`/verify` skill where the runner is already wired.

**`D3` applies** — the tool governs this repository's own workflow. **`D4` applies**: this ships a
gate, so it must be run against itself and its result recorded, not merely asserted to pass.
