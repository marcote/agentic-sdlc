# Tasks — North-Star Governance + Measurability Gate

> Executable breakdown. GATE (test-first) verified before issuing these
> tasks: in `coverage.md`, every **deterministic/structural** row (those with
> `tests/check_80_north_star.sh` as the linked test) is at `🔴 red` — the file
> does not yet exist, so all 7 assertions of `check_80` fail today (see the
> `/contract` run referenced below). The `NS-SCHEMA-CONTRACT` and
> `ALIGN-VERDICT-CONTRACT` rows are **documented contract — per-stack engine
> (deferred)**, not structural-deterministics: explicitly excluded from the
> "🔴 red with linked test" requirement (no bash check possible for an engine
> not built in this repo — see `plan.md` decision 2). `WOW-2LAYER` is
> UAT-only (prose). No structural row is left without a linked test. GATE: ✅ passes.

## Tasks

- [ ] **T1: `memory/north-star/base/*`** — covers NS-BASE; contributes to
  NS-SCHEMA-CONTRACT and AMEND-ADR
  - Create `schema.md` (measurable form: `mission`, `pillars[]` with
    `id`+`statement`+`signal`, `scope.in_scope`/`out_of_scope`,
    `alignment.threshold` — document field rules, not an executable validator),
    `alignment-rubric.md` (3 dimensions × 0–5 + pass rule),
    `amendment-protocol.md` (amendment = ADR + PR; when it applies; what does NOT
    require amendment), `adr-template.md` (Context/Decision/Scope-delta/
    Consequences), `README.md` (`extends: base` mechanism, how `base/` propagates),
    `decisions/.gitkeep`.
  - Verify: the 5 `assert_file` + the `assert_contains ... "extends: base"`
    (for README, not north-star.md) in `check_80` related to `base/` turn green.

- [ ] **T2: `memory/north-star/north-star.md` (placeholder)** — covers NS-PLACEHOLDER
  - Frontmatter `extends: base` + ` ```json ` skeleton block with
    `_(completar por proyecto)_` in content fields (no real mission or pillars —
    this repo is the harness, not an adopting project).
  - Verify: `assert_file memory/north-star/north-star.md` +
    `assert_contains ... "extends: base"` in `check_80` turn green.

- [ ] **T3: `.claude/commands/align.md` + `.claude/skills/align/SKILL.md`** —
  covers ALIGN-CMD; documents ALIGN-VERDICT-CONTRACT; declares the bootstrap
  - Command: input `brief.md` + North Star, output `alignment.md`,
    delegates to the skill. Skill: complete procedure of the 3-layer model
    (scope predicates → orphan check → quantified LLM-judge), the fixed verdict
    semantics (plan.md decision 3), and the "Bootstrap exception" section
    citing `002-north-star-governance` by name. Explicitly cite that the
    deterministic engine (`scopeReject`/`alignVerdict`/
    `validateNorthStar` or equivalents) is per-stack, with
    `poirot-fe scripts/north-star/{schema,align}.mjs` as reference
    implementation — never reimplement it inline in the skill.
  - Verify: `assert_file` for both + (partially) the `MEAS-GATE` block
    of `check_80` turn green.

- [ ] **T4: Step 0 — Measurability Gate in `.claude/skills/distill/SKILL.md`** —
  covers MEAS-GATE
  - Prepend a "Step 0 — Measurability Gate" to the existing procedure (current
    steps 1–6 do not change in number or content): reads
    `specs/<feature>/alignment.md`; absent → halts and asks for `/align`; present
    with verdict `aligned` → proceeds; `needs-amendment`/`rejected` → halts and
    signals the route (amendment or rejection, without continuing silently); declares
    the bootstrap exception for `002-north-star-governance` inline.
  - Verify: `assert_contains .claude/skills/distill/SKILL.md` for
    `alignment.md`, `Measurability Gate`, and `aligned` — all 3 in `check_80` green.

- [ ] **T5: Pillar column in `specs/_template/coverage.md`** — covers COVERAGE-PILLAR
  - Add the **Pillar** column (first column of the table) to the template,
    with an example row showing `pillar → objective → criterion`.
  - Verify: `assert_contains specs/_template/coverage.md "Pillar"` in
    `check_80` green. (Optional, not required by this feature: reinforce
    `tests/check_20_spec_templates.sh` with the same assert.)

- [ ] **T6: Two-layer Way-of-Work** — covers WOW-2LAYER
  - Edit `README.md` (section "Way of Work") and `docs/workflow.md` to
    explicitly distinguish harness=governance (commands + gates +
    constitution + North-Star) from execution-runtime=adopter (intake→brief,
    implement, finish), generically — without naming any runtime as
    mandatory for the harness.
  - Verify: UAT — manual reading confirming the distinction is clear and
    does not contradict the existing "Enforcement does not live in hooks" table.

- [ ] **T7: Final green** — covers SELFCHECK, JUDGE-ALIGNMENT; confirms NOBREAK
  - Create (already exists from `/contract`) `evals/cases/north-star-judge.md` with
    the 2 cases (in-scope passes all 3 dimensions; plausible-but-out-of-scope
    fails specifically on scope compliance) — run them against
    `memory/north-star/base/alignment-rubric.md` once T1–T3 exist, and
    record the result (e.g. in `verification/reports/`).
  - Run `bash tests/run.sh`: confirm `tests/check_80_north_star.sh` 🟢 and
    that pre-existing checks `00`–`70` remain 🟢 (no regression).
  - Update `coverage.md`: structural rows `no contract`/`🔴 red` →
    `🟢 green`; `JUDGE-ALIGNMENT` → `📋 case` with result recorded;
    `WOW-2LAYER` → `✅ uat` after human review of T6.

## Cross-cutting notes
- `check_80` (SELFCHECK) is fully green only after T1+T2+T3+T4+T5
  together (each contributes a subset of its asserts).
- The concrete deterministic engine (equivalent to `poirot-fe scripts/north-star/
  *.mjs`) is **not** a task of this `tasks.md` — it is per-stack, out of
  scope of this repo (see `plan.md` decision 2 and `spec.md` "Out of scope").
  An adopting repo that wants a truly executable `/align` needs to build it
  separately, in its own stack.
- No task in this file touches runtime app code (none exists in this
  repo) — the entire diff lives in `memory/`, `.claude/`, `specs/_template/`,
  `tests/`, `evals/`, and docs.
