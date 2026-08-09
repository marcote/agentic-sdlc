# Pin template (base)

The canonical form of a **pin** — one load-bearing decision, recorded with its price and its
own invalidation condition. This file defines the grammar the deterministic engine parses and
the semantics a human reads. See `README.md` for *which* decisions qualify.

## Grammar

A pin is a level-3 heading, a kind tag, and a list of fields:

```markdown
### S<n> — <short title>                    [stance|substrate]
- Confidence: PINNED | PROVISIONAL — <one-line gloss>
- Because:    <the fact about the world that produced this>
- Buys:       <what the decision gains>
- Forecloses: <what the decision closes off — the price>
- Falsifier:  <the evidence that would overturn this pin>
```

Pin ids are stable and never reused. Ordering is document order; `S0` is always first.

## Fields

| Field | Required on | Meaning |
| ----- | ----------- | ------- |
| `Confidence` | every pin | `PINNED` (decided) or `PROVISIONAL` (declared uncertainty — *"don't know, but this way"*). |
| `Because` | every pin | The domain fact behind the decision, not a preference. If you cannot state one, you are recording taste, not a pin. |
| `Buys` | every pin | What the decision gains. |
| `Forecloses` | every pin | **The price.** The expensive surprise is never the decision — it is the cost nobody stated. A block without this is not a pin. |
| `Falsifier` | every pin | What evidence would overturn it, declared *in advance*. This is what lets the gate ask a mechanical question — *does this new acceptance criterion match a declared falsifier?* — instead of re-arguing the whole set every feature. |
| `Hedge` | `PROVISIONAL` only | The cheap escape that declared uncertainty must buy. Emitted as a `[given]` coverage row, so it is verified rather than merely written. **A `PROVISIONAL` pin without a `Hedge` is a lie.** |
| `Guard` | required on `[stance]`, optional on `[substrate]` | An executable command asserting the pin still holds. The harness runs it by name and requires exit 0; it never inspects what the command checks. **Any pin kind may declare one** — whether a pin injects a per-feature coverage row is a separate question from whether it can be checked. A substrate choice is often the easier of the two to check mechanically. |
| `Injects` | `[stance]` only | The `[given]` row(s) added to each applicable feature's coverage matrix. Rejected on `[substrate]`: a substrate choice is a constraint on the plan, not a per-feature observable. |
| `Answers` | optional, any pin | The ground rule id(s) this pin settles — `Answers: GR2, GR4`. Optional: not every pin answers one. An id outside the effective set is **rejected**, never ignored; silently dropping a typo would report the real rule as uncovered while the author believes it is answered. A `SUPERSEDED` pin's claim does not count. |
| `Superseded` | amended pins | `<date> — <reason>`, including what tripped the pin. History stays inline; the pin keeps its id and gains a `SUPERSEDED` marker on its heading. |

## The two kinds

**`[substrate]`** — what the work runs on. Constrains the technical plan and produces no
acceptance criterion, because a substrate choice is a constraint rather than an observable
behaviour. It **may** still carry a `Guard`, and often should: a choice of toolchain or version
is usually a one-line check.

**`[stance]`** — the shape of the seam; it defines what *done* means. **Requires** both a
`Guard` and an `Injects`, so it is enforced rather than aspirational. A stance written only in
prose degrades: by the seventh feature something violates it and nobody notices.

The two kinds differ in whether they inject coverage rows — **not** in whether they can be
enforced. Tying `Guard` to the kind was this template's original error: it let a substrate pin
declare a check that validated cleanly and was then never executed.

## Declining a ground rule

A ground rule that genuinely does not apply is **declined**, not answered:

```markdown
### GR2 — n/a
- Because:   a pure transformation; nothing outlives the process and nothing is written
- Falsifier: any output is retained between runs, including a cache
```

A declination is **not a pin**. No decision was taken, so there is nothing to price — no `Buys`
and no `Forecloses`, and inventing empty ones would be filler-to-comply. Its `Falsifier` is what
makes it **expire**: the decline stops being valid the moment the project crosses the stated
line, instead of silently outliving the conditions that justified it.

## Worked examples

A substrate pin under declared uncertainty, paying a hedge:

```markdown
### S3 — Datastore: DuckDB                              [substrate]
- Confidence: PROVISIONAL — leaning this way
- Because:    one process writes today; the workload is analytical
- Buys:       zero infra, embedded, fast scans
- Forecloses: multi-process concurrent writes
- Falsifier:  more than one concurrent writer, or a multi-instance deploy
- Hedge:      data access behind a repository interface; no raw SQL outside it
```

A stance pin with teeth:

```markdown
### S1 — Data-driven core, presentation at the edge      [stance]
- Confidence: PINNED
- Because:    today's consumer is a terminal; HTTP and notebook consumers are plausible
- Buys:       adding a transport means writing an adapter, not rewriting the core
- Forecloses: "free" incremental streaming — it must be designed explicitly
- Falsifier:  the core is contractually pinned to exactly one consumer
- Guard:      scripts/guards/no-stdout-in-core.sh
- Injects:    [given] every core capability returns structured data; the terminal
              consumes it like any other adapter
```

An amended pin, keeping its history inline:

```markdown
### S3 — Datastore: PostgreSQL 16                        [substrate] SUPERSEDED
- Confidence: PINNED
- Because:    AC-04 requires N concurrent writers
- Buys:       networked concurrency, mature operational tooling
- Forecloses: zero-infra local execution
- Falsifier:  the workload returns to a single writer with no network consumer
- Superseded: 2026-09-14 — tripped by AC-04 (three concurrent workers); the S3 hedge
              (repository interface) was in place, so the swap touched one module
```

## Two failure modes the grammar cannot catch

- **A vacuous `Guard`.** A command that inspects a path which does not exist exits 0 forever.
  Prove every `Guard` against a violating fixture as well as a clean tree, or it certifies
  nothing.
- **A `Falsifier` nobody could observe.** *"If this turns out to be wrong"* is not a falsifier.
  Write the condition an acceptance criterion could plausibly state.
- **A `Guard` that is accepted and then never run.** Worse than a vacuous check, because
  nothing looks wrong: validation passes and the author believes the pin is enforced. Confirm a
  new `Guard` actually appears in the emitted guard list before trusting it.
