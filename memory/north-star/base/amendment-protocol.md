# Amendment Protocol (base)

> A North Star that can be silently edited is not governance, it is decoration.
> Every change to the `scope` or `pillars` of a project is a **governed and auditable
> event**: it requires an ADR and lands only via a human-approved PR.
> Never a direct commit to `north-star.md`.

## When an amendment is required

Any change to the canonical JSON block of `north-star.md` that touches:

- `pillars` — adding, removing, or materially changing the `id`, `statement`, or
  `signal` of a pillar.
- `scope.in_scope` or `scope.out_of_scope` — adding, removing, or narrowing/widening
  a predicate.

The rule is deterministic (equivalent to `requiresAdr(oldNs, newNs)`, per-stack): a
diff limited to surrounding prose, to the wording of `mission` that does not change the
`pillars`/`scope` sets, or to adjusting `alignment.threshold` **does not** require an ADR; a
diff of `pillars`/`scope` **always** does.

## What "amendment = ADR + PR" means

1. **An ADR** lands in `memory/north-star/decisions/NNNN-*.md` (sequential number,
   kebab-case slug), using `adr-template.md`. It must contain:
   - **Context** — why the current North Star no longer fits (what pressure or observed
     drift motivated the change).
   - **Decision** — the exact before/after of the affected `pillars`/`scope` fields.
   - **Scope-delta** — an explicit statement of what moves from `out_of_scope`
     to `in_scope` (or vice versa), so the impact radius is visible at a glance,
     not buried in a JSON diff.
   - **Consequences** — what is newly enabled or prohibited, and any follow-ups
     (e.g. previously rejected features that are now eligible).
2. **A PR** carries the ADR + the `north-star.md` diff together. A human reviews and
   approves — the amendment approval is explicitly **not automated**. The PR is the
   auditable trail: reviewer, timestamp, and diff are all git-native.

## Enforcement

A checker (equivalent to `hasAdrFor(decisionsDir)`, per-stack) verifies that at least
one ADR exists for a given change window. A `pillars`/`scope` change to
`north-star.md` that lands **without** a corresponding ADR is a **governance violation**
— signal it the same way you would signal a missing test, by criterion
`AMEND-ADR` of `specs/002-north-star-governance/acceptance.md`. This is the
`[given] audit-logging` pattern (`memory/constitution/base/patterns/audit-logging.md`)
applied to product governance instead of write endpoints: the "write" here is a change
to the mission/scope itself, and the ADR + PR pair is its auditable trail.

## What does NOT require an amendment

- Correcting a typo in the prose surrounding the JSON block.
- Adjusting `alignment.threshold` (tuneable, though a lightweight PR description of
  why is still worth writing).
- Anything under `base/` (schema, rubric, this protocol) — those are
  vendored/shared; see `README.md` for how `base/` updates propagate.
