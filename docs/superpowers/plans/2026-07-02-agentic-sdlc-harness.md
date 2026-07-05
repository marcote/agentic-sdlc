# Agentic SDLC Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold an agnostic, Claude-Code-first "harness" template repo that enforces spec-driven, verification-first (UAT) development with an inheritable constitution and test-first workflow gates.

**Architecture:** The repo is a template (no app code). It provides: static context (`CLAUDE.md` + `memory/constitution/`), dynamic context (`.claude/skills/`), 7 slash-commands, feature templates (`specs/_template/`), an evaluation rubric + verification report templates, a minimal advisory `secret-scan` hook, an advisory CI workflow, and docs. The template verifies its own structural integrity with a dependency-free bash test suite (`tests/run.sh`), which is also the CI check.

**Tech Stack:** Markdown (skills/commands/templates/docs), JSON (`.claude/settings.json`), POSIX/Bash (hook + test suite), GitHub Actions YAML (advisory CI). No language runtime or package manager — the harness is stack-agnostic.

## Global Constraints

These apply to EVERY task (copied verbatim from the spec):

- **Claude Code first.** Instruction files are `CLAUDE.md` + `.claude/`. No `AGENTS.md`/`GEMINI.md`.
- **Agnostic.** No application code, no stack-specific scaffolding, no language runtime dependency. Tests use only `bash` + coreutils (`grep`, `git`).
- **On-demand verification.** `/verify` and `/uat` are invoked by the dev/agent when closing a unit of work — never as blocking per-commit hooks.
- **No blocking commit hooks by default.** The only hook is `secret-scan`, and it is **advisory** (warns, exits 0) unless `SECRET_SCAN_BLOCK=1`.
- **Constitution inheritance = vendored + convention.** `memory/constitution/base/` is copied with the template; `constitution.md` declares `extends: base`.
- **Test-first enforced by the workflow, not by the dev.** A criterion cannot reach implementation without a linked test in `🔴 RED` state (`/contract` gate, checked in `/tasks`).
- **Feature close condition (AND-strict):** `BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%`.
- **Naming:** feature folders `specs/<NNN-feature>/` (kebab-case, zero-padded NNN); the canonical blank feature lives at `specs/_template/`.
- **Coverage state legend (used verbatim):** `🔴 red` → `🟢 green` → `✅ uat` for deterministic; `📋 case` for non-deterministic; `[given]` marks constitution-inherited rows; `deferred` marks justified gaps.

**Reference:** the approved design at `docs/superpowers/specs/2026-07-02-agentic-sdlc-harness-design.md`. When a task says "see design §N", read that section for rationale.

---

### Task 1: Self-verification test harness + repo skeleton

**Files:**
- Create: `tests/lib.sh`
- Create: `tests/run.sh`
- Create: `tests/check_00_skeleton.sh`
- Create: `.gitkeep` files for empty dirs (see Step 3)

