# Eval case — JUDGE-AUDIT-WORTH-IT

**Feature:** 021-mutation-audit · **Scored by:** an independent judge, not the model that ran the
audit · **Not before:** 2026-09-16

> Written retroactively by 023, which found this file cited and absent. 021's coverage row named it
> at `/contract` as `evals/README.md` requires; the file was never created, and the matrix rendered
> as though it had been.

## Question

021 re-declared 019 mutations from two closed features and ran them. **18 of 19 reproduced.** Was
the audit worth its cost, or did it confirm what was already true and bill a feature for it?

## What counts as evidence

**Confirmed** — the audit changed what a later feature does. The concrete candidate is already on
the record: 021's coverage finding (018 recorded 11 mutations against 16 criteria) is what
redirected `B15` away from *detecting suspect shapes* toward *criteria without a declaration*, and
022 was built on that redirection. If a judge reading 021 and 022 agrees the second could not have
been designed correctly without the first, the audit paid for itself.

**Refuted** — the validity number (18/19) was the audit's headline and it moved nothing. The
coverage gap was measured **while writing the brief**, before any mutation ran, so a judge may
reasonably hold that a `mutate.sh coverage` count would have produced the same redirection in an
afternoon. Then 021 was an expensive way to confirm that hand-written mutations were mostly fine.

## Why it cannot be scored by its author

021's own retro argues the audit was worth it. That is the party with an interest. The prediction it
opened — *"7 or 8 of these 19 will not break their criterion"* — was wrong by a factor of seven in
the flattering direction, and a feature whose advance prediction was that far off should not grade
its own usefulness.

## Trap

Do not score this on whether the audit found defects. It found three, all in 020, all by *using*
the tool rather than by auditing. That is evidence 020 was under-tested, not that auditing 018 and
019 was the right way to spend the feature.
