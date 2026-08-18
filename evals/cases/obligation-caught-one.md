# Eval case — JUDGE-OBLIGATION-CAUGHT-ONE

**Feature:** 022-mutation-coverage · **Scored by:** an independent judge · **Not before:** the first
feature that closes *under* the gate rather than shipping it.

> 022's row originally read `/uat judgment, next feature` and named no file. 023 found it. The
> deferral was honest; leaving it unwritten was not, because a row naming nothing renders exactly
> like a row whose case is merely unscored.

## Question

022 made declaring a mutation an obligation derived from `coverage.md`. Does obliging **surface a
criterion its author would not otherwise have declared**, or does it confirm diligence that was
already there?

## What counts as evidence

**Confirmed** — `mutate.sh coverage --spec` reports a non-zero undeclared count at `/verify` for a
feature that had already reached `/verify` believing itself complete, and the criterion it names
turns out to be one worth proving.

**Refuted** — three consecutive features report `0 undeclared` on the first run. Then the obligation
is a receipt for work already done, and under the amended `frictionless-adoption` signal (ADR
`0004`) a mandatory step whose value is delivered elsewhere is friction that has to justify itself.

## Why it cannot be scored against 022 itself

022's verdict on its own matrix is 13 obliged, 0 undeclared. That number was produced by writing
thirteen declarations and then checking that they had been written. `D4` requires a bootstrapping
gate be **run** against itself; it does not make that run evidence of enforcement. The report says
so in those words.

## Trap

A `0 undeclared` result is ambiguous and must not be read as success. It means either the author
declared everything unprompted, or the predicate obliged nothing — the three conditions exclude
`[given]` rows, judged rows and rows whose linked test does not resolve. Read the **obliged** count
before reading the undeclared one.