**Interfaces:**
- Produces (used by all later tasks' test files): shell helpers `assert_file <path>`, `assert_dir <path>`, `assert_contains <path> <ERE>`, and `summary` (exits non-zero if any assertion failed). Later tasks add `tests/check_NN_*.sh` files that source nothing themselves — `run.sh` sources `lib.sh` once, then sources every `check_*.sh` in order.

- [ ] **Step 1: Write the failing structure test**

Create `tests/check_00_skeleton.sh`:

```bash
# Sourced by tests/run.sh (lib.sh already loaded). Verifies top-level layout.
assert_dir memory/constitution/base/patterns
assert_dir specs/_template
assert_dir evals/cases
assert_dir verification/reports
assert_dir .claude/skills
assert_dir .claude/commands
assert_dir .claude/hooks
assert_dir docs
```

- [ ] **Step 2: Create the test library and runner**

Create `tests/lib.sh`:

```bash
# Dependency-free assertion helpers. No frameworks.
FAILS=0; PASSES=0
_pass(){ PASSES=$((PASSES+1)); echo "  PASS: $1"; }
_fail(){ FAILS=$((FAILS+1)); echo "  FAIL: $1"; }
assert_file(){ if [ -f "$1" ]; then _pass "file $1"; else _fail "missing file $1"; fi; }
assert_dir(){ if [ -d "$1" ]; then _pass "dir $1"; else _fail "missing dir $1"; fi; }
assert_contains(){ if grep -qE "$2" "$1" 2>/dev/null; then _pass "$1 =~ /$2/"; else _fail "$1 missing /$2/"; fi; }
summary(){ echo "---"; echo "TOTAL PASS=$PASSES FAIL=$FAILS"; [ "$FAILS" -eq 0 ]; }
```

Create `tests/run.sh`:

```bash
#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."
. tests/lib.sh
for t in tests/check_*.sh; do
  [ -f "$t" ] || continue
  echo "== $t =="
  . "$t"
done
summary
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `chmod +x tests/run.sh && bash tests/run.sh`
Expected: FAIL lines for the missing dirs; final line `TOTAL PASS=0 FAIL=8`; exit code non-zero.

- [ ] **Step 4: Create the skeleton dirs to make it pass**

Run:
```bash
mkdir -p memory/constitution/base/patterns specs/_template evals/cases \
  verification/reports .claude/skills .claude/commands .claude/hooks docs
touch evals/cases/.gitkeep verification/reports/.gitkeep
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; final line `TOTAL PASS=8 FAIL=0`; exit code 0.

- [ ] **Step 6: Commit**

```bash
git add tests .gitkeep evals/cases/.gitkeep verification/reports/.gitkeep
git add -A
git commit -m "feat: self-verification test harness + repo skeleton"
```

---

### Task 2: Constitution foundation (base + project + CLAUDE.md)

**Files:**
- Create: `CLAUDE.md`
- Create: `memory/constitution/base/principles.md`
- Create: `memory/constitution/base/README.md`
- Create: `memory/constitution/base/patterns/audit-logging.md`
- Create: `memory/constitution/base/patterns/rate-limiting.md`
- Create: `memory/constitution/base/patterns/idempotency.md`
- Create: `memory/constitution/constitution.md`
- Create: `memory/constitution/update-checklist.md`
- Create: `tests/check_10_constitution.sh`

**Interfaces:**
- Consumes: assertion helpers from Task 1.
- Produces: the pattern file contract — each `patterns/*.md` MUST contain a line beginning `**Injected criteria:**` and a `[given]` token, because `/distill` (Task 6) parses these to inject rows into `coverage.md`.

- [ ] **Step 1: Write the failing test**

Create `tests/check_10_constitution.sh`:

```bash
assert_file CLAUDE.md
assert_contains CLAUDE.md "memory/constitution"
assert_file memory/constitution/base/principles.md
assert_file memory/constitution/base/README.md
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "extends: base"
assert_file memory/constitution/update-checklist.md
for p in audit-logging rate-limiting idempotency; do
  assert_file "memory/constitution/base/patterns/$p.md"
  assert_contains "memory/constitution/base/patterns/$p.md" "Injected criteria"
  assert_contains "memory/constitution/base/patterns/$p.md" "\[given\]"
done
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `CLAUDE.md`**

```markdown
# Agentic SDLC Harness

Stack-agnostic template for disciplined agentic development (Claude Code first).
Contains no app code: provides the harness that surrounds the model.

## Stack
Agnostic. Copy it on top of any project.

## Conventions
- One feature = one folder `specs/<NNN-feature>/` (kebab-case, NNN zero-padded).
- Acceptance criteria are written in BDD (Given/When/Then).
- `coverage.md` is the source of truth for the state of each criterion.

## Hard rules (detail in memory/constitution/)
- No deterministic criterion advances to implementation without a test in 🔴 RED (`/contract`).
- A feature closes only with: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
- Verification is on-demand (`/verify`, `/uat`); no blocking commit hooks.
- Add a rule to memory/constitution/ each time you make a repeatable mistake.

## Workflow
`/constitution` → (brief) → `/distill` → `/plan` → `/contract` → `/tasks` → implement → `/verify` → `/uat`
See `docs/workflow.md`.

## Pointers
- Non-negotiable principles: `memory/constitution/`
- Skills (dynamic context): `.claude/skills/` (distill, verify, uat)
- Feature templates: `specs/_template/`
- Evaluation rubric: `evals/rubric.md`
- Verification reports (observability): `verification/reports/`
```

- [ ] **Step 4: Create the base constitution files**

`memory/constitution/base/principles.md`:

```markdown
# Constitution — Base Principles (inherited, non-negotiable)

These principles are the most stable layer of static context. Every spec, plan, and
verification must comply with them. They are inherited via `extends: base`.

1. **Verifiability.** Every requirement is expressed as a measurable acceptance criterion
   (BDD). What cannot be verified is not built.
2. **Test-first.** The deterministic portion of each criterion exists as a test in 🔴 RED
   before writing implementation (`/contract` gate).
3. **Full traceability.** Every brief objective reaches a criterion; every criterion
   maps to an eval or UAT step. Orphan rows = gap that blocks the spec freeze.
4. **Productivity first.** Verification is on-demand; nothing blocks commit/push.
5. **Auditable trail.** Each verification produces a versioned report.
6. **Security by default.** No secrets in the repo; inherited patterns (below)
   apply unless overridden with justification in the project's `constitution.md`.
```

`memory/constitution/base/README.md`:

```markdown
# How constitution inheritance works

- `base/` is a **vendored** shared asset: copied with the template.
- The project's `constitution.md` declares `extends: base` and adds deltas/overrides.
- Each file in `base/patterns/` is a "given practice": in addition to a prose principle,
  it declares **injected acceptance criteria** that `/distill` automatically adds as
  `[given]` rows in the `coverage.md` of each applicable feature.
- To update the base: edit `base/`, follow `../update-checklist.md`, and re-copy
  to projects that inherit it (explicit sync, no submodules).
```

`memory/constitution/base/patterns/audit-logging.md`:

```markdown
# Pattern: Audit Logging (given practice)

**Principle:** every write operation leaves an auditable trail.
**Applies to:** any feature with write endpoints/actions.
**Injected criteria:**
- `[given]` every write operation emits an audit-log with `actor` + `timestamp` + `entity`.
  → maps to `eval: audit-trail`.
```

`memory/constitution/base/patterns/rate-limiting.md`:

```markdown
# Pattern: Rate Limiting (given practice)

**Principle:** every network-exposed surface has a rate limit.
**Applies to:** any feature with public or semi-public endpoints.
**Injected criteria:**
- `[given]` every exposed endpoint responds `429` when the configured limit is exceeded.
  → maps to `eval: rate-limit`.
```

`memory/constitution/base/patterns/idempotency.md`:

```markdown
# Pattern: Idempotency (given practice)

**Principle:** repeatable write operations are idempotent.
**Applies to:** any feature with retries, webhooks, or payments.
**Injected criteria:**
- `[given]` resending the same request with the same `idempotency-key` does not duplicate the effect.
  → maps to `eval: idempotency`.
```

- [ ] **Step 5: Create the project constitution + update checklist**

`memory/constitution/constitution.md`:

```markdown
---
extends: base
---

# Constitution — Project

Extends `base` (see `base/principles.md`). Add project-specific principles and overrides
here. Overriding a `base/pattern` requires explicit justification.

## Project deltas
_(empty — to be filled per project)_

## Inherited pattern overrides
_(none — to disable a pattern, list it here with its justification)_

## Inner loop budget (tuneable)
- Escalate to human after **2 identical failures** or **3 total attempts** per task.
```

`memory/constitution/update-checklist.md`:

```markdown
# Checklist to update the constitution

When the agent makes a repeatable mistake or changes a rule:

- [ ] Is it a universal principle? → `base/principles.md`. Or a practice with criteria? → new `base/patterns/<x>.md`.
- [ ] If it's a pattern: include the `**Injected criteria:**` section with at least one `[given]`.
- [ ] Is it project-specific? → `constitution.md` (deltas/overrides).
- [ ] Update the date/reason in the commit.
- [ ] Re-copy `base/` to projects that inherit it (vendored).
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS (Task 1 + Task 2 assertions); `FAIL=0`; exit 0.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: constitution foundation (base patterns + project + CLAUDE.md)"
```

---

### Task 3: Feature templates (`specs/_template/`)

**Files:**
- Create: `specs/_template/brief.md`
- Create: `specs/_template/spec.md`
- Create: `specs/_template/acceptance.md`
- Create: `specs/_template/coverage.md`
- Create: `specs/_template/plan.md`
- Create: `specs/_template/tasks.md`
- Create: `tests/check_20_spec_templates.sh`

**Interfaces:**
- Consumes: helpers from Task 1; coverage state legend from Global Constraints.
- Produces: `coverage.md` MUST contain the state legend tokens and a markdown table with columns `Objective | Requirement | Criterion | Origin | Status`; `acceptance.md` MUST contain a `Given`/`When`/`Then` block. `/contract` and `/tasks` (Task 5) and `/distill` (Task 6) parse these.

- [ ] **Step 1: Write the failing test**

Create `tests/check_20_spec_templates.sh`:

```bash
for f in brief spec acceptance coverage plan tasks; do
  assert_file "specs/_template/$f.md"
done
assert_contains specs/_template/acceptance.md "Given"
assert_contains specs/_template/acceptance.md "When"
assert_contains specs/_template/acceptance.md "Then"
assert_contains specs/_template/coverage.md "Status"
assert_contains specs/_template/coverage.md "🔴"
assert_contains specs/_template/coverage.md "\[given\]"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new file/content assertions; exit non-zero.

- [ ] **Step 3: Create `brief.md`, `spec.md`, `acceptance.md`**

`specs/_template/brief.md`:

```markdown
# Brief — <feature>

> ORIGIN of the development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective
_(what business/user problem we are solving)_

## Why / motivation
_(why now, what happens if we don't do it)_

## Success metrics
_(measurable: e.g. "↑ mobile conversion 5%", "p95 latency < 300ms")_

## Out of scope
_(what it explicitly does NOT do)_
```

`specs/_template/spec.md`:

```markdown
# Spec — <feature>

> WHAT is being built. Produced by `/distill` from `brief.md`. Frozen
> when `coverage.md` has no orphan rows.

## Functional requirements
1. _(requirement)_

## User stories
- As _<role>_ I want _<capability>_ so that _<benefit>_.

## Edge cases (80% problem)
- _(cases not covered in the brief — expanded in the distillation loop)_

## Open questions / deferred
- _(ambiguities resolved or deferred with justification)_
```

`specs/_template/acceptance.md`:

```markdown
# Acceptance — <feature>

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the
> eval and the UAT step. The deterministic portion materializes as a test in `/contract`.

## Criterion: <name>  (deterministic)
```gherkin
Given <precondition>
When <action>
Then <observable and measurable result>
```

## Criterion: <name>  (non-deterministic → eval case)
_(behavior/quality that is not unit-tested; generates a case in `evals/cases/`)_
```

- [ ] **Step 4: Create `coverage.md`, `plan.md`, `tasks.md`**

`specs/_template/coverage.md`:

```markdown
# Coverage — <feature>

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

| Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|
| _(e.g.)_ ↑ conversion | Save card 1-tap | token < 300ms | project | `card_token.feature` | 🔴 red |
| — | (all writes) | audit-log actor+ts | `[given] base/audit-logging` | `audit.feature` | 🔴 red |
```

`specs/_template/plan.md`:

```markdown
# Technical plan — <feature>

> HOW it is built. Produced by `/plan`. Must be grounded in the constitution
> (cannot propose anything that violates a non-negotiable or a `[given]` pattern without an override).

## Technical decisions
- _(decision + trade-off + which constitution principle/pattern constrains it)_

## Components / modules
- _(unit → responsibility → interface)_

## Risks
- _(risk → mitigation)_
```

`specs/_template/tasks.md`:

```markdown
# Tasks — <feature>

> Executable breakdown. Produced by `/tasks`. GATE: `/tasks` does not emit implementation
> tasks while any deterministic criterion has no linked test in 🔴 RED.

## Tasks
- [ ] T1: _(testable unit)_ — covers criteria: _(rows from coverage.md)_
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: feature templates (brief/spec/acceptance/coverage/plan/tasks)"
```

---

### Task 4: Evals rubric + verification templates

**Files:**
- Create: `evals/rubric.md`
- Create: `evals/README.md`
- Create: `verification/verification-report.md`
- Create: `verification/uat-checklist.md`
- Create: `verification/code-review-checklist.md`
- Create: `tests/check_30_verification.sh`

**Interfaces:**
- Consumes: helpers from Task 1.
- Produces: `rubric.md` MUST name all five dimensions (`Task success`, `Tool use`, `Trajectory`, `Hallucination`, `Response quality`); `verification-report.md` MUST contain the five section headers (`Coverage snapshot`, `Output eval`, `Trajectory eval`, `UAT`, `Verdict`). `/verify` and `/uat` (Task 6) fill these.

- [ ] **Step 1: Write the failing test**

Create `tests/check_30_verification.sh`:

```bash
assert_file evals/rubric.md
for d in "Task success" "Tool use" "Trajectory" "Hallucination" "Response quality"; do
  assert_contains evals/rubric.md "$d"
done
assert_file evals/README.md
assert_file verification/verification-report.md
for s in "Coverage snapshot" "Output eval" "Trajectory eval" "UAT" "Verdict"; do
  assert_contains verification/verification-report.md "$s"
done
assert_file verification/uat-checklist.md
assert_file verification/code-review-checklist.md
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `evals/rubric.md` and `evals/README.md`**

`evals/rubric.md`:

```markdown
# Eval Rubric

> "An eval without a clear rubric measures nothing." Five dimensions, each with an
> explicit scale and threshold. Trajectory weighs the same as Task success: a green
> build that skipped verification is a FAIL.

| Dimension | What it measures | Type | Scoring | Threshold |
|---|---|---|---|---|
| **Task success** | Does the artifact meet the criteria? | deterministic | tests green / total deterministic criteria | **100%** (non-negotiable) |
| **Tool use** quality | Did it use the right tools correctly? | trajectory | LM judge + checks vs `tasks.md` | ≥ threshold |
| **Trajectory** compliance | Did it follow the flow? Did it skip verification? | trajectory | LM judge over the trace | no steps skipped |
| **Hallucination** | Invented deps/APIs? | mixed | real import check + judge | **0** |
| **Response quality** | non-deterministic criteria | non-determ. | eval cases + LM judge vs `acceptance` | ≥ threshold |
```

`evals/README.md`:

```markdown
# Evals

- `rubric.md` — how scoring works (5 dimensions).
- `cases/` — one case per NON-deterministic criterion (free format: `.yaml`/`.md`).
  Cases are created in `/contract`, BEFORE implementing.

## Runner
The concrete executable runner depends on the stack of the project adopting the harness
(out of scope for the template). The contract: a case must be scoreable against
`rubric.md` and its result feeds the "Trajectory eval" / "Response quality" section
of `verification-report.md`.
```

- [ ] **Step 4: Create the three verification templates**

`verification/verification-report.md`:

```markdown
# Verification Report — <feature> @ <commit/ref>

spec: <spec.md vN> · date: <YYYY-MM-DD> · constitution: base v<X> + project v<Y>

## 1. Coverage snapshot
_(copied from coverage.md: criterion → status → linked test/eval)_

## 2. Output eval (BUILD)  — deterministic, runs in /verify
_(per criterion: test → pass/fail | Task success: N/N = %)_

## 3. Trajectory eval  — non-deterministic, LM judge over the trace
_(tool use: score/threshold | steps skipped: … | hallucination: N)_

## 4. UAT  — appended by /uat, against acceptance.md
_(BDD scenario → walked → pass/fail → note; UAT failures are PRODUCT gaps → /distill)_

## 5. Verdict
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%>
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
Gaps routed: _(to /verify=implementation, to /distill=product)_
```

`verification/uat-checklist.md`:

```markdown
# UAT Checklist — <feature>

> Walked in `/uat`, against `acceptance.md`. UAT validates against the OBJECTIVE
> (brief), not just the spec — that is why it can reveal product gaps.

For each acceptance criterion:
- [ ] BDD scenario executed as written.
- [ ] Observable result matches the `Then`.
- [ ] Does the criterion, when met, move the success metric of the brief? (if not → product GAP → `/distill`)
- [ ] Status updated in `coverage.md` (→ ✅ uat).
```

`verification/code-review-checklist.md`:

```markdown
# Code Review Checklist — AI-generated code

> "AI-generated code requires the same or greater scrutiny than human-written code."

- [ ] Imports/dependencies exist and are correct (no hallucinated packages).
- [ ] Error handling covers realistic failure modes, not just the happy path.
- [ ] No hardcoded secrets.
- [ ] The code complies with applicable `[given]` patterns (audit-log, rate-limit, idempotency…).
- [ ] Logic that "looks correct" was verified against the criterion, not assumed.
- [ ] Changes traceable to rows in `coverage.md`.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: eval rubric + verification/UAT/code-review templates"
```

---

### Task 5: Slash commands (7)

**Files:**
- Create: `.claude/commands/constitution.md`
- Create: `.claude/commands/distill.md`
- Create: `.claude/commands/plan.md`
- Create: `.claude/commands/contract.md`
- Create: `.claude/commands/tasks.md`
- Create: `.claude/commands/verify.md`
- Create: `.claude/commands/uat.md`
- Create: `tests/check_40_commands.sh`

**Interfaces:**
- Consumes: helpers from Task 1; skills from Task 6 are referenced by name (`distill`, `verify`, `uat`).
- Produces: each command file MUST start with YAML frontmatter containing a `description:` line. `/contract` and `/tasks` define the test-first gate procedure that the design §8 mandates.

- [ ] **Step 1: Write the failing test**

Create `tests/check_40_commands.sh`:

```bash
for c in constitution distill plan contract tasks verify uat; do
  f=".claude/commands/$c.md"
  assert_file "$f"
  assert_contains "$f" "^description:"
done
assert_contains .claude/commands/tasks.md "RED"
assert_contains .claude/commands/contract.md "RED"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create the four spec-phase commands**

`.claude/commands/constitution.md`:

```markdown
---
description: Create or update the constitution (base + project). Seed and filter of the workflow.
---

Read `memory/constitution/base/principles.md` and `memory/constitution/constitution.md`.
To create/update rules, follow `memory/constitution/update-checklist.md`:
universal principles → `base/principles.md`; practices with criteria → `base/patterns/<x>.md`
(with `**Injected criteria:**` section and at least one `[given]`); project-specific → `constitution.md`.
```

`.claude/commands/distill.md`:

```markdown
---
description: Distill brief.md into spec + acceptance + coverage (grilling-style loop, covers gaps).
---

Invoke the `distill` skill. Requires `specs/<feature>/brief.md`. Do not proceed with open
ambiguities or orphan rows in `coverage.md`.
```

`.claude/commands/plan.md`:

```markdown
---
description: Produce the technical plan (plan.md) grounded in the constitution.
---

With `spec.md` frozen, write `specs/<feature>/plan.md`. Each technical decision must
respect the non-negotiables and the `[given]` patterns; any override requires explicit
justification in `memory/constitution/constitution.md`.
```

`.claude/commands/contract.md`:

```markdown
---
description: Generate the test contract (deterministic) and eval cases (non-deterministic) and verify it is RED.
---

For each criterion in `acceptance.md`:
- Deterministic → generate the test (BDD) and link it in `coverage.md`. RUN the suite: it must be 🔴 RED
  (proves the test is real and the feature does not exist). Record the linked test per criterion.
- Non-deterministic → create a case in `evals/cases/` (status 📋).
Do not mark any row as ready until the RED state (deterministic) or case present is confirmed.
```

- [ ] **Step 4: Create the decomposition + verification commands**

`.claude/commands/tasks.md`:

```markdown
---
description: Break down into executable tasks. GATE test-first — rejects if RED contract is missing.
---

GATE (machine-checkable, not discretionary): walk through `coverage.md`. For EACH
deterministic row, require `linked test != empty AND status == 🔴 RED`. If any does not
comply, DO NOT emit implementation tasks: report the missing rows and stop.
Only if the gate passes, write `specs/<feature>/tasks.md` (each task links its coverage rows).
```

`.claude/commands/verify.md`:

```markdown
---
description: On-demand verification — runs output + trajectory eval and emits the verification-report.
---

Invoke the `verify` skill. Generates `verification/reports/<feature>-<ref>.md` from
`verification/verification-report.md`, scoring against `evals/rubric.md`.
```

`.claude/commands/uat.md`:

```markdown
---
description: On-demand UAT against acceptance.md — validates against the objective of the brief.
---

Invoke the `uat` skill. Walk through `verification/uat-checklist.md`. A UAT failure is a
PRODUCT gap → route to `/distill`. Update `coverage.md` (→ ✅ uat) and the report.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: 7 slash-commands (constitution/distill/plan/contract/tasks/verify/uat)"
```

---

### Task 6: Skills (distill, verify, uat)

**Files:**
- Create: `.claude/skills/distill/SKILL.md`
- Create: `.claude/skills/verify/SKILL.md`
- Create: `.claude/skills/uat/SKILL.md`
- Create: `tests/check_50_skills.sh`

**Interfaces:**
- Consumes: helpers from Task 1; the templates from Tasks 3-4 (skills read/write those files).
- Produces: each `SKILL.md` MUST start with YAML frontmatter containing `name:` and `description:` (Claude Code skill contract).

- [ ] **Step 1: Write the failing test**

Create `tests/check_50_skills.sh`:

```bash
for s in distill verify uat; do
  f=".claude/skills/$s/SKILL.md"
  assert_file "$f"
  assert_contains "$f" "^name:"
  assert_contains "$f" "^description:"
done
assert_contains .claude/skills/distill/SKILL.md "grilling"
assert_contains .claude/skills/verify/SKILL.md "rubric"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `distill/SKILL.md`**

```markdown
---
name: distill
description: Distills brief.md into spec + acceptance (BDD) + coverage, hunting gaps in a grilling style. Use after writing a feature brief.
---

# Distill

Input: `specs/<feature>/brief.md`. Outputs: `spec.md`, `acceptance.md`, `coverage.md`.

## Procedure (loop until convergence)
1. **Seed from the constitution.** Read `memory/constitution/` (base + project). For each
   applicable `base/patterns/*.md`, inject its `[given]` criterion/criteria as rows in `coverage.md`.
2. **Extract.** From the brief: objectives, user stories, constraints, success metrics.
3. **Interrogate (grilling).** Ask the human about ambiguities one at a time. DO NOT proceed with
   open ambiguities. (Draw on the `grilling` skill if available.)
4. **Expand edge cases (80% problem).** Generate cases not covered by the brief; each one
   enters as a new row in `coverage.md` and forces a criterion.
5. **Trace.** Each objective → requirement → acceptance criterion (BDD). Mark deterministic
   vs non-deterministic.
6. **Check coverage.** If there are orphan rows (objective without criterion, or criterion without
   eval/UAT), return to step 3. Only when none remain (or they are `deferred` with justification),
   freeze `spec.md` + `acceptance.md`.
```

- [ ] **Step 4: Create `verify/SKILL.md` and `uat/SKILL.md`**

`.claude/skills/verify/SKILL.md`:

```markdown
---
name: verify
description: On-demand verification of a feature. Runs output + trajectory eval and emits the verification-report. Use when closing a feature implementation.
---

# Verify

## Procedure
1. Copy `verification/verification-report.md` to `verification/reports/<feature>-<ref>.md`.
2. **Output eval (BUILD):** run the deterministic tests linked in `coverage.md`.
   Task success = green/total. Threshold 100% (non-negotiable).
3. **Trajectory eval:** score against `evals/rubric.md` (tool use, steps skipped,
   hallucination). A flow that skipped verification is FAIL even if the build passes.
4. Update the statuses in `coverage.md` (🔴→🟢) and complete the Verdict.
5. If BUILD/TRAJECTORY fail → IMPLEMENTATION gap → go back to implement.
   DO NOT call UAT or closing non-deterministic evals from here.
```

`.claude/skills/uat/SKILL.md`:

```markdown
---
name: uat
description: Guided UAT of a feature against acceptance.md and the objective of the brief. Use after a green /verify.
---

# UAT

## Procedure
1. Walk through `verification/uat-checklist.md` criterion by criterion against `acceptance.md`.
2. Ask for each criterion: when met, does it move the success metric of the brief?
   If NOT → PRODUCT gap → route to `/distill` (the spec was incomplete).
3. Update `coverage.md` (→ ✅ uat) and the UAT + Verdict section of the report in
   `verification/reports/`.
4. The feature closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: skills (distill/verify/uat)"
```

---

### Task 7: secret-scan hook (TDD) + settings.json

**Files:**
- Create: `.claude/hooks/secret-scan.sh`
- Create: `.claude/settings.json`
- Create: `tests/check_60_secret_scan.sh`

**Interfaces:**
- Consumes: helpers from Task 1.
- Produces: `secret-scan.sh` has a pure, testable mode `--scan-text` (reads stdin; exit 1 if a secret pattern matches, else exit 0). Hook mode (no args) reads the tool-call JSON from stdin, no-ops unless it is a `git commit`, then scans `git diff --cached`; advisory by default (exit 0), blocks (exit 2) only if `SECRET_SCAN_BLOCK=1`.

- [ ] **Step 1: Write the failing behavior test**

Create `tests/check_60_secret_scan.sh`:

```bash
H=.claude/hooks/secret-scan.sh
assert_file "$H"
# --scan-text: secret present → exit 1
if printf 'AKIA1234567890ABCDEF\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "AWS key not detected"; else _pass "AWS key detected"; fi
if printf 'BEGIN RSA PRIVATE KEY\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "private key not detected"; else _pass "private key detected"; fi
if printf 'password = "hunter2"\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "password not detected"; else _pass "password detected"; fi
# --scan-text: clean text → exit 0
if printf 'hello world\n' | bash "$H" --scan-text >/dev/null 2>&1; then _pass "clean text passes"; else _fail "clean text wrongly flagged"; fi
# hook mode: non-commit command → silent exit 0
if printf '{"tool_input":{"command":"ls -la"}}' | bash "$H" >/dev/null 2>&1; then _pass "non-commit no-op"; else _fail "non-commit should exit 0"; fi
assert_file .claude/settings.json
assert_contains .claude/settings.json "secret-scan.sh"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL — file missing / not executable; exit non-zero.

- [ ] **Step 3: Implement `secret-scan.sh`**

```bash
#!/usr/bin/env bash
# Advisory secret scanner. Two modes:
#   --scan-text : read stdin, exit 1 if a secret pattern is found (pure, testable).
#   (no args)   : Claude Code PreToolUse hook. No-op unless the tool call is a git commit.
set -u

PATTERNS='(AKIA[0-9A-Z]{16})|(BEGIN [A-Z ]*PRIVATE KEY)|([Pp]assword[[:space:]]*=[[:space:]]*["'\''][^"'\'']+["'\''])|([Aa][Pp][Ii][_-]?[Kk][Ee][Yy][[:space:]]*[=:])'

scan_text(){ grep -qE "$PATTERNS"; }

if [ "${1:-}" = "--scan-text" ]; then
  if scan_text; then exit 1; else exit 0; fi
fi

# Hook mode: stdin is the tool-call JSON. Only act on git commit.
INPUT="$(cat)"
case "$INPUT" in
  *"git commit"*) : ;;
  *) exit 0 ;;                       # not a commit → silent, zero friction
esac

if git diff --cached 2>/dev/null | scan_text; then
  echo "secret-scan: possible secret in staged changes." >&2
  if [ "${SECRET_SCAN_BLOCK:-0}" = "1" ]; then exit 2; fi   # block only when opted-in
fi
exit 0                              # advisory by default
```

- [ ] **Step 4: Make it executable and create `settings.json`**

Run: `chmod +x .claude/hooks/secret-scan.sh`

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/secret-scan.sh" }
        ]
      }
    ]
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS including the 5 secret-scan behavior assertions; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: advisory secret-scan hook (TDD) + settings.json"
```

---

### Task 8: Docs, README, and advisory CI

**Files:**
- Create: `docs/factory-model.md`
- Create: `docs/workflow.md`
- Create: `README.md`
- Create: `.github/workflows/verify.yml`
- Create: `tests/check_70_docs_ci.sh`

**Interfaces:**
- Consumes: helpers from Task 1.
- Produces: nothing consumed by later tasks (final task). CI runs `bash tests/run.sh` as an advisory check.

- [ ] **Step 1: Write the failing test**

Create `tests/check_70_docs_ci.sh`:

```bash
assert_file docs/factory-model.md
assert_file docs/workflow.md
assert_file README.md
assert_contains README.md "constitution"
assert_contains README.md "coverage"
assert_file .github/workflows/verify.yml
assert_contains .github/workflows/verify.yml "tests/run.sh"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `docs/factory-model.md` and `docs/workflow.md`**

