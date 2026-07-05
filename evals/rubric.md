# Eval Rubric

> "An eval without a clear rubric measures nothing." Five dimensions, each with
> explicit scale and threshold. Trajectory weighs as much as Task success: a green build that
> skipped verification is a FAIL.

| Dimension | What it measures | Type | Scoring | Threshold |
|---|---|---|---|---|
| **Task success** | does the artifact meet the criteria? | deterministic | tests green / total deterministic criteria | **100%** (non-negotiable) |
| **Tool use** quality | did it use the right tools, correctly? | trajectory | LM judge + checks vs `tasks.md` | ≥ threshold |
| **Trajectory** compliance | did it follow the flow? did it skip verification? | trajectory | LM judge over the trace | no steps skipped |
| **Hallucination** | hallucinated deps/APIs? | mixed | real imports check + judge | **0** |
| **Response quality** | non-deterministic criteria | non-determ. | eval cases + LM judge vs `acceptance` | ≥ threshold |
