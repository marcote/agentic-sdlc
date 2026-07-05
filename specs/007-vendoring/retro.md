# Retro — 007-vendoring @ 060cd5b

closes: `specs/007-vendoring/alignment.md` · `verification/reports/007-vendoring-693f5e5.md` · date: 2026-07-05

> Closes the measurable prediction that `/align` opened (align↔retro column). Also closes the
> pending re-check that 006's retro deferred to this feature.

## Face A — Mission (closes the /align prediction)
Source: `alignment.md` mapping (frictionless-adoption, agnostic-portability, real-enforcement) + `north-star.md` signals.

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| frictionless-adoption | Steps/time to adopt the harness (lower = better) | ✅ moved | UAT walk (report `verification/reports/007-vendoring-693f5e5.md` §4): adoption = 1 command (`vendor.sh --apply`) + merge `.harness-new` + `/constitution`. Commit `693f5e5` |
| agnostic-portability | The contract stays intact when vendored onto an arbitrary stack | ✅ moved (synthetic target) | UAT: vendored onto a fresh `git init` repo with a `pyproject.toml`; the vendored engine ran there (`schema-valid` exit 0). Coverage rows `KEEP-COPIED` / `DROP-ABSENT` ✅ uat |
| real-enforcement | Gates block; harness dogfoods itself | ✅ moved | `/align` for 007 ran on the real engine (`alignment.md` — schema-valid + scope-reject + align-verdict), no longer LLM-judge-only; RED→GREEN `32eeef1`→`693f5e5` + this retro |

- **Align calibration:** pillarFit 4 held; scopeCompliance 5 held (the engine's `scope-reject` cleared all six objectives — no edge, unlike 006); missionAdvancement 3 was **conservative** — the UAT showed vendoring advances the mission strongly (it is *how* a stack-agnostic harness reaches any project), so a 4 would have been justified. (006's mission was optimistic; 007's was pessimistic — the calibration error flipped sign.)
- **Mission verdict:** confirmed
  - All three pillars moved with locators. Caveat (survived self-challenge): agnostic-portability was demonstrated on a *synthetic* target (temp repo), not a large real project — the mechanism is proven (the contract stayed intact and ran), but real-project vendoring would be stronger evidence.
  - **Cross-closure:** this feature closes **006's pending-observation** — 006's retro deferred frictionless-adoption + agnostic-portability to "when 007 vendors"; this UAT is that measurement, and both moved. 006's prediction is now confirmed via 007.

## Face B — Method (validates the WoW) — DERIVED from artifacts
- **Gaps caught by /distill:** 3 grilling ambiguities (KEEP-collision policy, test-cmd landing, provenance/git) + edge cases (re-run idempotency, unknown stack, non-git source, dry-run read-only, DROP leakage) + a classification refinement (`tests/` moved KEEP→DROP) `[deriv: spec.md "Edge cases" + "Open questions" + coverage.md; git b85c912]` — the notable one: `tests/` validates the harness-as-product, so it is DROP.
- **RED→GREEN discipline:** yes `[deriv: coverage.md history 🔴 12 FAIL → 🟢 198 PASS; git 32eeef1 contract RED before 693f5e5 impl GREEN]` — disclosure: the `DEPFREE` assert was refined during impl (it false-positived on the test-command *strings* vendor.sh seeds); the RED phase was genuine (assert_file failed with vendor.sh absent), the refinement fixed a test bug, not a criterion.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/007-vendoring-693f5e5.md section 5 — Gaps routed none]`.
- **Escalations to the human:** 0 inner-loop `[deriv: git — impl 693f5e5 single commit; the DEPFREE refinement was 1 iteration within the impl step, <3 attempts, no human escalation]`.
- **Friction from the WoW itself:** (1) the `DEPFREE` grep (copy-pasted from check_82/95) is too naive for a script that legitimately *names* toolchains as data — it should be a shared, invocation-aware helper in `tests/lib.sh`, not duplicated per check. (2) The pipeline tracklist is still inferred by hand (feature 008, still pending). (3) Positive: `/align` finally ran on the real engine — the bootstrap friction 006's retro flagged is now gone.

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** (1) *Shared DEPFREE helper* — factor an invocation-aware dependency-free assertion into `tests/lib.sh` (exclude comment/echo/data lines), so each feature does not re-implement (and mis-implement) it. (2) Re-affirm the feature-008 *derived phase-tracker* candidate (still pending). Apply via `memory/constitution/update-checklist.md`.
- **Candidate amendments → North Star:** none pressing. 007 scored scopeCompliance 5 with no edge, so the 006 candidate (clarify the "deterministic engine" `out_of_scope` wording) did **not** recur — leave the North Star as-is unless a future feature re-litigates the batteries-included reading.
