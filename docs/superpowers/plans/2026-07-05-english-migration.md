# English Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate all Spanish-language repo artifacts to English across five commits on branch `005-english-migration`.

**Architecture:** Five sequential commits, each self-contained and verified with `bash tests/run.sh`. Commit 1 lands first because the amendment-gate CI requires its ADR to exist before the North Star pillar IDs change. Commit 5 lands last because the D2 language rule governs future writing, not the migration itself.

**Tech Stack:** Markdown, bash, YAML (GitHub Actions). No build tools — the repo is dependency-free.

## Global Constraints

- Never translate file paths, directory names, or command names (`/align`, `/distill`, etc.)
- Never translate YAML frontmatter **keys** (`extends`, `name`, `description` as a key) — translate their **values**
- Never translate code blocks, shell commands, or inline code (backtick-fenced content)
- Never translate BDD keywords (`Given`, `When`, `Then`) — they are already English
- Never translate JSON **keys** — translate JSON **string values** (mission, statement, signal, scope items, etc.)
- Pillar ID rename: `enforcement-real` → `real-enforcement`, `portabilidad-agnostica` → `agnostic-portability`, `adopcion-sin-friccion` → `frictionless-adoption`, `impacto-medible` → `measurable-impact` — apply everywhere the old IDs appear
- All accented characters (á é í ó ú ñ ü ¿ ¡) should be gone from `.md` files after the migration (use this as your spot-check signal)

---

### Task 1: ADR 0003 + North Star pillar ID rename

**Files:**
- Create: `memory/north-star/decisions/0003-english-migration.md`
- Modify: `memory/north-star/north-star.md`

**Interfaces:**
- Produces: new ADR file + updated pillar IDs in the canonical JSON — required by the amendment-gate CI check before this PR can pass

- [ ] **Step 1: Create the branch**

```bash
git checkout -b 005-english-migration
```

- [ ] **Step 2: Write ADR 0003**

Create `memory/north-star/decisions/0003-english-migration.md` with this exact content:

```markdown
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
```

- [ ] **Step 3: Translate and update `memory/north-star/north-star.md`**

The file has two parts: human-readable prose (above the JSON block) and the canonical JSON block. Translate both. The translated file must satisfy:
- `extends: base` frontmatter unchanged
- All pillar IDs updated to the four new English IDs (see Global Constraints)
- All prose translated to English
- The JSON block remains syntactically valid

Key translated strings for the JSON block (translate the prose sections to match):

```json
{
  "mission": "A reusable, stack-agnostic harness that enforces a disciplined agentic SDLC (spec-driven, test-first, evidence-verified) on any project — governs how software is built, without imposing a stack or execution runtime, and without writing product code.",
  "pillars": [
    {
      "id": "real-enforcement",
      "statement": "Discipline is enforced by deterministic gates, not good intentions.",
      "signal": "Gates block closure when a condition is missing; violations are caught before merge (and the harness proves this by dogfooding itself: retro ledger / wow-report)."
    },
    {
      "id": "agnostic-portability",
      "statement": "Runs on any stack or project without imposing technology or runtime.",
      "signal": "The contract (schema, gates, artifacts) remains intact when vendored onto an arbitrary repo/stack."
    },
    {
      "id": "frictionless-adoption",
      "statement": "Incorporating the harness into a new repo costs little.",
      "signal": "Steps/time to adopt the harness in a project (lower = better)."
    },
    {
      "id": "measurable-impact",
      "statement": "The discipline the harness imposes must translate into better software: less rework and gaps caught before production, not gates that fire for the sake of firing.",
      "signal": "Gaps caught early (grilling/contract) and late rework avoided (post-verify/uat), aggregated per feature in the Method section of the wow-report; high = discipline prevents, not just bureaucratizes."
    }
  ],
  "scope": {
    "in_scope": [
      "commands, gates, and skills of the governance workflow",
      "product governance: constitution and North Star",
      "feature templates, coverage, and criterion state machine",
      "evals, verification, and UAT of the method",
      "adoption tooling: install, vendoring, and harness inheritance",
      "WoW self-validation (retro, wow-report) and method documentation"
    ],
    "out_of_scope": [
      "application code or product features of an adopting project",
      "stack-specific deterministic engine (provided by the adopter)",
      "imposing or naming a mandatory execution runtime",
      "blocking commit hooks",
      "runtime dependencies or frameworks"
    ]
  },
  "alignment": {
    "threshold": 3,
    "rubric": "memory/north-star/base/alignment-rubric.md"
  }
}
```

- [ ] **Step 4: Run the test suite**

```bash
bash tests/run.sh
```

