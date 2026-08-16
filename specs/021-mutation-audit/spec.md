# Spec — Re-run the mutation tables that read as evidence and cannot be reproduced

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- 26 `[mut$ … $]` declarations across `check_98`, `check_80` and `check_95` — every criterion of
  018 and 019, including the seven that never had one.
- `scripts/mutate.sh` — a multi-label criterion header is rejected by name instead of skipped.
- `tests/check_98_adoption.sh` — two self-scanning criteria stop detecting their own declaration.
- `memory/constitution/base/patterns/non-vacuous-checks.md` — the self-scan rule extended.
- The two audited verification reports, corrected in place.

## The measurement, taken during the grilling

**Validity — 18 of 19 recorded mutations reproduce.**

The one that does not is 019's M7 (*"a pillar `statement` moved without its `since`"* →
`AMEND-PROVENANCE-QUIET`). **It was valid when it was run.** At `babac0a` the criterion read the
previous North Star with `git show main:…`, so a mutated working tree really did differ from the
`old` side. CI then rejected that ref-dependence, and 019's own fix reconstructs `old` **from**
`new` — after which the same edit appears on both sides and no pillar moves between them.

So the mutation did not decay because it was weak. **The criterion changed underneath it**, and a
table written in prose cannot notice that. This is the argument for executable declarations, made
by the one case that failed.

**Coverage — 018 recorded 11 mutations against 16 criteria.**

Seven had none: `ADOPT-FIXTURE-DROP`, `ADOPT-VENDOR-APPLY`, `ADOPT-GUARD-CLEAN`,
`ADOPT-NO-SILENT-EMPTY`, `ADOPT-UNCOVERED-FIRES`, `S2-HEDGE-98`, `HERMETIC-ENV-98`. 019's 8
mutations cover its 8 criteria completely.

**The prediction was wrong, in the good direction.** `alignment.md` predicted 7 or 8 failures from
020's 6-of-14 rate. The actual figure is **1 of 19**. 020's rate was an artifact of its own
circumstances: those mutations were written against a tool that was still being built, so the
target moved under them. 018's and 019's were written against finished checks and were genuinely
run at the time.

## Two defects in 020, found by using it

### G-a — A multi-label criterion header is invisible to the runner

`check_98` carried one header naming two criteria:

```
# --- ADOPT-TESTCMD-INVOKED · ADOPT-TESTCMD-NOT-COUNTED: the seam, never the verdict ---
```

`nvc.sh` reads both labels. `mutate.sh criteria` reads **neither**, so both were silently absent
from the coverage count and neither could carry a mutation. Silent omission, which is the family
this whole line of work exists to close.

**Resolved:** the header is split into two, and `mutate.sh` now **rejects** a multi-label header by
name rather than skipping it. A declaration binds to one criterion; a header naming several is
genuinely unbindable, and the honest response is to say so.

### G-b — A self-scanning criterion detects its own declaration

A `[mut$ … $]` declaration is a comment line **inside the file it mutates**. Two criteria in
`check_98` scan that file for a literal:

- `ADOPT-GUARD-BY-NAME` — no fixture guard name may appear in the check.
- `HERMETIC-ENV-98` — no terminal reference may appear in the check.

Both went red the moment their declarations were written, because the declarations contain exactly
those literals. **Neither criterion was wrong; the scans were reading scaffolding as code.**

**Resolved:** both strip comment lines before scanning, which `check_99`'s equivalent already did.
The rule generalises and goes into the pattern file: *a scan over its own file excludes comment
lines, because a mutation declaration lives in one.*

## Resolved at grilling (2 more)

### G-c — A survivor is diagnosed, never silently re-mutated

Two mutations survived the first run. Both were **weak mutations**, not vacuous criteria, and each
was diagnosed before being rewritten:

| Criterion | Why it survived |
|---|---|
| `ADOPT-GUARD-CLEAN` | the edit appended `exit 1` **after** the guard's own `exit $bad` — unreachable |
| `AMEND-PROVENANCE-QUIET` | the edit moved a pillar statement, but `old` is reconstructed **from** `new`, so it moved on both sides |

The counts are reported separately: **0 criteria found vacuous, 2 mutations found weak.** Reaching
for "the mutation was too weak" without stating why is how this audit becomes a rubber stamp.

### G-d — The audit fixes criteria, not features

A survivor is a defect in the feature that shipped it. Both 018 and 019 stay closed; their reports
are corrected in place, the way 015 recorded nine untraceable criteria against `check_95` without
reopening 004.

## Requirements

### R1 — Every criterion of 018 and 019 declares a mutation
26 declarations: 18 in `check_98` (16 criteria plus the two freed by splitting the combined
header), 6 in `check_80`, 2 in `check_95`.

### R2 — A multi-label criterion header is rejected by name
`mutate.sh` reports it with file and line and exits 2. Skipping it is what hid two criteria.

### R3 — A self-scanning criterion excludes comment lines
So a mutation declaration cannot be read as the defect the scan looks for. Applied to the two
criteria that broke, and written into the pattern adopters inherit.

### R4 — Every declared mutation breaks its criterion
`mutate.sh run --tests tests` exits 0. This is the audit's result, kept live rather than recorded
once.

### R5 — The two reports are corrected in place
Each gains what the audit found: the coverage gap, the one mutation that no longer reproduces, and
why.

### R6 — The added cost is measured
14 declarations cost 13.02s. The audited set is 40 and the number is reported, not estimated.

## Edge cases (`/distill` expansion — 6)

1. **A mutation that was valid decays when its criterion changes.** The only failure found, and the
   reason prose could not carry this. → `spec.md` above.
2. **A declaration is itself the literal a self-scan forbids.** → G-b, R3.
3. **A header naming two criteria.** → G-a, R2.
4. **A survivor treated as a weak mutation without diagnosis.** → G-c, two counts reported.
5. **A weak mutation that is unreachable rather than wrong** (`exit 1` after `exit`). → G-c.
6. **Cost growth.** 40 mutations take 54.04s at `/verify` and in CI, not in the suite. → R6.

## Non-goals

Auditing every check file; reopening 018 or 019; deciding who must declare (`B15`); replacing the
by-hand exploration at `/verify`.
