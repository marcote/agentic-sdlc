# Brief — 036-memory-process

## Objective
Slice 034 answered a semantic question with a parser: a regex compared numbers in lessons with numbers in the constitution. It flagged L18 ("Python 3.11 or later") against D5 ("20 or fewer"), and `main` is red. The owner calls it the most elementary mistake: "no entiende contexto, un parser tonto." The owner had asked for the state of the art, and we copied its format but not its principle. The memory already held the lesson (L3: fixtures hold your own assumptions), and nobody used it.

The owner's rules for this slice:
- "Acá no hay intuición. Hay proceso." A design starts from a sourced review of the state of the art, not from the agent's intuition.
- All memory is used, the good and the bad decisions. No selective memory.
- No `retired` lessons. A lesson evolves: it is promoted into a rule or a check, or merged into another lesson. History stays.
- "Captured" versus "used" is only a statistic. Drop it as a status.
- Limit memory like a cache: L0 is enforced by a check, L1 is always loaded with a cap, and L2 is loaded on demand. Build L2 only when the cap is crossed.

The review is in `research.md`, beside this brief.

## Done means
- `main` is green, and no parser judges what a lesson means.
- A model judges whether a lesson conflicts with the constitution or with another lesson. It names the clause, and the owner resolves the conflict at the next H1. A judge's false alarm costs one look, never a red `main`.
- The judge is checked against labeled cases before we trust it, and the numbers are on the result page.
- Lessons have the statuses `active`, `proposed`, `promoted` and `merged`. Every current row is migrated, and the owner approves each move at H1.
- Every spec says, for each requirement, whether it is mechanical or semantic. A semantic one is judged, never parsed.
- Every spec cites its sources, and says how each active lesson applies.
- The brief step asks for the sourced review. The spec step reads the whole memory.

## Out of this slice
- L2 on-demand lessons (build when L1 crosses its cap).
- A model review of the spec before H1.
- Onboarding and `/status` (slice 037).
- Pushing and the open PR #44 (the owner decides after accept).
