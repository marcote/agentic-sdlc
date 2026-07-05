# Spec — CI-gate for the North Star amendment

> WHAT is built. Produced by `/distill` from `brief.md` + `alignment.md`
> (`aligned`). Frozen when `coverage.md` has no orphan rows.

## Functional requirements

1. **Amendment-gate script** (bash + `python3` stdlib, dependency-free — no uv/pip/node).
   Given a `base..head` range,
   detects whether the **sets** `pillars`/`scope` of the canonical JSON block in
   `memory/north-star/north-star.md` changed — **semantic set comparison**, not text
   (reordering/reformatting without altering content does not count). If they changed, requires
   all three conditions and fails (exit ≠ 0) if any is missing:
   - (a) a `memory/north-star/decisions/NNNN-*.md` file **new** in the range
     (`hasAdrFor`);
   - (b) the resulting JSON block is **schema-valid** (`base/schema.md`);
   - (c) `tests/run.sh` green.
2. **GitHub Action** that runs the gate on `pull_request` and `push` to `main` and
   exposes it as a requirable **status-check**.
3. **Branch protection** on `main` requiring that status-check → blocks both PRs and
   direct pushes with an invalid amendment.
4. **Constitution delta**: the project `constitution.md` declares the blocking amendment
   gate as the **only exception** to principle 4 ("nothing blocks commit/push"), bounded to
   changes of `pillars`/`scope` in the North Star.
5. **Self-check**: `tests/` covers the gate script (with base/head fixtures) and the wiring
   (the script and the workflow exist); `tests/run.sh` stays green and dependency-free.

## User stories

- As a **harness maintainer**, I want a `pillars`/`scope` change without an ADR to be
  blocked by CI, so that governance does not depend on an approval a solo maintainer cannot
  give themselves.
- As an **adopter**, I want a script + doc to activate the same gate in my repo, to
  inherit amendment enforcement without reinventing it.

## Edge cases (80% problem)

- Reformat/reorder the JSON block **without** changing the sets → does **not** require ADR
  (semantic set comparison).
- Add an ADR **without** touching the North Star → allowed (not blocked).
- `pillars`/`scope` change with ADR but leaving the JSON **schema-invalid** →
  blocked (condition b).
- Change **only** `alignment.threshold`, prose, or wording of `mission` that does not alter
  the sets → does **not** require ADR.
- "New ADR" = a `decisions/NNNN-*.md` file **added** in the range; editing an existing one
  does not satisfy `hasAdrFor`.
- Normal feature work (does not touch `pillars`/`scope`) → the gate does **not block**
  (preserves "productivity first").

## Open questions / deferred

- **Applying branch protection to this repo now** vs just providing the script → resolved:
  applied to this repo on finish + script/doc provided for adopters.
- Verifying "**truly blocking**" (branch protection) is **GitHub config, not a hermetic
  unit test**: the `AMEND-BLOCK-REAL` and `AMEND-BLOCK-PUSH` criteria are validated in
  **UAT** (walk: apply protection, attempt an invalid amendment, confirm block), not with
  a local test.
- **Gate runtime:** `python3` stdlib (`json` module), not pure bash — pure bash JSON
  parsing is fragile. `python3` is a system interpreter (present on all runners + dev
  machines), not an installable dependency, so it does **not** cross the `out_of_scope`
  "runtime dependencies" and does not require a North Star amendment; it does loosen the
  `DEP-FREE` criterion to "bash/coreutils + python3 stdlib" (re-frozen here).
- **Deferred to constitution (future):** refine the **literal wording** of principle 4
  ("nothing blocks commit/push") toward its **productivity-first intent**, so that a narrow
  governance gate does not read as a contradiction. That is a separate constitution
  amendment; this feature only records the reconciliation (criterion `CONST-EXCEPTION`).
