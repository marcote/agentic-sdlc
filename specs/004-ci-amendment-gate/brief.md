# Brief — CI-gate for the North Star amendment

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Have North Star amendments (changes to `pillars`/`scope` of `north-star.md`)
gated by **deterministic and blocking CI**, not by human approval. A change
that touches `pillars`/`scope` **without** the corresponding ADR, or with the
harness suite red, **cannot be merged to `main`**. Amendment enforcement stops
depending on goodwill (or a review that a solo maintainer cannot give themselves)
and becomes a deterministic gate, consistent with the `real-enforcement` pillar.

## Why / motivation

The `amendment-protocol` requires "ADR + PR approved by a human", but GitHub does
not let the author approve their own PR: a solo maintainer gets stuck, and the real
enforcement of the amendment today is **by convention**, not by gate. That contradicts
the harness itself, which preaches discipline enforced by deterministic gates
(`real-enforcement`) and not by manual gatekeeping. Without a real gate, a change
to `pillars`/`scope` can land without an ADR and without a green suite — the same
governance drift that the `amendment-protocol` says it prevents.

## Success metrics

- A change to `pillars`/`scope` of `north-star.md` **without** a new ADR in
  `memory/north-star/decisions/` in the same PR is **blocked** by CI (red, not
  mergeable) — deterministic.
- The same change **with** its ADR and the green suite **passes** the gate.
- A change that does NOT touch `pillars`/`scope` (typo in prose, `threshold` adjustment) **does
  not** require an ADR and is not blocked.
- The gate is **truly blocking**: `main` cannot be merged to unless the status-check
  is green (branch protection active and required).
- The harness self-check stays green (`tests/run.sh`) and covers the new layer.
- The layer stays **dependency-free** (bash/coreutils + GitHub Actions; no Node/npm
  in the source).

## Out of scope

- Gating changes that are not product governance (adopter's app features) — the
  gate is specific to `north-star.md` `pillars`/`scope`.
- Reimplementing the full `/align` engine; this covers only the `requiresAdr`/
  `hasAdrFor` half of the `amendment-protocol`.
- Porting the gate to other forges (GitLab/Bitbucket); the target is GitHub Actions +
  branch protection, consistent with the existing `.github/workflows/verify.yml`.
- Changing the language of the source (kept in Spanish).
