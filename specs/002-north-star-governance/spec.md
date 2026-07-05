# Spec — North-Star Governance + Measurability Gate

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when
> `coverage.md` has no orphan rows.
>
> Design: `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`
> Origin: capability piloted in `poirot-fe` (branch `feature/north-star-governance`,
> PR #24) — the concrete deterministic engine lives there (`scripts/north-star/*.mjs`)
> as **reference implementation**; this spec ports the **contract**, not the engine.

## Functional requirements

### North-Star base layer (`memory/north-star/`, peer of the constitution)
1. `memory/north-star/base/`: `schema.md` (required measurable form: `mission`,
   `pillars[]` with `id`+`statement`+`signal`, `scope.in_scope`/`scope.out_of_scope`,
   `alignment.threshold`), `alignment-rubric.md` (3 dimensions — pillar fit, scope
   compliance, mission advancement — 0–5, pass = all ≥ threshold),
   `amendment-protocol.md` (amendment = ADR + PR), `adr-template.md`, `README.md`
   (documents the `extends: base` mechanism), `decisions/.gitkeep`.
2. `memory/north-star/north-star.md`: project **placeholder** —
   `extends: base` + canonical JSON skeleton block marked
   `_(completar por proyecto)_`; the real content (mission, pillars) is completed by
   each adopting repo (no MEXBANK/poirot content here).
3. A North Star is **measurable** iff it is schema-valid: non-empty `mission`, ≥1
   pillar with `id`+`statement`+`signal`, non-empty `scope.in_scope`/`out_of_scope`,
   `alignment.threshold` present. A non-measurable one → the flow refuses to
   run against it (Measurability Gate, below).

### Intake gate `/align` (harness-owned)
4. `.claude/commands/align.md` + `.claude/skills/align/SKILL.md`: input
   `specs/<feature>/brief.md` + the project North Star; output
   `specs/<feature>/alignment.md` with verdict, scores, objective→pillar mapping,
   and orphans.
5. The checkable 3-layer model (contract; the concrete deterministic engine
   is implemented by each adopting stack — see "Out of scope"):
   (a) **scope predicates** — conservative contiguous-phrase match against
   `out_of_scope` → `rejected`; (b) **orphan check** — every objective maps to
   ≥1 pillar, otherwise → blocked; (c) **quantified LLM-judge** — scores the 3
   rubric dimensions 0–5.
6. Verdict aggregation (fixed, documented here; implemented per-stack):
   an `out_of_scope` hit → `rejected` (hard, regardless of scores); otherwise,
   orphan → blocked; otherwise, all 3 dimensions ≥ `threshold` (default 3) →
   `aligned`; otherwise → `needs-amendment`.

### Measurability Gate (the law) in `/distill`
7. `.claude/skills/distill/SKILL.md` gains a **Step 0**: reads
   `specs/<feature>/alignment.md`; if missing → halts and asks to run `/align`
   first; if verdict is not `aligned` (`needs-amendment`/`rejected`) →
   halts and signals the route (amendment or rejection); only `aligned` proceeds.
   **Bootstrap exception:** the feature that introduces `/align`
   (`002-north-star-governance`, this one) is exempt — the single exception.

### Governed drift (amendments)
8. Changing the North Star (`scope`/`pillars`) requires an **ADR** (context,
   decision, scope-delta, consequences) in
   `memory/north-star/decisions/NNNN-*.md`, which lands via **PR** (human
   approval). A scope/pillars change without a corresponding ADR is a
   governance violation (flaggable). It is the auditable trail
   (`[given] base/audit-logging` applied to product governance rather than
   write endpoints).

### Traceability
9. `specs/_template/coverage.md` gains a **Pillar** column; the chain becomes
   `pillar → objective → criterion → test/eval`. A criterion whose objective
   has no pillar is a detectable drift signal.

### Integrity
10. `tests/check_80_north_star.sh` (bash, dependency-free, auto-picked by the
    `tests/run.sh` glob): base layer present, `north-star.md` with
    `extends: base`, `/align` command+skill exist, the `distill` skill contains
    the gate wiring (Step 0), and the coverage template contains the Pillar column.

### Way-of-Work (two layers)
11. The source README/docs explicitly distinguish: the **harness
    governs** (commands + gates + constitution + North-Star); the steps that
    are not commands (intake→brief, implement, finish) are provided by an
    **execution-runtime** chosen by each adopter (generic — the harness names
    no runtime as mandatory).

## User stories
- As a **product/tech lead**, I want out-of-scope features to be blocked at
  intake, so that the product does not drift from its mission under agentic throughput.
- As an **agent**, I want a machine-checkable gate that tells me whether a
  brief belongs to the mission before distilling it.
- As a **maintainer of any adopting repo**, I want this as a reusable harness
  capability, with my own North Star as a project delta and my own deterministic
  engine in my stack.
- As a **reviewer**, I want every scope change to arrive as ADR + PR,
  so that drift is deliberate, justified, and auditable.

## Edge cases (80% problem)
- North Star absent or schema-invalid → the flow refuses (clear message), not
  a silent crash — but the checker that decides this is per-stack; only the rule
  is documented here.
- Brief with mixed objectives (one in-scope, one out-of-scope) → `rejected` (the
  out-of-scope objective blocks the entire brief).
- Borderline brief (in-scope, judge scores 2 on one dimension) →
  `needs-amendment`, never a silent pass.
- An objective that maps only weakly to a pillar → low judge score →
  exposed, not hidden.
- An amendment lands without ADR → flagged as governance violation.
- Bootstrap: the feature that introduces `/align` cannot be gated by it —
  skipped only for this feature (documented), just as the original harness
  bootstrap skipped its own gates.
- Adopting repo without a deterministic engine yet implemented → the template
  remains valid (the contract is complete in prose/schema), but the `/align`
  gate cannot truly execute until the adopter writes their checker —
  this is explicit, not a silent fallback.

## Open questions / deferred
- **Amendment = ADR + PR** (resolved): the PR is the approval, the ADR is the
  formal record.
- **Threshold** (resolved): 0–5 per dimension, pass = all ≥3, overrideable
  per project via `alignment.threshold`.
- **Concrete deterministic engine** (deferred, out of scope of this repo):
  each adopting stack implements it; `poirot-fe scripts/north-star/*.mjs` is
  the cited reference implementation (already built and unit-tested there).
- **`north-star.md` with real project content** (deferred): in the
  source it is a placeholder; each adopter completes their mission/pillars.
- `[given] idempotency` + `[given] rate-limiting` → deferred (this layer is
  governance markdown; no retries/webhooks or network surface).
- Rewriting `specs/001-example` to pass through `/align` → out of scope
  (predates the gate).
