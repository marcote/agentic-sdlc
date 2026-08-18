# Acceptance — 026-matrix-parser

> BDD (Given/When/Then). Deterministic unless marked `📋 case`.

## MTX-HEADER-FOUND
**Given** a matrix whose header names a criterion and a status column
**When** `matrix_header` runs against it
**Then** it echoes the field index of each named column, located by name rather than by position.

## MTX-SIX-AND-SEVEN
**Given** the same criterion under a six-column and a seven-column layout
**When** `matrix_rows` runs against each
**Then** both yield the same criterion, because the split yields the same field count and only the
header distinguishes them.

## MTX-SECOND-TABLE-EXCLUDED
**Given** a coverage file with a measurement table below the matrix
**When** `matrix_rows` runs
**Then** only the matrix's rows are emitted — the second table is out of range, not filtered out
afterwards.

## MTX-NO-TABLE-REPORTED
**Given** a file with no table whose header names both columns
**When** `matrix_header` runs
**Then** it emits nothing, and every consumer reports that file by name and exits non-zero.

## MTX-LABEL-TRIMMED
**Given** a criterion cell reading `` ` message clarity ` ``
**When** `matrix_rows` runs
**Then** the label is `message clarity` — surrounding whitespace and backticks removed, internal
spaces kept.

## MTX-IDEM-IN-RANGE
**Given** a linked cell reading `idem` following a row that names a file
**When** `matrix_rows` runs
**Then** it resolves to that file, and an `idem` in a *later* table never inherits from the matrix.

## STATUS-NAMES-CRITERION
**Given** `specs/001-example/coverage.md`, which has six columns
**When** `scripts/status.sh 001-example` runs
**Then** the gap line names `idempotency by key`, not `` `[given] base/idempotency` ``.

## STATUS-NO-PHANTOM-ORPHAN
**Given** `specs/022-mutation-coverage/coverage.md`, which carries a measurement table
**When** `scripts/status.sh 022-mutation-coverage` runs
**Then** it reports no orphan row — there is no such row in the matrix.

## MTX-SINGLE-READER
**Given** `scripts/status.sh`, `scripts/mutate.sh` and `scripts/cases.sh`
**When** each is read
**Then** none splits `coverage.md` on the pipe on its own, and all three source
`scripts/lib/matrix.sh`.

## MTX-COVERAGE-UNCHANGED
**Given** the baseline `205 obliged, 137 undeclared, 110 excluded, 0 unresolvable`
**When** `mutate.sh coverage --all` runs after the refactor
**Then** it is identical — a refactor that moves a number has changed meaning while claiming to
change structure.

## MTX-CASES-UNCHANGED
**Given** the baseline `15 case rows, 15 resolved, 0 unresolved, 0 missing, 0 orphan`
**When** `scripts/cases.sh` runs after the refactor
**Then** it is identical.

## MTX-DEPFREE
**Given** a machine with bash and coreutils and no installable toolchain
**When** the reader is sourced and used
**Then** it works.

## MTX-COST-REPORTED
**Given** the refactor
**When** the three tools are timed
**Then** the added cost is reported as a measurement, not an estimate.

## JUDGE-ONE-READER-HELD — `📋 case`
**Given** the next tool that needs to read `coverage.md`
**When** it is written
**Then** did it source the shared reader, or did a fourth parser appear? Scored by an independent
judge; **not before** a fourth consumer exists.