Expected: `TOTAL PASS=N FAIL=0` — all checks green. The amendment-gate test (`check_95`) passes because the gate script is exercised against fixtures only (not the real git range); the real CI gate runs on the PR.

- [ ] **Step 5: Commit**

```bash
git add memory/north-star/decisions/0003-english-migration.md memory/north-star/north-star.md
git commit -m "chore(north-star): ADR 0003 + migrate pillar IDs to English"
```

---

### Task 2: Migrate governance layer

**Files — translate ALL prose, keep all code/paths/keys untouched:**
- Modify: `README.md`
- Modify: `CLAUDE.md`
- Modify: `docs/workflow.md`
- Modify: `docs/factory-model.md`
- Modify: `docs/superpowers/specs/2026-07-02-agentic-sdlc-harness-design.md`
- Modify: `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`
- Modify: `docs/superpowers/specs/2026-07-05-north-star-seed-design.md`
- Modify: `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`
- Modify: `docs/superpowers/plans/2026-07-02-agentic-sdlc-harness.md`
- Modify: `docs/superpowers/plans/2026-07-05-wow-self-validation.md`
- Modify: `memory/constitution/constitution.md` — translate prose; D2 rule is added later in Task 5
- Modify: `memory/constitution/base/principles.md`
- Modify: `memory/constitution/base/README.md`
- Modify: `memory/constitution/base/patterns/audit-logging.md`
- Modify: `memory/constitution/base/patterns/idempotency.md`
- Modify: `memory/constitution/base/patterns/rate-limiting.md`
- Modify: `memory/constitution/update-checklist.md`
- Modify: `memory/north-star/base/README.md`
- Modify: `memory/north-star/base/schema.md`
- Modify: `memory/north-star/base/alignment-rubric.md`
- Modify: `memory/north-star/base/amendment-protocol.md`
- Modify: `memory/north-star/base/adr-template.md`
- Modify: `memory/north-star/decisions/0001-seed-north-star.md`
- Modify: `memory/north-star/decisions/0002-add-impacto-medible-pillar.md`
- Modify: `evals/README.md`
- Modify: `evals/rubric.md`
- Modify: `evals/cases/north-star-judge.md`
- Modify: `verification/code-review-checklist.md`
- Modify: `verification/uat-checklist.md`
- Modify: `verification/verification-report.md`
- Modify: `verification/wow-report.md`
- Modify: `.github/workflows/amendment-gate.yml` — translate comments only; leave all `run:`, `uses:`, `with:`, `name:` values and shell code unchanged
- Modify: `.github/workflows/verify.yml` — same rule as above
- Modify: `scripts/amendment-gate.sh` — translate comments only; leave all shell code unchanged
- Modify: `scripts/setup-branch-protection.sh` — translate comments only
- Modify: `tests/check_95_amendment_gate.sh` — translate comments AND fix the broken assertion (see step below)
- Modify: `tests/check_80_north_star.sh` — translate comments only
- Modify: `tests/check_00_skeleton.sh` through `tests/check_70_docs_ci.sh` — translate comments only
- Modify: `tests/check_90_retro.sh` — translate comments only
- Modify: `tests/run.sh` — translate comments only
- Modify: `tests/fixtures/amendment-gate/base.md` — translate the comment and prose; leave the JSON block unchanged
- Modify: remaining fixture files in `tests/fixtures/amendment-gate/` — translate prose/comments only

**Interfaces:**
- Consumes: none
- Produces: fully English governance docs; fixed `check_95` assertion

- [ ] **Step 1: Fix the broken test assertion in `tests/check_95_amendment_gate.sh`**

This file currently asserts `[Pp]rincipio 4` against the constitution. After translation the constitution will say "Principle 4". Update this line:

Old:
```bash
assert_contains memory/constitution/constitution.md "[Pp]rincipio 4"
```

New:
```bash
assert_contains memory/constitution/constitution.md "[Pp]rinciple 4"
```

Also in `memory/north-star/decisions/0001` and `0002`, the old pillar IDs appear in prose. When translating, render the old IDs as their new English equivalents (e.g., "the `real-enforcement` pillar" instead of "`enforcement-real`").

- [ ] **Step 2: Translate all files listed above**

Work through the file list. For each file:
- Translate all prose to English
- Preserve all file paths, command names, code blocks, YAML keys, JSON keys
- In `memory/north-star/decisions/0001` and `0002`: render any mention of old pillar IDs using the new English IDs (`real-enforcement`, `agnostic-portability`, `frictionless-adoption`, `measurable-impact`)

- [ ] **Step 3: Spot-check for remaining Spanish**

