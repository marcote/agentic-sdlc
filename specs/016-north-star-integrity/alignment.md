# Alignment — 016-north-star-integrity

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md` **as amended by
ADR `0004`**. Run deterministically by the 006 engine: `schema-valid` → exit 0; `scope-reject` per
objective → exit 1 for all five; `align-verdict` → `aligned`.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
Falsification run: any dimension at 2 returns `needs-amendment`, so the verdict is not an
aggregator artifact.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | O1/O2 land on `real-enforcement` — *"gates block closure when a condition is missing"* is exactly a validator refusing an unfilled North Star — and on `frictionless-adoption`, since the from-zero path is where the defect bites. O3/O4/O5 land on `measurable-impact`: the align↔retro ledger is the harness's measurement loop, and provenance is what makes a deferred prediction judgeable later. Held at 4 by O4: stamping provenance into `alignment.md` improves the *legibility* of a measurement rather than the measurement itself, which is a step of inference. |
| scope compliance | **5** | The highest any brief has scored here, and it is not generosity. Both halves are **removals of ambiguity in an existing contract**, not new opinions: `schema-valid` already refuses malformed input and this adds *unfilled*; pillars already have `id`/`statement`/`signal` and this adds which ADR last touched them. No tool, language, runtime or vendor is named. The `out_of_scope` predicate closest to the edge — *"stack-specific deterministic engine (provided by the adopter)"* — is respected by design: the schema is the contract, the engine is the reference implementation, and the brief says so. |
| mission advancement | 4 | O1/O2 are directly observable: the seeded stub either validates or it does not, measurable in one command against a real vendored target. O3/O5 likewise — the gate either rejects a stale provenance or it does not. Held at 4 rather than 5 by O4, whose payoff is deferred: provenance stamping only pays when a `pending-observation` is swept against a signal that moved, and the first such sweep is **2026-09-08**. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — `schema-valid` refuses an unfilled North Star with an exit distinct from malformed; `/align` names the seeded fields | `real-enforcement`, `frictionless-adoption` |
| O2 — a real North Star about to-do lists is not a false positive; the discriminator is the stub's own form | `real-enforcement`, `agnostic-portability` |
| O3 — every pillar records the ADR that last changed its `statement`/`signal`; the harness's own are mapped | `measurable-impact` |
| O4 — `/align` stamps provenance into `alignment.md` so a retro can tell whether the signal moved under its prediction | `measurable-impact` |
| O5 — the amendment gate rejects a governed change with stale provenance; provenance alone is not an amendment | `real-enforcement`, `measurable-impact` |

## Pillar provenance (stamped by `/align`, R6)

The ADR each mapped pillar's `statement`/`signal` last came from, at the moment this brief was
scored. A later `/retro` reads this to tell whether the signal moved **underneath** the prediction
it is closing — without it, a `pending-observation` deferred for a month is judged against whatever
the signal says then, with nothing recording that it changed.

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `agnostic-portability` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |

**This feature is scored under `frictionless-adoption` as amended by `0004`**, three days old and
still unproven — 014's retro recorded that its discriminating half has never fired. Stamped rather
than asserted: if it fires before this feature's own sweep, the record exists.

## Orphans

None.

## Pillars deliberately NOT claimed

- **`agnostic-portability` is claimed only by O2**, and narrowly: the false-positive rule is what
  keeps the check working on an arbitrary product domain. The rest of the feature changes a schema
  every adopter inherits, which is portability-neutral, not portability-advancing.

## Gate note

Three things this gate flags for the feature to carry forward:

1. **The false-positive rule is the whole risk of half A.** A product whose domain *is* to-do lists,
   task tracking or placeholders will contain the word `TODO` legitimately in `in_scope` /
   `out_of_scope`. If the discriminator is the bare word, this feature ships a validator that
   refuses a valid North Star — worse than the defect it fixes, because it blocks real work.
   `/uat` must test that case explicitly, not the happy path.

2. **This changes what "valid" means for every existing adopter.** The migration must be one field
   per pillar and no more, and the harness's own North Star must be migrated *inside* this feature
   (`D3`). If migration turns out to need more than that, the brief's scope claim is wrong and the
   honest move is to narrow, not to widen quietly.

3. **The falsification test, set before the result is known.** *Does the provenance stamp ever
   change a verdict, or is it decoration that reads well?* It pays only if a `pending-observation`
   is later swept against a signal that moved. The first sweep is **2026-09-08**, after this feature
   closes. **`measurable-impact` therefore cannot be `✅` at `/retro` on the strength of half B** —
   `⏳ pending-observation` is the honest verdict for it, and claiming otherwise would be exactly
   the laundering 014's retro refused.
