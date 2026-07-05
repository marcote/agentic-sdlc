# Pattern: Idempotency (given practice)

**Principle:** repeatable write operations are idempotent.
**Applies to:** any feature with retries, webhooks, or payments.
**Injected criteria:**
- `[given]` resending the same request with the same `idempotency-key` does not duplicate the effect.
  → maps to `eval: idempotency`.
