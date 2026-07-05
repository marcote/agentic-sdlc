# fixture: valid.md with a changed governed set (new out_of_scope predicate)

Adds one out_of_scope predicate vs valid.md — a real amendment of the scope set.
`sets-changed` must report `changed`.

```json
{
  "mission": "A reusable harness that governs a disciplined agentic SDLC.",
  "pillars": [
    { "id": "real-enforcement", "statement": "gates block, not intentions", "signal": "gaps caught before merge" },
    { "id": "frictionless-adoption", "statement": "cheap to adopt", "signal": "steps to adopt (lower better)" }
  ],
  "scope": {
    "in_scope": ["governance workflow commands and gates", "adoption tooling"],
    "out_of_scope": ["application code of an adopting project", "blocking commit hooks", "stack-specific deterministic engine", "imposing a mandatory runtime"]
  },
  "alignment": { "threshold": 3 }
}
```
