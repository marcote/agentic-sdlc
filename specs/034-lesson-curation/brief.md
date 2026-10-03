# Brief — 034-lesson-curation

## Objective
Slice 033 moved the lessons into the repo, but the migration copied some of them without checking them. L8 still says 35 words, while the constitution says 25. L2, L4 and L6 are marked as judgment, though a check already enforces them, so the page says 3 learned out of 10 when the truth is higher. L2 and L9 say the same thing. And spec 033 left one proposed lesson open: the lint must reject a requirement id that is also a task id. The owner wants the lessons curated, and a check so that a lesson can never again contradict the constitution.

## Done means
- No lesson contradicts a number the constitution states.
- Every lesson that a test enforces names that test and is learned.
- L2 is merged into L9.
- The lint rejects a requirement id that is also a task id, and that lesson is learned.

## Out of this slice
- Retiring lessons that are not used.
- The trading repo.
