# Eval case — stack-charter-judge

> Non-deterministic criteria: **JUDGE-TRIPPED**, **JUDGE-COHERENCE**, **JUDGE-HEDGE-COST**
> (`specs/013-stack-charter/acceptance.md`). Scored manually (or by an LLM judge) per
> `evals/README.md`. State: 📋 case.
>
> These cover the three judgments the stack charter delegates to the model rather than to a
> script, following the `/align` split: the deterministic parts (field completeness,
> `PROVISIONAL`⇒`Hedge`, `[stance]`⇒`Guard`) live in `scripts/stack/engine.py` and are unit
> tested by `tests/check_92_stack.sh`; the semantic parts live here.
>
> The charters below are **illustrative**. An adopting repo runs the same shapes against its
> own charter and its own stack.

## What is being judged

1. Whether a feature's acceptance criterion **trips a declared `Falsifier`** (`/plan` → `TRIPPED`).
2. Whether a **set** of pins coheres, judged as a set rather than pin by pin (`/stack` step 5).
3. Whether a proposed `Hedge` passes the **admission test** — a hedge must cost ~nothing now.

---

## Case 1 — JUDGE-TRIPPED fires on a real match

**Charter (input, illustrative):**
```
### S3 — Datastore: embedded single-writer store        [substrate]
- Confidence: PROVISIONAL
- Because:    one process writes today; the workload is analytical
- Buys:       zero infra, fast scans
- Forecloses: multi-process concurrent writes
- Falsifier:  more than one concurrent writer, or a multi-instance deploy
- Hedge:      data access behind a repository interface
```

**Acceptance criterion (input):**
> "Given three worker processes running in parallel, when each records a completed job,
> then all three writes are durable and no record is lost."

**Expected judge behavior:**
- Verdict **`TRIPPED`**, citing S3 and its `Falsifier` (more than one concurrent writer).
- Reports the reversal cost **as S3 declared it**, not a fresh estimate.
- Reports **whether the `Hedge` exists in the code** — a repository interface actually present,
  or absent, with the honest bill either way.
- Offers exactly two paths: amend S3, or narrow the criterion.

**FAIL if:** the judge continues silently, re-estimates the cost instead of quoting the
declared one, or omits the hedge-exists check — that check is the entire point of having paid
for a `PROVISIONAL` pin.

## Case 2 — JUDGE-TRIPPED does NOT fire on keyword overlap

**Charter:** same S3 as Case 1.

**Acceptance criterion (input):**
> "Given the datastore is unreachable, when a query is issued, then the CLI exits non-zero with
> a readable error rather than a stack trace."

**Expected judge behavior:**
- Verdict **`PASS`** with respect to S3. The criterion *mentions the datastore* but places no
  concurrent writer and no multi-instance deploy against it — S3's `Falsifier` is untouched.

**FAIL if:** the judge returns `TRIPPED` on topical overlap. A false `TRIPPED` is not a
conservative error: a gate that cries wolf gets routed around, which is worse than no gate.
False positives and misses are weighted equally here.

## Case 3 — JUDGE-COHERENCE objects to an incoherent set

**Charter (input, illustrative):**
```
### S1 — API-first: every capability exposed over HTTP before any UI   [stance]
### S2 — Implementation language: a low-level assembly language        [substrate]
### S4 — Ship the first public endpoint within two weeks               [substrate]
```

**Expected judge behavior:**
- Raises an **explicit objection on the set**, not on any single pin: each is individually
  defensible, and the incoherence lives only in the combination (API-first delivery pace
  against a language with no practical HTTP ecosystem).
- Names which pins conflict and why, and asks which one gives.

**FAIL if:** the judge validates each pin in isolation and returns no objection, or objects
vaguely without naming the conflicting pair. The forcing function is that the model must
**pronounce on the set**.

## Case 4 — JUDGE-COHERENCE stays explicit on a sound set

**Charter (input):** a coherent set — a mainstream managed runtime, a networked relational
store, API-first, deployed to a managed host.

**Expected judge behavior:** returns an **explicit "coherent"** verdict naming what it checked.

**FAIL if:** the judge returns silence or an empty response. Silence is indistinguishable from
"did not evaluate", and an unfalsifiable pass is theater.

## Case 5 — JUDGE-HEDGE-COST rejects premature abstraction

**Input:**
> `S0` rigor tier is **scratch** (runs on the author's laptop, single user, no secrets, fully
> re-runnable). A `PROVISIONAL` pin on the output format proposes this hedge: *"introduce a
> full ports-and-adapters layer with a plugin registry so any future output format can be
> added without touching the core."*

**Expected judge behavior:**
- **Rejects** the hedge under the admission test: it costs real design work now, so it is
  premature abstraction rather than a hedge.
- Offers the two honest alternatives: pin firmly and accept the declared reversal cost (cheap
  at this tier — the artifact is disposable), or resolve the uncertainty before proceeding.

**FAIL if:** the judge accepts the hedge because the uncertainty is genuine. The uncertainty
being real is not the test; the **cost of the hedge** is. A judge that accepts every hedge
turns the mechanism into the problem it was designed to prevent.

## Case 6 — JUDGE-HEDGE-COST accepts a free hedge

**Input:**
> `S0` is **product** (deployed, multi-user, handles third-party data). A `PROVISIONAL` pin on
> the datastore proposes: *"return values from the query layer instead of printing them, so the
> caller decides presentation."*

**Expected judge behavior:** **accepts** — the hedge costs ~nothing today and its absence would
cost a rewrite, which is the asymmetry the charter exists to capture.

**FAIL if:** the judge rejects it as over-engineering. Applying the admission test as a blanket
"never hedge" is the mirror failure of Case 5, and it loses exactly the highest-value pins.
