# Brief — 037-verify-last

## Objective
Slice 036 merged a red `main`. Accept ran the suite, and only after that the reflector wrote five new lessons. Test E6 compares the whole real lessons table with the migration table, so it failed on `main` and on PR #45. It is the same failure as L18 in slice 035: accept changes the tree after it verified it. In the 036 spec, the agent dropped a re-check after the reflector, by reasoning and not by evidence.

The owner is tired of this situation: each slice exposes a defect of the one before. The owner's order: finish what is pending before anything else. The trading repo waits until this is solved.

Pending:
- `main` is red (E6, and accept writes after the suite).
- The curator checks lessons against the constitution only, not against each other.
- A promoted check passes when its name appears anywhere in a file (L22).
- The suite takes 44.5 s against a budget of 45 s.

## Done means
- Accept merges exactly the tree the suite passed, except for its own report files in the slice directory.
- A memory change that breaks a test stops the merge before `main` moves.
- `main` and PR #45 are green.
- The curator also names conflicts between two active lessons.
- A promoted check must name a test function, a heading, or a script that exists.
- The suite runs well under its budget, and the budget goes down.

## Out of this slice
- Any new feature. Findings go to `docs/backlog.md` (L5).
- The trading repo.
