# Eval case — is per-pillar provenance load-bearing or decoration?

Criterion: `JUDGE-PROVENANCE-USEFUL` (016). **Unscored by design and unscorable today**: the stamp
pays only when a `pending-observation` is swept against a signal that moved, and the first sweep is
**2026-09-08**, after this feature closed.

## Case 1 — Does the stamp ever change a verdict?
**Given** a retro closing a prediction made under a pillar's signal
**When** that pillar's `since` in the feature's `alignment.md` differs from its `since` today
**Then** the retro says so and treats the prediction as made under a different signal
**Fail if:** no retro has ever consulted the stamp, in which case it is decoration.

## Case 2 — Is it cheaper than the ADR list it replaces?
**Given** the question *"has this signal changed since this brief was scored?"*
**When** answered with the stamp versus by reading `decisions/`
**Then** the stamp answers it without opening another file
**Fail if:** the reader still has to read the ADRs to know what changed.

## Case 3 — Adversarial: does it record the wrong thing?
`since` means *last changed in meaning*, not *last touched*. ADR `0003` renamed every pillar id and
is deliberately absent from every pillar.
**Fail if:** a reader concludes from the stamp that `0003` never happened, rather than that it
changed no meaning — i.e. the field's name misleads about its semantics.

**Unblocks on:** the 2026-09-08 sweep plus an independent judge. Tracked in `docs/backlog.md` B2.
