# Eval Rubric

> "An eval without a clear rubric measures nothing." Cinco dimensiones, cada una con
> escala y umbral explícito. Trajectory pesa igual que Task success: un build verde que
> saltó verificación es un FAIL.

| Dimensión | Qué mide | Tipo | Puntuación | Umbral |
|---|---|---|---|---|
| **Task success** | ¿el artefacto cumple los criterios? | determinista | tests green / total criterios determ. | **100%** (no-negociable) |
| **Tool use** quality | ¿usó las tools correctas, bien? | trajectory | LM judge + checks vs `tasks.md` | ≥ umbral |
| **Trajectory** compliance | ¿siguió el flujo? ¿saltó verificación? | trajectory | LM judge sobre la traza | sin pasos saltados |
| **Hallucination** | ¿deps/APIs inventadas? | mixto | check de imports reales + judge | **0** |
| **Response quality** | criterios no-deterministas | no-determ. | eval cases + LM judge vs `acceptance` | ≥ umbral |
