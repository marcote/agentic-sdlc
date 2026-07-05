# fixture: agrega un pilar nuevo (set CAMBIÓ) pero deja el JSON schema-INVÁLIDO

El pilar `c` tiene `signal` vacío → viola `base/schema.md` (signal string no vacío).

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
