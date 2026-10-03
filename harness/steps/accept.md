# Step 4 — accept

Goal: a merged slice, verified by machine.

1. When build exits 0, run `uv run scripts/accept.py specs/<slice>`.
2. Exit 0: the slice is on `main`. Show the owner `result.html`. The owner reads it; no approval is needed.
3. Exit 1: show the owner the ESCALATIONS list. That list is the only question to the owner.
4. Exit 3 from build: show the owner its ESCALATIONS list. Apply the answers to the spec. Commit each owner answer with the subject `spec(<slice>): answer escalation <task> <choice>` (an answer commit). Run build again.
