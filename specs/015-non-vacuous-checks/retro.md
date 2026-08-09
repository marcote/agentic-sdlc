# Retro — 015-non-vacuous-checks @ e10ab1e

closes: `specs/015-non-vacuous-checks/alignment.md` · `verification/reports/015-non-vacuous-checks-83d3533.md` · date: 2026-08-09

> Closes the measurable prediction that `/align` opened. A feature is not DONE until this retro
> closes its three faces.

## Face A — Mission (closes the /align prediction)

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | Gates block closure when a condition is missing; the harness proves it by dogfooding itself | ✅ moved | `check_90` blocked this very close for a missing retro (suite 401/2 in a detached-HEAD clone **and** locally — the gate, not an environment artifact). `NVC-INNER-GUARD` confirms all 19 of `check_96`'s own labels emit inside the nested run, so the meta-check is judged by its own rule; F2 proves that pass is not trivial by inflating its declaration count to 36 and failing it |
| `measurable-impact` | Gaps caught early and late rework avoided, aggregated per feature | ✅ moved | **15 previously unknown untraceable criteria** across `check_82/84/86/88/95`, from features 004, 006, 007, 008, 009 (`coverage.md` UAT table). Nine in `check_95` alone: every amendment-gate criterion has been untraceable since feature 004. This is the first time a 015-family verdict moves on evidence rather than on mechanism |

**The falsification test, set at `/align` before the result was known** (`alignment.md` gate note 2):

> *Does the meta-check flag at least one real instance in the standing, green suite that was
> **not already known**? `DEPFREE` in 008 is already known and does not count — a scan that
> rediscovers only the defect that motivated it has proved a fixture, not a capability.*

**Answer: fifteen.** Not one, and not the seeded one. The largest cluster (`check_95`, nine
criteria) had been green and untraceable for the entire life of the amendment gate. `measurable-impact`
moves on that, and it is the first `✅` this pillar has taken since 004.

- **Align calibration:** `4/4/3` held, with one correction owed. `missionAdvancement: 3` was
  scored as a **reach ceiling** — the deliverable lives in `tests/` (DROP) so it never reaches an
  adopter. That reasoning was right about reach and **wrong about impact**: 15 real defects in
  five closed features is more than a 3 predicts. The gate note anticipated exactly this and said
  the interesting question would be *what carried it* — the answer is the defects it flagged in
  already-closed features, which is what the note guessed. `pillarFit: 4` and
  `scopeCompliance: 4` held. **Two pillars were deliberately not claimed** (`agnostic-portability`,
  `frictionless-adoption`) and that abstention held up: nothing here travels to an adopter.
- **Mission verdict:** confirmed

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 11 `[deriv: 3 grilling ambiguities resolved in f765b67 + 8 bullets under the "Edge cases" section of specs/015-non-vacuous-checks/spec.md, section-scoped]` — the section-scoping is deliberate, following 014's correction of 013's inflated count. The load-bearing three were all **measured before being asked**: static branch pairing was tested on the real suite and produced a 50% false-positive rate, the self-scan convention was found already present in `check_92`/`check_94`, and the 61-vs-127 label split came from counting, not guessing.
- **RED→GREEN discipline:** yes `[deriv: coverage.md state history + 8becb9f → 83d3533; suite 385/0 → 386/17 at /contract → 404/0 → 399/0 → 401/2 at close]` — one assertion (`HERMETIC-ENV-96-SELF`) passed at RED by design and was documented in `coverage.md` at contract time rather than discovered later.
- **Rework post-/verify:** 0 · **post-/uat:** **1** `[deriv: verification/reports/015-non-vacuous-checks-83d3533.md §4-§5 "Gaps routed: two to /distill (product)"]` — `NVC-ZERO-FP` was itself vacuous. Worse than 013's single rework, and the detail matters: it was not a missed edge case, it was this feature committing its own defect.
- **Escalations to the human:** 3 `[deriv: one AskUserQuestion round in the /distill grilling — detection strategy, self-scan enforcement, scope of the 127 unlabelled asserts]` — all genuine forks with materially different outcomes, all measured first so the human chose between quantified options rather than opinions.
- **Friction from the WoW itself:**
  **(1) The mechanical half caught nothing that the mechanical half missed — and the thing it missed was the most important defect of the feature.** `NVC-ZERO-FP` ran `--declarations-only`, `selfscan` and `duplicates` but never `traceability` against a real log. The suite read **404/0 while fifteen criteria were untraceable**. It was caught by walking the acceptance criterion **by hand at `/uat`**. That is not a footnote: this feature exists because prose failed three times, and its own central assertion was saved by prose-and-attention, not by machinery. The honest reading is that the two halves are complementary, not that one replaces the other — and the brief's framing ("the deliverable is an executable meta-check **plus** the pattern, in that order of importance") was subtly wrong about the ordering.
  **(2) A spec criterion had to be corrected after freezing.** `NVC-LABEL-UNIQUE` demanded global label uniqueness and fired four times on a known-good suite where the recurrence was legitimate — an inherited `[given]` criterion is *supposed* to recur. Routed back to `/distill` and replaced with something strictly stronger. `/distill` should have caught it: the constitution's own injection mechanism guarantees cross-file label reuse, and that was knowable at spec time without running anything.
  **(3) Three defects were produced by this feature's own tooling while building it**, all in the family it targets: fixture strings parsed as phantom declarations (110 labels instead of 97); `selfscan` flagging `check_96` for a `grep` inside a fixture heredoc — the tool producing, on its own file, the exact false positive it exists to catch; and a quoting slip that made `strip_heredocs` return **zero** declarations, which every downstream assertion would then have satisfied vacuously.

## Face C — Loop (self-improvement)

- **Candidate rules → constitution:** one, and it is narrow on purpose.
  1. **A `[given]` addition to `base/patterns/non-vacuous-checks.md`, not a new pattern:** *an assertion that a tool reports "clean" must run every rule that tool enforces, and name which ones it ran.* Evidence: `NVC-ZERO-FP` claimed a known-good suite was clean while never executing the rule the claim was about. This is distinct from the five rows already there — `check-can-fail` asks whether an assertion can fail, this asks whether it exercised what it claims. **Proposing it as prose is exactly what failed three times**, so it ships only if the accompanying mechanical form is obvious; if it is not, it belongs in `docs/backlog.md`, not in the constitution as decoration.
- **Candidate deltas → project:** none. `D4` was exercised for the first time since it landed and held without amendment: the exemption was declared before implementation, the meta-check judged its own file, and T5 preceded T6.
- **Candidate amendments → North Star:** none. `S2` was not strained; `S3` was strained and **survived by attempt**, which is what its `Falsifier` demanded — the parser stayed inside bash/awk without a second bespoke state machine, so `S2-HEDGE` correctly stayed `deferred`. `S1`'s first strain since 014 was recorded in `plan.md` and did not trip.

---

## Deferral hygiene

No `pending-observation` here. **013 and 014 both remain open and neither was closed by this
feature** — 013 needs a real `UNPINNED`/`TRIPPED` against a pre-existing pin (this `/plan` emitted
`PASS`, and the one candidate `UNPINNED` was considered and honestly rejected as failing the
inclusion test); 014 needs a mandatory step *rejected* for lacking justification, or a feature
stopped by `UNCOVERED`. Neither occurred. Sweep date **2026-09-08** unchanged for both.
