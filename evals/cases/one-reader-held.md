# Eval case — JUDGE-ONE-READER-HELD

**Feature:** 026-matrix-parser · **Scored by:** an independent judge · **Not before:** a fourth tool
needs to read `coverage.md`.

## Question

026 replaced three parsers with one. **Does the single reader hold**, or does the next tool grow its
own `awk -F'|'` because sourcing a helper felt heavier than three lines of awk?

## What counts as evidence

**Confirmed** — a fourth consumer appears and sources `scripts/lib/matrix.sh`, including the case
where it needs a column the helper does not yet expose and the helper is extended rather than
bypassed.

**Refuted** — a fourth parser appears. The likeliest form is not defiance but convenience: a check
file or a one-off script that needs one column and splits the line inline. `MTX-SINGLE-READER`
guards the three known consumers by name and would not see it.

## Why it cannot be scored now

There is no fourth consumer. Three existed because they were written months apart, each solving its
own problem, and none of their authors knew they were the third.

## Trap

Do not score this on whether `MTX-SINGLE-READER` stays green. That criterion checks the three tools
named in it. A judge scoring it would be scoring the guard's scope, not the property — which is the
whole failure family this repository keeps finding.
