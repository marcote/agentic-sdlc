# Technical plan — Derived phase-tracker (`scripts/status.sh`)

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Technical decisions

- **D1 — bash/coreutils, `python3` only if needed.** File existence, grep for markers/emoji,
  and report parsing are pure bash. Same dep-free baseline as the other scripts. Constrained
  by: `agnostic-portability` + the `DEPFREE` criterion.

- **D2 — Phase table as data, derivation as code.** The 10 phases are an ordered list; each
  phase has a `done` predicate function reading the authoritative source (spec req. 2). No
  hard-coded "feature X is at phase Y" — always derived. Constrained by: the brief's core
  objective (authoritative, not inferred) + principle 1.

- **D3 — non-placeholder reuses `check_90`'s regex.** A doc artifact is "filled" iff it has
  no `_\([^)]*\)_` / `<[^ >][^>]*>` markers — the exact test the retro gate already uses, so
  the two never diverge on what "filled" means. Constrained by: consistency with `check_90`.

- **D4 — coverage states by grep, not a table parser.** `contract` done = `coverage.md` has a
  `🔴`/`🟢`/`✅` glyph in a table row; `implement` done = no `🔴` and no `no contract` glyph
  remains among the criteria rows; a gap/orphan = a table row whose **Pillar** cell is empty
  or a criterion still `🔴`/`no contract`. Grep on the glyphs avoids a fragile markdown table
  parser. *Trade-off:* relies on the coverage legend glyphs being stable (they are the
  documented state machine). Constrained by: `coverage.md` is the declared source of truth.

- **D5 — report verdicts by grep.** `verify`/`uat`/`retro` read the newest
  `verification/reports/<feature>-*.md` for `BUILD: ✅` / `UAT: ✅` / `retro: ✅` (the exact
  lines `check_90` and the report template use). Constrained by: `verification-report.md`
  template stability.

- **D6 — Anomaly = "a done phase after a not-done phase".** Walk the ordered phases; once a
  pending phase is seen, any later done phase is an anomaly (skip/out-of-order). Anomaly →
  `⚠` line + non-zero exit; otherwise exit 0 (spec req. 6). Constrained by: `real-enforcement`
  (catch skips) without failing normal WIP (`NORMAL-EXIT0`).

- **D7 — Repo root = CWD; feature resolved under `specs/`.** `status.sh <feature>` reads
  `specs/<feature>/` and `verification/reports/<feature>-*.md` relative to CWD (like the other
  scripts run from repo root). Unknown feature (`no specs/<feature>/`) → error + non-zero exit.
  Enables hermetic fixtures: `check_86` builds a temp repo layout and `cd`s into it.

- **D8 — Shared DEPFREE helper in `tests/lib.sh` (candidate B).** Add
  `assert_dep_free <file>`: greps the file **excluding comment/echo/data lines** for a real
  toolchain invocation (`npm|npx|node|uv|pip|pnpm|yarn`), `_pass`/`_fail` accordingly.
  `check_82`, `check_84`, `check_95`, `check_86` call it instead of an inline grep. *Trade-off:*
  a behavior-preserving refactor of three passing checks — guarded by re-running the full
  suite (they must stay green). Constrained by: the must-not-regress guard rule just added to
  `principle 2` (the refactor is a guard, the suite is the pre-existing green).

## Components / modules

- **`scripts/status.sh`** → the tracker. An ordered phase list + per-phase `done` predicate +
  anomaly walk + gaps extractor + report printer. Read-only; exit 0 / non-zero-on-anomaly.
- **`tests/lib.sh`** → gains `assert_dep_free` (D8).
- **`tests/check_86_status.sh`** → hermetic fixtures (temp repo with mini `specs/<feat>/` +
  `verification/reports/`) at various stages (up-to-distill, red-coverage, out-of-order,
  fully-done, unknown) + `DEPFREE` (via the shared helper) + `HELPER-SHARED` (assert `lib.sh`
  defines it and `check_82/84/95` reference it). Sourced automatically by `run.sh`.

## Risks

- **Glyph/line drift** — status derivation depends on the `coverage.md` glyphs and report
  verdict lines. → Mitigation: reuse the *exact* markers `check_90`/templates use; `check_86`
  fixtures pin them; if a template changes, a fixture breaks loudly.
- **Refactor regresses a check** — D8 touches `check_82/84/95`. → Mitigation: full suite must
  stay green before/after (must-not-regress guard); the helper preserves the prior grep intent.
- **Placeholder regex false-negative** — a partially-filled artifact with a leftover `<…>` is
  read as pending. → Acceptable/consistent with `check_90`; a leftover marker *is* an unfilled
  spot.
