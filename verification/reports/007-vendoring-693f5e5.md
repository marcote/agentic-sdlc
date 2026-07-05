# Verification Report — 007-vendoring @ 693f5e5

spec: spec.md (frozen) · date: 2026-07-05 · constitution: base + project (delta D1/D2)

## 1. Coverage snapshot
12 deterministic criteria (`coverage.md`), all linked to `check_84_vendor.sh` (hermetic
against `mktemp -d` targets), all 🟢 green. No `base/pattern` applies as `[given]`
(vendor.sh copies files — no write endpoints / network surface). No non-deterministic
eval cases.

## 2. Output eval (BUILD)  — deterministic, runs in /verify
`bash tests/run.sh` → **TOTAL PASS=198 FAIL=0**. `check_84` (12 asserts) green:

| Group | Criteria | Result |
|---|---|---|
| dry-run | DRYRUN-NOWRITE · DRYRUN-PLAN | ✅✅ |
| KEEP / DROP | KEEP-COPIED · KEEP-OVERWRITE · DROP-ABSENT | ✅✅✅ |
| SEED | SEED-STUB · SEED-NOCLOBBER | ✅✅ |
| stack / provenance | STACK-DETECT · PROVENANCE | ✅✅ |
| invariants / doc | DEPFREE · HANDOFF · SELF-CHECK | ✅✅✅ |

**Task success: 12/12 deterministic = 100%.** (Threshold 100% ✓)

## 3. Trajectory eval  — non-deterministic, LM judge over the trace
- **Tool use:** `/contract` before impl; hermetic fixtures via `mktemp -d` (temp targets with
  a `package.json` / pre-existing `CLAUDE.md`), asserting KEEP present / DROP absent / SEED
  stubbed / collision→`.harness-new` / stack→`test.sh` / provenance stamped. Aligned with
  `tasks.md` (T1–T7). `/align` itself was run **on the 006 engine** (`schema-valid` +
  `scope-reject` + `align-verdict`), not the LLM judge alone — dogfood.
- **Trajectory compliance:** **test-first verified** — `/contract` (commit `32eeef1`) ran the
  suite in 🔴 RED (12 FAIL, vendor.sh + docs/vendoring.md absent) *before* the impl (`693f5e5`)
  turned it green. Full chain honored: `/align` (aligned, run on the engine) → `/distill`
  (3 grilling Qs) → `/plan` (grounded, allowlist-copy decision) → `/contract` (RED) → `/tasks`
  (gate passed) → impl. **No steps skipped.**
- **Hallucination:** 0. `vendor.sh` uses only bash/coreutils + `git` (provenance) + is invoked
  with `python3` available; no npm/node/uv/pip **invocation**. Transparency: the `DEPFREE`
  assert was refined during implementation to distinguish a real toolchain *invocation* from
  the test-command *strings* vendor.sh legitimately seeds (`npm test`, `pytest`, …) — a
  test-bug fix (the intent "vendor.sh needs no toolchain to run" holds), recorded in
  `coverage.md` and the impl commit.

## 4. UAT  — against acceptance.md + the brief objective
Full vendoring walk onto a **fresh fake adopter repo** (`git init`, a `pyproject.toml`, a
pre-existing `CLAUDE.md`), validating the batteries-included objective:

- **Dry-run** printed the plan (detected `pytest`, provenance preview, KEEP list) and wrote
  nothing. ✅
- **`--apply`** landed governance (`.claude/commands/align.md`, `.claude/skills/distill`,
  `scripts/north-star/engine.py`, `memory/constitution/base/principles.md`, `specs/_template`);
  harness-self absent (`specs/001-example`, `verification/reports`, `README.md`, `tests/`). ✅
- **Non-destructive:** the existing `CLAUDE.md` (`# my project`) was preserved and
  `CLAUDE.md.harness-new` written; `scripts/test.sh` seeded with `pytest`;
  `.harness-provenance` stamped (SHA + date). ✅
- **Batteries-included (the hard proof):** the **vendored engine ran inside the target** —
  `python3 <target>/scripts/north-star/engine.py schema-valid <target>/…/north-star.md` → exit 0,
  and `align-verdict` → `aligned`. The harness runs in the adopter repo out of the box. ✅

Does it move the success metric? **Yes** — adoption is one command
(`vendor.sh --apply`) + merge `.harness-new` + `/constitution`. **This also closes 006's
pending re-check**: frictionless-adoption (steps to adopt: measurably low) and
agnostic-portability (the contract — schema/gate/engine — stayed intact vendored onto an
arbitrary repo) both moved, measured here. **No product gap.**

## 5. Verdict
BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% (12/12) · retro: pending
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/007-vendoring/retro.md` — also closes 006's pending re-check
(frictionless-adoption + agnostic-portability, measured by this UAT).
Gaps routed: none.
