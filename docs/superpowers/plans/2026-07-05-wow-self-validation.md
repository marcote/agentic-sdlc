# WoW Self-Validation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give the harness the ability to self-validate its own Way of Working: a retro that closes the measurable prediction of `/align` (align↔retro column), deterministic enforcement in CI, and an aggregated rollup — all dogfooded by building it with the harness's own test-first discipline.

**Architecture:** One `retro.md` artifact per feature (two faces: Mission closes `alignment.md`, Method derives WoW signals from artifacts). The DONE contract is extended with `∧ retro ✅`. `tests/check_90_retro.sh` enforces it in CI (detects "closed" by DONE verdict in `verification/reports/`, uniform rule without hardcoding). `/retro` (skill+command) produces the retro with anti-theater order `derive→self-challenge→write`; `/wow-report` (skill+command) aggregates the ledger in `verification/wow-report.md`.

**Tech Stack:** Markdown (skills/commands/templates/docs) + POSIX Bash (checks, `tests/lib.sh` style, dependency-free, no frameworks). The "test" for each change is an assertion in `tests/check_*.sh` run via `tests/run.sh` — this IS the harness's RED→GREEN discipline applied to itself.

## Global Constraints

- **Dependency-free:** checks use only `tests/lib.sh` (`assert_file`, `assert_dir`, `assert_contains` with `grep -qE`) + Bash/coreutils. No frameworks, nothing to install.
- **On-demand verification, no blocking commit hooks:** the enforcement is CI (`.github/workflows/verify.yml` runs `tests/run.sh`). Do not add git hooks.
- **One feature = one folder `specs/<NNN-feature>/`** (kebab-case, NNN zero-padded).
- **Template repo:** `north-star.md` is a placeholder → `/align` is fail-closed and **does not run here**. Face A (Mission) of the `003` retro closes as `n/a` + reason; Face B (Method) is real. See the design doc, section "Constraint: template-repo vs adopter-repo".
- **Language:** all new content in English, consistent with the existing harness.
- **Each task runs `bash tests/run.sh` and ends in green before committing.**
- Reference design doc: `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

---

## Phase 1 — Foundation: retro template + DONE contract

### Task 1: Template `specs/_template/retro.md` (RED via check_20)

**Files:**
- Modify: `tests/check_20_spec_templates.sh:1`
- Create: `specs/_template/retro.md`

**Interfaces:**
- Produces: the `specs/_template/retro.md` file with headers `Face A` / `Face B` / `Face C`, the `Evidence` column, and the `deriv` marker — which Tasks 3 and 5 assume are present.

- [ ] **Step 1: Write the failing assertion** — add `retro` to the templates loop in `tests/check_20_spec_templates.sh`. Change line 1:

```bash
for f in brief spec acceptance coverage plan tasks retro; do
```

- [ ] **Step 2: Run the suite to see it fail**

Run: `bash tests/run.sh 2>&1 | grep -E "check_20|retro"`
Expected: FAIL with `missing file specs/_template/retro.md`

- [ ] **Step 3: Create `specs/_template/retro.md`** with this exact content:

```markdown
# Retro — <feature> @ <commit>

closes: `specs/<feature>/alignment.md` · `verification/reports/<feature>` · date: <YYYY-MM-DD>

