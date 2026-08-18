# Acceptance — 022-mutation-coverage

> BDD (Given/When/Then). Deterministic unless marked `📋 case`.

## COV-OBLIGED-PREDICATE
**Given** a coverage matrix holding a `project` row that is `🟢 green` and links a check file that
exists, alongside a `[given]` row, a `📋 case` row and a `deferred` row
**When** `mutate.sh coverage --spec` runs against it
**Then** exactly the first row is counted as obliged, and the other three are not.

## COV-GAP-NAMED
**Given** an obliged criterion whose label carries no `[mut$ … $]` declaration in its check file
**When** the gate runs
**Then** it exits **1** and names that label together with the feature that obliged it.

## COV-CLEAN-PASSES
**Given** a feature whose every obliged criterion declares a mutation
**When** the gate runs
**Then** it exits **0** and states how many criteria it found obliged.

## COV-UNRESOLVABLE-REPORTED
**Given** a row whose linked-test cell names `check_00_typo.sh`, which does not exist
**When** the gate runs
**Then** it exits **2** and names the feature, the label and the unresolved cell — it is not
silently excluded from the obligation.

## COV-TYPO-NOT-EXEMPTION
**Given** a row whose linked-test cell names `chek_97_mutation_coverage.sh` — a script name that
does not match `check_*.sh` at all
**When** the gate runs
**Then** it exits **2** rather than treating the row as having no assertion to mutate.

## COV-NOT-OBLIGED-COUNTED
**Given** rows excluded by rule — `📋 case`, `deferred`, `/uat judgment`
**When** the gate runs
**Then** their count is printed, so exclusion is a reported number rather than a silence.

## COV-IDEM-RESOLVED
**Given** a row whose linked-test cell is `idem`, following a row that names a check file
**When** the gate runs
**Then** the `idem` row resolves to that same check file and is obliged on the same terms.

## COV-ALL-REPORTS-DEBT
**Given** every `specs/*/coverage.md` in this repository
**When** `mutate.sh coverage --all` runs
**Then** it prints a per-feature line and a total, exits **0** despite the standing debt, and the
total it prints is derived at that ref rather than read from a stored figure.

## COV-NO-GIT
**Given** a tree with no `.git` directory and no network
**When** `mutate.sh coverage` runs
**Then** it behaves identically — no branch ref is read, which is what 019 shipped and CI rejected.

## COV-SELF
**Given** `specs/022-mutation-coverage/coverage.md`, this feature's own matrix
**When** the gate it ships runs against it
**Then** it exits **0** — `D4`, the gate subjected to itself with a real verdict.

## COV-WIRED
**Given** `.claude/skills/verify/SKILL.md` and `.github/workflows/verify.yml`
**When** either is read
**Then** both name `mutate.sh coverage`, and `tests/run.sh` does not.

## COV-DEPFREE
**Given** a machine with bash, coreutils and python3 and no installable toolchain
**When** the subcommand runs
**Then** it completes — no package manager, no runtime beyond what 020 already required.

## COV-COST-REPORTED
**Given** a completed run of `coverage --all`
**When** its output is read
**Then** it carries a measured elapsed time, not an estimate.

## JUDGE-OBLIGATION-CAUGHT-ONE — `📋 case`
**Given** the first feature to close under this gate after 022
**When** its `/verify` runs
**Then** did the obligation surface a criterion its author would not otherwise have declared?
Unscorable until such a feature exists — the enforcement claim `alignment.md` refused to score as
mission advancement 5.
