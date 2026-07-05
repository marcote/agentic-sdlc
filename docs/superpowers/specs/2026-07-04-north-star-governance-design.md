# North-Star Governance + Measurability Gate — Design

**Date:** 2026-07-04
**Status:** Design — pending review, then goes through the harness workflow
**Branch:** feature/north-star-governance
**Origin:** capability piloted in `poirot-fe` (branch `feature/north-star-governance`,
PR #24); this **upstreams** it to the base harness as a cross-cutting capability.

## Summary

Add to the `agentic-sdlc` harness a **product governance layer** — the **North
Star** — as a **peer** of the constitution (which is technical), plus an **`/align`
intake gate** with a 3-layer checkable model, and the **Measurability Gate** law: *if
the North Star cannot be defined, governed, and quantified, the workflow does not
execute against it*. This prevents **product drift**: perfectly built features that are
outside the mission — something an agentic SDLC amplifies (the agent lacks the instinct
"should this even exist?").

## Guiding principle of the port: contract in the template, per-stack engine

The harness is a **stack-agnostic, dependency-free template** (its self-check is
pure bash; it does not assume Node/npm). Therefore we port the **contract**, not the
Node engine from poirot:

- The template brings the **specification** of the North-Star: `base/` (schema, rubric,
  amendment protocol, ADR), the `/align` command+skill (describing the 3-layer model),
  the gate in `/distill`, the Pillar column in the coverage template, and a bash
  **presence/structure** self-check.
- The **runnable deterministic engine** (validate schema, `scopeReject`,
  `alignVerdict`, `amendment`) is **the responsibility of each adopting repo**, just as
  the harness already leaves the *eval-runner* to the adopter (`evals/README`). The
  `poirot-fe scripts/north-star/*.mjs` is cited as the **reference implementation** (Node).

Language: **Spanish**, like the rest of the source.

## Scope

**Includes:**
1. **North-Star governance** (base + `/align` + gate in `/distill` + Pillar column +
   self-check), as a stack-agnostic contract.
2. **Refining the Way-of-Work** of the source with the formal **two-layer** model
   (governance vs execution-runtime), in **generic** form (the intake/implement/finish
   runtime is chosen by the adopter).

**Does not include:** poirot-specific content (`north-star.md` with the MEXBANK mission,
the API, English translations). In the source, `north-star.md` is a **placeholder** to
be filled in per project (like the example `constitution.md`).

## Components (land in the source, in Spanish)

1. **`memory/north-star/base/`** — `schema.md` (required measurable form:
   `mission`, `pillars[]` with `id`+`statement`+`signal`, `scope.in/out`, `alignment`
   with `threshold`+`rubric`), `alignment-rubric.md` (3 dimensions: pillar fit,
   scope compliance, mission advancement; 0-5; pass = all >= threshold, default 3, and
   no `out_of_scope`), `amendment-protocol.md` (amendment = **ADR + PR**),
   `adr-template.md`, `README.md` (`extends: base` mechanism), `decisions/.gitkeep`.
2. **`memory/north-star/north-star.md`** — **placeholder** (`extends: base` +
   skeleton canonical JSON block with `_(fill in per project)_`).
3. **`.claude/commands/align.md` + `.claude/skills/align/SKILL.md`** — the
   `/align` gate: validates the North Star (fail-closed if not measurable), extracts
   objectives from the brief, runs the 3-layer model (deterministic scope predicates +
   orphan check + quantified LLM-judge), writes `specs/<feature>/alignment.md` with
   verdict `aligned | needs-amendment | rejected`. Declares that the **deterministic
   checker is provided by each stack** (contract), citing the poirot reference impl.
4. **Gate in `/distill`** — edit `.claude/skills/distill/SKILL.md`: **Step 0 —
   Measurability Gate** (reads `alignment.md`; only `aligned` proceeds; missing/`rejected`/
   `needs-amendment` blocks; bootstrap exception for the feature that introduces
   `/align`).
5. **`specs/_template/coverage.md`** — **Pillar** column (`pillar -> objective ->
   criterion`).
6. **`tests/check_80_north_star.sh`** — bash self-check (the source uses `tests/`):
   base present, `north-star.md` with `extends: base`, `/align` command+skill exist,
   and the `distill` skill contains the gate wiring. Auto-picked up by the
   `tests/run.sh` glob.
7. **Way-of-Work (two layers)** — enrich the source README/docs: the harness
   **governs**; the steps that are not commands (intake->brief, implement, finish) are
   provided by an **execution-runtime** chosen by the adopter. Generic (without naming
   superpowers as mandatory).

## How it is built

**Dogfooding the source harness itself**: this design -> `brief.md` in
`specs/002-north-star-governance/` -> `/distill -> /plan -> /contract -> /tasks ->
implement`. `/align` is **skipped for this feature** (bootstrap: it cannot gate
itself), just as the original harness bootstrap skipped its own gates.
Self-check `tests/run.sh` green + new `check_80` green. Branch -> **PR**.

## Checkable model (3 layers) — the contract

1. **Hard deterministic — scope predicates:** an objective that matches `out_of_scope`
   (conservative match by contiguous phrase) -> `rejected`.
2. **Hard deterministic — orphan check:** every objective maps to >=1 pillar; if not ->
   blocked.
3. **Quantified — LLM-judge:** scores 3 dimensions 0-5 against the rubric; pass =
   all >= threshold and no scope hit -> `aligned`; in-scope but below threshold ->
   `needs-amendment`.

Law above all (**Measurability Gate**): without a measurable North Star, with an orphan
objective, or with a score below the threshold (without an approved amendment) -> the
workflow does not run.

## Risks / limitations

- **Contract without engine in the template:** an adopter must implement the
  deterministic checker in their stack. Mitigated by the explicit spec (`schema.md`,
  rubric, verdict semantics) + the poirot reference impl cited.
- **Semantic vs deterministic boundary:** keyword scope predicates do not
  capture semantic drift -> the *scope compliance* judge dimension is the backstop
  (and `scopeReject` is deliberately conservative to avoid producing false rejections).
- **Bootstrap:** `/align` cannot gate the feature that introduces it — documented
  as the sole exception.

## Out of scope

- The runnable engine in the source (remains per-stack; poirot is the reference).
- Rewriting the `specs/001-example` example to pass through `/align` (predates the gate).
- Changing the source language (remains Spanish).