> Closes the measurable prediction that opened `/align` (the align↔retro column). A feature is not
> DONE until this retro closes all three faces. Design:
> `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

## Face A — Mission (closes the /align prediction)
Source: `specs/<feature>/alignment.md` (objective→pillar mapping) + `north-star.md` (signal per pillar).

| Pillar (mapping) | Predicted signal | Verdict | Evidence (MANDATORY locator) |
|---|---|---|---|
| <pillar-id> | <North Star signal> | ✅ moved / ❌ did not move / ⏳ not yet observable | <value/SHA/coverage-row/URL — no prose> |

- **Align calibration:** <did the pillarFit/scope/mission scores from alignment.md hold up in retrospect?>
- **Mission verdict:** <confirmed | refuted | pending-observation | n/a>
  - if `confirmed`/`refuted` → the Evidence cell(s) above CANNOT be empty.
  - if `pending-observation` → **re-check trigger:** <when / what signal to look at>
  - if `n/a` → **reason:** <why this feature does not close against any signal>

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted
Each field carries its `[deriv: …]` marker — the locator showing where the figure came from. Without locator = invalid.

- **Gaps caught by /distill:** <N> `[deriv: <coverage.md / git log from distill>]` — <the notable ones>
- **RED→GREEN discipline:** <yes / no + exceptions> `[deriv: <coverage.md state history + git>]`
- **Post-/verify rework:** <N> · **post-/uat:** <N> `[deriv: <gaps routed in verification/reports/<feature>>]`
- **Human escalations:** <N> `[deriv: <trace / git>]` — <why>
- **Friction from the WoW itself:** <what got in the way or was missing> (the only free-judgment field)

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** <rule or "none"> (apply via `memory/constitution/update-checklist.md`)
- **Candidate amendments → North Star:** <proposed ADR or "none"> (via `memory/north-star/base/amendment-protocol.md`)
```

- [ ] **Step 4: Run the suite to see it pass**

Run: `bash tests/run.sh 2>&1 | tail -3`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 5: Commit**

```bash
git add tests/check_20_spec_templates.sh specs/_template/retro.md
git commit -m "feat(003): retro.md template (3 faces) + check_20"
```

---

### Task 2: Extend the DONE contract with `∧ retro ✅`

**Files:**
- Modify: `CLAUDE.md` (closing hard rule)
- Modify: `docs/workflow.md` (flow, table, closing line)
- Modify: `verification/verification-report.md` (§5 verdict)

**Interfaces:**
- Produces: the three docs mention `retro` in the closing context — which Task 3 (`check_90`) verifies with `assert_contains`.

- [ ] **Step 1: Edit `CLAUDE.md`** — in the "Hard rules" section, replace the closing line:

From:
```
- A feature is done only when: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
```
To:
```
- A feature is done only when: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅ (`/retro` closes the `/align` prediction).
```

- [ ] **Step 2: Edit `docs/workflow.md`** — three changes.

(a) Line 4, the flow, add `/retro` at the end:
```
/constitution → (brief.md) → /align → /distill → /plan → /contract → /tasks → implement → /verify → /uat → /retro
```

(b) In the commands table, add two rows after the `/uat` row:
```
| `/retro` | `alignment.md` + `verification/reports/…` | `retro.md` | closes the `/align` prediction (Face Mission) + derives WoW signals (Face Method) |
| `/wow-report` | all `retro.md` | `verification/wow-report.md` | aggregates the ledger: drift per pillar, re-checks, method health, theater smells (observes, never gates) |
```

(c) Closing line (§ Closing), replace:
```
`feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅`.
```

- [ ] **Step 3: Edit `verification/verification-report.md`** — in the `## 5. Verdict` section, replace the two verdict lines:

From:
```
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%>
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
```
To:
```
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%> · retro: <✅/pending>
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/<feature>/retro.md` (closes the measurable `/align` prediction).
```

- [ ] **Step 4: Run the suite (must not break check_30, which verifies the report sections)**

Run: `bash tests/run.sh 2>&1 | tail -3`
Expected: `TOTAL PASS=… FAIL=0` (check_30 stays green: the "Verdict"/"UAT"/etc. sections remain present)

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md docs/workflow.md verification/verification-report.md
git commit -m "feat(003): extend DONE contract with retro ✅ (CLAUDE.md, workflow, report)"
```

---

## Phase 2 — Deterministic Enforcement: `check_90`

### Task 3: `tests/check_90_retro.sh` — presence, wiring, and per-feature closure

**Files:**
- Create: `tests/check_90_retro.sh`

**Interfaces:**
- Consumes: `specs/_template/retro.md` (Task 1), the DONE contract wiring in docs (Task 2), `tests/lib.sh` (`_pass`/`_fail`/`assert_*`).
- Produces: the `retro ✅` gate. Detects "closed" by report with DONE verdict; uniform rule without hardcoded exceptions.

