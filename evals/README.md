# Evals

- `rubric.md` — how to score (5 dimensions).
- `cases/` — one case per non-deterministic criterion (free format: `.yaml`/`.md`).
  Cases are created in `/contract`, BEFORE implementing.

## Runner
The concrete executable runner depends on the stack of the project adopting the harness
(out of scope for the template). The contract: a case must be scoreable against
`rubric.md` and its result feeds the "Trajectory eval" / "Response quality"
section of `verification-report.md`.
