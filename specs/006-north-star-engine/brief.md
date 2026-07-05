# Brief — North Star engine (python3 reference implementation)

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Ship the **deterministic executable engine for the North Star inside this repo**, as a
**dependency-free python3 reference implementation**. Today `north-star/base/` specifies
the *contract* in prose (`schema.md`, `alignment-rubric.md`, `amendment-protocol.md`) but
the only *executable* engine lives in another repo (`poirot-fe` as Node `.mjs`), and
`amendment-gate.sh` re-implements a slice of it inline. This feature makes the harness
**self-contained**: one in-repo engine that validates the schema, judges scope and
alignment, and enforces the amendment protocol — reused by both `/align` and the
amendment gate.

## Why / motivation

`base/` follows "**contract in the template, engine per-stack**", but the harness itself
has **no engine** — it points at `poirot-fe`. That means: (a) an adopter copying the
harness inherits a contract with no runnable reference; (b) `amendment-gate.sh` duplicates
JSON parsing instead of calling a shared engine; and (c) copy-once **vendoring cannot
classify the engine as KEEP** because there is nothing in-repo to copy. `amendment-gate.sh`
**already assumes `python3` (stdlib json) as a dependency-free baseline** — so a python3
reference engine costs no new dependency and unblocks all three problems.

## Success metrics

- The canonical ```json``` block of a `north-star.md` **validates against `schema.md`**
  via the engine — pass on valid, fail with a precise message on invalid (deterministic).
- **`scopeReject`**: an objective outside the declared `scope` is rejected; one inside is
  accepted.
- **`alignVerdict`**: given rubric scores, the engine maps them to the `/align` verdict
  (`aligned` / not) exactly as `alignment-rubric.md` prescribes.
- **`requiresAdr` / `hasAdrFor`**: a change to the `pillars`/`scope` sets is flagged as
  requiring an ADR, and presence of the matching ADR is detected.
- **`amendment-gate.sh` reuses the engine** — no duplicated JSON parsing between the gate
  and the engine.
- **Dependency-free**: `python3` stdlib only, no Node/npm in the source path.
- The harness self-check stays green (`tests/run.sh`) and covers the engine.

## Out of scope

- **The eval-runner** — separate concern, still left to the adopter.
- **Keeping the Node `.mjs` in sync** — `poirot-fe`'s implementation stays as an optional
  alternative; this feature does not port to or maintain other stacks.
- **The vendoring script** (feature 007) — it only *copies* this engine once it exists.
- **Changing the contract** — `schema.md` / rubric / protocol semantics are unchanged; this
  is an implementation of the existing contract, not an amendment (no pillars/scope change).