`docs/factory-model.md`:

```markdown
# The Factory Model

The developer's primary output is not code: it is the SYSTEM that produces code.
The dev defines specs and guardrails (constitution); the agent produces; verification validates.

- **Developer zone:** defines specs → designs guardrails (constitution) → reviews/approves.
- **Factory floor (agent):** planning → coding → tests & verification → verified output.
- **Cross-cutting guardrails:** the constitution (declarative) + workflow gates.

`Agent = Model + Harness`. This repo IS the harness: instructions, tools, skills,
guardrails, feedback loops, and observability around the model.
```

`docs/workflow.md`:

```markdown
# Workflow end-to-end

```
/constitution → (brief.md) → /distill → /plan → /contract → /tasks → implement → /verify → /uat
```

| Command | Input | Output | Verification |
|---|---|---|---|
| `/constitution` | — | `memory/constitution/` | seed + filter |
| (intake) | objective | `brief.md` | success metrics |
| `/distill` | `brief.md` | `spec` + `acceptance` + `coverage` | grilling loop, zero orphan rows |
| `/plan` | `spec` | `plan.md` | grounded in constitution |
| `/contract` | `acceptance` | tests 🔴 + eval cases 📋 | proves it is RED |
| `/tasks` | `coverage` | `tasks.md` | GATE: rejects if RED contract is missing |
| implement | `tasks` | code | inner loop 🔴→🟢 (budget → ESCALATE) |
| `/verify` | code | `verification/reports/…` | output + trajectory eval |
| `/uat` | report | complete report | against objective; gap → `/distill` |

## Three loops
1. **Grilling** (in `/distill`): closes specification gaps before coding.
2. **Inner loop** (implementation, per task): auto-corrects 🔴→🟢; escalates to human after
   2 identical failures or 3 attempts (tuneable in the constitution).
3. **Feedback** (`/verify`+`/uat`): verify failure → implementation; UAT failure → product → `/distill`.

## Closure
`feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%`.
```

