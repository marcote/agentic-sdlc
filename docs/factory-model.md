# The Factory Model

The developer's primary output is not code: it is the SYSTEM that produces code.
The dev defines specs and guardrails (constitution); the agent produces; the verification validates.

- **Developer zone:** defines specs → designs guardrails (constitution) → reviews/approves.
- **Factory floor (agent):** planning → coding → tests & verification → verified output.
- **Cross-cutting guardrails:** the constitution (declarative) + workflow gates.

`Agent = Model + Harness`. This repo IS the harness: instructions, tools, skills,
guardrails, feedback loops, and observability around the model.
