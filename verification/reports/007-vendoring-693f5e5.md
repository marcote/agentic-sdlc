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

## 4. UAT  — appended by /uat, against acceptance.md
_(pending — run in `/uat`)_

## 5. Verdict
BUILD: ✅ · TRAJECTORY: ✅ · UAT: pending · coverage: 100% (12/12) · retro: pending
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/007-vendoring/retro.md` — also closes 006's pending re-check
(frictionless-adoption + agnostic-portability, measured by vendoring).
Gaps routed: none (no BUILD/TRAJECTORY gap → no return to implement).
