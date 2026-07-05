# 0003 — Rename pillar IDs to English

> Amendment of `pillars`: renames all four pillar IDs from Spanish to English as part
> of the full repository English migration. Lands together with the `north-star.md` diff
> in the same PR (see `base/amendment-protocol.md`). A human reviews and approves.

## Context

The harness is migrating all repository artifacts to English (branch
`005-english-migration`). The canonical North Star JSON block contains pillar IDs in
Spanish (`enforcement-real`, `portabilidad-agnostica`, `adopcion-sin-friccion`,
`impacto-medible`), which are inconsistent with a fully English repository. Because
pillar IDs are part of the `pillars` set governed by the amendment protocol, the rename
requires an ADR even though the change is purely cosmetic.

## Decision

Rename the four pillar IDs in the canonical JSON block of `north-star.md`:

| Old ID (ES) | New ID (EN) |
|---|---|
| `enforcement-real` | `real-enforcement` |
| `portabilidad-agnostica` | `agnostic-portability` |
| `adopcion-sin-friccion` | `frictionless-adoption` |
| `impacto-medible` | `measurable-impact` |

Pillar semantics (statement, signal) are unchanged in meaning — only language changes.

## Scope delta

No items move between `in_scope` and `out_of_scope`. Only `pillars[].id` values change.

## Consequences

- Any adopter stack that hard-codes the old pillar IDs in its alignment tooling must
  update those references.
- All `alignment.md` files in this repo that reference old IDs are updated in the same
  branch (`005-english-migration`), specifically `specs/004-ci-amendment-gate/alignment.md`.
- ADRs 0001 and 0002, which reference old IDs in their prose, are translated to English
  in the same branch — the IDs they mention become the new English IDs in translation.
