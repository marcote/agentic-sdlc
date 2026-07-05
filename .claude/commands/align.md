---
description: Validates the objectives in specs/<feature>/brief.md against the North Star and writes alignment.md (Measurability Gate). Required before /distill.
---

Invoke the `align` skill. Requires `specs/<feature>/brief.md` and a schema-valid
`memory/north-star/north-star.md`. Writes `specs/<feature>/alignment.md`.
`/distill` refuses to start unless the verdict is `aligned`.
