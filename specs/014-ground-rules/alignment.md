# Alignment — 014-ground-rules

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`
**as amended by ADR `0004`** (PR #17). **Run deterministically by the 006 engine**
(`scripts/north-star/engine.py`): `schema-valid` → exit 0; `scope-reject` per objective →
exit 1 for all five (no `out_of_scope` hit); `align-verdict` → `aligned`.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
`/distill` may proceed. Scores are **lower than 013's** (4/3/3 against 5/4/4), and that is
deliberate: this feature sits closer to the scope edge than its predecessor and the doubt rule
was applied rather than noted-and-ignored (see calibration).

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | O1 and O3 land squarely on `real-enforcement`, whose signal is *literally* "gates block closure when a condition is missing" — the `UNCOVERED` verdict is that sentence implemented. O2 lands on `agnostic-portability`: naming questions rather than answers is precisely what lets the floor survive vendoring onto an arbitrary stack. Held at 4, not 5, by **O4**: its mapping to `frictionless-adoption` is real but indirect — the `n/a`+reason escape is what keeps a disposable project cheap, yet the objective is stated as a property of the *floor*, and reading it as advancing an adoption signal requires a step of inference. Its `real-enforcement` mapping is solid; the aggregate min is the weaker of the two. |
| scope compliance | **3** | The lowest score any brief has taken here, and the reasoning is the point. This feature makes the harness **opinionated for the first time** — six mandatory questions shipped in `base/`, inherited by every adopter. That sits directly against the `out_of_scope` predicate *"imposing or naming a mandatory execution runtime"*. It does not **hit** it: `scope-reject` returned exit 1 on all five objectives, and a ground rule names no tool, language, runtime or vendor — *"how does anything outside reach this?"* prescribes nothing. But the rubric's band for "in-scope while touching the edge of an `out_of_scope` predicate" is exactly 3, and I am genuinely in doubt between 3 and 4. **013's retro recorded that I failed to apply the rubric's own instruction — *when in doubt prefer the lower* — and scored optimistically. Applying it here is following that lesson rather than repeating it.** The safeguard is inherited, not new: `no-prescribe.sh` already scans `memory/stack/base/` prose and will cover `ground-rules.md` the moment it lands. |
| mission advancement | 3 | O3 alone would score 5 (mechanical coverage reporting is directly observable). Held to 3 by **O4**: "the floor does not scale with `S0`" is a genuine and important property, but its effect on any named signal is *preventive* — it stops a future erosion that has not happened. That is plausible-but-hard-to-measure, which is the rubric's 3, and it is the same shape of claim that 013's retro judged to have been over-scored at 4. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — A project cannot reach its first technical plan while a load-bearing aspect has no recorded rationale | `real-enforcement`, `measurable-impact` |
| O2 — Ship exactly six universal ground rules that name questions and never answers, so the harness becomes opinionated without imposing any stack | `agnostic-portability`, `frictionless-adoption` |
| O3 — Ground-rule coverage is mechanically reportable (pin / `n/a`+reason / uncovered) and enforced by a fourth `/plan` verdict | `real-enforcement` |
| O4 — The floor is independent of the rigor tier: `S0` scales how deep each answer goes, never whether a ground rule is answered | `real-enforcement`, `frictionless-adoption` |
| O5 — Bring the harness's own charter to full ground-rule coverage (reflexive dogfood) | `real-enforcement`, `measurable-impact` |

## Orphans

None. Every objective maps to ≥1 pillar.

## Gate note

`scope-reject` cleared all five objectives (exit 1) and `align-verdict` returned `aligned`
deterministically from `{pillarFit: 4, scopeCompliance: 3, missionAdvancement: 3}`.

**`frictionless-adoption` is claimed — and it could not have been, one commit ago.** Under the
pre-amendment signal ("steps/time to adopt, lower = better") six mandatory questions were an
unambiguous negative and the only honest move would have been to leave the pillar unclaimed, as
013 did. ADR `0004` changed the measured quantity to *steps without a recorded justification*,
and this brief is built to satisfy exactly that: every ground rule must state what it prevents,
the count is hard-capped at six, and `n/a`+reason keeps a disposable project's cost to one line
per rule. **This is the first brief scored under the amended signal, which makes it the first
real test of whether the amendment was sound or self-serving.** `/retro` must rule on that, not
merely on the pillars.

Three things this gate flags for the feature to carry forward:

1. **`scopeCompliance: 3` is one point above rejection.** If the delivered `ground-rules.md`
   names a single tool, language, runtime or vendor as a default — even in an example outside a
   fenced block — the feature crosses from *mechanism* to *imposition* and retroactively fails
   the predicate. `/uat` must verify this against the shipped artifact, not the brief's promise.
   `no-prescribe.sh` makes it mechanical, but the judgment of whether a *question* smuggles an
   answer is not mechanical.

2. **The six-cap is a scored commitment, not a preference.** Part of why `frictionless-adoption`
   is claimable is that the friction is bounded. A seventh ground rule added later without
   removing one invalidates the basis of this score.

3. **`/retro` must rule on whether the amendment helped or laundered.** The honest failure mode
   is that ADR `0004` made a negative verdict unavailable and the pillar now passes by
   construction. The check: did any real adoption friction get *rejected* for lacking
   justification, or does everything now qualify?
