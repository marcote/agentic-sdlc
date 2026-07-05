# Agentic SDLC Harness

Agnostic template (Claude Code first) for disciplined agentic development, with
verification/UAT as north star.

> **Based on Google's work.** This harness is a practical implementation of the ideas in
> Google's whitepaper **_"The New SDLC With Vibe Coding — From ad-hoc prompting
> to Agentic Engineering"_** (Addy Osmani, Shubham Saboo, and Sokratis Kartakis, May 2026):
> the *factory model*, *context engineering* (static vs dynamic), the equation
> `Agent = Model + Harness`, *output + trajectory* evals, and the *80% problem*. The
> **constitution** concept comes from **Spec Kit** (GitHub / Microsoft). See
> [Credits and references](#credits-and-references).

## The loop at a glance
`/constitution → brief → /align → /distill → /plan → /contract → /tasks → implement → /verify → /uat`

`/align` is the **intake gate** (Measurability Gate): it scores the brief against the
project's North Star (`memory/north-star/`) and `/distill` refuses to start unless
the verdict is `aligned`.

---

## Way of Work

### Philosophy

The developer's primary output **is not code: it is the system that produces code**
(the *factory model*). You define the specs and guardrails; the agent implements; the
verification validates. Four rules govern everything:

1. **Productivity first** — verification is run by the agent *on-demand*; the inner
   loop (local commit, push to work branches) never stops. The only exception is a narrow
   governance gate on `main` (the North Star amendment-gate), which does not block feature
   throughput.
2. **Intent > syntax** — the artifact that matters is the *spec* + the *acceptance
   criteria*, not the code.
3. **The constitution is code** — versioned, reviewed, inheritable. Add a rule every
   time the agent commits a repeatable mistake.
4. **Everything verifiable leaves a trail** — each verification emits a versioned report.

### Two layers: governance vs execution-runtime

The Way of Work is split into two layers with distinct owners:

| Layer | What it is | Owner | Stability |
|---|---|---|---|
| **Governance** (the harness) | the commands (`/align`, `/distill`, `/plan`, `/contract`, `/tasks`, `/verify`, `/uat`), deterministic gates, the **constitution** (how to build) and the **North Star** (why the product exists) | the harness — versioned, reviewed, the same for every adopter | stable |
| **Execution-runtime** (chosen by the adopter) | the steps that are **not** commands: the intake that produces `brief.md`, the implementation work between `/tasks` and `/verify`, and the finish (merge/PR/cleanup) | each adopting repo | swappable |

The harness **governs**; it does not impose an execution runtime. Any set of
assistants can cover intake→brief, implement, and finish as long as they respect
the governance layer's artifacts and gates. The harness **does not name any runtime
as mandatory** — a project's brainstorming/TDD/etc. assistants are point-in-time
helpers **subordinate** to this flow, not a parallel process.

Analogously, the governance layer brings the **contract** (North Star schema,
rubric, amendment protocol, semantics of the `/align` verdict) but **not** the
deterministic executable engine that evaluates it: each adopting stack provides that,
just as the eval-runner (`evals/README.md`) is left to the adopter. See `memory/north-star/base/README.md`.

### Enforcement does not live in hooks

Discipline is enforced at **workflow transitions** (once per phase), not in per-commit
hooks. Three layers, from coarsest to finest:

| Layer | What it does | When |
|---|---|---|
| **Constitution** (declarative) | non-negotiables; the agent uses it as seed and filter | always |
| **Workflow gates** (deterministic) | `/contract` red gate, `coverage.md` state machine, strict AND close | at command transitions · **90% of enforcement** |
| **Hooks** (fine) | only `secret-scan` advisory (warns, does not block) | opt-in |

### The 7 phases

Each command produces an artifact and has its verification. The backbone is
`coverage.md`: each row travels from the objective to its report.

| # | Command | Produces | Gate / verification |
|---|---|---|---|
| 1 | `/constitution` | `memory/constitution/` | seed + filter for the whole flow |
| 2 | *(intake)* | `brief.md` | product objective + success metrics (not the solution) |
| — | `/align` | `alignment.md` | **Measurability Gate**: scores the brief against the North Star; only `aligned` advances to `/distill` |
| 3 | `/distill` | `spec.md` + `acceptance.md` + `coverage.md` | grilling loop; does not freeze with orphan rows |
| 4 | `/plan` | `plan.md` | grounded in the constitution (cannot violate a `[given]`) |
| 5 | `/contract` | tests 🔴 + eval cases 📋 | runs the suite and **proves it is RED** |
| 6 | `/tasks` | `tasks.md` | **GATE test-first**: refuses to emit tasks if a red contract is missing |
| 7 | *(implement)* | code | inner loop 🔴→🟢; escalates to human on the 20% conceptual |
| 8 | `/verify` | `verification/reports/…` | output eval (BUILD) + trajectory eval, against `rubric.md` |
| 9 | `/uat` | full report | validates against the **objective**; a failure = product gap → `/distill` |

### The three loops

- **Grilling** (inside `/distill`): closes *specification gaps* before coding.
  The agent interrogates ambiguities one at a time and expands edge cases (the *80% problem*).
- **Inner loop** (implementation, per task): auto-corrects 🔴→🟢. Clear cut condition
  — DONE when the criterion's tests pass; **ESCALATES** to human after 2 identical failures
  or 3 attempts (tuneable in the constitution), instead of burning tokens.
- **Feedback** (`/verify` + `/uat`): a `/verify` failure is an *implementation* gap
  → go back to implement; a `/uat` failure is a *product* gap → go back to `/distill`.

### The backbone: `coverage.md`

Traceability matrix + state machine. Mechanical rule: **every objective reaches a
criterion; every criterion maps to an eval/UAT**. Orphan row = gap that blocks the spec
freeze. States of a deterministic criterion:

`no contract → 🔴 red → 🟢 green → ✅ uat` · `📋 case` (non-deterministic) · `[given]`
(inherited from the constitution) · `deferred` (justified gap)

### Test-first, BDD style

Each acceptance criterion is written as a **Given/When/Then** scenario, and that scenario
*is* the test. `/contract` materializes it in red; `/tasks` does not deliver implementation
work until it exists. Not left to the dev's discretion.

### Close condition (strict AND)

```
feature "DONE"  ⟺  BUILD ✅  AND  TRAJECTORY ✅  AND  UAT ✅  AND  coverage 100%
```

- **BUILD** — 100% of deterministic criteria in 🟢 (the contract, non-negotiable).
- **TRAJECTORY** — weighs as much as BUILD: a green build that *skipped verification* is a fail.
- **UAT** — the only one that validates against the brief objective and reveals product gaps.

---

## Structure
- `CLAUDE.md` — static context (stack, hard rules, workflow).
- `memory/constitution/` — non-negotiable principles (inheritable base + project).
- `memory/north-star/` — product governance (why it exists): `base/` (schema,
  rubric, amendment protocol) + `north-star.md` (the harness's North Star; the
  adopter replaces it with their own, just like the constitution) + `decisions/` (amendment ADRs).
- `specs/_template/` — feature template (brief/spec/acceptance/coverage/plan/tasks).
- `evals/` — 5-dimension rubric + non-deterministic cases.
- `verification/` — report, UAT and code-review checklists + `reports/` (observability).
- `.claude/` — skills (distill/verify/uat), 7 commands, advisory hook, settings.
- `docs/` — `factory-model.md` and `workflow.md` (detailed reference).

## Starting a feature
1. `cp -r specs/_template specs/001-my-feature` and write the `brief.md`.
2. `/distill` → `/plan` → `/contract` → `/tasks` → implement → `/verify` → `/uat`.
3. `coverage.md` is your source of truth for state.

> 📎 **Populated example:** `specs/001-example/` shows a real feature mid-way
> — with the `coverage.md` matrix mixing states (🔴 / 🟢 / ✅ / 📋 / `[given]` /
> `deferred`) to show the Way of Work in action.

## Inheriting the constitution in another project
`memory/constitution/base/` is a **vendored** shared asset: copy it to the new project.
The local `constitution.md` declares `extends: base` and adds its deltas. To update,
follow `memory/constitution/update-checklist.md` and re-copy `base/`.

## Verifying the harness
`bash tests/run.sh` — the template self-verifies (structure + hook). Also runs in CI (advisory).

## Gating North Star amendments (optional but recommended)
Changing the `pillars`/`scope` sets of the North Star is a governed event (ADR + PR, see
`memory/north-star/base/amendment-protocol.md`). The `.github/workflows/amendment-gate.yml`
workflow enforces it in CI: if a commit/push changes those sets without a new ADR, without
leaving the JSON block schema-valid, or with the suite in red, the `amendment-gate` check
fails. Normal feature development **is not blocked** (narrow block — it is the only exception
to principle 4, recorded in the constitution's D1 delta).

To make it **truly blocking** (not just advisory), the owner runs once:

```sh
scripts/setup-branch-protection.sh            # current repo, main branch
scripts/setup-branch-protection.sh OWNER/REPO main
```

This makes `amendment-gate` a *required* status-check with `enforce_admins=true`: a PR with
the gate in red is not mergeable and a direct push skipping it is rejected. Requires `gh` with
admin permissions.

## Credits and references

This harness does not invent the methodology: it operationalizes it. Conceptual credit goes to:

- **Google — _"The New SDLC With Vibe Coding — From ad-hoc prompting to Agentic
  Engineering"_** (Addy Osmani, Shubham Saboo, Sokratis Kartakis; May 2026). Source of the
  *factory model*, *context engineering* (static/dynamic), `Agent = Model + Harness`,
  *harness engineering*, *output + trajectory* evals, the *conductor/orchestrator*, and the
  *80% problem*. All Way of Work vocabulary comes from here.
- **Spec Kit — GitHub / Microsoft.** The **constitution** concept (non-negotiables that
  govern the flow) and the `specify → plan → tasks` pipeline.

Internal documents in this repo:

- Design (rationale): `docs/superpowers/specs/2026-07-02-agentic-sdlc-harness-design.md`
- Implementation plan: `docs/superpowers/plans/2026-07-02-agentic-sdlc-harness.md`
- Flow detail: `docs/workflow.md` · Factory model: `docs/factory-model.md`
