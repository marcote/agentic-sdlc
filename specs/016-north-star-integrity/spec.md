# Spec — North Star integrity: unfilled is not valid, and every pillar says when it last changed

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `memory/north-star/base/schema.md` — the contract gains `since` and the unfilled rule.
- `scripts/north-star/engine.py` — reference implementation, exit **3 = unfilled**.
- `scripts/amendment-gate.sh` — provenance must move when a governed field moves.
- `.claude/skills/align/SKILL.md` — refuse on unfilled; stamp provenance.
- `memory/north-star/north-star.md` + `scripts/vendor.sh` stub — migrated (`D3`).

## Resolved at grilling (3)

### G-a — The unfilled discriminator is **byte identity with the seeded stub**, not the word `TODO`

A value is *unfilled* iff it is byte-identical to the value `vendor.sh` seeds, **or** it still
carries a template marker (`_(…)_`, `<…>`). Zero false positives **by construction**: a product
whose domain is to-do lists can write `"out_of_scope": ["TODO tracking beyond a single list"]` and
it is not byte-identical to `"TODO: what it explicitly does not do"`.

The seeded values live in **one** place — a `SEEDED` table in the engine — and `check_80` asserts
that table matches what `vendor.sh` actually writes. Two copies of a sentinel that drift apart
would make the check silently stop catching anything, which is the family the suite now guards.

**Stated limitation:** an adopter who invents their own placeholder (`"mission": "fill this in"`)
is not caught. This detects *not having done the step*, not *having done it badly*.

### G-b — Provenance is `since: "<ADR number>"` on each pillar, and it is **required**

Four digits, e.g. `"0004"`. Not a path: paths break when a file is renamed, and the ADR number is
the stable identity the protocol already uses. **Required**, so a pillar cannot exist without
saying where it came from — which is the whole point.

A `since` naming an ADR file that does not exist is **rejected by name**, per the doctrine 014
fixed for `Answers:`: silently ignoring an unknown id reports a state the author does not have.

### G-c — Provenance is **metadata, not a governed field**

Changing `since` alone is **not** an amendment and must not require an ADR — otherwise recording
that ADR `0005` changed a signal would itself need ADR `0006`, forever. The amendment gate's
governed hash stays `(id, statement, signal)` + `scope`, unchanged.

The gate gains the **inverse** check, which is where the value is: if a pillar's `statement` or
`signal` changed and its `since` did **not**, the amendment is rejected. That is what makes the
record self-maintaining instead of a convention someone remembers.

## Requirements

### R1 — `schema-valid` distinguishes unfilled from malformed
Exit **3 = unfilled**, mirroring the charter engine's exit 3 = empty (013, same cause: vendoring
seeds a stub, so a fresh adopter never has "no file" — they have a well-formed file with nothing in
it). Exit 1 stays *invalid*, exit 2 stays *malformed*. Every rejection names **which** fields are
still seeded, not just that some are.

### R2 — `/align` is fail-closed against unfilled
Step 1 stops on exit 3 and says *seed your North Star*, not *fix a malformed file*. This is the
same distinction 013 drew so nobody hunts a bug that is not there.

### R3 — `since` on every pillar, validated
Required, four digits, must resolve to a file in `memory/north-star/decisions/`. Unknown id →
rejected by name.

### R4 — The harness's own North Star is migrated (`D3`)
Mapped to the ADRs that actually produced each pillar, not to the newest one:
`real-enforcement` → `0001`, `agnostic-portability` → `0001`, `measurable-impact` → `0002`,
`frictionless-adoption` → `0004`. `0003` renamed every id mechanically and is deliberately **not**
recorded as provenance — it changed no `statement` and no `signal`, and recording it would make the
field mean "last touched by any commit" rather than "last changed in meaning".

### R5 — The amendment gate requires provenance to move
A governed field changing with `since` unchanged → **blocked**, citing the pillar. `since` changing
alone → **passes** (not an amendment). Both directions asserted; one without the other is half a
rule.

### R6 — `/align` stamps provenance into `alignment.md`
The written `alignment.md` records each mapped pillar's `since`, so a retro reading it later can
tell whether the signal moved under its own prediction.

### R7 — The stub still vendors, and is still rejected
`vendor.sh` seeds the same stub, now including a seeded `since`. A freshly vendored repo must
return exit 3 — the defect this feature fixes, asserted against a **real vendored target** rather
than a fixture.

## Edge cases (`/distill` expansion — 9)

1. **A product whose domain is to-do lists.** → G-a, byte identity.
2. **Half-filled: mission written, pillars still seeded.** Rejected, naming the pillars. → R1.
3. **A seeded North Star has no ADRs yet**, so its `since` is seeded too. The unfilled check runs
   **before** the provenance check, so the message says *seed it* rather than *ADR 0000 missing*.
4. **`since` naming a nonexistent ADR.** → R3, rejected by name.
5. **Provenance changed alone.** → R5, passes.
6. **Signal changed, provenance stale.** → R5, blocked.
7. **A pillar added.** Already a set change under the existing gate; its `since` must name the
   adding ADR.
8. **A pillar renamed only** (`0003`'s case). An `id` change is a set change and already needs an
   ADR; it is not a provenance event. → R4.
9. **The `SEEDED` table drifting from `vendor.sh`.** The discriminator would silently stop matching
   and the check would pass on a stub forever. → G-a, asserted.

## Non-goals

A whole-file version number (considered and rejected: `v4` communicates nothing); changing the
amendment protocol; retro-fitting closed features' `alignment.md`; detecting semantic drift in a
reworded signal; implementing an adopter's validator.
