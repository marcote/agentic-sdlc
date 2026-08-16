# Technical plan — 019-lifecycle-boundary

> HOW it is built. Produced by `/plan`, behind the fail-closed stack-charter gate.

## Stack gate

```
$ python3 scripts/stack/engine.py ground-rules memory/stack/stack.md   # exit 0, all six covered
$ python3 scripts/stack/engine.py pin-valid    memory/stack/stack.md   # exit 0
```

**Verdict: `PASS`.** Ten pins, every ground rule answered, and this feature takes no load-bearing
technical decision that is not already pinned. It edits a governed JSON block and adds assertions
to two existing check files.

### Criteria read against each declared `Falsifier`

| Pin | Reading |
|---|---|
| `S1` | *"any artifact under `base/` stating an answer rather than a question."* The four predicates land in `north-star.md`, which is this repository's own product delta, not `base/`. `memory/north-star/base/` is untouched. Not tripped. |
| `S4` | The charter format is untouched; this is the North Star. Not tripped. |
| `S6` | The change is one markdown file in git, reviewed as a diff. This pin is the reason an amendment is a PR rather than an API call. Not tripped, and directly relied on. |
| `S2`, `S3` | No engine capability, no new command, no dependency. `scope-reject` and `schema-valid` are invoked exactly as documented. |
| `S7` | Every assertion is about this repository's own governance artifacts. Not tripped. |
| `S9` | The fixture is untouched. This feature never vendors. |

**No pin's `Falsifier` is approached.** Recorded rather than left to silence: `/plan` requires
exactly one verdict, and an unspoken pass is indistinguishable from not having looked.

## Technical decisions

**D1 — The corpus check reads `specs/*/brief.md`, not the `alignment.md` mapping tables.**
Measured: only 6 of 12 alignments carry `| On —` rows; the pre-013 ones predate that format. Every
brief but one has `## Success metrics` bullets, and that section is what `/align` step 2 actually
reads. Constrained by `S6` — the artifacts are the state, so the check reads them rather than a
derived index.

**D2 — The corpus asserts the count it scored, not only the hit count.** Edge case 4. A zero-hit
result and a run that read nothing are the same observation from outside, which is the vacuity
family `check_96` exists for. The check reports *N objectives scored, 0 hits*.

**D3 — The reflexive gate run uses `--files OLD NEW --added`, not `--range`.** The gate already
supports both; `--files` is the hermetic mode and needs no git history, which keeps
`HERMETIC-ENV-80` honest under a detached-HEAD CI checkout. `OLD` is the North Star as it stands on
`main`, extracted with `git show`, and `NEW` is the working tree.

**D4 — The suite command is injected as a stub in the reflexive run.** `--suite-cmd` exists for
this. Letting the gate shell out to the real `tests/run.sh` from inside `tests/run.sh` would nest
the suite a second time, and `docs/backlog.md` B7 already tracks the one nesting we have.

**D5 — The ADR is written before the North Star is edited.** Not ceremony: the gate's first
condition is that an ADR was *added* in the same change, and writing the diff first is how a
governance change becomes a commit that has to be retrofitted with its justification.

## Components / modules

| Unit | Responsibility | Interface |
|---|---|---|
| `memory/north-star/decisions/0005-lifecycle-boundary.md` | the recorded decision, four sections | read by the gate and by humans |
| `memory/north-star/north-star.md` | `out_of_scope` 5 → 9, nothing else | the canonical JSON block |
| `check_80` additions | predicates reachable, bounded, adoption clear, corpus clean, ADR complete | `_pass` / `_fail` |
| `check_95` additions | the gate blocks this diff without `0005`, passes with it; provenance stays quiet | `_pass` / `_fail` |

## Risks

**A predicate excludes the harness's own delivery.** The inward false positive, and the only way
this feature ships something worse than the gap it closes. Mitigated by `NS-ADOPTION-STAYS-IN-SCOPE`
and by the wording *"of the software being built"*, tested against three adoption objectives.

**The boundary rejects closed work.** Mitigated by the 101-objective corpus, already run during the
grilling at zero hits. It grows with the repository rather than freezing at today's count.

**`NS-BOUNDARY-BOUNDED` compares against a moving target.** It reads the previous North Star from
`git show origin/main:…`, which is unavailable in some checkouts. Falls back to asserting the
governed sets directly — `in_scope` has exactly its six known entries and one pillar per known id —
and says which mode it ran in rather than skipping silently.

**The gate passes for the wrong reason.** A reflexive run that never reaches the ADR condition
would be green against any implementation, which is exactly what `AMEND-PROV-ONLY` did in 016.
Mitigated by asserting **both** directions on the same diff: blocked without `0005`, passing with
it.

## Gate bootstrap (`D4`)

Not applicable. The gate this feature must satisfy shipped in feature 004. `D3` (reflexive
dogfood) applies and is the point of `AMEND-LIFECYCLE-REFLEXIVE`: the gate is run against this
feature's own diff, not against a fixture.
