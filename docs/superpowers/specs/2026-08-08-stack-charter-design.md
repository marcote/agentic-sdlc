  # Design — Stack Charter: pinning load-bearing decisions before they are expensive

**Date:** 2026-08-08
**Status:** design approved, pending implementation plan
**Feature slot:** `013-stack-charter`

---

## 1. Problem

The harness is deliberately stack-agnostic. That agnosticism has a cost the workflow
currently does not pay: **nothing in the loop forces the load-bearing technical decisions
to be made, stated, or priced.** They get made anyway — silently, by the agent, at
implementation time, one file at a time.

Two failure shapes:

1. **The mute assumption.** No step asks "where does this deploy?", "how many concurrent
   writers?", "is stdout the only consumer?". The agent picks something reasonable and
   moves on. It is not a *mistake* — nothing is red, coverage closes, the feature ships —
   so the existing "add a rule when the agent repeats a mistake" accretion never fires.
   The bill arrives three features later as rework.

2. **The incoherent set.** Individual decisions can each be defensible while the
   combination is not (*API-first in Assembler*). Nothing in the loop ever evaluates the
   decisions *as a set*.

Concrete instances raised by the maintainer:

- Start on DuckDB; discover concurrent read/write; end on Postgres. Expensive rework.
- Build the whole app in `println`; later need to expose it over REST. Near-rewrite,
  because compute and transport were fused by omission.
- Deploy target (Railway vs DigitalOcean vs local) changes architecture, and is usually
  decided last.

Existing evidence of the hole: `CLAUDE.md` carries a `## Stack` section that `vendor.sh`
stubs as `_(your language/framework)_`. Nothing obliges anyone to fill it and no command
reads it.

**The framing that drives the whole design:** the harness's job is *not* to eliminate
assumptions. It is to ensure **no load-bearing assumption is mute**. An assumption stated
out loud, with its price, is not a surprise later — even when it turns out wrong.

## 2. Non-goals

