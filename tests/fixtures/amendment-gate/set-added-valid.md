# fixture: adds a new pillar (pillars set CHANGED); schema-valid

```json
{
  "mission": "m",
  "pillars": [
    { "id": "a", "statement": "sa", "signal": "ga" },
    { "id": "b", "statement": "sb", "signal": "gb" },
    { "id": "c", "statement": "sc", "signal": "gc" }
  ],
  "scope": {
    "in_scope": ["ix"],
    "out_of_scope": ["ox"]
  },
  "alignment": { "threshold": 3 }
}
```
