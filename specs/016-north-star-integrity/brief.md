# Brief — North Star integrity: unfilled is not valid, and every pillar says when it last changed

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Two defects in the same artifact, both about **not being able to tell what you are looking at**.

**A — an unfilled North Star validates.** `scripts/vendor.sh` seeds a stub whose mission, pillars
and scope are all `"TODO: …"` strings, and `schema-valid` returns **exit 0** on it. `/align` is
fail-closed against a *malformed* North Star, not against an *unfilled* one, so a fresh adopter's
very first feature is scored against placeholders and gets a verdict that means nothing.

**B — a pillar does not record when it last changed.** Reading `north-star.md` today you cannot
tell that `frictionless-adoption`'s signal means something different than it did on 2026-08-06.
The only record is four ADRs and one hand-written sentence of prose in the file. Every
`alignment.md` scores a brief against a signal that may later change, and nothing connects the two:
014's alignment says *"as amended by ADR `0004`"* because a human typed it.

## Why / motivation

**A is the adoption path failing at step one.** The from-zero flow is `vendor` → `/constitution` →
seed North Star → `/stack` → first feature. If the seed step is skipped or half-done, everything
downstream still returns green verdicts. This is the exact shape 013 fixed for the charter — a
vendored stub is a *well-formed file with nothing in it*, and treating that as valid lets the first
feature of every adopted repo through unexamined. The charter engine has exit **3 = empty** for
precisely this; the North Star engine has no equivalent.

**B is not high churn — it is illegible history.** Measured: four ADRs in five weeks, of which
`0001` is the seed and `0003` was a mechanical translation. **Two real semantic amendments.** So
the problem is not that the North Star moves too much; it is that its movement leaves scars as
inline prose instead of structure. That is what makes it read like a patch on a patch.

The concrete cost is in the align↔retro ledger, which is the harness's whole measurement loop: a
retro closes a prediction made under a signal, and today there is no mechanical way to know whether
that signal changed underneath it. A `⏳ pending-observation` deferred for a month is judged in
2026-09 against whatever the signal says *then*.

## Success metrics

- **`schema-valid` refuses an unfilled North Star** with an exit code distinct from malformed, and
  the message says *seed it*, not *fix a bug that is not there*.
- **A real North Star with a product about to-do lists is not a false positive.** The discriminator
  is the seeded stub's own form, not the word `TODO` appearing anywhere.
- **`/align` refuses to run** against an unfilled North Star and says which fields are still seeded.
- **Every pillar records the ADR that last changed its `statement` or `signal`**, and the harness's
  own four pillars are mapped to the ADRs that actually produced them.
- **`/align` stamps that provenance into `alignment.md` automatically**, so a retro can tell whether
  the signal moved under its own prediction without a human remembering to type it.
- **The amendment gate requires provenance to be updated** when a governed field changes — a
  pillar's `statement`/`signal` changing while its provenance stays put is rejected. Provenance
  changing on its own is **not** an amendment and must not require an ADR about an ADR.
- **The suite stays green and hermetic**, and the vendored stub still vendors.

## Out of scope

- **A version number for the North Star as a whole.** `v4` communicates nothing about what changed;
  per-pillar provenance answers the question actually being asked. Considered and rejected.
- **Changing the amendment protocol.** ADR + PR + green suite stays exactly as it is; this only
  adds a mechanical check that the record is kept.
- **Retro-fitting `alignment.md` files of closed features.** 002–015 are not reopened; the stamp
  applies from 016 onward.
- **Detecting semantic drift in a signal.** Whether a reworded signal *means* the same thing is a
  judgment; this records *that* it changed and *which ADR* did it.
- **Enforcing this on an adopter's own validator.** The schema is the contract, the engine is the
  reference implementation, per the standing "contract in the template, engine per-stack" doctrine.

## Dependency

The 006 engine (`scripts/north-star/engine.py`) and its exit contract; `memory/north-star/base/schema.md`;
`scripts/amendment-gate.sh` and its CI workflow (feature 004); the `vendor.sh` stub.

**This changes a shipped schema, so it changes what "valid" means for every adopter.** The
migration is one field per pillar, and the harness's own North Star must be migrated inside this
feature — `D3` (reflexive dogfood), not `D4`: this feature ships no gate that would block itself.

**Expected not to close 013's or 014's `pending-observation`.** Neither trigger is plausible here,
and saying so now is cheaper than discovering it at `/retro`.