- [ ] **Step 1: Create the check.** `tests/run.sh` sources it automatically (glob `check_*.sh`). Exact content of `tests/check_90_retro.sh`:

```bash
# Sourced by tests/run.sh (lib.sh already loaded). Enforces the retro gate: the
# back half of the Measurability Gate. Template + wiring of the DONE contract +
# per-feature close. "Closed" = its verification/reports/<NNN>-*.md shows the
# DONE verdict (BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%). Feature
# closed ⟹ specs/<NNN>-*/retro.md complete. No hardcode: a feature without a
# DONE report is "in-flight" and is skipped (uniform rule).

# --- Template: 3-face structure (Layer 1+2) ---
assert_file specs/_template/retro.md
for h in "Face A" "Face B" "Face C" "Evidence" "deriv"; do
  assert_contains specs/_template/retro.md "$h"
done

# --- DONE contract wiring ---
assert_contains CLAUDE.md "retro ✅"
assert_contains docs/workflow.md "retro ✅"
assert_contains verification/verification-report.md "retro ✅"

# --- Per-feature close (uniform rule) ---
# "Closed" = the report has BUILD ✅ and UAT ✅ and coverage 100% (three independent
# greps: robust to line layout and avoids fragile ||/&& precedence).
closed_seen=0
for report in verification/reports/*.md; do
  [ -f "$report" ] || continue
  grep -qE "BUILD:[[:space:]]*✅"   "$report" || continue
  grep -qE "UAT:[[:space:]]*✅"     "$report" || continue
  grep -qE "coverage:[[:space:]]*100%" "$report" || continue
  closed_seen=1
  nnn=$(basename "$report" | grep -oE '^[0-9]+')
  featdir=$(ls -d specs/${nnn}-*/ 2>/dev/null | head -1)
  if [ -z "$featdir" ]; then _fail "report $report DONE but no specs/${nnn}-*"; continue; fi
  retro="${featdir}retro.md"
  if [ ! -f "$retro" ]; then _fail "feature $nnn DONE but $retro is missing"; continue; fi
  _pass "feature $nnn DONE has $retro"
  # No unfilled placeholders
  if grep -qE '_\(…\)_|<[^ >][^>]*>' "$retro"; then _fail "$retro has unfilled placeholders"; else _pass "$retro no placeholders"; fi
  # Valid mission verdict
  if grep -qE 'Mission verdict:[*[:space:]]*(confirmed|refuted|pending-observation|n/a)' "$retro"; then
    _pass "$retro valid mission verdict"
  else
    _fail "$retro missing valid mission verdict"
  fi
  # n/a requires a reason (Layer: anti-escape)
  if grep -qE 'Mission verdict:[*[:space:]]*n/a' "$retro"; then
    if grep -qiE 'reason' "$retro"; then _pass "$retro n/a with reason"; else _fail "$retro n/a without reason"; fi
  fi
  # Each Face B field with [deriv:] (Layer 1)
  if [ "$(grep -cE '\[deriv:' "$retro")" -ge 4 ]; then _pass "$retro Face B with deriv (≥4)"; else _fail "$retro Face B with <4 [deriv:] (derivable fields without locator)"; fi
done
[ "$closed_seen" -eq 1 ] && _pass "close loop exercised" || _pass "no closed features yet (vacuous)"
```

- [ ] **Step 2: Run the suite and verify green on the current repo**

Run: `bash tests/run.sh 2>&1 | grep -E "check_90|retro|FAIL" ; echo "---"; bash tests/run.sh 2>&1 | tail -2`
Expected: template + wiring assertions PASS; `no closed features yet (vacuous)` PASS (the only report, `002-north-star-judge.md`, has no DONE verdict); `FAIL=0`.

- [ ] **Step 3: Test the closure logic with a temporary fixture (forced RED).** Create a fake DONE report WITHOUT retro and confirm the check fails:

