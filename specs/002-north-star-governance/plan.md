# Technical plan — North-Star Governance + Measurability Gate

> HOW it is built. Produced by `/plan`. Grounded in the constitution (violates
> no non-negotiable nor a `[given]` pattern without override). Design:
> `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`

## Technical decisions

1. **North Star = markdown + a machine-readable canonical JSON block.**
   `north-star.md` carries YAML frontmatter `extends: base` (same mechanism as
   `constitution.md`) plus **one** fenced ` ```json ` block that is the canonical
   North Star, parseable (`mission`, `pillars[]`, `scope.in_scope`/`out_of_scope`,
   `alignment.threshold`); the surrounding prose explains it for humans but nothing
   in the flow reads it to decide. *Constrained by:* base principle #1
   (Verifiability) — "what cannot be verified, is not built" extended
   from the technical to the product dimension.

2. **Contract in the template, per-stack engine (the central port decision).**
   The harness is a stack-agnostic, dependency-free template (self-check in
   pure bash, without Node/npm). Therefore this repo brings the **complete
   specification** (schema form, rubric dimensions+pass-rule, exact verdict
   semantics, amendment protocol) but does **not** implement the executable
   deterministic engine (`parseNorthStar`/`validateNorthStar`/`scopeReject`/`alignVerdict`/
   `requiresAdr`/`hasAdrFor`). Each adopting repo builds it in its own
   stack — exactly the same pattern that `evals/README.md` already uses for the
   eval-runner ("depends on the stack of the project adopting the harness"). Cites
   `poirot-fe scripts/north-star/{schema,align,amendment}.mjs` as **reference
   implementation** (Node, already built and with its own suite
   `tests/unit/north-star/*.node.spec.js`, green). *Trade-off:* an adopter must
   write its own checker before `/align` is truly executable —
   mitigated by the explicit spec + the cited reference impl. *Constrained by:*
   the repo is dependency-free (`docs/factory-model.md`, `tests/run.sh` in pure
   bash); Node/npm is not introduced in the source by this feature.

3. **Verdict aggregation: fixed and deterministic, documented here, implemented
   per-stack.** Given scores + mapping + scope-check: an `out_of_scope` hit →
   `rejected` (hard, regardless of the other two scores); otherwise, any orphan
   → blocked (not `aligned`); otherwise, all 3 dimensions ≥ `threshold` (default 3)
   → `aligned`; otherwise → `needs-amendment`. *Constrained by:* the threshold
   rule resolved in `spec.md` (Open questions).

4. **`/align` is harness-owned**, not delegated to any specific execution-runtime
   (e.g. `superpowers`) — governance lives in the harness, like
   `/constitution`/`/distill`/`/plan`/`/contract`/`/tasks`/`/verify`/`/uat`.
   Follows the same `.claude/commands/<c>.md` (thin, delegates) +
   `.claude/skills/<c>/SKILL.md` (procedure) pattern as the rest of the flow.
   Writes `specs/<feature>/alignment.md`; `/distill` reads it and refuses to
   start if the verdict is not `aligned`. *Constrained by:* README.md, table
   "Enforcement does not live in hooks" — *workflow gates* (deterministic, at
   command transitions) are "90% of enforcement"; `/align` is added as gate #0,
   not as a hook.

5. **The gate in `/distill` is a prepended Step 0, not a rewrite.**
   `.claude/skills/distill/SKILL.md` gains a **Step 0 — Measurability Gate**
   before its current "Step 1 — Seed from the constitution" (existing steps 1–6
   are not renumbered or altered in content). The Step 0 text declares the
   bootstrap exception inline (to not rely solely on `coverage.md` to document
   it). *Constrained by:* base principle #2 (test-first / deterministic gate)
   and the existing rule "do not proceed with open ambiguities" in the skill itself.

6. **`coverage.md` template gains a column: Pillar** (first column, before
   "Objective"), consistent with the `pillar → objective → criterion` chain in the
   design. `tests/check_80_north_star.sh` asserts that
   `specs/_template/coverage.md` contains the word `Pillar` — a decision
   made in this `/contract` (not explicitly enumerated in the design, which only
   describes 4 groups of asserts for `check_80`) so that a real RED exists today
   proving the gap, rather than leaving the column with no linked check.
   Extending `tests/check_20_spec_templates.sh` with a richer content assert
   remains a possible follow-up, not required by this feature.

7. **Bash self-check, dependency-free, auto-glob.**
   `tests/check_80_north_star.sh` (new) mirrors the style of
   `tests/check_10_constitution.sh` (`assert_file`/`assert_contains` from
   `tests/lib.sh`, without frameworks). No changes needed in `tests/run.sh`: the
   `for t in tests/check_*.sh` glob already picks it up in alphanumeric order.
   *Constrained by:* base constitution — the self-check is on-demand, nothing
   blocks commit/push by default (rule 4).

8. **Bootstrap.** `/align` cannot gate the feature that introduces it
   (`002-north-star-governance`, this one) — skipped only for this
   feature, documented in `coverage.md` and (once implemented, task T3 of
   `tasks.md`) in `.claude/skills/align/SKILL.md` itself. From the next
   feature onward, `/align` runs before `/distill` without exception.

9. **Two-layer Way-of-Work, generic.** `README.md` (section "Way of Work")
   and `docs/workflow.md` are enriched to explicitly distinguish: the
   **harness governs** (commands, deterministic gates, constitution,
   North-Star) — stable, versioned layer, the same for every adopter; the
   steps that are **not** commands (intake→brief, implement, finish) are
   provided by an **execution-runtime** that each adopter chooses (the harness
   names none as mandatory — not even `superpowers`, even if it is the
   runtime that `poirot-fe` chose in practice). It is prose content: there is
   no reliable bash check for "clearly explains the two-layer distinction"; it is
   closed by UAT (human reading), not by `check_80`.

10. **Additive, no engine code, no Node/npm.** Everything landing in this
    feature lives under `memory/north-star/`, `.claude/`, `specs/_template/`,
    `tests/`, `evals/`, and docs — no runtime app code (there is no runtime app in
    this repo: it is the template). *Constrained by:* the repo is stack-agnostic /
    dependency-free by design (see `docs/factory-model.md`); introducing a
    Node engine here would violate that property for every non-Node adopter.

## Components / modules

- **`memory/north-star/base/`** — `schema.md` (required form + validity rules),
  `alignment-rubric.md` (3 dims × 0–5 + pass rule), `amendment-protocol.md`
  (ADR + PR), `adr-template.md`, `README.md` (`extends: base`), `decisions/.gitkeep`.
- **`memory/north-star/north-star.md`** — placeholder: frontmatter `extends: base`
  + JSON skeleton block `_(completar por proyecto)_`.
- **`.claude/commands/align.md` + `.claude/skills/align/SKILL.md`** — orchestrate
  the gate; document the 3-layer model and produce `alignment.md`; cite the
  poirot reference impl for the concrete engine.
- **`.claude/skills/distill/SKILL.md`** — edit: Step 0 — Measurability Gate.
- **`specs/_template/coverage.md`** — **Pillar** column added.
- **`tests/check_80_north_star.sh`** — integrity self-check (presence +
  wiring grep), auto-picked by `tests/run.sh`.
- **`evals/cases/north-star-judge.md`** — the non-deterministic eval case
  (JUDGE-ALIGNMENT), generic (illustrative pillars — the harness has no North
  Star of its own with real content).
- **Docs:** `README.md` (Way of Work, two layers), `docs/workflow.md` (`/align`
  as first gate + Measurability Gate note).
- **Outside this repo (per-stack, deferred):** the deterministic engine
  equivalent to `poirot-fe scripts/north-star/{schema,align,amendment}.mjs` —
  each adopter writes it in their own stack; there is no `tasks.md` task to
  build it here.

## Risks

- **Semantic vs deterministic boundary.** Keyword-based scope predicates do not
  capture semantic drift → the "scope compliance" judge dimension is the
  backstop; documented explicitly so an adopter does not confuse the deterministic
  predicate with the sole defense.
- **Contract without engine in the template.** An adopting repo must implement the
  deterministic checker before `/align` is truly executable →
  mitigated with the explicit spec (`schema.md`, rubric, verdict semantics)
  + the `poirot-fe` reference impl already green and cited by exact path.
- **Bootstrap confusion.** It must be clear that `/align` is skipped *only* for
  the feature that introduces it, not in general → documented in three places:
  `coverage.md`, `.claude/skills/align/SKILL.md` itself (task T3), and the
  Step 0 of `.claude/skills/distill/SKILL.md` (task T4).
- **Pillar column without a dedicated check in the original design.** Resolved by
  adding a `Pillar` assert to `check_80_north_star.sh` (decision 6) so that
  criterion COVERAGE-PILLAR has a real RED, not an unverified promise.
- **Prose↔JSON block drift** (for when real content exists): the JSON block is
  the sole source of truth; the prose is only explanatory — the validator
  (per-stack) never reads the prose.
