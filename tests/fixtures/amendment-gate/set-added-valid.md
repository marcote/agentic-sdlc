# fixture: adds a new pillar (pillars set CHANGED); schema-valid

```json
{
  "mission": "m",
  "pillars": [
    { "id": "a", "statement": "sa", "signal": "ga", "since": "0001" },
    { "id": "b", "statement": "sb", "signal": "gb", "since": "0001" },
    { "id": "c", "statement": "sc", "signal": "gc", "since": "0001" }
  ],
  "scope": {
    "in_scope": ["ix"],
    "out_of_scope": ["ox"]
  },
  "alignment": { "threshold": 3 }
}
```
