# Evals

- `rubric.md` — cómo se puntúa (5 dimensiones).
- `cases/` — un case por criterio NO-determinista (formato libre: `.yaml`/`.md`).
  Los cases se crean en `/contract`, ANTES de implementar.

## Runner
El runner ejecutable concreto depende del stack del proyecto que adopte el harness
(fuera de alcance del template). El contrato: un case debe poder puntuarse contra el
`rubric.md` y su resultado alimenta la sección "Trajectory eval" / "Response quality"
del `verification-report.md`.
