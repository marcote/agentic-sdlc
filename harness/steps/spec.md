# Step 2 — spec

Goal: a spec the owner can approve at gate H1 without a second meeting.

1. Read `brief.md`, the north star, the charter, and `docs/modules.md`.
2. Copy `specs/_template/spec.md` beside the brief. Fill every section.
   - Use only terms from the glossary. Add a new term to the spec glossary.
   - Write each requirement in EARS form, with one anchor in the north star.
   - Give each requirement one or more examples with real values. A requirement no example can check is `judged`, with a rubric.
   - Plan: tasks that cite requirements. Reuse modules from the map. Justify every new module or library in the `item | justification` table.
   - A change to the north star or the charter goes in the Amendments section.
3. Run `uv run scripts/spec.py page specs/<slice>/spec.md`. Fix every finding, then run it again.
4. Optional: draw the main scenarios with interfig as SVG, and reference them in the spec.
5. Show the owner `spec.html`. This is gate H1. Apply what the owner rejects, and render again.
6. After approval: commit, then run `uv run scripts/build.py specs/<slice>`.
