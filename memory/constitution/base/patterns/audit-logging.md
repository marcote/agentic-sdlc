# Pattern: Audit Logging (given practice)

**Principle:** every operation that writes state leaves an auditable trail.
**Applies to:** any feature with write endpoints/actions.
**Injected criteria:**
- `[given]` each write operation emits an audit-log with `actor` + `timestamp` + `entity`.
  → maps to `eval: audit-trail`.
