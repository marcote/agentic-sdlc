---
extends: base
---

# North Star — Ledger

## Canonical North Star

```json
{
  "mission": "Turn a plain-text ledger into a total a person can check by hand",
  "pillars": [
    {
      "id": "checkable-by-hand",
      "statement": "Every number the tool prints can be traced back to the lines that produced it",
      "signal": "a reader reproduces the printed total from the input without running the tool",
      "since": "0001"
    }
  ],
  "scope": {
    "in_scope": ["reading a plain-text ledger from stdin", "printing one total"],
    "out_of_scope": ["storing anything between runs", "a graphical interface"]
  },
  "alignment": { "threshold": 3 }
}
```