- **Not** an enumerated compatibility matrix. It ages badly and can never cover the
  future. Coherence is judged by the model at pin time; only incompatibilities that
  actually bite get promoted to written rules (the constitution's existing idiom).
- **Not** a 30-question wizard. Interview depth is capped by the rigor tier (§5) and by
  the rule that a question is only asked when the agent cannot infer the answer *and* the
  answer changes architecture.
- **Not** a relaxation of the constitution. The hard rules stay absolute (§6).
- **Not** the portable profile layer. Deferred — see §11.

## 3. Core model: the pin

### 3.1 Inclusion test

> A decision is a pin **iff changing it later costs rework.**

This test replaces an enumerated decision list. The maintainer does not need to foresee
future variables; the harness needs one criterion it can apply to anything. Deploy target,
datastore, language/runtime, interface stance: in. Linter choice, log format: out.

A second, higher-value class is defined by an asymmetry:

> **cost now ≈ 0 · cost later = rewrite**

Returning a dict instead of printing it costs nothing today; extracting it from 40
`println` calls costs a sprint. This class is the highest-value content of the charter and
is exactly what a user will *never* think to ask for. See §7.2.

### 3.2 Two kinds of pin

|                | **Stance pin**                                       | **Substrate pin**                          |
| -------------- | ---------------------------------------------------- | ------------------------------------------ |
| What it fixes  | The shape of the seam — what "done" means             | What it runs on                            |
| Examples       | API-first, data-driven core, CLI-as-adapter           | PostgreSQL 16, Railway, uv, Python 3.13    |
| Effect         | Injects `[given]` rows into `coverage.md`             | Constrains `/plan`                          |
| Verifiable     | Yes — expressible as a BDD criterion + a code guard   | No — it is a constraint, not a criterion   |

The distinction matters because stance pins are *functional*, not merely technical, and
because they can be **enforced**. `API-first` written in a README is an aspiration. As a
stance pin it becomes a coverage row plus an executable guard.

Note: `API-first` and `CLI-driven` are not in tension — they are the same pin. They only
conflict if the CLI *is* the application. With a data-producing core and the CLI as one
adapter among several, both hold simultaneously: **one core, many consumers.**

### 3.3 Canonical pin form

```markdown
### S3 — Datastore: DuckDB                              [substrate]
- Confidence:    PROVISIONAL — "leaning this way"
- Because:       today a single process writes; workload is analytical
- Buys:          zero infra, embedded, fast scans
- Forecloses:    multi-process concurrent writes
- Falsifier:     >1 concurrent writer, or multi-instance deploy
- Hedge:         data access behind a repository interface;
                 no raw SQL outside that layer
```

```markdown
### S1 — Data-driven core, presentation at the edge      [stance]
- Confidence:    PINNED
- Because:       today's consumer is a TTY; REST / MCP / notebook are plausible
- Buys:          adding a transport = writing an adapter, not rewriting the core
- Forecloses:    "free" incremental streaming — it must be designed explicitly
- Guard:         no stdout write outside `*/adapters/`
- Injects:       [given] every core capability returns structured data;
                 the CLI consumes it like any other adapter
```

### 3.4 Field semantics

| Field         | Required on           | Purpose |
| ------------- | --------------------- | ------- |
| `Confidence`  | all                   | `PINNED` (decided) or `PROVISIONAL` (declared uncertainty — "don't know, but this way"). |
| `Because`     | all                   | The domain fact that produced the pin, not a preference. |
| `Buys`        | all                   | What the decision gains. |
| `Forecloses`  | all                   | **The price.** The expensive surprise is never the decision — it is the cost nobody stated. A pin without `Forecloses` is not a pin. |
| `Falsifier`   | all                   | Evidence that would overturn the pin, declared in advance. This is what makes the per-feature guard mechanical rather than vibes: *does any new acceptance criterion match a declared falsifier?* |
| `Hedge`       | `PROVISIONAL` only    | Declared uncertainty converts into an architectural constraint: keep that seam cheap to change. **A `PROVISIONAL` pin without a `Hedge` is a lie.** Emitted as a `[given]` coverage row, so it is verifiable rather than aspirational. |
| `Guard`       | stance pins           | A cheap executable check in the suite (grep/AST is enough). Without it, `Injects` is a coverage row ticked by eye and the stance erodes by feature 7. |
| `Injects`     | stance pins           | The `[given]` row(s) added to each applicable feature's `coverage.md`. |
| `Supersedes` / `SUPERSEDED` | amended pins | Amendment history lives in the same file (§8.3). |

### 3.5 Hedge admission test

This mechanism can metastasize into ports-and-adapters for a 200-line script. The
counterweight:

> **A hedge must cost ~nothing now.** If it costs real design work, it is not a hedge —
> it is premature abstraction.

When the hedge is not free, the two honest options are: pin firmly and accept the declared
reversal cost, or go resolve the uncertainty before proceeding. Without this rule the
system being designed becomes the problem.

## 4. The floor: not configurable

Some things must hold regardless of how throwaway the project is — *"don't hardcode the
passwords just because I forgot to tell you not to."*

That is **not a pin**. A pin is negotiable; this is not. It stays where it already lives:
`memory/constitution/base/principles.md` P6 (*Security by default*), backed by the
existing `.claude/hooks/secret-scan.sh`. It does not depend on the rigor tier and never
scales down.

```
base/principles.md   ← the floor. Independent of S0. Never lowers.
S0 (rigor tier)      ← calibrates everything above the floor.
S1..Sn (pins)        ← elicited to the depth S0 permits.
```

## 5. S0 — the rigor tier

S0 is the first pin and it calibrates the others. It is **derived, not chosen by label** —
consistent with §7.1, the interview asks about the world, not for a classification:

- Does it run on your machine, or on a server?
- Does anyone besides you use it?
- Does it touch secrets, money, or third-party data?
- If it breaks, do you re-run it — or does state get corrupted?

The underlying axis is **blast radius**: who is harmed when it breaks, and is it re-runnable.

S0 is written in the same format as any other pin, which means it carries a `Falsifier`
("if this starts running deployed, S0 rises"). **The tier can change too, and it is
announced.** The personal script that suddenly runs in a server cron does not catch you
off guard.

## 6. What S0 scales: scope, not rules

S0 scales **how much work enters the loop**, never the rules applied to it.

- At a low tier, `/distill` produces 3 criteria instead of 15 and `/stack` elicits 3 pins
  instead of 9. Hedging is also rarer: at low blast radius the honest move is usually to
  pin firmly and accept the declared reversal cost, since rework on a throwaway artifact is
  cheap by definition. §3.5 still governs — the tier does not change the hedge admission
  test, it changes how often the test is passed.
- Over whatever criteria *do* exist, the `/contract` RED gate still applies and coverage
  is still 100%.

One mode of operation, calibrated. 100% coverage of 3 criteria is not theater — it means
the feature was small. The hard rules in `CLAUDE.md` and `base/principles.md` remain
non-negotiable; if the tier could switch them off, "non-negotiable" would mean
"non-negotiable except when not", and the constitution would lose its force as a filter.

## 7. Elicitation protocol

The hard part is extracting data the maintainer does not have. *"Often I don't even know
the limitations or the non-functional requirements myself."*

### 7.1 Ask about the domain, not the technology

You cannot answer what you do not know — but you do know facts about the world from which
the unknown can be **derived**.

> ❌ *"Postgres or DuckDB?"* → "you decide" → mute assumption
>
> ✅ *"Will one process write this, or several at once? Today, and in six months?"* →
> "one today, no idea later" → the agent **derives**: DuckDB suffices today,
> `PROVISIONAL`, falsifier = second writer, hedge = repository interface.

The agent performs the translation domain → NFR → pin. The human supplies what they know
(the world); the agent supplies what it knows (the technical consequences).

### 7.2 Procedure

Numbered, in the style of the existing `/distill` skill:

0. **Derive S0** from the blast-radius questions (§5).
1. **Draft.** Read the North Star and propose the pin sheet with the agent's own defaults,
   marking each entry `inferred` / `assumed` / `unknown`. Never start from a blank page.
   **Obligation:** proactively propose the asymmetric-cost pins (§3.1) that the North Star
   implies, even though the human did not ask. For *"diagnose a stock portfolio"* this
   surfaces on its own: the output is an analysis object, and stdout is one consumer among
   several.
2. **Price.** Every proposed pin ships with `Buys` / `Forecloses`. The human can object to
   the price, not only to the choice.
3. **Grill.** Ask **only** where the agent (a) cannot infer *and* (b) the answer changes
   architecture. One question at a time, reusing the grilling idiom `/distill` already has.
   Everything else is assumed **out loud** and can be overridden. This bounds the interview.
4. **"I don't know" is a valid answer.** It produces `PROVISIONAL` + a mandatory `Hedge`
   (subject to §3.5). It never blocks. If "I don't know" blocked, the human would lie to
   get through the ritual.
5. **Coherence objection.** A final pass over the *complete set*, which must produce an
   explicit verdict rather than silence. This is where *API-first in Assembler* surfaces.
6. **Write** the charter and emit the exposure header.

### 7.3 Exposure header

Auto-derived at the top of the charter:

```
9 pins · 6 PINNED · 3 PROVISIONAL
Exposure: S3 datastore, S6 deploy target, S8 auth
```

This is literally *"start without surprises"*. It does not claim you know everything — it
shows, in one line, **what you don't know that can bite you.**

## 8. Gates

### 8.1 Init — `/stack`

Placed where the gap is: after seeding the North Star (it needs to know *what* is being
built), before the first brief.

```
/constitution → seed North Star → /stack → brief → /align → /distill → /plan* → /contract → ...
                                  ▲ new                            ▲ guarded
```

Runs the §7.2 procedure and writes the charter.

### 8.2 Per-feature guard — at `/plan`, fail-closed

`/plan` and not earlier, because it is **the only step that makes technical decisions**,
and it already has the required inputs: `acceptance.md` (what the feature demands) and the
charter (what is pinned). Precedent: `/distill` already fails closed on `MEAS-GATE`.

Both classifications are **model-judged, not string-matched**: "is this decision
load-bearing?" applies the §3.1 inclusion test, and "does this criterion trip a falsifier?"
is a semantic reading of the criterion against the declared falsifier. The harness supplies
the forcing function — the guard must emit one of the three verdicts explicitly and may not
stay silent — while the model supplies the judgement. This is the same division of labour
as the coherence objection (§7.2 step 5) and the same reason no compatibility matrix is
enumerated (§2).

Three outcomes:

**`PASS`** — every load-bearing decision the plan needs is pinned; no falsifier tripped.
Proceed, and `plan.md` **cites the pins it depends on** (traceability, consistent with
Principle 3).

**`UNPINNED`** — the plan requires a load-bearing choice with no pin. Stop, run the
mini-interview scoped to that decision, **append the pin to the charter**, proceed.
*This is the accretion loop* — the answer to "I cannot enumerate future variables". The
charter grows from real features rather than from guessing.

**`TRIPPED`** — an acceptance criterion matches a pin's `Falsifier`. **This is the DuckDB
moment.** Stop and present:

- which criterion tripped which pin;
- the reversal cost **as previously declared** — not a fresh estimate;
- **whether the `Hedge` actually exists in the code.** If S3 was `PROVISIONAL` with a
  repository hedge and the repository is there, the swap is cheap and the guard says so.
  If the hedge was skipped, it presents the honest bill. This is the moment of truth for
  the entire §3.4 `Hedge` mechanism — declaring `PROVISIONAL` is not enough, the hedge has
  to have been built;
- two paths: **amend the pin**, or **change the feature** (narrow the criterion so it does
  not trip).

There is never a silent continue.

### 8.3 Amendment

Amending a pin does **not** go through CI — Principle 4, productivity first. This is
deliberately unlike the North Star `amendment-gate`, which protects product governance.

The superseded pin stays in the charter marked `SUPERSEDED` with date, reason, and what
tripped it. History lives in one file; no ADR directory is introduced (see §11).

## 9. Reuse of existing machinery

Most of the enforcement is free:

| Need | Existing mechanism |
| ---- | ------------------ |
| Stance `Injects` become coverage rows | `/distill` step 1 already reads `base/patterns/*.md` and injects `[given]`. It additionally reads stance pins. |
| `Guard` checks run | They are tests in the suite; `/verify` already picks them up. |
| Charter health | `wow-report` already aggregates the retro ledger. Two cheap signals: **pins that tripped** (the charter worked) vs **decisions that bit with no pin** (charter gap). Without these there is no way to know whether this mechanism earns its keep. |
| Fail-closed gate precedent | `/distill`'s `MEAS-GATE`. |
| Grilling idiom | `/distill` step 3. |

## 10. Location

`memory/stack/` — a new store, holding the project charter.

Rejected alternatives:

- **`memory/north-star/`** — that store is the product *why*, and its CI `amendment-gate`
  guards `pillars`/`scope`. Mixing technical decisions in muddies both.
- **A section inside `constitution.md`** — tempting, because `extends: base` already models
  inheritance and it avoids a third store. Rejected because it mixes stable rules with
  facts that churn (`Confidence`, `SUPERSEDED`), and because it grows the file that
  `/distill`, `/plan`, `/contract` and `/tasks` all read on every run.

The accepted cost: `memory/` goes from two stores to three, and `vendor.sh` gains surface.
The offsetting benefit is that `/plan` reads one focused file, and the dead `## Stack` stub
in `CLAUDE.md` finally gets a real destination — it becomes a pointer to the charter.

Layout:

```
memory/stack/
  stack.md          # the charter: S0 + S1..Sn + exposure header + SUPERSEDED history
  base/
    pin-template.md # canonical pin form + field semantics
    README.md       # inclusion test, hedge admission test, the two pin kinds
```

### 10.1 Surface touched

For scoping the implementation plan — v1 is one feature, not a program:

| Artifact | Change |
| -------- | ------ |
| `memory/stack/` | New: `stack.md`, `base/pin-template.md`, `base/README.md`. |
| `.claude/commands/stack.md` + `.claude/skills/stack/SKILL.md` | New: the §7.2 elicitation procedure. |
| `.claude/commands/plan.md` | Add the fail-closed guard (§8.2) with its three verdicts. |
| `.claude/skills/distill/SKILL.md` | Step 1 additionally reads stance pins and injects their `Injects` rows. |
| `scripts/vendor.sh` | `memory/stack/base/` as KEEP; `memory/stack/stack.md` as SEED stub. |
| `CLAUDE.md` / stub in `vendor.sh` | `## Stack` becomes a pointer to the charter instead of a dead blank. |
| `docs/workflow.md` | Insert `/stack` in the documented loop. |
| `.claude/skills/wow-report/SKILL.md` | Two charter-health signals (§9). |

## 11. Deferred (explicitly not in v1)

- **The portable profile layer.** Conceptually the design is two layers — portable
  defaults that seed, project pins that bind. v1 ships only the charter, which carries
  nearly all the value. The `Draft` step still proposes sensible defaults from the model's
  own knowledge; it just does not yet know *this maintainer's* idiosyncrasies. The profile
  is added when there is evidence of repeated answers across repos. The design leaves the
  slot open.
- **Stack ADR directory.** Superseded pins stay inline in `stack.md`. Split only if it
  becomes unwieldy.
- **CI gate on pin amendment.** Principle 4.
- **Enumerated compatibility matrix.** Explicitly rejected, §2.

## 12. Decisions log for this design

| # | Decision | Rationale |
| - | -------- | --------- |
| 1 | Opinions live in an opt-in layer, not in `base/` | "Use uv" and "Verifiability" are different categories; `base/` stays universal so the harness stays a template. |
| 2 | Two conceptual layers: profile seeds, charter binds | Mirrors the `base/` + `constitution.md` idiom the harness already uses. |
| 3 | Init pinning **plus** a per-feature guard | The DuckDB case does not break at init; it breaks when "N concurrent writers" enters `acceptance.md`. |
| 4 | Coherence judged by the model, not a matrix | Matrices age and cannot cover the future; the harness supplies the forcing function, the model supplies judgement. |
| 5 | S0 scales **scope**, not rules | Keeps the constitution's non-negotiables actually non-negotiable. |
| 6 | Charter in `memory/stack/` | Separates lifecycles; keeps hot-path files lean. |
| 7 | Profile deferred to v2 | Ship the part that solves the real problem. |
