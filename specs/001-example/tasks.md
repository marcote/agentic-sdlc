# Tasks — Save card with 1-tap

> Executable breakdown. Produced by `/tasks`. GATE: implementation tasks are not issued
> while a deterministic criterion exists without a linked test in 🔴 RED.
> (Gate already passed: every deterministic criterion has its `.feature` linked in `coverage.md`.)

## Tasks
- [x] T1: `TokenizationClient` with 300ms timeout — covers: *token < 300ms*, *no PAN* (🟢, UAT ✅ first one)
- [x] T2: audit-log middleware on writes — covers: *audit-log* `[given]` (🟢)
- [x] T3: `OneTapPayHandler` (payment with saved card) — covers: *pays without re-entering* (🟢)
- [ ] T4: Idempotency by `idempotency-key` in `SaveCardHandler` — covers: *idempotency* `[given]` (🔴 → in progress)
- [ ] T5: Eval case for rejection message clarity — covers: *clear message* (📋 case to complete)

## Next step
Close T4 (🔴→🟢), then `/verify` on the feature and `/uat` against `acceptance.md`.
The feature does not close until BUILD ✅ + TRAJECTORY ✅ + UAT ✅ + coverage 100%.