```bash
mkdir -p specs/900-fixture
printf 'BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: pending\n' > verification/reports/900-fixture-report.md
bash tests/run.sh 2>&1 | grep -E "900|FAIL"
```
Expected: `FAIL: feature 900 DONE but specs/900-fixture/retro.md is missing`

- [ ] **Step 4: Add the retro to the fixture and confirm GREEN** (verifies the gate passes when the retro exists and is complete):

```bash
cat > specs/900-fixture/retro.md <<'EOF'
## Face A
- Mission verdict: n/a
  - reason: test fixture
## Face B
- Gaps: 0 [deriv: n/a]
EOF
bash tests/run.sh 2>&1 | grep -E "900"
```
Expected: `PASS: feature 900 DONE has …`, `PASS: … n/a with reason`, `PASS: … Face B with deriv`.

- [ ] **Step 5: Clean up the fixture and confirm final green**

```bash
rm -rf specs/900-fixture verification/reports/900-fixture-report.md
bash tests/run.sh 2>&1 | tail -2
```
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 6: Commit**

```bash
git add tests/check_90_retro.sh
git commit -m "feat(003): check_90_retro — deterministic retro gate (uniform close, no hardcode)"
```

---

## Phase 3 — Skills and Commands

### Task 4: Skill + command `/retro`

**Files:**
- Create: `.claude/commands/retro.md`
- Create: `.claude/skills/retro/SKILL.md`
- Modify: `tests/check_40_commands.sh:1`
- Modify: `tests/check_50_skills.sh:1`

**Interfaces:**
- Consumes: `specs/_template/retro.md` (output format), `alignment.md` + `coverage.md` + `verification/reports/<feature>` (inputs).
- Produces: the `/retro` command and the `retro` skill that Task 6 (dogfood) invokes on `003`.

- [ ] **Step 1: Write the failing assertions.** In `tests/check_40_commands.sh` line 1, add `retro` to the loop:

```bash
for c in constitution distill plan contract tasks verify uat retro; do
```

In `tests/check_50_skills.sh` line 1, add `retro` to the loop and two content assertions at the end of the file:

```bash
for s in distill verify uat retro; do
```
And add after the existing lines:
```bash
assert_contains .claude/skills/retro/SKILL.md "adversarial"
assert_contains .claude/skills/retro/SKILL.md "deriv"
```

- [ ] **Step 2: Run the suite to see it fail**

Run: `bash tests/run.sh 2>&1 | grep -E "retro|FAIL"`
Expected: FAIL with `missing file .claude/commands/retro.md` and `.claude/skills/retro/SKILL.md`

- [ ] **Step 3: Create `.claude/commands/retro.md`:**

```markdown
---
description: Closes the measurable /align prediction when closing a feature. Writes specs/<feature>/retro.md (Face Mission + Face Method). Required for the DONE verdict.
---

Invoke the `retro` skill. Requires the feature closed in `verification/reports/<feature>`
(BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%) and `specs/<feature>/alignment.md`.
Writes `specs/<feature>/retro.md`. Without a complete retro the feature is not DONE.
```

- [ ] **Step 4: Create `.claude/skills/retro/SKILL.md`:**

