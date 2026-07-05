---
description: Generate the test contract (deterministic) and eval cases (non-deterministic) and prove it is RED.
---

For each criterion in `acceptance.md`:
- Deterministic → generate the test (BDD) and link it in `coverage.md`. RUN the suite: it must be 🔴 RED
  (proves the test is real and the feature does not exist yet). Record the linked test per criterion.
- Non-deterministic → create a case in `evals/cases/` (state 📋).
Do not mark any row as ready until you confirm RED status (deterministic) or case present.
