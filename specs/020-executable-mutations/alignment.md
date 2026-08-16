# Alignment — 020-executable-mutations

Measurability Gate over `brief.md` × `north-star.md` **as amended by ADR `0005`** — the first
feature scored against the lifecycle boundary. Run by the 006 engine: `schema-valid` exit 0;
`scope-reject` exit 1 on all seven objectives; `align-verdict` `aligned`.

## Verdict

**`aligned`** — `{pillarFit: 5, scopeCompliance: 5, missionAdvancement: 4}`, threshold 3.
Falsification run: dropping `missionAdvancement` to 2 returns `needs-amendment`.

The filter was proved live in the same run: the control objective *"we ship blocking commit hooks"*
fired at exit 0 while all seven real objectives cleared.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | **5** | `real-enforcement`'s signal is *"gates block closure when a condition is missing"*, and its statement is *"discipline is enforced by deterministic gates, not good intentions"*. `check-can-fail` has been a good intention in every feature since 015 — injected as a row, satisfied by a human writing that it was proved. This converts it to a gate. That is not an analogy to the pillar; it is the pillar's sentence. |
| scope compliance | **5** | `in_scope` names *"evals, verification, and UAT of the method"*. This is verification of the method's own checks. It is also the first brief scored against the four lifecycle predicates from ADR `0005`, and it approaches none of them. |
| mission advancement | 4 | `measurable-impact`'s signal is gaps caught early and late rework avoided. Two vacuous assertions in the last two features were rework caught at `/verify`; a mechanism that catches them at `/contract` moves the signal. Held at 4 because that is a **prediction about future features**, and the honest evidence — a criterion caught by the mechanism rather than by hand — cannot exist until a feature after this one. O5 partly answers it by replay, which is why this is 4 and not 3. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — a criterion declares its mutation inline, in a parseable grammar | `real-enforcement` |
| O2 — the suite applies each mutation and requires the named criterion to fail | `real-enforcement`, `measurable-impact` |
| O3 — the mutation is reverted either way, the tree proved byte-identical | `real-enforcement` |
| O4 — a criterion that cannot fail is named, with the mutation that failed to break it | `real-enforcement` |
| O5 — 019's vacuous criterion is caught, replayed as a fixture | `measurable-impact` |
| O6 — the added wall-clock cost is measured and recorded | `frictionless-adoption` |
| O7 — green and hermetic; adopters inherit the pattern without the runner | `agnostic-portability` |

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |
| `agnostic-portability` | `0001` |

`frictionless-adoption` is stamped at `0004`, whose amended signal is what makes O6 a real objective
rather than a courtesy: an unjustified cost is the defect that ADR measures.

## Orphans

None.

## Pillars deliberately NOT claimed

- **`frictionless-adoption` is claimed only by O6**, and narrowly. The mechanism adds a mandatory
  step for anyone writing a check in this repository. Under ADR `0004` that step must carry a
  justification proportional to what it prevents, and O6 is the measurement of its price — not a
  claim that adoption got easier.

## Gate note

1. **`D4` applies and the four conditions must be met.** This ships a gate that judges criteria,
   and its own criteria are criteria. The exemption is from being **blocked**, never from being
   **run**: the mechanism must emit a real verdict against this feature's own assertions before
   close, and a trivial pass because nothing touches does not discharge it. `plan.md` must declare
   this before implementation.

2. **The risk that this feature is itself vacuous is the highest of any feature so far.** A
   mutation runner that reports *"all criteria failed under their mutations"* while never applying
   a mutation is indistinguishable from success — the exact family it exists to catch, one level
   up. The runner needs its own negative: a criterion declared with a mutation that provably does
   **not** break it must be reported.

3. **O5 is the falsification test, and it is unusually strong.** Most features defer their proof.
   This one has two real historical instances. **Replaying 019's vacuous
   `NS-PREDICATE-REACHABLE` and 018's `ADOPT-REL-RESOLUTION` as fixtures is the whole question:**
   if the mechanism does not catch what was actually shipped, it does not work, and no amount of
   synthetic fixtures makes up for that. Neither may be replayed in a form edited to be easier to
   catch.

4. **`B7` bounds the design.** The suite already re-runs itself once for `check_96`. A per-mutation
   re-run of the whole suite would multiply that; O6 commits to measuring the real cost, and a
   design that re-runs only the affected check file is the obvious answer but must be shown to
   still detect the failure.