```markdown
---
name: retro
description: Closes the /align prediction when closing a feature — issues the verdict on the pillar signal and derives WoW signals from artifacts. Writes specs/<feature>/retro.md. Use after a green /verify+/uat, as the final step of closing.
---

# Retro

Input: `specs/<feature>/alignment.md` + `coverage.md` + `verification/reports/<feature>` + git.
Output: `specs/<feature>/retro.md` (template in `specs/_template/retro.md`). This is the
**back half of the Measurability Gate**: `/align` opened a measurable prediction; the
retro closes it. The feature is not DONE until this retro closes all three faces.

## Anti-theater (why order matters)
A check cannot prove honesty. The procedure shrinks the space where fill-in
"just to comply" can hide: **derive → self-challenge → write**, never the other way around.

## Procedure

1. **Derive first (Face B, Layer 1).** Do not type figures from memory. Each Method
   field comes from an artifact with its `[deriv: <locator>]`:
   - Gaps caught by /distill → rows in `coverage.md` + `git log` from the distill phase.
   - RED→GREEN discipline → `coverage.md` state history (🔴 before 🟢) + git.
   - Post-/verify and post-/uat rework → gaps routed in `verification/reports/<feature>`.
   - Escalations → trace / git.
   Only "Friction from the WoW itself" is free judgment; the rest is derived.

2. **Issue Face A with mandatory evidence locator (Layer 2).** Read `alignment.md`:
   for each pillar in the `mapping`, find its `signal` in `north-star.md` and issue
   the verdict (`✅ moved` / `❌ did not move` / `⏳ not yet observable`) with an Evidence
   cell that is a **locator** (value, SHA, coverage row, URL) — not prose. Without a locator
   for a `confirmed`/`refuted`, the honest verdict is `pending-observation` with its
   re-check trigger. Note the **align calibration** (did the pillarFit/scope/mission scores
   hold up?). If the repo's North Star is a placeholder (not schema-valid), Face A is
   `n/a` with reason — there is no real signal to close against.

3. **Adversarial self-challenge (Layer 3).** Before writing, argue AGAINST your own
   draft: "the report says 0 rework — verify against `git log`; says the pillar-fit of
   align was exact — argue the opposite". Only what survives the challenge gets written.
   (Future reinforcement, not now: delegate the challenge to a separate skeptic subagent
   distinct from the one that drafted.)

4. **Face C (loop).** Propose candidate rules → constitution and/or amendments → North
   Star. Only propose; applying them follows `update-checklist.md` / `amendment-protocol.md`.

5. **Mission verdict.** `confirmed` | `refuted` | `pending-observation` (+trigger) |
   `n/a` (+mandatory reason). Write `specs/<feature>/retro.md` from the template.

## Gate
`tests/check_90_retro.sh` requires, for every feature with a DONE report: retro present,
no unfilled placeholders, valid mission verdict, non-empty evidence for `confirmed`/`refuted`,
`[deriv:]` on each Face B field, and a reason for `n/a`. The feature is not DONE without
`retro ✅`.
```

- [ ] **Step 5: Run the suite to see it pass**

