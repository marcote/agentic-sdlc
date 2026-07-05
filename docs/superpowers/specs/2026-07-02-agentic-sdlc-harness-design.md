# Design — Agentic SDLC Harness

**Date:** 2026-07-02
**Author:** Marco Torres
**Status:** Approved (design) — pending implementation plan

Based on Google's whitepaper *"The New SDLC With Vibe Coding — From ad-hoc
prompting to Agentic Engineering"* (Day 1; Osmani, Saboo, Kartakis) and on the
*constitution* concept from GitHub/Microsoft Spec Kit.

---

## 1. Objective and scope

Define the structure of an **agnostic harness / project template**: a software
repo (without app code) prepared for code agents to build with discipline. It is
the *"factory model"* from the paper: the developer designs the system (specs,
guardrails, verification) and the agent produces; verification validates the output.

**Framework decisions:**

| Decision | Choice |
|---|---|
| Repo type | Harness / project template (not a production agent, not a methodology) |
| Stack | Agnostic — only the agentic layer, copied on top of any project |
| Agent convention | **Claude Code first** (`CLAUDE.md` + `.claude/`) |
| Enforcement | **On-demand** verification by the agent; **no blocking commit hooks** |
| North Star | **Verification / UAT**: closing the loop that Spec Kit leaves loose |
| Constitution inheritance | **Vendored + convention** (`base/` is copied with the template) |
| Test-first | **Enforced by the workflow** (phase gate), not discretionary; BDD/TDD style |

**Explicit North Star:** verification and UAT are first-class citizens. The
harness's differential over Spec Kit is closing the verification cycle — the Spec
Kit article itself does not cover testing or acceptance criteria.

---

## 2. Design principles

1. **Productivity first.** Verification is executed by the agent *on-demand* via
   skills/commands, not blocking hooks. Nothing stops a commit/push by default.
2. **Intent > syntax.** The developer's primary artifact is the *spec* + the *acceptance
   criteria*, not the code.
3. **The constitution is code.** Versioned, reviewed in PRs, with its own update checklist.
   *"Add a rule every time the agent does something it should not do again."*
4. **Everything verifiable leaves a trace.** Each verification produces a *report*
   (build + trajectory + UAT), not a simple ephemeral pass/fail.

### Concept mapping

| Concept | Origin | Role in the repo |
|---|---|---|
| **Constitution** | Spec Kit | Non-negotiable principles. The most stable layer of *static context*. |
| **Static vs Dynamic context** | Paper (Fig. 4) | `CLAUDE.md` + `memory/` = static. `.claude/skills/` = dynamic (progressive disclosure). |
| **Factory model** | Paper (Fig. 6) | The dev designs the system; the agent produces; verification validates. |
| **Verify build + trajectory** | Paper (Fig. 5) | Not just "does it compile?" (output) but "did it follow the flow?" (trajectory) + UAT against criteria. |

---

## 3. Directory structure

