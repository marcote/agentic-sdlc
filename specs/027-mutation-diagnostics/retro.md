# Retro — 027-mutation-diagnostics @ 0642d4b

closes: `specs/027-mutation-diagnostics/alignment.md` ·
`verification/reports/027-mutation-diagnostics-0642d4b.md` · date: 2026-08-18

## Face A — Mission (closes the /align prediction)

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | gates block closure when a condition is missing; the harness proves it by dogfooding itself | ✅ moved | `MUT-UNTRACKED-REFUSED` exits 2 before any sandbox; `MUT-STALE-REPLAY-026` reports `STALE` on 026's unedited declaration |
| `measurable-impact` | gaps caught early and late rework avoided | ✅ moved | 16 of 21 weak mutations across four features were stale, and were reported as weak; `mutate.sh run` now separates the counts |
| `frictionless-adoption` | every mandatory step carrying a justification proportional to what it prevents | ✅ moved | added cost measured at **0.009s per declaration**, against ~2% predicted at `/align` |

- **Align calibration:** `missionAdvancement: 3` was right. This fixes no criterion and closes no
  vacuity — it changes what the runner says when something is already wrong. `pillarFit: 5` held:
  `real-enforcement`'s signal names dogfooding explicitly and the evidence is this repository's own
  four features.
- **Mission verdict:** pending-observation
  - **re-check trigger:** the next feature whose declaration goes stale. Does its author fix the
    **declaration**, or re-read the criterion first? A `STALE` line followed by a rewritten criterion
    refutes this.
    · **sweep by:** 2026-10-18

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 7 `[deriv: specs/027-mutation-diagnostics/spec.md § "Edge cases (/distill expansion — 7)"]` — the load-bearing one is edge 1: `sed -i.bak` rewrites its target on a no-match, which kills the obvious mtime design before it was written.
- **RED→GREEN discipline:** partial, and it is the weakest here `[deriv: verification/reports/027-mutation-diagnostics-0642d4b.md § 3]` — 7 FAIL, **6 PASS**. Four are regression guards asserting behaviour that must be preserved; two are green by construction.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/027-mutation-diagnostics-0642d4b.md — "Gaps routed: none"]`
- **Escalations to the human:** 0 `[deriv: git log main..HEAD; one unattended run from "go"]`
- **Friction from the WoW itself:** **I shipped an assertion whose input guaranteed its own outcome,
  in the feature about diagnosing exactly that.** `MUT-BAK-NOT-A-CHANGE` grepped the output for
  `STALE` while the fixture's criterion was labelled `STALE-ONE` — it matched the label, not the
  verdict, and passed before a line of the mechanism existed. `/contract` caught it because 6 green
  out of 13 was implausible enough to look at. **The RED state's value here was not the red; it was
  the green that did not belong.**

## Face C — Loop (self-improvement)

- **Candidate rule → constitution: landed.** `base/patterns/non-vacuous-checks.md` gains *"The
  runner's outcomes, and what each one tells you to fix"* — a table mapping each not-proved outcome
  to the artifact at fault, plus the two ways a declaration goes stale (never matched · the code
  moved), why staleness is judged by content and never by timestamp, and why an untracked file is a
  refusal rather than an outcome. This is the first rule from this line of work that ships as prose
  **because it now has a mechanism behind it** — the runner enforces the distinction, so the words
  describe a check rather than substituting for one.
- **A design error of mine from 026, found by 027 tripping over it.** `MTX-CASES-UNCHANGED` asserted
  the exact string `16 case rows, 16 resolved`. 027 adds a `📋 case` row, so it went red **for the
  one reason that is never a regression**, and would have done so on every future feature forever.
  Corrected in place to assert the invariant and a floor. 026 stays closed — 021's precedent.
  **An absolute count of a growing set is a criterion with an expiry date**, and I wrote one nine
  days after recording that lesson about sweep dates.
- **Three of thirteen mutations were weak, and two were the same old error:** a global rename that
  renames the definition *and* its use, which 022 shipped and I repeated. `B21` closed today
  describes the anchor family; this one is adjacent and not covered by it. Left unfiled — one
  recurrence is not a family, and this repository has enough open entries.
- **Candidate amendments → North Star:** none.
