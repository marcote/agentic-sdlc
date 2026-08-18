# Acceptance — 023-case-resolution

> BDD (Given/When/Then). Deterministic unless marked `📋 case`.

## CASE-RESOLVES-CLEAN
**Given** a matrix whose `📋 case` row names a file that exists and that names the row's criterion
**When** `scripts/cases.sh` runs against it
**Then** it exits **0** and states how many rows it resolved — not silence.

## CASE-MISSING-FILE
**Given** a `📋 case` row naming `evals/cases/gone.md`, which does not exist
**When** the check runs
**Then** it exits **2**, naming the feature, the criterion and the path.

## CASE-NO-PATH
**Given** a `📋 case` row whose linked cell names no path under `evals/cases/`
**When** the check runs
**Then** it exits **1**, naming the criterion — a promise to judge later is not a case file.

## CASE-LABEL-BINDS
**Given** a `📋 case` row for `JUDGE-X` citing a file that exists but never names `JUDGE-X`
**When** the check runs
**Then** it exits **1** and says the file does not name that criterion — existence alone does not
bind a row to its case.

## CASE-ORPHAN-FILE-REPORTED
**Given** a case file under `evals/cases/` that no `📋 case` row cites
**When** the check runs
**Then** it is reported by name, and the count of orphans is printed even when it is zero.

## CASE-COLUMNS-BY-HEADER
**Given** a matrix with **six** columns and one with **seven**, each carrying one `📋 case` row
**When** the check runs
**Then** both rows are read correctly, because columns are located by header name rather than by
position.

## CASE-HEADER-UNREADABLE
**Given** a matrix whose header row names neither a criterion nor a status column
**When** the check runs
**Then** it exits **2** naming that file — a matrix it cannot understand is reported, never guessed
at.

## CASE-LEGEND-NOT-COUNTED
**Given** a matrix whose status-legend line contains the literal `📋 case` outside any table row
**When** the check runs
**Then** that line is not counted as a case row. This is the miscount that gave `B14` its 32.

## CASE-MULTI-ROW-FILE
**Given** one case file cited by three rows, naming all three criteria
**When** the check runs
**Then** all three resolve, and the file is counted once as cited.

## CASE-REPO-CLEAN
**Given** this repository at this ref
**When** the check runs over `specs/*/coverage.md`
**Then** it exits **0**, with every `📋 case` row resolved and every case file cited.

## CASE-WIRED
**Given** `.claude/skills/verify/SKILL.md` and `.github/workflows/verify.yml`
**When** either is read
**Then** both name `scripts/cases.sh`, and `tests/run.sh` does not.

## CASE-DEPFREE
**Given** a machine with bash and coreutils and no installable toolchain
**When** the check runs
**Then** it completes.

## CASE-COST-REPORTED
**Given** a completed run over the whole repository
**When** its output is read
**Then** it carries a measured elapsed time, not an estimate.

## JUDGE-CASES-NOW-COUNTABLE — `📋 case`
**Given** `B2`, deferred because the cases have never been scored
**When** an independent judge is available
**Then** did making the set resolvable change anything, or was knowing the count never the obstacle?
Scored by an independent judge; **not before** a judge exists for `B2`.
