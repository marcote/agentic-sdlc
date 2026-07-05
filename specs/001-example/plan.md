# Technical plan — Save card with 1-tap

> HOW it is built. Produced by `/plan`. Grounded in the constitution: cannot violate
> a non-negotiable or a `[given]` pattern without a justified override.

## Technical decisions
- **Tokenization via external vault** (we don't store the PAN). Trade-off: network dependency
  → mitigated with timeout and degradation to "not saved" (never blocks an approved purchase).
  Constrained by the *security by default* principle + PCI objective.
- **Idempotency by `idempotency-key`** on the save endpoint. Required by the
  `[given] base/idempotency` pattern.
- **Audit-log via middleware** on every write. Required by `[given] base/audit-logging`.

## Components / modules
- `TokenizationClient` — talks to the vault; 300ms timeout; single responsibility.
- `SaveCardHandler` — orchestrates save + idempotency + audit; interface `save(card, key)`.
- `OneTapPayHandler` — retrieves token and executes the 2nd purchase payment.

## Risks
- Slow vault degrades UX → timeout + fallback "not saved" (don't block purchase).
- `idempotency-key` collision between users → key namespaced by user.
