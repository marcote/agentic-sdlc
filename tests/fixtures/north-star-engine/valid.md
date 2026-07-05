# fixture: schema-valid north-star (canonical, realistic out_of_scope)

Human prose. The canonical block below is what the engine reads.

```json
{
  "mission": "A reusable harness that governs a disciplined agentic SDLC.",
  "pillars": [
    { "id": "real-enforcement", "statement": "gates block, not intentions", "signal": "gaps caught before merge" },
    { "id": "frictionless-adoption", "statement": "cheap to adopt", "signal": "steps to adopt (lower better)" }
  ],
  "scope": {
    "in_scope": ["governance workflow commands and gates", "adoption tooling"],
    "out_of_scope": ["application code of an adopting project", "blocking commit hooks", "stack-specific deterministic engine"]
  },
  "alignment": { "threshold": 3 }
}
```
