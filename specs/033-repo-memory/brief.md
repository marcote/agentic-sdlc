# Brief — 033-repo-memory

## Objective
The owner said memory that lives in Claude's local store is lost when the harness is ported to another repo or run by another agent. Today the lessons and the owner's working preferences live in `~/.claude/projects/.../memory/`. That is the store of one agent, on one machine. The owner wants memory to be part of the harness: in the repo, versioned, read by any agent. The lessons that can be checked by a machine should become checks. And the harness should learn by itself, slice by slice, from what build and accept record.

## Done means
- The lessons and the owner's preferences live in the repo, and every agent reads them through `AGENTS.md`.
- Each lesson names the check that enforces it, or says why no check can.
- After each slice, a reflection step proposes new lessons from the build report. Soft lessons land by themselves; new rules wait for the owner at the next gate H1.
- Build gives the implementer and the reviewer the active lessons.

## Out of this slice
- A memory server outside the repo.
- Rebuilding a test when an example changes after T0, and slice-scoped test names. They stay in the backlog as lessons without a check.
- The trading repo.