- [ ] **Step 4: Create `README.md` and the CI workflow**

`README.md`:

```markdown
# Agentic SDLC Harness

Stack-agnostic template (Claude Code first) for disciplined agentic development, with
verification/UAT as the north star. Based on Google's whitepaper *"The New SDLC With Vibe
Coding"* and the *constitution* concept from Spec Kit.

## The loop at a glance
`/constitution → brief → /distill → /plan → /contract → /tasks → implement → /verify → /uat`

## Structure
- `CLAUDE.md` — static context (stack, hard rules, workflow).
- `memory/constitution/` — non-negotiable principles (inheritable base + project).
- `specs/_template/` — feature template (brief/spec/acceptance/coverage/plan/tasks).
- `evals/` — 5-dimension rubric + non-deterministic cases.
- `verification/` — report, UAT and code-review checklists + `reports/` (observability).
- `.claude/` — skills (distill/verify/uat), 7 commands, advisory hook, settings.
- `docs/` — factory-model and workflow.

## Start a feature
1. `cp -r specs/_template specs/001-my-feature` and write the `brief.md`.
2. `/distill` → `/plan` → `/contract` → `/tasks` → implement → `/verify` → `/uat`.
3. `coverage.md` is your source of truth for status.

## Verify the harness
`bash tests/run.sh` — the template self-verifies (structure + hook). Also runs in CI.

## Principles
Productivity first (on-demand verification, no blocking commit hooks),
intent > syntax, the constitution is code, everything verifiable leaves a trace.
```

