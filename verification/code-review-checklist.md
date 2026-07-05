# Code Review Checklist — AI-generated code

> "AI-generated code requires the same or greater scrutiny than human-written code."

- [ ] Imports/dependencies exist and are correct (no hallucinated packages).
- [ ] Error handling covers realistic failure modes, not just the happy path.
- [ ] No hardcoded secrets.
- [ ] The code complies with applicable `[given]` patterns (audit-log, rate-limit, idempotency…).
- [ ] Logic that "looks correct" was verified against the criterion, not assumed.
- [ ] Changes are traceable to rows in `coverage.md`.
