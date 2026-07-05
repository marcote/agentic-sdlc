# fixture: valid.md with pillars and scope entries reordered (same sets)

Pillars swapped, scope arrays reordered — the SET content is identical to valid.md.
`sets-changed` must report `same` (comparison is set-based, order-agnostic).

```json
{
  "mission": "A reusable harness that governs a disciplined agentic SDLC.",
  "pillars": [
    { "id": "frictionless-adoption", "statement": "cheap to adopt", "signal": "steps to adopt (lower better)" },
    { "id": "real-enforcement", "statement": "gates block, not intentions", "signal": "gaps caught before merge" }
  ],
  "scope": {
    "in_scope": ["adoption tooling", "governance workflow commands and gates"],
    "out_of_scope": ["stack-specific deterministic engine", "blocking commit hooks", "application code of an adopting project"]
  },
  "alignment": { "threshold": 3 }
}
```
