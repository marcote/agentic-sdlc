# Technical plan — CI-gate for the North Star amendment

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Technical decisions

- **D1 — `python3` stdlib for the JSON logic (not pure bash).** The detection of "the
  pillars/scope set changed" and schema validation are done with a `python3` helper (the
  stdlib `json` module) that extracts the canonical block from both versions and compares
  the `pillars`/`scope` sets semantically. The rest of the gate (git I/O, orchestration,
  messages) is bash. *Trade-off:* pure bash JSON parsing is fragile; `python3` gives real
  robustness. *Cost:* loosens the **DEP-FREE** criterion from "bash/coreutils only" to
  "bash/coreutils + `python3` stdlib" (re-frozen in the spec). *Why it does not cross the
  North Star:* `python3` is a **system interpreter** (like bash/grep), not an installable
  dependency (no uv/pip/npm, no package-manifest) → does not match `out_of_scope`
  "runtime dependencies or frameworks", does not require an amendment. **node** is ruled out
  by the brief ("no Node/npm"); **uv** would be an installable toolchain → out_of_scope.
  Constrained by: `agnostic-portability` (keep the baseline small) and the `out_of_scope`.

- **D2 — Pure logic core separated from git I/O (testability).** The script exposes
  pure functions operating on **files**, not on a git range:
  `sets_changed OLD NEW`, `schema_valid FILE`, `has_new_adr ADDED_FILES...`. A CLI wrapper
  wires them from a `base..head` range. *Why:* allows `check_95` to exercise them with
  **fixtures** (old/new pairs of `north-star.md` + synthetic file lists), without
  building git states — the same fixture pattern as `check_90`. Constrained by:
  principle 2 (test-first) and 1 (verifiability) — a criterion that cannot be unit-tested
  with fixtures is not deterministic.

- **D3 — Separate workflow `amendment-gate.yml`, not augmenting `verify.yml`.** A
  dedicated workflow gives a **status-check with its own name** ("amendment-gate") that
  branch protection can require, independent of the advisory `verify` check. Runs on
  `pull_request` and `push` to `main`. *Trade-off:* one more workflow file, in exchange
  for a requirable gate without dragging in the advisory semantics of `verify.yml`.

- **D4 — base..head range by event.** On `pull_request`:
  `${{ github.event.pull_request.base.sha }}..HEAD`. On `push`:
  `${{ github.event.before }}..${{ github.sha }}`. The wrapper derives the two contents of
  `north-star.md` (`git show BASE:memory/north-star/north-star.md` vs HEAD) and the list
  of added files (`git diff --name-status --diff-filter=A BASE HEAD`).

- **D5 — `hasAdrFor` = a `decisions/NNNN-*.md` file with status `A` (added) in the range.**
  Editing an existing ADR does **not** count (protocol: "new sequential number"). Constrained
  by: `base/amendment-protocol.md`.

- **D6 — Reconciliation with principle 4 (no literal override).** Principle 4 says,
  literally, "nothing blocks commit/push", but its **intent is productivity-first**. This
  gate blocks **only** North Star `pillars`/`scope` changes (rare governance), not the
  feature throughput — so it is **consistent with the intent**, not an override of it.
  Recorded in `constitution.md` (project delta). Consistent with `base/amendment-protocol.md`,
  which already declares amendments a gated event. *Deferred (not in this feature):*
  refining the **literal wording** of principle 4 toward "productivity-first" is a separate
  constitution amendment.

## Components / modules

- **`scripts/amendment-gate.sh`** → the gate. Pure functions (`sets_changed`,
  `schema_valid`, `has_new_adr`) + CLI wrapper (`--range BASE..HEAD` for CI;
  `--files OLD NEW --added "f1 f2"` for testing). Output: exit 0 (pass) / ≠0 (block) + message
  citing the missing condition. Dependency-free.
- **`.github/workflows/amendment-gate.yml`** → runs `scripts/amendment-gate.sh --range …`
  on `pull_request` + `push` to `main`; is the requirable status-check.
- **`scripts/setup-branch-protection.sh`** → applies (via `gh api`) branch protection on
  `main` requiring the "amendment-gate" check and prohibiting bypass; reusable by adopters.
  Documented in the README.
- **`tests/check_95_amendment_gate.sh`** → exercises the pure functions with fixtures
  (scenarios for the 10 deterministic criteria) + wiring asserts (script + workflow exist)
  + DEP-FREE (no `package.json`/`node_modules`). Sourced by `tests/run.sh`.
- **`memory/constitution/constitution.md`** → delta recording the D6 exception.
- **`README.md`** → short section: how to activate branch protection (adopter).

## Testability of criteria

- **Deterministic (10)** → `check_95` with fixtures: old/new pairs of `north-star.md`
  (reformat, set change, prose-only, threshold-only, schema-invalid) + added-files lists
  (with/without ADR) + a suite stub. Go **RED** in `/contract`.
- **UAT (2)** `AMEND-BLOCK-REAL` / `AMEND-BLOCK-PUSH` → branch protection config; walked
  in `/uat` (apply protection, attempt an invalid amendment by PR and by push, confirm block).
  Not unit-testable hermetically.

## Risks

- **`python3` absent in a minimalist environment** → mitigation: the gate checks for `python3`
  at startup and fails-closed with a clear message ("requires python3 stdlib"); it is present
  on all GitHub runners and practically on every dev machine. This is the accepted cost of D1
  on `agnostic-portability` (baseline: bash/coreutils + python3).
- **`github.event.before` on the first push / force-push** can be invalid
  (`000000…`) → mitigation: if BASE does not resolve, the gate treats the range as "review
  the current state" (schema-valid + if HEAD touched pillars/scope vs the last commit with
  north-star.md), and in the worst case fails-closed asking for manual review.
- **Branch protection requires admin permissions** → `setup-branch-protection.sh` documents
  that the owner runs it once; the runner token does not apply it in CI.
