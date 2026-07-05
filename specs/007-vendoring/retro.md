# Retro — <feature> @ <commit>

closes: `specs/<feature>/alignment.md` · `verification/reports/<feature>` · date: <YYYY-MM-DD>

> Closes the measurable prediction that `/align` opened (align↔retro column). A feature is not
> DONE until this retro closes its three faces. Design:
> `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

## Face A — Mission (closes the /align prediction)
Source: `specs/<feature>/alignment.md` (objective→pillar mapping) + `north-star.md` (signal per pillar).

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| <pillar-id> | <signal from the North Star> | ✅ moved / ❌ did not move / ⏳ not yet observable | <value/SHA/coverage-row/URL — not prose> |

- **Align calibration:** <did the pillarFit/scope/mission scores from alignment.md hold up in retrospect?>
- **Mission verdict:** <confirmed | refuted | pending-observation | n/a>
  - if `confirmed`/`refuted` → the Evidence cell(s) above CANNOT be empty.
  - if `pending-observation` → **re-check trigger:** <when / what signal to look at>
  - if `n/a` → **reason:** <why this feature does not close against any signal>

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted
Each field carries its `[deriv: ...]` marker — the locator where the number came from. Without a locator = invalid.

- **Gaps caught by /distill:** <N> `[deriv: <coverage.md / git log of distill>]` — <the notable ones>
- **RED→GREEN discipline:** <yes / no + exceptions> `[deriv: <coverage.md state history + git>]`
- **Rework post-/verify:** <N> · **post-/uat:** <N> `[deriv: <gaps routed in verification/reports/<feature>>]`
- **Escalations to the human:** <N> `[deriv: <trace / git>]` — <why>
- **Friction from the WoW itself:** <what in the harness got in the way or was missing> (only free-judgment field)

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** <rule or "none"> (apply via `memory/constitution/update-checklist.md`)
- **Candidate amendments → North Star:** <proposed ADR or "none"> (via `memory/north-star/base/amendment-protocol.md`)