```bash
grep -rn -P '[áéíóúñüÁÉÍÓÚÑÜ¿¡]' --include="*.md" --include="*.sh" --include="*.yml" . \
  | grep -v "^\.git/"
```

Expected: no output. Any hit is a file that still has accented characters — translate it.

- [ ] **Step 4: Run the test suite**

```bash
bash tests/run.sh
```

Expected: `TOTAL PASS=N FAIL=0`

- [ ] **Step 5: Commit**

```bash
git add README.md CLAUDE.md docs/ memory/constitution/constitution.md memory/constitution/base/ \
  memory/constitution/update-checklist.md memory/north-star/base/ \
  memory/north-star/decisions/0001-seed-north-star.md \
  memory/north-star/decisions/0002-add-impacto-medible-pillar.md \
  evals/ verification/code-review-checklist.md verification/uat-checklist.md \
  verification/verification-report.md verification/wow-report.md \
  .github/workflows/ scripts/ tests/
git commit -m "chore(governance): migrate docs and memory to English"
```

---

### Task 3: Migrate tooling — skills, commands, templates

**Files:**
- Modify: `.claude/skills/align/SKILL.md`
- Modify: `.claude/skills/distill/SKILL.md`
- Modify: `.claude/skills/retro/SKILL.md`
- Modify: `.claude/skills/uat/SKILL.md`
- Modify: `.claude/skills/verify/SKILL.md`
- Modify: `.claude/skills/wow-report/SKILL.md`
- Modify: `.claude/commands/align.md`
- Modify: `.claude/commands/constitution.md`
- Modify: `.claude/commands/contract.md`
- Modify: `.claude/commands/distill.md`
- Modify: `.claude/commands/plan.md`
- Modify: `.claude/commands/retro.md`
- Modify: `.claude/commands/tasks.md`
- Modify: `.claude/commands/uat.md`
- Modify: `.claude/commands/verify.md`
- Modify: `.claude/commands/wow-report.md`
- Modify: `specs/_template/brief.md`
- Modify: `specs/_template/acceptance.md`
- Modify: `specs/_template/coverage.md`
- Modify: `specs/_template/plan.md`
- Modify: `specs/_template/retro.md`
- Modify: `specs/_template/spec.md`
- Modify: `specs/_template/tasks.md`

**Interfaces:**
- Consumes: none
- Produces: English-language skills, commands, and spec templates — the primary interface adopters interact with

- [ ] **Step 1: Translate all files listed above**

For skill files (`SKILL.md`): translate all prose including the YAML frontmatter `name` value and `description` value. Preserve all file paths referenced within (e.g., `specs/<feature>/brief.md`, `memory/north-star/north-star.md`). Preserve all command names (`/align`, `/distill`, etc.).

For command files (`.claude/commands/*.md`): translate the frontmatter `description` value and all body prose. These are short files — typically one-liners pointing to the skill.

For template files (`specs/_template/*.md`): translate all prose guidance and placeholder comments. Template placeholders like `<feature>` and `<nombre>` become `<feature>` and `<name>`. Section headings translate to English (e.g., "Objetivo de producto" → "Product objective", "Por qué / motivación" → "Why / motivation", "Métricas de éxito" → "Success metrics").

Key translations for `check_80_north_star.sh` assertions — these strings must remain present in their respective files after translation (they are already English and must not be changed):
- `.claude/skills/distill/SKILL.md` must still contain `"Measurability Gate"` and `"aligned"`

- [ ] **Step 2: Spot-check**

```bash
grep -rn -P '[áéíóúñüÁÉÍÓÚÑÜ¿¡]' --include="*.md" .claude/ specs/_template/
```

Expected: no output.

- [ ] **Step 3: Run the test suite**

```bash
bash tests/run.sh
```

