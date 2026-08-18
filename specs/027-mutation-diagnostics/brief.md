# Brief — A mutation that matched nothing is reported as one that failed to break anything

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

`scripts/mutate.sh run` reports four outcomes. Two of them are each doing the work of two:

| reported | actually happened |
|---|---|
| `survived its own mutation` | the criterion is weak · **or the edit matched nothing and the criterion was never tested** |
| `emitted no result` | the check is broken · **or its files never reached the sandbox** |

The second reading in each row is a *stale* declaration, not a weak one, and the difference decides
what to fix: a weak mutation means the criterion needs a better negative; a stale one means the
declaration is pointing at code that moved or never existed.

This makes them separate outcomes.

## Why / motivation

**Three backlog items are the same defect seen from three sides.**

`B21` — measured across three features: **022, 4 of 5 weak mutations were anchor errors · 023, 1 of
3 · 026, 7 of 9.** 026's seven were one mistake repeated: the logic lives in an `awk` program
embedded in shell and the edits anchored on shell syntax. Every one printed `survived its own
mutation`, which says the criterion is weak. None of those criteria was weak.

`B22` — 026 moved column resolution into `scripts/lib/matrix.sh` and **four declarations belonging to
022 and 023 were left editing code that no longer existed.** `sed` matched nothing, the criteria kept
passing, and four previously-proved criteria became unfalsifiable without any of them changing a
line. This is 021's finding with the implementation moving instead of the criterion — and **CI
caught it, not the author.**

`B17` — twice now (020 and 022) a run reported `emitted no result` for every declaration in a new
check file, because the file and its fixtures were untracked and `git ls-files` never handed them to
the sandbox. The verdict was right and the diagnosis was wrong, which is the more dangerous of the
two — it reads as a broken check.

**Together that is 12 misdiagnoses across four features**, every one of them costing a cycle of
reading the wrong thing.

**Measured, so the cost is known before the design:** a content hash of the 364-file sandbox takes
**0.018s**. Two per mutation across 88 declarations adds ~3.2s to a 147s run — about **2%**.

## Success metrics

- **An edit that changes no bytes is its own outcome**, named as stale, and never reported as a
  criterion surviving.
- **Untracked files under `--tests` stop the run before it starts**, named, rather than producing a
  file's worth of wrong diagnoses.
- **Stale still counts as not proved.** This is a change of diagnosis, not of verdict — a criterion
  whose declaration matched nothing has not been shown to fail.
- **The counts are separate** in the summary, so *weak* and *stale* are never added together. 021
  established that mixing the two is how an audit becomes a rubber stamp.
- **The replay is real:** 026's actual stale declaration, in the form it shipped, reports stale.
- **Green, hermetic**, and the added cost measured against the 2% predicted here.

## Out of scope

- **Fixing stale declarations automatically.** Guessing where code moved to is a different and much
  worse idea.
- **Detecting a weak mutation that does change bytes.** An edit that flips an unreachable line
  changes bytes and proves nothing; that stays a judgement call at `/verify`.
- **`sed -i.bak` leaving backups in the sandbox.** They are excluded from the hash because the
  sandbox is thrown away; tidying them is not this feature's business.

## Dependency

`scripts/mutate.sh` (020, 022) and its declaration grammar.

**`D3` applies** — the tool audits this repository's own workflow. **`D4` applies:** this changes a
gate's exit contract, so it must be run against itself with a real verdict.

**Stated in advance:** this fixes no criterion and moves no coverage number. It changes what the
runner *says* when something is already wrong. The measurable claim is that the next stale
declaration is diagnosed as stale on the first read — and that cannot be shown by this feature,
only by the next one.
