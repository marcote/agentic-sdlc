# fixture: well-formed JSON but schema-invalid (empty mission)

The JSON parses fine, but `mission` is empty → schema-invalid.
`schema-valid` must exit 1 (invalid), NOT exit 2 (malformed).

```json
{
  "mission": "",
  "pillars": [
    { "id": "a", "statement": "sa", "signal": "ga" }
  ],
  "scope": {
    "in_scope": ["x"],
    "out_of_scope": ["y"]
  },
  "alignment": { "threshold": 3 }
}
```
