# Pattern: Non-vacuous Checks (given practice)

**Principle:** an assertion that cannot fail proves nothing, and a result nobody can trace back to
a criterion is not a result. The harness already gates that a test **exists** and goes **red**; it
gates nothing about whether an assertion **can fail** or whether a declared check **actually ran**.

**Applies to:** any feature that ships an assertion — a test, a gate, a guard, a lint rule, a CI
step. In practice that is every feature. The cost is one row per applicable criterion; the
evidence is **11 defects of this family across three features** (`e6bc658` in 008, five in 013,
five in 014), every one caught by hand, one caught only because a human asked a question the
artifacts could not answer.

**Injected criteria:**

- `[given]` an assertion is proved to **fail on a violating fixture**, not only to pass on a
  conforming one. → maps to `eval: check-can-fail`.
  *Prevents:* a check that reports a floor that is not there. Every gate downstream then proceeds
  with a clean conscience.
- `[given]` every criterion label declared in a check **emits a result in the run output**, so
  "did this criterion execute?" is answerable from the run and not from reading the file. → maps
  to `eval: check-traceable`.
  *Prevents:* an assertion that silently never executes — a borrowed fixture pointing at a missing
  file recorded neither PASS nor FAIL (013), and `DEPFREE` in 008 emitted through a shared helper
  that carried no criterion label, undetected for a month in a green suite.
- `[given]` an assertion that a bad input is **rejected** requires the **named diagnostic**, not
  only a non-zero exit code. → maps to `eval: check-rejects-by-diagnostic`.
  *Prevents:* passing because the capability *does not exist*. Three assertions in 014 were green
  against an unimplemented subcommand, because the runner's own "unknown command" error exits with
  the same code the assertion expected.
- `[given]` a check that **scans its own source** for a forbidden literal assembles that literal at
  runtime, so it cannot match its own scanning line, and is proved so by a self-test. → maps to
  `eval: check-no-self-match`.
  *Prevents:* self-detection — three occurrences (`check_90`/`e6bc658`; `HERMETIC-ENV` matching its
  own `/dev/tty` grep; a grace-period pattern flagging the sentence that *denies* a grace period).
- `[given]` a check that reports on a tree, range or revision **states which one** in its output.
  → maps to `eval: check-names-its-tree`.
  *Prevents:* a confident false verdict from the wrong input. Twice on the same day: the amendment
  gate reported "not applicable" over an **empty commit range**, and a hermeticity check reported a
  false result against a clone of **uncommitted** work. Neither was a tool defect; both were
  invisible because the tool never said what it had looked at.

## `check-can-fail`, executed

The first row above may be satisfied by a human writing *"proved failable"* in a report. The
proving is real when it happens; it happens **once, by hand, and is never repeated**. A criterion
that could fail in one month is not thereby asserted to still be able to fail in the next.

A criterion may instead declare the edit that must break it, next to the assertion:

```
# --- SOME-CRITERION: what it asserts ---
# --- [mut$ printf 'BAD\n' > subject.txt $] ---
```

A runner applies that edit to a throwaway copy of the tree, re-runs the check file that owns the
criterion, and requires it to emit `FAIL`. One that survives is named, with the edit that failed to
break it.

**Three outcomes, and they are not interchangeable.** *Proved* · *survived its own edit* · *emitted
nothing at all*. The third must never be read as the first: silence and failure look identical from
outside, which is this pattern's whole subject.

**The runner needs its own negative.** One reporting every criterion as failable while applying
nothing is indistinguishable from one that works.

**Evidence it was worth building.** Two vacuous assertions shipped in consecutive features and were
caught only by mutating by hand — an assertion comparing two copies of the same tree, and one
building its test input from the artifact under test. Replayed against this mechanism in the form
actually shipped, both are reported.

*Adopters inherit the pattern, not the runner.* A runner encodes a repository's own `_pass`/`_fail`
conventions. The declaration grammar is the portable part.

## What this pattern does not cover

**Semantic vacuity stays a review concern.** Whether an assertion's pattern is satisfied by text
that was already present (`wow-report =~ /pin/`), or is too loose to discriminate (an unanchored
name matching a longer word), requires knowing what the assertion *means*. Claiming otherwise
would repeat this pattern's own failure mode one level up.

**An undeclared criterion is invisible to any mechanisation of this.** A tool can verify that
everything *declared* emits; it cannot know about a criterion nobody wrote down.

**Two of these five can be mechanised, and doing so is worth more than the rows.** `check-traceable`
and `check-no-self-match` are decidable from a run log and the check sources: parse the criterion
labels a file declares, require each to emit a result inside that file's own section of the run,
and require a scan whose target can include the scanning file to build its pattern at runtime.
Built that way in this repository's own suite on 2026-08-09, it found **fifteen** untraceable
criteria across five files from five closed features — none of which a per-feature coverage row
would have reached, because none of those features were open.

**Mechanise them in your stack and you may stop injecting those two rows**, recording the swap as
an override with the gate it depends on named, so the exemption cannot outlive the gate. The
harness ships no such tool: any implementation is bound to its own suite's conventions, and one
built for another repo's conventions would be an imposed answer rather than a required question.

The remaining three stay with review either way. `check-can-fail` needs to know whether a fixture
genuinely violates what the assertion asserts, and that is a question about meaning.

## Why a `[given]` row should do what prose did not

This rule was written down twice before landing: proposed in 013's retro, restated as decision D10
in 014's plan. **Occurrences 6–10 happened anyway, in the same branch as the warning.** The
difference now is not emphasis, it is position: a `[given]` criterion becomes a row in
`coverage.md`, and a feature does not close below 100% coverage. A retro proposal and a plan
decision were gated by nothing.

That is a falsifiable claim, and the next feature to ship a vacuous check while carrying these rows
in its coverage refutes it.
