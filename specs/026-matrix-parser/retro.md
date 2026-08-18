# Retro — 026-matrix-parser @ 2d395fa

closes: `specs/026-matrix-parser/alignment.md` ·
`verification/reports/026-matrix-parser-2d395fa.md` · date: 2026-08-18

## Face A — Mission (closes the /align prediction)

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `measurable-impact` | gaps caught early and late rework avoided | ✅ moved | `status.sh 001-example` went from naming the Origin cell to naming `idempotency by key`; a defect live since 008 |
| `real-enforcement` | gates block closure when a condition is missing | ✅ moved | `matrix_header` returns non-zero and silent on a file with no matrix; all three consumers now report it |
| `agnostic-portability` | the contract holds when vendored onto an arbitrary repo | ⏳ not yet observable | six- and seven-column matrices now read alike (`MTX-SIX-AND-SEVEN`), but none of the three tools is vendored — they are in neither `KEEP` nor `DROP` |
| `frictionless-adoption` | steps to adopt, each mandatory step carrying a recorded justification | ✅ moved | no step added; three parsers became one, at **1.84s** for all three tools |

- **Align calibration:** `missionAdvancement: 3` was right and I want the reason on the record. Two
  user-visible defects were fixed, one of which nobody had noticed. Everything else is structure,
  and the honest scale had to stay comparable to 023's 3 for a 3-row cleanup.
- **Mission verdict:** pending-observation
  - **re-check trigger:** a fourth tool needs to read `coverage.md`. Does it source the reader, or
    does a fourth parser appear? The likeliest failure is not defiance but convenience — a check
    file that needs one column and splits the line inline. `MTX-SINGLE-READER` guards the three
    tools **named in it** and would not see it.
    · **sweep by:** 2026-10-18

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 7 `[deriv: specs/026-matrix-parser/spec.md § "Edge cases (/distill expansion — 7)"]` — and **the third defect was found by running the tools, not by reading them**: `status.sh 022` printing a phantom orphan row was not in the brief until `/distill` ran it.
- **RED→GREEN discipline:** yes, one exception `[deriv: verification/reports/026-matrix-parser-2d395fa.md § 3]` — 13 FAIL, 1 PASS; `HERMETIC-ENV-91` green by construction, the third feature running.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/026-matrix-parser-2d395fa.md — "Gaps routed: none"]`
- **Escalations to the human:** 0 `[deriv: git log main..HEAD; one unattended run from "vamos tu propuesta"]`
- **Friction from the WoW itself:** **nine of fourteen mutations broke nothing on the first run — the
  worst rate this repository has recorded**, and every one was the same mistake. The logic lives in
  an embedded `awk` program, and I wrote shell-shaped anchors for it: `s|^_mx_crit=0$|…|` against a
  line that reads `      _mx_crit=0; _mx_crit = idx("criterion")`, indented, inside a quoted awk
  block. Seven declarations, one error, repeated. **The runner caught all nine; reading them would
  have caught none.**

## Face C — Loop (self-improvement)

- **Candidate rule → constitution, and this one has earned it:** *a mutation against logic embedded
  in another language — awk inside shell, SQL inside python — must anchor on that language's text,
  not the host's.* Three features have now produced weak mutations from anchor errors (022: 4 of 5;
  023: 1 of 3; 026: 7 of 9), and this is the first time the **cause** is the same across all of them
  rather than a scatter of one-offs. **Not landed here**: a rule stated as prose is what has failed
  three times in this repository, and the mechanical form is not obvious. It goes to
  `docs/backlog.md` as `B21`, with the three measurements attached so the next attempt starts from
  data.
- **Second finding, filed not fixed:** `status.sh`, `mutate.sh` and `cases.sh` are in **neither**
  `KEEP` nor `DROP` in `scripts/vendor.sh`. An adopter neither receives them nor is told they were
  withheld — the same silence family, in the vendoring plan. `B20`.
- **A correction to my own defence-in-depth reading.** Twice now — 023's `CASE-LEGEND-NOT-COUNTED`
  and this feature's `MTX-SECOND-TABLE-EXCLUDED` — a mutation survived because a *second* guard
  caught it, and I first read that as "the criterion is unfalsifiable". It is not. It means **the
  fixture was too weak to isolate the guard under test**: widening the fixture's second table so its
  criterion column collides made the mutation break it immediately. Redundant protection is not the
  same as an untestable claim, and I called it wrong the first time.
- **Candidate amendments → North Star:** none. No `pillars`/`scope` change.