Run: `bash tests/run.sh 2>&1 | tail -2`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/retro.md .claude/skills/retro/SKILL.md tests/check_40_commands.sh tests/check_50_skills.sh
git commit -m "feat(003): skill+command /retro (anti-theater derive→challenge→write)"
```

---

### Task 5: Skill + command `/wow-report`

**Files:**
- Create: `.claude/commands/wow-report.md`
- Create: `.claude/skills/wow-report/SKILL.md`
- Modify: `tests/check_40_commands.sh:1`
- Modify: `tests/check_50_skills.sh:1`

**Interfaces:**
- Consumes: all `specs/*/retro.md` + `alignment.md` + `verification/reports/*`.
- Produces: the `/wow-report` command and the `wow-report` skill that Task 7 invokes to generate `verification/wow-report.md`.

- [ ] **Step 1: Write the failing assertions.** In `tests/check_40_commands.sh` line 1, add `wow-report`:

```bash
for c in constitution distill plan contract tasks verify uat retro wow-report; do
```

In `tests/check_50_skills.sh` line 1, add `wow-report`, and two content assertions:

```bash
for s in distill verify uat retro wow-report; do
```
And at the end:
```bash
assert_contains .claude/skills/wow-report/SKILL.md "pillar"
assert_contains .claude/skills/wow-report/SKILL.md "smell"
```

- [ ] **Step 2: Run the suite to see it fail**

Run: `bash tests/run.sh 2>&1 | grep -E "wow-report|FAIL"`
Expected: FAIL with `missing file .claude/commands/wow-report.md` and `.claude/skills/wow-report/SKILL.md`

- [ ] **Step 3: Create `.claude/commands/wow-report.md`:**

```markdown
---
description: Regenerates verification/wow-report.md — the retro ledger rollup. Answers "is the WoW working?" with drift per pillar, pending re-checks, method health, and theater smells.
---

Invoke the `wow-report` skill. Reads all `specs/*/retro.md` + `alignment.md` +
`verification/reports/*` and regenerates `verification/wow-report.md` (committed snapshot,
read-only, never gates).
```

- [ ] **Step 4: Create `.claude/skills/wow-report/SKILL.md`:**

```markdown
---
name: wow-report
description: Aggregates the retro ledger in verification/wow-report.md — drift per pillar (mapping × signal verdict), pending re-checks, method health, and theater smells. On-demand observability, never gates. Use to answer "is the WoW working?".
---

# WoW Report

Input: all `specs/*/retro.md`, their `alignment.md`, and `verification/reports/*`.
Output: `verification/wow-report.md` (generated and committed snapshot). **Observes, never
gates** — the deterministic enforcement is `tests/check_90_retro.sh`; this is synthesis for
the human.

## Procedure
Regenerate `verification/wow-report.md` with five sections:

1. **Mission — is each North Star pillar actually being served?** Cross-reference the
   objective→pillar `mapping` of each `alignment.md` with the signal verdict of `retro.md`.
   Table per pillar: features that promised to serve it × whether the signal moved. **A pillar
   with features that promised to serve it but no signal moved = measurable drift** (highlight it).

2. **Pending re-checks (worklist).** Collect `pending-observation` items with their trigger;
   mark the overdue ones.

3. **Method — does the WoW add value?** (N=<n>, small sample, no statistics). Per-feature
   table: gaps caught, RED discipline, rework verify/uat, escalations. Group recurring
   friction themes.

4. **Loop — does the WoW improve itself?** Candidate rules proposed vs landed in
   constitution; amendments proposed vs approved (ADR).

5. **Theater smells (human spot-check, Layer 4).** Flag suspicious retros: empty Evidence
   cells, all-green (zero gaps + zero rework + zero friction), overdue `pending-observation`
   items. An overly clean retro IS a signal.

## N=1 Honesty
The report explicitly states "N=<n>, small sample, no statistics". It does not fake
trends; it shows per-feature + totals + themes.
```

- [ ] **Step 5: Run the suite to see it pass**

Run: `bash tests/run.sh 2>&1 | tail -2`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/wow-report.md .claude/skills/wow-report/SKILL.md tests/check_40_commands.sh tests/check_50_skills.sh
git commit -m "feat(003): skill+command /wow-report (ledger rollup, observes never gates)"
```

---

## Phase 4 — Dogfood: `003` self-validates

> This phase is the reflexive capstone: using the newly built capability on the very feature that built it. In the template repo Face A closes as `n/a` (North Star placeholder); Face B is real. These are not classic TDD steps but invocations of the WoW itself with deliverables verifiable by `check_90`.

### Task 6: Close `003` with its own `/retro` (recursive bootstrap)

**Files:**
- Create: `specs/003-wow-self-validation/brief.md`
- Create: `verification/reports/003-wow-self-validation-report.md`
- Create: `specs/003-wow-self-validation/retro.md`

**Interfaces:**
- Consumes: the `retro` skill (Task 4), `check_90` (Task 3), the full diff from Phases 1-3 (git log).
- Produces: the first real ledger entry — which Task 7 (`/wow-report`) aggregates.

- [ ] **Step 1: Create `specs/003-wow-self-validation/brief.md`** — the minimal brief that anchors the feature to the harness workflow:

```markdown
# Brief — 003 WoW self-validation

**Objective:** the harness self-validates by submitting to its own Way of Working — a retro
that closes the measurable prediction of `/align` (the align↔retro column), enforcement in CI,
and an aggregated rollup.

**Success metrics:** `tests/run.sh` green with `check_90`; `/retro` and `/wow-report`
present and wired; `003` itself closed with a complete retro (real Face B).

**Scope note:** template repo → North Star placeholder → `/align` does not truly run here; the
Face A (Mission) closes as `n/a`. Full design:
`docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.
```

- [ ] **Step 2: Create the DONE verification report for `003`** in `verification/reports/003-wow-self-validation-report.md`. The harness BUILD is `tests/run.sh` in green:

```markdown
# Verification Report — 003-wow-self-validation @ <commit>

spec: design 2026-07-05 · date: 2026-07-05 · constitution: base + project

## 1. Coverage snapshot
Structural criteria covered by `tests/check_*.sh` (template, wiring, gate, skills/commands).

## 2. Output eval (BUILD)
`bash tests/run.sh` → TOTAL FAIL=0. Task success: structural checks 100%.

## 3. Trajectory eval
Built test-first: every new file had its assertion in RED before being created
(git log Phases 1-3). No steps skipped.

## 4. UAT
Capability exercised end-to-end: DONE fixture without retro → `check_90` FAIL; with retro →
PASS (Task 3 steps 3-4). `/retro` produces this very retro.

## 5. Verdict
BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/003-wow-self-validation/retro.md`.
```

- [ ] **Step 3: Run `/retro` on `003`** (invoke the `retro` skill; order derive→self-challenge→write). Derive Face B from the real `git log` of Phases 1-3. Write `specs/003-wow-self-validation/retro.md`. Expected content (adjust figures to what `git log` shows):

```markdown
# Retro — 003-wow-self-validation @ <commit>

closes: `specs/003-wow-self-validation/alignment.md` (n/a) · `verification/reports/003-wow-self-validation-report.md` · date: 2026-07-05

## Face A — Mission (closes the /align prediction)
Source: N/A — this repo's North Star is a placeholder (not schema-valid); `/align` is fail-closed.

| Pillar (mapping) | Predicted signal | Verdict | Evidence (MANDATORY locator) |
|---|---|---|---|
| — | — | n/a | verification/reports/002-north-star-judge.md (NS placeholder) |

- **Align calibration:** N/A (`/align` did not run).
- **Mission verdict:** n/a
  - **reason:** repo = harness template; `north-star.md` is a placeholder, no real signal to close against. The align↔retro column is truly dogfooded in an adopter repo.

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted
- **Gaps caught by /distill:** 0 `[deriv: no /distill ran; feature came from brainstorming→design→plan]` — the grilling happened in brainstorming (2 forks + N=1 + NS placeholder).
- **RED→GREEN discipline:** yes `[deriv: git log Phases 1-3 — each check in RED before the file]` — Tasks 1,3,4,5 with "see it fail" step before creating.
- **Post-/verify rework:** 0 · **post-/uat:** 0 `[deriv: verification/reports/003-wow-self-validation-report.md]`
- **Human escalations:** several by design `[deriv: brainstorming transcript]` — all design decisions, not inner-loop failures.
- **Friction from the WoW itself:** the North Star placeholder prevents dogfooding Face A here; discovered that `check_90` needs no bootstrap for `002` (uniform rule).

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** "in the template repo, Face A of the retro closes as `n/a`; only an adopter validates it for real" — candidate note for the constitution/README.
- **Candidate amendments → North Star:** none.
```

- [ ] **Step 4: Run the suite — now `003` is a closed feature and `check_90` requires it**

Run: `bash tests/run.sh 2>&1 | grep -E "003|FAIL" ; bash tests/run.sh 2>&1 | tail -2`
Expected: `PASS: feature 003 DONE has specs/003-wow-self-validation/retro.md`, `PASS: … n/a with reason`, `PASS: … Face B with deriv`; `FAIL=0`.

- [ ] **Step 5: Commit**

```bash
git add specs/003-wow-self-validation/ verification/reports/003-wow-self-validation-report.md
git commit -m "feat(003): dogfood — 003 closes with its own /retro (recursive bootstrap)"
```

---

### Task 7: Generate `verification/wow-report.md` with `/wow-report`

**Files:**
- Create: `verification/wow-report.md`

**Interfaces:**
- Consumes: the `wow-report` skill (Task 5), `specs/003-wow-self-validation/retro.md` (Task 6).
- Produces: the ledger snapshot — the "Is the WoW working?" view with N=1.

- [ ] **Step 1: Run `/wow-report`** (invoke the `wow-report` skill). Generates `verification/wow-report.md`. Expected content:

```markdown
# WoW Report — @ <commit>  (generated snapshot; do not edit manually)

> N=1, small sample, no statistics. Template repo: the Mission Face is not yet measured for real
> (North Star placeholder). This report tests the machinery + the Method Face.

## 1. Mission — is each North Star pillar being served?
North Star placeholder → no real pillars. 003: Mission `n/a` (reason: template repo).
Measurable drift: N/A until an adopter repo.

## 2. Pending re-checks
None (003 closed as `n/a`, no `pending-observation`).

## 3. Method — does the WoW add value? (N=1)
| Feature | Gaps /distill | RED discipline | Rework verify/uat | Escalations |
|---|---|---|---|---|
| 003 | 0 (grilling in brainstorming) | ✅ yes | 0 / 0 | design, not inner-loop |
Friction themes: North Star placeholder blocks Face A; bootstrap simplification discovered during build.

## 4. Loop — does the WoW improve itself?
Candidate rules: 1 proposed (template repo Face A note), 0 landed yet.
North Star amendments: 0 / 0.

## 5. Theater smells
003 is not all-green (declares real friction and 0 gaps justified by coming from brainstorming, not /distill). Evidence present. No smells.
```

- [ ] **Step 2: Run the suite (must not break anything; `/wow-report` does not gate)**

Run: `bash tests/run.sh 2>&1 | tail -2`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 3: Commit**

```bash
git add verification/wow-report.md
git commit -m "feat(003): generate wow-report.md (ledger N=1, real Method Face)"
```

---

### Task 8: Final green + merge readiness

**Files:** none (verification)

- [ ] **Step 1: Full suite green**

Run: `bash tests/run.sh 2>&1 | tail -3`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 2: Clean secret scan** (if applicable to the repo)

Run: `bash tests/run.sh 2>&1 | grep -iE "secret|check_60"`
Expected: no FAIL

- [ ] **Step 3: Review the full branch diff**

Run: `git log --oneline main..HEAD && git diff --stat main..HEAD`
Expected: commits from Phases 1-4; manifest files present.

- [ ] **Step 4:** Report to the human that branch `003-wow-self-validation` is ready to merge to `main`. Do not merge without explicit approval.

---

## Self-Review (done by the plan author)

**1. Spec coverage:**
- 3-face retro template → Task 1 ✅
- DONE contract `∧ retro ✅` → Task 2 ✅
- `check_90` (template + wiring + uniform closure, no hardcoding) → Task 3 ✅
- 4-layer anti-theater → Face B `[deriv]` (Task 1/3), mandatory evidence + `check_90` (Task 3), self-challenge in skill (Task 4), smells in `/wow-report` §5 (Task 5) ✅
- Skill+command `/retro` → Task 4 ✅ · `/wow-report` → Task 5 ✅
- Bootstrap: no hardcoding, `002` non-DONE is skipped → Task 3 (vacuous loop) ✅
- Recursive dogfood `003` (Face A `n/a` due to NS placeholder, Face B real) → Tasks 6-7 ✅
- `/wow-report` generates committed snapshot → Task 7 ✅

**2. Placeholder scan:** the `<…>` inside blocks are template/retro syntax (real content to be filled by the executor with git data), not plan placeholders. No TBD/TODO.

**3. Type consistency:** file/command/skill names (`retro`, `wow-report`, `check_90_retro.sh`, `verification/wow-report.md`) are consistent across tasks; the `check_40`/`check_50` loops reference exactly those names.

**Known fragility note (for the executor):** the `done_re`/DONE detection in `check_90` uses `grep` over UTF-8 emojis; if the environment has locale issues, verify with `LC_ALL=C.UTF-8`. The Task 3 fixture (steps 3-5) exists precisely to catch this before trusting the gate.
