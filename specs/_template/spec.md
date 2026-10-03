# Spec <NNN> — <name>

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

## 1. Glossary

| term | meaning |
| --- | --- |

## 2. Requirements

| id | requirement | kind | anchor | examples |
| --- | --- | --- | --- | --- |

Kind is `mechanical` or `semantic`. A `semantic` requirement lists `judged` in examples.

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: a property every run keeps, from a north-star principle. Name the principles this slice relies on.
- reconciliation: an output compared with a published value from outside the repo.
- e2e run: a small run through every layer, with a fixed expected output.

The e2e run writes `specs/<slice>/results.json` as `[{"id": "<hypothesis or requirement id>", "value": "<text>"}]`.
Accept appends each entry to the north star, labelled reported.

A test may use recorded real data. A test does not mock the project's own code.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |

| item | justification |
| --- | --- |

## Memory applied

One row per active lesson in `memory/lessons.md`.

| lesson | applies |
| --- | --- |

## Sources

| practice | source | implies |
| --- | --- | --- |

## 6. Amendments

Changes to the north star or the charter. Gate H1 approves each row.

## 7. Assumptions and open items

| item | label |
| --- | --- |
