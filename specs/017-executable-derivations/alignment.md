# Alignment — 017-executable-derivations

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0004`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all five objectives; `align-verdict`
`aligned`.

## Verdict

**`aligned`** — `{pillarFit: 5, scopeCompliance: 5, missionAdvancement: 4}`, threshold 3.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 5 | The first 5 this dimension has taken. `real-enforcement`'s signal reads "gates block closure when a condition is missing, and the harness proves it by dogfooding itself". A number that disagrees with its own command is a missing condition, and running the check over every closed retro is the dogfood clause. `measurable-impact` is equally direct: the align↔retro ledger is the measurement loop, and this makes its numbers reproducible. No objective needs a step of inference. |
| scope compliance | 5 | Nothing is named, prescribed or imposed. The change is one field format in a template the adopter already owns, plus a check over it. The nearest `out_of_scope` predicate — "stack-specific deterministic engine" — is untouched: this is a shell command the author writes, not an engine the harness ships. |
| mission advancement | 4 | Held below 5 deliberately. The mechanism is directly observable and already produced a finding before the feature existed: 013's claimed 8 yields 10 by command. But the *reach* is one field family in one artifact. Plans, alignments and reports carry numbers too, and widening is explicitly out of scope pending evidence. A 4 predicts a real but bounded gain. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — a numeric Face B claim carries an executable derivation and the suite runs it | `real-enforcement`, `measurable-impact` |
| O2 — a number disagreeing with its command fails, naming field, claim and output | `real-enforcement` |
| O3 — the check runs over every closed retro; what it flags is fixed or explained | `real-enforcement`, `measurable-impact` |
| O4 — a non-numeric derivation stays prose, because a commit trail is not a count | `frictionless-adoption` |
| O5 — the command surface is bounded and stated | `agnostic-portability`, `frictionless-adoption` |

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `agnostic-portability` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |

## Orphans

None.

## Gate note

Four things this gate flags.

1. **This executes commands read from a markdown file.** That is a real surface and the brief must
   not wave it away. The precedent is the charter's `Guard` field, which the harness already runs
   by name from `stack.md`. `/uat` must confirm the scope is bounded to the repository's own
   retros, and that the boundary is stated where a reader will find it.

2. **A closed feature's retro can go red later.** If a spec is edited after close, its count no
   longer reproduces. That is correct behaviour and it will feel like a regression. `/retro` must
   say so plainly rather than let the first occurrence look like a defect.

3. **`O4` is the anti-filler clause and is easy to lose.** Forcing a git trail into a command would
   be filler-to-comply — the exact failure the WoW rejects elsewhere. If implementation ends up
   converting non-numeric derivations, the feature has drifted.

4. **The falsification test, set before the result is known.** *Does the check find a number that
   no human noticed?* 013 is already known to yield 10 against a claimed 8, so **013 does not
   count** — it motivated the feature. The test is whether a **second, unknown** disagreement
   appears across the other closed retros. If none does, `measurable-impact` is `⏳`, not `✅`.
