# Spec — The gates run against a vendored target, not only the copying

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `tests/fixtures/adopter/` — a small adopter repository, product half inert.
- `tests/check_98_adoption.sh` — vendors onto a copy of it and runs the real gates there.
- `scripts/stack/engine.py` — companion-file resolution fixed (see R6, found at `/distill`).

## Found at `/distill`, before any code was written

Running the gates against a vendored fixture produced a divergence in under a minute.

```
$ python3 scripts/stack/engine.py ground-rules TARGET/memory/stack/stack.md
malformed: no ground rule file found        # exit 2
$ ls TARGET/memory/stack/base/ground-rules.md
TARGET/memory/stack/base/ground-rules.md    # it is right there
```

`_effective_rules` resolves `memory/stack/base/ground-rules.md` against the **process cwd**. The
North Star engine resolves `decisions/` against the **artifact's own directory** (`_adr_ids`, line
114). Two engines, two rules, and only one of them survives being pointed at a repository it is not
standing in.

This is the same family as the pin-id defect: a gate reports a state the target does not have. It
is the **second, unknown divergence** `alignment.md` demanded before `measurable-impact` could
be `✅`.

**Severity, stated honestly.** `/plan` runs the command from the adopter's own root, where cwd and
artifact coincide, so no adopter has been misled yet. It bites the moment anything governs a target
from outside — which is this feature, and would be any future runner.

## Resolved at grilling (6)

### G-a — The fixture is an adopter that has already run `/constitution`, seeded its North Star and run `/stack`

It ships those authored files in place. Vendoring on top therefore exercises SEED no-clobber
against real content rather than against absence.

**Stated limitation:** this does not model first-time vendoring. That is already covered by
`check_84`'s `SEED-STUB` and by 016's `NS-VENDORED-STUB-REJECTED`.

### G-b — It lives at `tests/fixtures/adopter/`

`tests` is already DROP, so the fixture is DROP with no new entry to keep in sync. It also sits
outside the default scan roots of `prose.sh` (`specs memory docs`) and of `nvc.sh`
(`tests/check_*.sh`).

That exclusion is correct rather than convenient: `D5` is a **project delta**, and an adopter
inherits the harness's artifacts, not its prose conventions.

### G-c — The stack is Python 3, standard library only

`pyproject.toml` is a marker `vendor.sh` already detects, and `python3` is already a declared
dependency of this harness under `S2`. So the fixture's own test command runs in the suite with no
install step.

Naming `uv` was considered and rejected. It would make the fixture's test command unrunnable
hermetically and would breach `S3`'s dependency-free baseline. The pin still records a real
decision with a real price.

### G-d — Pin ids use the prefix `P`, which this repository's charter does not use

Not decoration. `S` is the one prefix our own charter uses, which is exactly why the parser
accepted only `S` for three features. A fixture reusing `S` would rebuild the blind spot it exists
to remove.

### G-e — A `Guard` is executed by the string the engine emitted, never by a path this check knows

That is what *"the harness runs it by name"* means mechanically. A check that invokes a hardcoded
path tests our knowledge of the fixture instead of the seam.

### G-f — The fixture's suite result is reported, never counted

`PASSES` and `FAILS` are snapshotted around the invocation and asserted unchanged by it. Per `S7`,
a green harness suite must never also silently claim the fixture works.

## Requirements

### R1 — A fixture adopter repository, inert and small
A stack marker, one source file, its own test, its own `scripts/test.sh`, an authored charter with
four pins and two guards, and an authored North Star with one ADR. Its product half implements no
behaviour: it exists to be governed, not to work.

### R2 — The suite vendors onto a copy of it and runs the gates there
One invocation of `tests/run.sh`, no manual step. Every scenario gets its **own** sandbox copy —
`git checkout` cannot restore untracked files, which is how two fixture harnesses leaked state on
2026-08-09.

### R3 — Each gate returns the target's own content
`exposure` reports the fixture's pins, `schema-valid` exits 0 on its filled North Star,
`ground-rules` gives all six a verdict from the target's own rule file, and `guards` emits the
fixture's guards. No gate returns empty, not-applicable, or this repository's own artifacts.

### R4 — `UNCOVERED` fires on a foreign charter
A copy with the pin answering `GR4` removed reports that rule uncovered, by name. Paired with R3's
positive, so neither direction stands alone.

### R5 — A declared `Guard` runs by name, and its failure is observed
Exit 0 on the clean fixture and non-zero on a violating copy. A `Guard` that cannot fail is
vacuous, which `base/pin-template.md` names as the first of its two uncatchable failure modes.

### R6 — Companion files resolve relative to the artifact, in both engines
The stack engine adopts the North Star engine's rule. Explicit `--rules` still wins; the change is
to the default. Asserted from a cwd that is **not** the target, since that is the only cwd where
the two behaviours differ.

### R7 — The fixture's own test command is invoked, and its result is not counted
Its exit code is observed and reported. If `python3` is absent the criterion emits `_skip` with a
reason, never silence.

## Edge cases (`/distill` expansion — 10)

1. **A scenario mutates the committed fixture** and later runs pass for the wrong reason. → R2,
   one sandbox per scenario, plus a criterion that the committed tree is unchanged.
2. **Vendoring merges `scripts/guards/`**, so the harness's `no-prescribe.sh` lands in the target.
   The fixture's charter must emit only its own two. → R3.
3. **The fixture's `scripts/test.sh` already exists**, so vendoring writes `.harness-new`. The
   harness must run the adopter's file, not the seeded one. → R7.
4. **A guard resolves its own paths relative to its script**, so it must work with the target as
   cwd. → R5.
5. **The engine is pointed at an artifact outside its cwd.** The defect above. → R6.
6. **`decisions/` is absent entirely**, so `_adr_ids` returns `None` and `since` resolves against
   nothing. The fixture ships one ADR, so this feature does not reach that path. Recorded in
   `docs/backlog.md` rather than widened into here.
7. **`python3` is unavailable.** → R7, `_skip` with a reason.
8. **The fixture grows into an application.** → R1's budget, and a `/uat` judgment the budget
   cannot make.
9. **Someone adds the fixture's suite result to the harness count.** → G-f, `S7`.
10. **The fixture's markdown is exempt from `D5`.** Asserted as intent, not left as an accident of
    scan roots. → G-b.

## Non-goals

An application; `/uat` against a product objective; whether the workflow is worth its cost; testing
an adopter's own engine; re-testing the copying that `check_84` and `check_88` already prove.