```
agentic-sdlc/
│
├── CLAUDE.md                      # STATIC context: stack, conventions, hard rules,
│                                  #   workflow, pointers to memory/ and skills. Always loaded.
│
├── memory/                        # Persistent STATIC context (Spec Kit "memory")
│   └── constitution/
│       ├── base/                  # INHERITED · shared asset · vendored
│       │   ├── principles.md      #   non-negotiables in prose
│       │   ├── patterns/          #   "given practices" that inject criteria
│       │   │   ├── audit-logging.md
│       │   │   ├── rate-limiting.md
│       │   │   └── idempotency.md
│       │   └── README.md          #   how inheritance works
│       ├── constitution.md        # PROJECT · `extends: base` + local deltas
│       └── update-checklist.md    # "add a rule every time the agent fails"
│
├── specs/                         # one folder per feature — the heart of the flow
│   └── <NNN-feature>/
│       ├── brief.md               #  ORIGIN: product objective + why + metrics
│       ├── spec.md                #  WHAT: requirements, user stories, edge cases
│       ├── acceptance.md          #  measurable criteria (BDD Given/When/Then) ←── eval/UAT
│       ├── coverage.md            #  traceability matrix (gap detector + state machine)
│       ├── plan.md                #  HOW: technical decisions (grounded in constitution)
│       └── tasks.md               #  decomposition into executable units
│
├── evals/                         # automatable verification (output + trajectory)
│   ├── rubric.md                  #  5 dimensions: task success, tool use, trajectory,
│   │                              #    hallucination, response quality
│   ├── cases/                     #  cases derived from acceptance.md (non-deterministic)
│   └── README.md                  #  how to run them (template; optional runner)
│
├── verification/                  # NORTH STAR · on-demand verification + UAT
│   ├── uat-checklist.md           #  UAT per acceptance criterion
│   ├── verification-report.md     #  report template (build + trajectory + UAT)
│   ├── code-review-checklist.md   #  scrutiny for AI code (hallucinated deps, error handling)
│   └── reports/                   #  emitted reports, versioned (observability / trace)
│
├── .claude/                       # DYNAMIC context + Claude-native harness
│   ├── skills/                    #  progressive disclosure, loaded on-demand
│   │   ├── distill/               #    brief → spec (grilling · covers gaps · matrix)
│   │   ├── verify/                #    runs evals + generates verification-report
│   │   └── uat/                   #    guides UAT against acceptance.md
│   ├── commands/                  #  /constitution /distill /plan /contract /tasks /verify /uat
│   └── settings.json              #  permissions + minimal advisory hook (secret-scan, non-blocking)
│
├── docs/                          # the "why" — educational
│   ├── factory-model.md           #  how to think about the repo (paper Fig. 6)
│   └── workflow.md                #  the end-to-end flow with diagram
│
└── README.md                      # entry point: what it is, how to use it, the loop at a glance
```

**Mapping to the paper's layers (Fig. 4 and 7):**
- **Static context** → `CLAUDE.md` + `memory/`
- **Dynamic context** → `.claude/skills/` (progressive disclosure)
- **Guardrails** → `memory/constitution/` (declarative) + minimal hook (executable)
- **Feedback loop** → `evals/` + `verification/`
- **Observability** → `verification/reports/`

---

## 4. The constitution as an inheritable artifact

Two layers, inheritance-style (preset that gets extended):

