# fixture: same governed sets as valid.md, different mission wording + prose

Different human prose here. Pillars and scope sets are byte-identical to valid.md;
only the mission string and this surrounding text differ. `sets-changed` must report `same`.

```json
{
  "mission": "A totally reworded mission that does not touch pillars or scope.",
  "pillars": [
    { "id": "real-enforcement", "statement": "gates block, not intentions", "signal": "gaps caught before merge" },
    { "id": "frictionless-adoption", "statement": "cheap to adopt", "signal": "steps to adopt (lower better)" }
  ],
  "scope": {
    "in_scope": ["governance workflow commands and gates", "adoption tooling"],
    "out_of_scope": ["application code of an adopting project", "blocking commit hooks", "stack-specific deterministic engine"]
  },
  "alignment": { "threshold": 5 }
}
```
