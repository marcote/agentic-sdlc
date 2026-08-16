# Technical plan — 021-mutation-audit

> HOW it is built. Produced by `/plan`, behind the fail-closed stack-charter gate.

## Stack gate

```
$ python3 scripts/stack/engine.py ground-rules memory/stack/stack.md   # exit 0, all six covered
$ python3 scripts/stack/engine.py pin-valid    memory/stack/stack.md   # exit 0
```

**Verdict: `PASS`.** Ten pins, every ground rule answered. This feature adds comment lines to three
check files and two diagnostics to a shell tool. It takes no load-bearing technical decision.

### Criteria read against each declared `Falsifier`

| Pin | Reading |
|---|---|
| `S3` | 26 declarations are `sed`, `rm`, `printf` and `python3 -c`. No toolchain. Not tripped. |
| `S7` | Every assertion is about this repository's own machinery. Not tripped. |
| `S8` | R2 makes a multi-label header **abort with a named diagnostic** rather than continue on a partial reading. That is this pin, applied. |
| `S2`, `S4`, `S5`, `S6`, `S9` | Untouched. |

## Technical decisions

**D1 — A survivor is diagnosed before it is re-mutated, and the two counts stay separate.**
*Criteria found vacuous* and *mutations found weak* are different findings. The first run produced
0 and 2; conflating them would let any audit end clean by rewriting edits until they bite.

**D2 — The combined header is split, and the runner rejects the shape.** Splitting alone fixes
today; rejecting stops it recurring silently. `nvc.sh` reads both labels of such a header, so the
two tools disagreed and only one said so.

**D3 — Self-scanning criteria strip comment lines, they do not special-case `[mut$`.** A narrower
rule would leave the next comment-shaped false positive to be discovered. `check_99` already scans
this way; this makes three criteria consistent.

**D4 — The reports are corrected in place, with an audit section appended.** Not rewritten: the
original text is what was believed at the time, and the correction is the finding. Same treatment
015 gave `check_95`.

**D5 — The audited set runs at `/verify` and in CI, never in `tests/run.sh`.** Unchanged from 020,
and now it matters more: 40 declarations cost **54.04s**, against 13.02s for 14.

## Components / modules

| Unit | Responsibility | Interface |
|---|---|---|
| 26 `[mut$ … $]` declarations | the audited set, kept live | read by `mutate.sh` |
| `scripts/mutate.sh` | reject a multi-label header by name | exit 2 + diagnostic |
| `check_98` two scans | strip comments before matching | `_pass` / `_fail` |
| `base/patterns/non-vacuous-checks.md` | the self-scan rule, extended | prose adopters inherit |
| the two reports | corrected in place | markdown |

## Risks

**The audit becomes a rubber stamp.** The failure mode is rewriting a surviving mutation until it
bites without asking why it survived. `D1` and `AUDIT-ALL-PROVED`'s paired diagnosis are the
mitigation; `/uat` checks that both counts are reported.

**Cost.** 54s per `/verify` and per CI run, growing with every declaration. Visible on every run by
`AUDIT-COST-REPORTED` rather than discovered later. `B7` is the standing item.

**A declaration rots against a changing criterion.** This is the one real failure the audit found,
and it cannot be prevented — only detected. Detection is now continuous, which is the whole point.

## Gate bootstrap (`D4`)

Not applicable. The gate shipped in 020. `D3` (reflexive dogfood) applies: the tool is run against
closed features of this repository's own workflow, which is what it exists for.
