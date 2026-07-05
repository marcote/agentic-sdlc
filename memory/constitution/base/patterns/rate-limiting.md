# Pattern: Rate Limiting (given practice)

**Principle:** every network-exposed surface has a rate limit.
**Applies to:** any feature with public or semi-public endpoints.
**Injected criteria:**
- `[given]` each exposed endpoint responds `429` when the configured limit is exceeded.
  → maps to `eval: rate-limit`.
