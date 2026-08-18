# Eval case — JUDGE-STALE-READ-FIRST-TIME

**Feature:** 027-mutation-diagnostics · **Scored by:** an independent judge · **Not before:** a
feature after 027 produces a stale declaration.

## Question

027 split `survived its own mutation` into *weak* and *stale*. **Does the new diagnosis change what
the author does**, or is it a better word for a thing they were going to investigate the same way?

## What counts as evidence

**Confirmed** — a later feature's run reports `STALE`, and its retro shows the author went straight
to the declaration's anchor rather than to the criterion. The measurable form: no cycle spent
re-reading the criterion's logic before fixing the edit.

**Refuted** — a later feature reports `STALE` and its author still rewrites the criterion first, or
the run reports stale for a declaration the author then fixes by weakening the assertion. Then the
outcome is a label and the cost of computing it is not repaid.

## Why it cannot be scored now

Every declaration 027 ships was written **after** the outcome existed and by the person who added
it. 026's replay proves the mechanism fires on a real historical instance; it cannot show whether
the word helps somebody who did not write it.

## Trap

Do not score this on the count of stale declarations found. A high count means the authoring habit
is poor, which is `B21`'s subject, not this one. This asks only whether the **diagnosis** is acted
on correctly once given.
