# fixture: adds a new pillar (set CHANGED) but leaves the JSON schema-INVALID

Pillar `c` has an empty `signal` → violates `base/schema.md` (signal must be non-empty string).

```json
{
  "mission": "m",
  "pillars": [
    { "id": "a", "statement": "sa", "signal": "ga", "since": "0001" },
    { "id": "b", "statement": "sb", "signal": "gb", "since": "0001" },
    { "id": "c", "statement": "sc", "signal": "", "since": "0001" }
  ],
  "scope": {
    "in_scope": ["ix"],
    "out_of_scope": ["ox"]
  },
  "alignment": { "threshold": 3 }
}
```
