---
description: Closes the measurable prediction of /align when a feature closes. Writes specs/<feature>/retro.md (Face Mission + Face Method). Required for the DONE verdict.
---

Invoke the `retro` skill. Requires the feature closed in `verification/reports/<feature>`
(BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%) and `specs/<feature>/alignment.md`.
Writes `specs/<feature>/retro.md`. Without a complete retro the feature is not DONE.
