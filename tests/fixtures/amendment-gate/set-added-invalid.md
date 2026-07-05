# fixture: adds a new pillar (set CHANGED) but leaves the JSON schema-INVALID

Pillar `c` has an empty `signal` → violates `base/schema.md` (signal must be non-empty string).

```json
{
  "mission": "m",
  "pillars": [
    { "id": "a", "statement": "sa", "signal": "ga" },
    { "id": "b", "statement": "sb", "signal": "gb" },
    { "id": "c", "statement": "sc", "signal": "" }
  ],
  "scope": {
    "in_scope": ["ix"],
    "out_of_scope": ["ox"]
  },
  "alignment": { "threshold": 3 }
}
```
