# Acceptance — 027-mutation-diagnostics

> BDD (Given/When/Then). Deterministic unless marked `📋 case`.

## MUT-STALE-NAMED
**Given** a criterion whose declared edit matches nothing in the tree
**When** `mutate.sh run` executes it
**Then** it reports `STALE` with the edit, and **not** `survived its own mutation`.

## MUT-STALE-NOT-PROVED
**Given** that same stale declaration
**When** the run finishes
**Then** it is counted in `not proved` and the exit code is **1** — the diagnosis sharpens, the
verdict does not soften.

## MUT-WEAK-STILL-SURVIVES
**Given** a criterion whose edit **does** change bytes and which still passes
**When** the run executes it
**Then** it reports `survived its own mutation` — the old outcome is intact, not replaced.

## MUT-COUNTS-SEPARATE
**Given** a run with one stale and one weak declaration
**When** the summary line is read
**Then** the two are reported as separate counts, never added together.

## MUT-BAK-NOT-A-CHANGE
**Given** an edit that matches nothing, run through `sed -i.bak`, which rewrites the file and
creates a backup regardless
**When** staleness is judged
**Then** it is judged by content with `*.bak` excluded, so the rewrite is not read as a change.

## MUT-APPLY-ERROR-STILL-DISTINCT
**Given** a declaration whose command fails outright
**When** the run executes it
**Then** it reports `could not be applied` — successful-and-inert and failed-outright stay separate.

## MUT-UNTRACKED-REFUSED
**Given** an untracked file under the tests directory
**When** `mutate.sh run` starts
**Then** it exits **2** naming that file, before building any sandbox.

## MUT-TRACKED-RUNS
**Given** a tests directory with no untracked files
**When** the run starts
**Then** the pre-flight passes silently and the run proceeds.

## MUT-STALE-REPLAY-026
**Given** 026's declaration exactly as it shipped —
`sed -i.bak 's|^_mx_crit=0$|_mx_crit=5|' scripts/lib/matrix.sh` — against the code as it stood
**When** the runner executes it
**Then** it reports `STALE`. The falsification test: if the mechanism does not catch what actually
shipped, it does not work.

## MUT-SUMMARY-LEGIBLE
**Given** a run in which every declaration is stale, as a refactor produces
**When** the summary is read
**Then** the stale count is stated, so the shape is legible without reading every line.

## MUT-DIAG-DEPFREE
**Given** a machine with bash, coreutils and python3 and no installable toolchain
**When** the runner executes
**Then** it works.

## MUT-DIAG-COST
**Given** the added content hashing
**When** the full run is timed
**Then** the added cost is reported and compared against the **2%** predicted at `/align`.

## JUDGE-STALE-READ-FIRST-TIME — `📋 case`
**Given** the next feature whose declaration goes stale
**When** its author reads the runner's output
**Then** did the diagnosis land on the first read, or was the wrong thing investigated anyway?
Unscorable here: every declaration this feature ships was written knowing the outcome exists.
