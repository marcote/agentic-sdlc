# Protocolo de amendment (base)

> Un North Star que se puede editar en silencio no es gobernanza, es decoración.
> Todo cambio al `scope` o a los `pillars` de un proyecto es un evento **gobernado
> y auditable**: requiere un ADR y aterriza solo vía un PR aprobado por humano.
> Nunca un commit directo a `north-star.md`.

## Cuándo se requiere un amendment

Cualquier cambio al bloque JSON canónico de `north-star.md` que toque:

- `pillars` — agregar, quitar, o cambiar materialmente el `id`, `statement` o
  `signal` de un pilar.
- `scope.in_scope` o `scope.out_of_scope` — agregar, quitar, o angostar/ensanchar
  un predicado.

La regla es determinista (equivalente a `requiresAdr(oldNs, newNs)`, per-stack): un
diff limitado a la prosa, a la redacción de la `mission` que no cambia los conjuntos
de `pillars`/`scope`, o al ajuste de `alignment.threshold` **no** requiere un ADR; un
diff de `pillars`/`scope` **siempre** lo requiere.

## Qué significa "amendment = ADR + PR"

1. **Un ADR** aterriza en `memory/north-star/decisions/NNNN-*.md` (número
   secuencial, slug kebab-case), usando `adr-template.md`. Debe contener:
   - **Contexto** — por qué el North Star actual ya no encaja (qué presión o drift
     observado motivó el cambio).
   - **Decisión** — el before/after exacto de los campos `pillars`/`scope`.
   - **Scope-delta** — una declaración explícita de qué se mueve de `out_of_scope`
     a `in_scope` (o viceversa), para que el radio de impacto sea visible de un
     vistazo, no enterrado en un diff de JSON.
   - **Consecuencias** — qué habilita o prohíbe de nuevo, y cualquier follow-up
     (p. ej. features antes rechazadas que ahora son elegibles).
2. **Un PR** lleva el ADR + el diff de `north-star.md` juntos. Un humano lo revisa y
   aprueba — la aprobación del amendment explícitamente **no** está automatizada. El
   PR es el rastro auditable: reviewer, timestamp y diff son todos git-nativos.

## Enforcement

Un checker (equivalente a `hasAdrFor(decisionsDir)`, per-stack) verifica que exista
al menos un ADR para una ventana de cambio dada. Un cambio de `pillars`/`scope` a
`north-star.md` que aterriza **sin** un ADR correspondiente es una **violación de
gobernanza** — señalizala igual que se señalaría un test faltante, por el criterio
`AMEND-ADR` de `specs/002-north-star-governance/acceptance.md`. Este es el patrón
`[given] audit-logging` (`memory/constitution/base/patterns/audit-logging.md`)
aplicado a la gobernanza de producto en vez de a endpoints de escritura: la
"escritura" acá es un cambio a la misión/scope en sí, y el par ADR + PR es su rastro
auditable.

## Qué NO requiere un amendment

- Corregir un typo en la prosa que rodea al bloque JSON.
- Ajustar `alignment.threshold` (tuneable, pero igual amerita una descripción de PR
  liviana de por qué).
- Cualquier cosa bajo `base/` (schema, rúbrica, este protocolo) — esos son
  vendored/compartidos; ver `README.md` para cómo se propagan las actualizaciones a
  `base/`.