Expected: `TOTAL PASS=N FAIL=0`. The `check_80_north_star.sh` assertions for `"Measurability Gate"` and `"aligned"` in `distill/SKILL.md` must still pass — verify those strings are present after translating.

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/ .claude/commands/ specs/_template/
git commit -m "chore(tooling): migrate skills, commands, and templates to English"
```

---

### Task 4: Migrate completed specs and verification reports

**Files:**
- Modify: `specs/001-example/acceptance.md`
- Modify: `specs/001-example/brief.md`
- Modify: `specs/001-example/coverage.md`
- Modify: `specs/001-example/plan.md`
- Modify: `specs/001-example/spec.md`
- Modify: `specs/001-example/tasks.md`
- Modify: `specs/002-north-star-governance/acceptance.md`
- Modify: `specs/002-north-star-governance/brief.md`
- Modify: `specs/002-north-star-governance/coverage.md`
- Modify: `specs/002-north-star-governance/plan.md`
- Modify: `specs/002-north-star-governance/spec.md`
- Modify: `specs/002-north-star-governance/tasks.md`
- Modify: `specs/003-wow-self-validation/brief.md`
- Modify: `specs/003-wow-self-validation/retro.md`
- Modify: `specs/004-ci-amendment-gate/acceptance.md`
- Modify: `specs/004-ci-amendment-gate/alignment.md` — **also update old pillar ID references**
- Modify: `specs/004-ci-amendment-gate/brief.md`
- Modify: `specs/004-ci-amendment-gate/coverage.md`
- Modify: `specs/004-ci-amendment-gate/plan.md`
- Modify: `specs/004-ci-amendment-gate/retro.md`
- Modify: `specs/004-ci-amendment-gate/spec.md`
- Modify: `specs/004-ci-amendment-gate/tasks.md`
- Modify: `verification/reports/002-north-star-judge.md`
- Modify: `verification/reports/003-wow-self-validation-report.md`
- Modify: `verification/reports/004-ci-amendment-gate.md`

**Interfaces:**
- Consumes: new pillar IDs from Task 1 (needed for `alignment.md` update)
- Produces: fully English historical record

- [ ] **Step 1: Update pillar ID references in `specs/004-ci-amendment-gate/alignment.md`**

This file references old IDs in its mapping table and prose. Replace:
- `enforcement-real` → `real-enforcement`
- `portabilidad-agnostica` → `agnostic-portability`
- `adopcion-sin-friccion` → `frictionless-adoption`
- `impacto-medible` → `measurable-impact`

Then translate the full file prose to English.

- [ ] **Step 2: Translate all remaining files listed above**

Translate prose to English. Preserve file paths, command names, code blocks, BDD keywords, JSON keys, and the `Pillar` column header in `coverage.md` files (already English per the template).

For files in `specs/002-north-star-governance/` and `specs/004-ci-amendment-gate/`: any mention of old pillar IDs in prose gets the new English ID.

- [ ] **Step 3: Spot-check**

```bash
grep -rn -P '[áéíóúñüÁÉÍÓÚÑÜ¿¡]' --include="*.md" specs/ verification/reports/
```

Expected: no output.

- [ ] **Step 4: Run the test suite**

```bash
bash tests/run.sh
```

Expected: `TOTAL PASS=N FAIL=0`

- [ ] **Step 5: Commit**

```bash
git add specs/001-example/ specs/002-north-star-governance/ \
  specs/003-wow-self-validation/ specs/004-ci-amendment-gate/ \
  verification/reports/
git commit -m "chore(specs): migrate completed specs and reports to English"
```

---

### Task 5: Add constitution D2 language rule

**Files:**
- Modify: `memory/constitution/constitution.md`

**Interfaces:**
- Consumes: none
- Produces: D2 delta codifying English-only repo artifacts as a non-negotiable

- [ ] **Step 1: Add D2 to the constitution**

Open `memory/constitution/constitution.md`. After the existing D1 delta block and before `## Overrides de patterns heredados` (now translated to `## Overrides of inherited patterns`), add:

```markdown
### D2 — Language

All repo artifacts are written in English: docs, specs, skills, commands, memory,
scripts, and CI configs. The developer may interact with the agent in any language;
the agent writes to the repo in English regardless.
```

- [ ] **Step 2: Run the test suite**

```bash
bash tests/run.sh
```

Expected: `TOTAL PASS=N FAIL=0`. Confirm `check_95` still passes — it checks that `amendment-gate`, `[Pp]rinciple 4`, and `pillars/scope` are present in the constitution.

- [ ] **Step 3: Final full spot-check across the entire repo**

```bash
grep -rn -P '[áéíóúñüÁÉÍÓÚÑÜ¿¡]' --include="*.md" --include="*.sh" --include="*.yml" . \
  | grep -v "^\.git/"
```

Expected: no output. The entire repo is now in English.

- [ ] **Step 4: Commit**

```bash
git add memory/constitution/constitution.md
git commit -m "chore(constitution): add D2 language rule"
```

---

## After all tasks: open PR

```bash
gh pr create \
  --title "chore: migrate repo to English (005)" \
  --body "Migrates all repo artifacts from Spanish to English across 5 commits.

- ADR 0003: pillar ID rename (real-enforcement, agnostic-portability, frictionless-adoption, measurable-impact)
- Governance layer: README, CLAUDE.md, docs, memory, evals, verification, CI, scripts, tests
- Tooling: skills, commands, spec templates
- Completed specs 001–004 and verification reports
- Constitution D2 language rule

All tests pass. Amendment-gate will validate the North Star change on this PR."
```
