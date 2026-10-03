# Constitution — Base Principles (inherited, non-negotiable)

These principles are the most stable layer of the static context. Every spec, plan, and
verification must comply with them. They are inherited via `extends: base`.

1. **Verifiability.** Every requirement is expressed as a measurable acceptance criterion
   (BDD). What cannot be verified is not built.
2. **Test-first.** Each example exists as a test in 🔴 RED before implementation: build's T0 RED gate.
   An **invariant** ("X must never appear", "must stay dep-free") is **tied to an observable deliverable**.
   Its test then fails until what it verifies exists.
   A test that is green with nothing implemented **does not count as 🔴**, and T0 rejects it as vacuous.
   *Must-not-regress guard exception:* a criterion that only asserts an **already-green** behavior stays green has **no honest RED phase**.
   Breaking the behavior to redden it would be theater.
   Such a criterion is **annotated as a guard**: its test is the existing green suite, and T0 does not require it red.
   Fake green that *should* be red is rejected; a guard that *protects* real behavior is kept.
   *Interactive-IO exception:* a real terminal exchange (a `[y/N]` prompt read from `/dev/tty`) has **no honest hermetic RED**.
   Such a criterion is validated by hand, outside accept's machine verification, and T0 does not require it red.
   Its **deterministic neighbors stay in** the RED set: a `--yes` flag or a no-terminal abort still reddens and greens normally.
3. **Full traceability.** Every objective in the brief reaches a criterion; every criterion
   maps to an eval or UAT step. Orphan rows = gap that blocks the spec freeze.
4. **Productivity first.** Verification is on-demand: no blocking per-commit hooks,
   the inner loop — local commit and push to work branches — never stops, and feature
   throughput is not gated. Only exception allowed: a **narrow governance gate** on the
   protected integration branch (protecting product governance), as long as it does **not**
   block that throughput; its concrete instance is declared as a delta in the project's
   `constitution.md`.
5. **Auditable trail.** Each verification produces a versioned report.
6. **Security by default.** No secrets in the repo; inherited patterns
   (below) apply unless overridden with justification in the project's `constitution.md`.
