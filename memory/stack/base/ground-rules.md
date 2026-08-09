# Ground rules (base)

The **floor of the charter**: aspects of a project that must have a recorded rationale before
implementation begins. Each is answered by a pin declaring `Answers: GR<n>`, or declined with an
`n/a` block carrying `Because` + `Falsifier`. Never by silence, and never by omission.

A ground rule names a **question**, never an answer. That distinction is what lets this file be
universal without imposing anything: *"how does anything outside reach this?"* prescribes no
technology — it only forbids not having thought about it. A file that named answers would be a
different thing entirely, and would not belong in a stack-agnostic harness.

`/plan` refuses to proceed while any ground rule lacks a verdict (`UNCOVERED`).

## The six

There are exactly six, and **six is a hard cap** — asserted in the suite, not merely written
here. A seventh may only enter by removing one. This bound is part of why the friction is
justified rather than merely tolerated: an unbounded list becomes a thirty-question intake form,
and the first thing anyone does with a thirty-question form is stop reading it.

### GR1 — Consumption
- Question: How does anything outside reach this, and is the core separable from the way it is
  reached?
- Prevents: fusing computation and transport by default, so that adding a second consumer later
  means rewriting rather than adding. The cost of deciding this on day one is approximately
  zero; the cost of reversing it is a rewrite.

### GR2 — Persistence and concurrency
- Question: What holds state, and how many things write to it at the same time — today, and
  plausibly within a year?
- Prevents: choosing a store against an unstated concurrency assumption, and discovering the
  mismatch only when a second writer appears. State and concurrency are one question because
  answering either alone leaves the expensive half undecided.

### GR3 — Deployment and topology
- Question: Where does this run, and in how many instances?
- Prevents: deciding the target last, after an architecture has quietly assumed a single
  machine, a local filesystem, or a process that never restarts.

### GR4 — Language, runtime and execution
- Question: What is this written in, which version, how are dependencies declared, and how is it
  run?
- Prevents: an implicit toolchain — one that works on the author's machine, is never written
  down, and has to be reconstructed by whoever arrives next or by the automation that builds it.

### GR5 — What "verified" means
- Question: What does the verification command actually exercise, and what does a passing run
  prove?
- Prevents: a green result that proves less than everyone assumes. A suite whose meaning is
  unstated cannot be trusted at the moment it matters, which is the moment it disagrees with you.

### GR6 — Failure posture
- Question: When this breaks, what happens — does it retry, corrupt, alert, or continue
  silently?
- Prevents: discovering the answer during the incident. Failure behaviour that was never chosen
  is failure behaviour that was chosen by accident.

## Answering, and declining

**Answer** a ground rule with a pin that declares `Answers: GR<n>`. One pin may answer several
rules; a rule is covered if any live pin claims it. A `SUPERSEDED` pin does **not** count —
history is not a rationale, and if it counted, amending a pin would silently drop the project
below the floor.

**Decline** a ground rule that genuinely does not apply:

```markdown
### GR2 — n/a
- Because:   a pure transformation; nothing outlives the process and nothing is written
- Falsifier: any output is retained between runs, including a cache
```

A declination is **not a pin**: no decision was taken, so there is nothing to price and no
`Buys` or `Forecloses` to state. Its `Falsifier` is what makes it **expire** — a decline written
in week one stops being valid the moment the project crosses the stated line, instead of
silently outliving the conditions that justified it.

Declining is the escape hatch that keeps this floor cheap for small work: a disposable project
may honestly decline several rules at one line each. It is also the easiest way to defeat the
floor without appearing to, so a decline that is convenient rather than true is a defect, not a
shortcut.

## The floor does not scale

`S0` scales **how deep** an answer goes and how many pins exist beyond the floor. It never
scales **whether** a ground rule is answered. This is the second floor alongside `P6` in
`memory/constitution/base/principles.md`: at the most disposable tier, the answers get shorter
and more of them are declines — the questions still get asked.

## Extending

A project may **add** ground rules in `memory/stack/ground-rules.md` (`extends: base`), the same
inheritance idiom `constitution.md` and `north-star.md` already use. It may not **remove** one:
the effective set is rejected if any base rule is missing. Removal is unnecessary because the
auditable escape already exists — decline it, and say why.
