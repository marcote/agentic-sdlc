# Retro — 023-case-resolution @ 185f176

closes: `specs/023-case-resolution/alignment.md` ·
`verification/reports/023-case-resolution-185f176.md` · date: 2026-08-18

## Face A — Mission (closes the /align prediction)

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | gates block closure when a condition is missing | ✅ moved | `scripts/cases.sh` exits 1 on `FIX-PROMISE` and 2 on a dangling citation; `/verify` step 6 makes it a closure condition |
| `measurable-impact` | gaps caught early and late rework avoided | ✅ moved | `B14`'s figures corrected 32→14 and 21→1, derived by the tool: `cases: 15 case rows, 15 resolved, 0 orphan` |
| `agnostic-portability` | the contract holds when vendored onto an arbitrary repo | ✅ moved | `CASE-COLUMNS-BY-HEADER` — a six-column matrix reads the same as a seven-column one |
| `frictionless-adoption` | steps to adopt, each mandatory step carrying a recorded justification | ⏳ not yet observable | a sixth `/verify` step was added, at 0.17s; whether the sequence is still worth its ceremony is not answerable from inside the feature that lengthened it |

- **Align calibration:** the scores held, and **`missionAdvancement: 3` was right.** The measured gap
  was 3 rows of 14. Scoring 4 would have been grading the mechanism's shape rather than what it
  moved, and the doubt rule exists for exactly this. `pillarFit: 5` also held.
- **Mission verdict:** pending-observation
  - **re-check trigger:** does `cases.sh` ever block a feature that did not already know it was
    broken? The `📋 case` row is written at `/distill` and the case file at `/contract`, so an author
    following the workflow never trips it. If it stays at 0 for three features, its value is
    archaeological — it caught 021's and 022's debt once — and it should be said plainly rather than
    counted as enforcement.
    · **sweep by:** 2026-09-18

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 8 `[deriv: specs/023-case-resolution/spec.md § "Edge cases (/distill expansion — 8)"]` — the load-bearing one is edge 5, the six-column matrix, found while measuring rather than while designing.
- **RED→GREEN discipline:** yes, one exception `[deriv: verification/reports/023-case-resolution-185f176.md § 3]` — `/contract` was 13 FAIL, 1 PASS; `HERMETIC-ENV-93` was green from the moment the file existed. Same class as 022's `COV-DEPFREE`.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/023-case-resolution-185f176.md — "Gaps routed: none"]`
- **Escalations to the human:** 1 `[deriv: the /distill correction reported before writing the brief]` — `B14`'s premise was wrong by 7× and the feature the user had just approved was 7× smaller than advertised. Reported with the corrected figures and a recommendation, then continued.
- **Friction from the WoW itself:** **the fixtures were built from the shapes I expected, and the
  defect came from the shape I did not.** Seven fixtures, all using `UPPER-KEBAB` labels, because
  every criterion in this harness looks like that. `001-example`'s criterion is the prose *"message
  clarity"*, and stripping spaces instead of trimming them reported `UNBOUND` against a correct
  file. The fixture set was an inventory of my assumptions. The repository was the adversary, and it
  found it in one run.

## Face C — Loop (self-improvement)

- **Candidate rules → constitution:** **one, and it is not the obvious one.** The obvious rule —
  *"a `📋 case` row must name a case file"* — is already mechanised by this feature and needs no
  prose. The candidate worth writing is about fixtures: *a fixture set built only from shapes the
  author expects is an inventory of assumptions, and the real artifact must be in the test set.* It
  is **not landed**, because this repository has measured three times that a procedural rule stated
  as prose does not stick, and because one occurrence is not a family. It goes to `docs/backlog.md`
  if it recurs.
- **Second candidate, NOT landed:** the shared matrix parser. Three tools now read `coverage.md` and
  only one resolves columns by header. Filed as `B19` rather than fixed here — `B9` is the standing
  evidence that two readers of one artifact eventually disagree, and retrofitting `mutate.sh` inside
  a feature about case files is the chaining the backlog exists to prevent.
- **Evidence against the previous feature, recorded here because nobody else will:** 023 is the
  first feature to close **under** 022's mutation obligation, and it reported `0 undeclared` on the
  first run. `evals/cases/obligation-caught-one.md` names *three consecutive features at 0* as the
  refuting condition. **This is the first of the three.** One point settles nothing and it points
  away from 022's claim.
- **Candidate amendments → North Star:** none. No `pillars`/`scope` change.