- **`base/`** — INHERITED, shared asset, **vendored** (copied with the template).
  Contains the non-negotiables in prose (`principles.md`) and **patterns** ("given
  practices"). Each pattern is not just prose: **it injects default acceptance criteria**.

  Example `patterns/audit-logging.md`:
  > **Principle:** every operation that writes state leaves an auditable trace.
  > **Injected criteria:** `[given] every write endpoint emits audit-log with
  > actor+timestamp` → maps to `eval: audit-trail`.

- **`constitution.md`** — PROJECT, declares `extends: base` + local deltas/overrides.

**Synchronization:** `base/` lives inside the template and is copied with it. `extends: base`
is a convention that the `/distill` skill resolves by reading the folder. The base evolves
by copying when it changes (zero infra).

**Where it enters the loop:** the constitution is **seed + filter**, not a separate step:
- **Seeds** interrogation questions in `/distill` ("does this clash with zero-trust?").
- **Filters**: rejects requirements that violate a non-negotiable.
- **Injects** `[given]` rows into `coverage.md` *before* starting, so that each spec
  begins pre-populated with inherited criteria and the loop only covers the *delta*.

Connects with the paper *(engineering leaders)*: *"Invest in the harness components as a
shared team asset… build their harness once and refine it many times"* and *"AI amplifies
the engineering culture it lands in."* The `base/` **is** that culture, versioned.

---

## 5. The originating layer: from objective to verifiable spec

Three chained artifacts, each more precise than the previous:

```
brief.md        → product objective + why + success metrics (NOT the solution)
   ↓  (distillation loop · grilling style)
spec.md         → functional requirements + user stories + edge cases
   ↓
acceptance.md   → measurable acceptance criteria (BDD)  ←── this IS the eval/UAT
```

Closure principle from the paper: **"Specs become eval criteria"**. Each acceptance
criterion is simultaneously what the UAT and the eval verify. If an objective does not
reach a criterion, it is a gap.

### 5.1 The distillation loop (how gaps are hunted)

Cycle that `/distill` runs (grilling-style) until convergence. Four moves:

```
        ┌─────────────────────────────────────────────┐
        │  brief.md (objective + success metrics)       │
        └───────────────────┬─────────────────────────┘
                            ▼
   ┌──────────────────────────────────────────────────────┐
   │ 1. EXTRACT    objectives, stories, constraints         │
   │ 2. INTERROGATE ambiguities → questions to the human   │ ◄─┐ iterates
   │ 3. EXPAND     edge cases the human didn't see (80%)   │   │ (grilling)
   │ 4. TRACE      objective → requirement → criterion     │──┘
   └───────────────────────┬──────────────────────────────┘
                           ▼
              coverage.md without orphan rows? ── no ──► keep grilling
                           │ yes (freeze)
                           ▼
              spec.md + acceptance.md  (frozen, versioned)
```

**Interrogation (step 2):** grilling-style — the agent **does not advance** with open
ambiguities: it asks one at a time, insists, freezes the spec only when the matrix has no
orphan rows (or they are *deferred* with justification).

### 5.2 The traceability matrix (`coverage.md`) — gap detector

Live table; the backbone of enforcement. Mechanical rule: **every objective in the brief
must reach a verifiable criterion; every criterion must map to an eval or UAT step.**
Any orphan row is an explicit gap that blocks the spec *freeze* — detected by the
agent when running `/distill`, not a hook.

| Objective | Requirement | Criterion | Origin | Status |
|---|---|---|---|---|
| — | (all) | audit-log on writes | `[given] base/audit-logging` | ✅ inherited |
| ↑ conversion | Save card 1-tap | token < 300ms, PCI | project | 🟡 in grilling |

The edge cases generated in step 3 (the **80% problem**) enter as new rows,
forcing criteria for them.

---

## 6. End-to-end workflow

**7 commands + 3 loops.** The `brief.md` is authored during intake (manual or assisted);
the 7 slash-commands are: `/constitution`, `/distill`, `/plan`, `/contract`, `/tasks`,
`/verify`, `/uat`. The backbone is `coverage.md`: each row travels from
the objective to its verification report.

```
 PHASE (paper)         COMMAND            ARTIFACT              VERIFICATION
─────────────────────────────────────────────────────────────────────────────
 Harness config       /constitution   → memory/constitution/   (seed + filter)
 Requirements         intake          → brief.md               objective + metrics
                      /distill        → spec + acceptance + coverage   (grilling loop)
 Design/Architecture  /plan           → plan.md                (grounded in constitution)
 Testing (contract)   /contract       → tests 🔴 + eval cases   (proves it is RED)
 (decomposition)      /tasks          → tasks.md    GATE: rejects if red contract missing
 Implementation       (implement)     → code        inner loop 🔴→🟢 (see §7)
 Testing & QA         /verify         → verification-report     output + trajectory eval
 UAT                  /uat            → append to report        against acceptance.md
```

### The three loops

1. **Grilling loop** (within `/distill`): closes *specification gaps* before
   writing code. Cheap.
2. **Implementation loop** (inner, per task): the agent self-corrects 🔴→🟢 (see §7).
3. **Feedback loop** (`/verify` and `/uat`): if it fails, routes back:
   - **/verify** failure → *implementation* problem → returns to implement.
   - **/uat** failure → the build meets the spec but the spec did not meet the objective →
     **product gap** → returns to `/distill`.

**On-demand, non-blocking:** `/verify` and `/uat` are invoked by the dev (or the agent when
closing a task/feature), never by a commit hook. The commit/push flows freely; verification
runs when closing a unit of work and always leaves a versioned report.

---

## 7. The implementation loop (inner loop)

Runs **for each task in `tasks.md`**. Concrete version of the agent loop from the paper (Fig. 2).

```
   pick task from tasks.md
        │  (reads its linked rows in coverage.md = criteria this task satisfies)
        ▼
   write/modify code  +  make the tests for THOSE criteria pass
        │
        ▼
   run LOCAL deterministic checks:  typecheck · unit tests for criteria · lint
        │
        ▼
   OBSERVE ──┬─ passes & no constitution violation ──► task DONE ─► next task
             ├─ MECHANICAL failure (bug) ──► auto-corrects, retries  ┐ budget N attempts
             ├─ same failure 2 times (no-progress) ──► ESCALATE      │
             └─ CONCEPTUAL failure (ambiguity / impossible criterion) ┘─► ESCALATE
   ESCALATE = stops coding · does not burn tokens · routes to /distill or the human
```

### What it compares against (Tests vs Evals — paper)

| # | Oracle | Who checks | When |
|---|---|---|---|
| 1 | **Criteria tests** (deterministic part of `acceptance.md`) | inner loop (agent) | each iteration |
| 2 | **Constitution / `[given]` patterns** (non-negotiables) | inner loop (agent) | each iteration |
| 3 | **Evals** (NON-deterministic part: trajectory, quality, hallucination) | `/verify` (external) | when closing feature |

### Cut condition

- ✅ **DONE:** all local checks for the task's criteria pass **and** zero
  constitution violations → `coverage.md` row moves to `implemented (pending verify)`.
- ⛔ **ESCALATE:** budget exhausted, **or** no-progress (same failure 2 times), **or** failure
  classified as *spec gap*. The agent stops and returns control. Materializes the
  **80% problem**: does the mechanical 80% and reserves the conceptual 20% for the human.

**Default budget (tunable in `constitution`):** escalate after 2 identical failures or
3 total attempts per task.

The inner loop **never** calls UAT or non-deterministic evals — it leaves those for the gate.

---

## 8. Test-first enforced (red contract as phase gate)

Enforcement lives in a **workflow transition — once per feature, before coding — not
in a per-commit hook.** The dev never hits a wall when committing; they simply
don't get implementation tasks without the red test contract.

**BDD:** each acceptance criterion is written as a Given/When/Then scenario, and that
scenario *is* the test.

```gherkin
Criterion: card token < 300ms
  Given a valid card
  When the user saves with 1 tap
  Then the token is returned in < 300ms
  And the response is PCI-compliant   # ← injected [given] by constitution
```

**The gate (`/contract`, separate command):**

```
 /distill ──► acceptance.md (BDD scenarios) + coverage.md
 /contract ──► generates tests (deterministic) + eval cases (non-deterministic)
     │          and RUNS the suite → must be 🔴 RED (proves the test is real)
 /tasks ──► GATE: rejects emitting implementation tasks if any
     │       deterministic criterion has no test linked in 🔴 RED state
 (implement) ──► inner loop drives 🔴 RED → 🟢 GREEN
```

The `/tasks` gate is **machine-checkable, not discretionary**: it walks `coverage.md` and
for each deterministic row requires `test_ligado != null AND estado == RED`. Without that,
there are no implementation tasks.

**Symmetric for non-deterministic:** criteria that cannot be unit-tested generate **eval
cases** in `evals/cases/` also before implementing. The gate is "contract-first", not
just "test-first".

### coverage.md as a criterion state machine

| Criterion | Scenario/Test | Status |
|---|---|---|
| token < 300ms | `card_token.feature` | 🔴 red → 🟢 green → ✅ uat |
| audit-log `[given]` | `audit.feature` | 🔴 red |
| ↑ conversion (non-determ.) | `eval/conversion.yaml` | 📋 case present |

Rule: a row cannot move to `implement` without leaving "no contract"; it cannot move to
`done` without being 🟢; it does not close without ✅ in `/uat`. The agent checks this at
each command transition — zero commit hooks.

---

## 9. The verification layer (the north star)

### 9.1 Rubric (`evals/rubric.md`)

*"An eval without a clear rubric measures nothing."* Five dimensions, each with
explicit scale and threshold:

| Dimension | What it measures | Type | Score | Threshold |
|---|---|---|---|---|
| **Task success** | does the artifact meet the criteria? | deterministic | green tests / total determ. criteria | **100%** (non-negotiable) |
| **Tool use quality** | did it use the right tools, correctly? | trajectory | LM judge + checks vs `tasks.md` | ≥ def. threshold |
| **Trajectory compliance** | did it follow the flow? did it skip verification? | trajectory | LM judge over the trace | no skipped steps |
| **Hallucination** | invented deps/APIs? | mixed | real import check + judge | **0 hallucinations** |
| **Response quality** | non-deterministic criteria | non-determ. | eval cases + LM judge vs `acceptance` | ≥ def. threshold |

*"A fluent output that skipped its verification steps is a more dangerous failure than one
with a visible error."* → **Trajectory compliance** weighs as much as Task success.

### 9.2 Verification-report (`verification/verification-report.md`)

Fixed structure, emitted in `/verify` and completed in `/uat`; each section traceable to
`coverage.md`:

```markdown
# Verification Report — <feature> @ <commit/ref>
spec: <spec.md vN>   ·   date   ·   constitution: base vX + project vY

## 1. Coverage snapshot        (copied from coverage.md)
## 2. Output eval (BUILD)      ← deterministic: test → pass/fail | Task success: N/N
## 3. Trajectory eval          ← LM judge: tool use, skipped steps, hallucination
## 4. UAT                      ← added by /uat, against acceptance.md (reveals product gaps)
## 5. Verdict                  ← BUILD / TRAJECTORY / UAT + routed gaps
```

### 9.3 Feature closure condition (strict AND)

```
   feature "DONE"  ⟺  BUILD ✅  AND  TRAJECTORY ✅  AND  UAT ✅  AND  coverage 100%
```

- **BUILD** (output): binary, non-negotiable — 100% of deterministic criteria in 🟢.
- **TRAJECTORY**: rubric with LM judge; fails if it skipped verification or misused tools,
  even if the build passes.
- **UAT**: validates against the *objective*, not the spec. The only one that reveals **product gaps**
  and routes to `/distill`.

---

## 10. Guardrails, hooks and CI (the non-intrusive minimum)

The real enforcement lives in the workflow. Hooks are the last thin layer. Three
mechanisms, from coarsest to finest:

```
 1. CONSTITUTION (declarative)   → non-negotiables. Applied by the AGENT.
 2. WORKFLOW GATES (deterministic) → red gate of /contract, state machine of
                                    coverage.md, strict-AND closure.  ◄── 90% of enforcement.
 3. HOOKS (executable, thin)      → only the cheapest and irreversible. Opt-in.
```

### 10.1 Hooks (`.claude/settings.json`)

One single hook, **advisory by default (warns, does not block)**:

| Hook | Point | Default | Why |
|---|---|---|---|
| **secret-scan** | PreToolUse on git commit | warns (does not block) | Only irreversible case with a trivial check. Promotable to blocking with a flag. |

### 10.2 CI (optional, advisory by default)

```
 PR opened ──► CI runs /verify (evals + trajectory) ──► posts verification-report
                                                          as a PR COMMENT
                        (advisory · NOT a required check by default)
```

- **By default:** the report is posted as a comment; it informs, does not block the merge.
- **Governance lever:** a team/leader can promote the check to *required* with a
  toggle — the *"Require eval coverage as a precondition for any agent shipping into a
  shared workflow"* from the paper. Explicit governance decision, not default friction.

### 10.3 Observability

Each `/verify` leaves a versioned `verification-report.md` in `verification/reports/`. That
*is* the observability layer (*"traces what the agent actually did"*) — an auditable trace
of what was built and how, plus token/latency if the runner captures them. No extra infra.

---

## 11. Out of scope (YAGNI)

- App code scaffolding (the harness is agnostic).
- Multi-agent support (GEMINI.md / AGENTS.md portable) — Claude Code first.
- `base/` inheritance via submodule or published package — vendored is used.
- Blocking commit/push hooks beyond the advisory secret-scan.
- Complete production eval runner — structure + template are delivered; the concrete
  executable runner depends on the stack of the project adopting the harness.

---

## 12. Risks and mitigations

| Risk | Mitigation |
|---|---|
| The inner loop enters an infinite loop (token burn) | Attempt budget + no-progress detection → ESCALATE |
| The agent "appears to" verify and skips steps | Trajectory compliance weighs as much as build; the report leaves a trace |
| The `base/` constitution goes out of sync between projects | Vendored + `update-checklist.md`; explicit synchronization on copy |
| Test-first becomes friction | The gate runs once per feature (not per commit); enforcement at workflow transition |
| Product gaps go undetected | UAT validates against the *objective*, not the spec; routes back to `/distill` |
