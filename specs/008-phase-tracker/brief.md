# Brief — Derived phase-tracker (`scripts/status.sh`)

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

A deterministic, dependency-free **`scripts/status.sh <feature>`** that **derives** the
pipeline phase state of a feature from its artifacts (which files exist under
`specs/<feature>/` + verification report) and the criterion states in `coverage.md`, and
reports: **phases done ✓ / current phase / next command to run / coverage gaps**. The SDLC
computes its own progress instead of the agent inferring a tracklist by hand. Read-only.

Secondary (candidate B from feature 007's retro): factor the **dependency-free assertion**
into a **shared, invocation-aware helper in `tests/lib.sh`** (distinguishes a real toolchain
*invocation* from a test-command *string*), used by this feature's check and de-duplicating
the copy-pasted grep in `check_82` / `check_84` / `check_95`.

## Why / motivation

The pipeline (`brief → align → distill → plan → contract → tasks → implement → verify → uat
→ retro`) is **fixed and deterministic**, and each phase's state is **derivable** from the
presence/state of artifacts. Today the tracklist is **inferred by hand** (the agent builds
an ad-hoc task list): a discipline leak — if a phase is skipped or run out of order, nothing
catches it, which contradicts `real-enforcement`. A derived tracker makes the workflow state
**authoritative and mechanical**, and lowers adoption friction (an adopter sees exactly where
they are and what to run next). This gap was flagged by the maintainer and recorded in both
006 and 007 retros.

## Success metrics

- `scripts/status.sh <feature>` prints, for each of the pipeline phases, a **done/pending**
  state **derived** from artifact presence + `coverage.md` (not hard-coded).
- It names the **current phase** and the **next command** to run.
- It surfaces **coverage gaps**: criteria not yet green/uat, or orphan rows.
- **Deterministic + dependency-free** (bash/coreutils + `python3` if needed for parsing).
- **Read-only**: it never mutates the repo.
- The shared `tests/lib.sh` dep-free helper exists and `check_82`/`check_84`/`check_95` use
  it (no duplicated dep-free grep).
- Self-check green: a `check_NN` exercises `status.sh` against fixtures and the suite stays green.

## Out of scope

- **Acting on the next step** — `status.sh` reports; it does not run the next command
  (read-only).
- **A `/next` / `/status` command wrapper** — deferred; a thin command can wrap the script later.
- **A cross-feature / global dashboard** — one feature at a time; `wow-report` already
  aggregates the retro ledger across features.
