# Eval case — JUDGE-PREVENTS-THE-SIXTH

**Feature:** 020-executable-mutations · **Scored by:** an independent judge · **Not before:** the
first feature that closes after 020.

## Question

Declaring a mutation is opt-in. Does this mechanism prevent the next vacuous assertion, or does it
only make the manual proving repeatable and auditable?

## What counts as evidence

**Confirmed** — a feature after 020 ships a criterion, declares its mutation, and the runner reports
`survived its own mutation` **before** `/verify`'s by-hand exploration finds it. That is the
mechanism catching what reading would have missed.

**Refuted** — a vacuous assertion ships in a feature after 020 and is caught the old way, by hand at
`/verify`, because its author did not declare a mutation for it. Then the gap is the *declaring*,
not the running, and the follow-up is a rule about who must declare.

## Why it cannot be scored now

020 proves the mechanism catches 018's and 019's real defects **in replay**. Replay shows the
mechanism works on known instances. It cannot show whether the next author reaches for it.

## Trap

Do not score this against 020's own criteria. Six of this feature's thirteen mutations initially
failed to break anything and were rewritten — which proves the runner works, not that the habit
holds when nobody is watching for it.
