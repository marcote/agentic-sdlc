# Constitution — Base Principles (inherited, non-negotiable)

These principles are the most stable layer of the static context. Every spec, plan, and
verification must comply with them. They are inherited via `extends: base`.

1. **Verifiability.** Every requirement is expressed as a measurable acceptance criterion
   (BDD). What cannot be verified is not built.
2. **Test-first.** The deterministic portion of each criterion exists as a test in 🔴 RED
   before writing implementation (gate of `/contract`). An **invariant** criterion
   (*must-not-regress*: "X must never appear", "must stay dep-free") is **tied to an
   observable deliverable** to have a genuine RED phase — its test must fail until what it
   verifies exists. `green-by-construction` (green with nothing implemented) **does not count
   as 🔴** and the `/tasks` gate rejects it; tying it to the deliverable is the correct way
   to give it the RED→GREEN arc.
   *Must-not-regress guard exception:* a criterion whose sole job is to assert that an
   **already-green** behavior stays green through a change (e.g. "the existing gate behaves
   identically after a refactor") has **no honest RED phase** — breaking the behavior to
   redden it would be theater. Such a criterion is **annotated as a guard** (its linked test
   is the pre-existing green suite) and **excluded from the `/contract` RED-required set**,
   the same way `UAT (config)` rows are excluded. This is the complement of the rule above:
   fake-green that *should* be red is rejected; a guard that *protects* real behavior is kept.
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