`.github/workflows/verify.yml`:

```yaml
name: verify
on: [pull_request]

# Advisory by default: this check can fail (red X) without blocking the merge.
# To make it blocking, mark it as "required" in Branch protection (governance decision).
jobs:
  self-verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Harness self-verification
        run: bash tests/run.sh
      # Placeholder (agent-driven /verify in CI): post verification-report as a comment
      # on the PR is at the project's discretion — depends on the stack and eval runner.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS across every `check_*.sh`; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: docs (factory-model/workflow), README, advisory CI"
```

---

## Self-Review

**1. Spec coverage** (design §→ task):
- §2 principles + mapping → Task 2 (`CLAUDE.md`, principles), Task 8 (docs).
- §3 directory structure → Tasks 1-8 (every dir/file created and asserted).
- §4 inheritable constitution (base + patterns `[given]`) → Task 2.
- §5 originating layer (brief→spec→acceptance) + coverage + grilling → Tasks 3, 6 (distill).
- §6 workflow 7 commands + 3 loops → Task 5 (commands), Task 8 (workflow.md).
- §7 inner loop + cut condition → Task 2 (budget in constitution), Task 8 (workflow.md), Task 6 (verify/uat no-close-from-inner).
- §8 test-first gate (contract RED, /tasks gate) → Task 5 (contract.md, tasks.md).
- §9 verification (rubric 5 dim, report, AND-strict) → Task 4.
- §10 guardrails/hooks/CI (secret-scan advisory, CI advisory) → Task 7, Task 8.
- §11 out of scope → respected (no app code, no submodule, no production runner).
- §12 risks → mitigations present (budget/ESCALATE, trajectory weight, vendored, gate per phase).

No gaps.

**2. Placeholder scan:** The `<feature>`, `<ref>`, `_(fill in)_` values inside the files are intentional TEMPLATE content (the template must have fields to fill in), not plan placeholders. Each Step in the plan contains the real content/code. No `TBD`/`TODO`/`implement later` in plan instructions.

**3. Type/consistency check:**
- Helpers `assert_file`/`assert_dir`/`assert_contains`/`summary` defined in Task 1 and used with the same signature in all `check_*.sh` files.
- `secret-scan.sh --scan-text` (Task 7) matches between test and implementation.
- Coverage state tokens (`🔴`/`🟢`/`✅`/`📋`/`[given]`) consistent across §Global Constraints, Task 3 (coverage.md), Task 5 (commands), Task 6 (skills).
- Skill names (`distill`/`verify`/`uat`) consistent between Task 5 (commands that invoke them) and Task 6 (SKILL.md).
- Report sections (`Coverage snapshot`/`Output eval`/`Trajectory eval`/`UAT`/`Verdict`) consistent between Task 4 (template) and its test.
