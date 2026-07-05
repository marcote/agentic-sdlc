---
extends: base
---

# How North-Star inheritance works

- `base/` is a **vendored** shared asset: copied with the harness template,
  just like `memory/constitution/base/`.
- The project's `north-star.md` declares `extends: base` in its YAML frontmatter and
  adds the project's own mission, pillars, and scope — the product governance analogue
  of how `constitution.md` declares `extends: base` and adds its deltas.
- `base/schema.md` is the **checkable shared shape** that every project's North Star
  must satisfy. `base/alignment-rubric.md` is the **shared scoring method** that the
  `/align` skill's judge applies. `base/amendment-protocol.md` is the **shared change
  control process** for editing scope/pillars. None of these three is project-specific —
  a project's delta is its mission, pillars, and scope only, never the rules for
  validating/scoring/amending them.
- **Contract in the template, engine per-stack.** `base/` specifies the shape, the
  rubric, and the protocol; the deterministic executable engine (validate schema,
  `scopeReject`, `alignVerdict`, `requiresAdr`/`hasAdrFor`) is provided by each
  adopting repo in its own stack — just as the harness leaves the eval-runner to the
  adopter (`evals/README.md`). Reference implementation:
  `poirot-fe scripts/north-star/{schema,align,amendment}.mjs` (Node, already built and
  unit-tested there).
- To update `base/`: edit it here, follow the same discipline as
  `memory/constitution/update-checklist.md` (review the change and re-copy it to every
  project that inherits it — explicit synchronization, no submodules).
