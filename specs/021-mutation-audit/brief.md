# Brief — Re-run the mutation tables that read as evidence and cannot be reproduced

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Feature 018's verification report carries a table of **11 mutations**. Feature 019's carries **8**.
Each row is a sentence: *"a guard name hardcoded into the check"*, *"a predicate broadened"*. Each
claims the named criterion failed under it.

Neither table can be re-run. They were written as prose, not as commands.

Feature 020 shipped a runner for exactly this and, on its first real use, found that **6 of its own
14 mutations broke nothing**. Those were written the same week, by the same author, under the same
belief that they worked.

This re-declares 018's and 019's mutations as `[mut$ … $]`, runs them, and reports what survives.

## Why / motivation

**Two failure modes, and the second was invisible until measured.**

*Validity* — a mutation that does not break its criterion proves nothing, and the report says it
did. 020 measured that rate at **6 of 14** on freshly written mutations.

*Coverage* — measured while writing this brief: **018 recorded 11 mutations against 16 criteria.**
Seven criteria — `ADOPT-FIXTURE-DROP`, `ADOPT-VENDOR-APPLY`, `ADOPT-GUARD-CLEAN`,
`ADOPT-NO-SILENT-EMPTY`, `ADOPT-UNCOVERED-FIRES`, `S2-HEDGE-98`, `HERMETIC-ENV-98` — have no
recorded mutation at all. The report's §2 reads as though failability was established for the
feature; it was established for two thirds of it.

**Why this is not bookkeeping.** A mutation that survives means the criterion is vacuous, in a
feature that is closed, green, and cited by later work. That is the same shape 015 found when
`nvc.sh` first ran: **15 untraceable criteria in features that had been green for a month.** The
question is not whether the reports were written in good faith. It is whether green means what it
says.

**Why now.** The runner exists and costs about a second per mutation. Every week that passes adds
features that cite these two as precedent — 020's own falsification test replays criteria from both.

## Success metrics

- **Every criterion of 018 and 019 carries a declared mutation**, including the seven that never
  had one, so coverage is 100% for the audited set rather than 69%.
- **The measurement is reported as two numbers**: how many recorded mutations were valid, and how
  many criteria had none. Both are findings; neither is a failure to hide.
- **Every criterion that survives its mutation is fixed or explicitly justified.** A vacuous
  criterion found and left is worse than one never looked for, because now it is on the record.
- **The audited set is added to the `/verify` mutation run**, so it stays proved rather than being
  proved once by this feature.
- **018's and 019's reports are corrected in place**, with what the audit found. A report that
  overstated its evidence is amended, not quietly superseded.
- **The suite stays green and hermetic**, and the added cost is measured.

## Out of scope

- **Auditing every check file.** 512 assertions exist. `B16` names 018 and 019 because their tables
  are the ones presented as evidence; the rest were never claimed to be exhaustive.
- **Rewriting either feature's outcome.** If a criterion was vacuous, the finding is recorded and
  the criterion is fixed. The features stay closed.
- **Deciding who must declare a mutation.** That is `B15`, and it needs this measurement first.
- **Judging the authors of the tables.** The rate 020 measured came from the same hand in the same
  week; this is about what prose can carry, not about care.

## Dependency

`scripts/mutate.sh` and its declaration grammar (020), `tests/check_98_adoption.sh`,
`tests/check_80_north_star.sh`, `tests/check_95_amendment_gate.sh`, and the two verification
reports being audited.

**`D3` applies.** The tool audits closed features of this repository's own workflow, which is what
reflexive dogfood names. **`D4` does not:** the gate already exists and shipped in 020.

**The expected result is uncomfortable and is stated in advance.** If the 020 rate holds, roughly
**7 or 8 of these 19** will not break their criterion. Predicting it here means the feature cannot
later be framed as a clean pass.
