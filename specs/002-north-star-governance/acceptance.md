# Acceptance — Gobernanza North-Star + Measurability Gate

> Criterios de aceptación medibles en BDD. CADA criterio ES simultáneamente el
> eval y el paso de UAT. La porción determinista se materializa como test en
> `/contract`. Los criterios marcados **contrato documentado — motor per-stack
> (deferred)** describen comportamiento del motor determinista (schema
> validation, scope predicates, verdict aggregation) que este repo especifica
> pero NO implementa ni unit-testea — ver `plan.md` decisión 2 y
> `poirot-fe scripts/north-star/*.mjs` como reference implementation.

## Criterio: NS-BASE — capa base North-Star presente  (determinista · estructural)
```gherkin
Given el repo tiene la capacidad north-star-governance instalada
When se listan memory/north-star/base/{schema.md, alignment-rubric.md, amendment-protocol.md, adr-template.md, README.md}
Then los 5 archivos existen
And README.md documenta el mecanismo extends: base
```

## Criterio: NS-PLACEHOLDER — north-star.md es un placeholder válido  (determinista · estructural)
```gherkin
Given memory/north-star/north-star.md
When se lee su frontmatter
Then contiene "extends: base"
And trae un bloque ```json``` esqueleto marcado "_(completar por proyecto)_"
```

## Criterio: NS-SCHEMA-CONTRACT — forma medible documentada  (contrato documentado — motor per-stack, deferred)
```gherkin
Given schema.md documenta mission, pillars[] (id+statement+signal),
  scope.in_scope/out_of_scope, y alignment.threshold como campos requeridos
When un repo adoptante implementa su propio validador (equivalente a validateNorthStar)
Then un north-star.md al que le falta un campo requerido falla la validación con una razón clara
```
_(No unit-testeado en este repo — el validador concreto es per-stack;
`poirot-fe scripts/north-star/schema.mjs` es la reference implementation ya
unit-testeada allí.)_

## Criterio: ALIGN-CMD — comando+skill /align existen y documentan el modelo  (determinista · estructural)
```gherkin
Given .claude/commands/align.md y .claude/skills/align/SKILL.md
When se leen
Then documentan: entrada brief.md + north-star.md, salida alignment.md, y el
  modelo de 3 capas (scope predicates, orphan check, LLM-judge)
```

## Criterio: ALIGN-VERDICT-CONTRACT — semántica del veredicto  (contrato documentado — motor per-stack, deferred)
```gherkin
Given un objetivo de brief y un North Star schema-válido
When se evalúan scopeReject + orphan-check + alignVerdict (per-stack)
Then un hit de out_of_scope produce "rejected"; un huérfano produce bloqueo;
  las 3 dimensiones ≥ threshold sin reject/huérfano producen "aligned"; y
  estar in-scope sin huérfano pero bajo threshold produce "needs-amendment"
```
_(No unit-testeado en este repo — ver `poirot-fe scripts/north-star/align.mjs`
(`scopeReject`, `alignVerdict`) + su suite
`tests/unit/north-star/align.node.spec.js`.)_

## Criterio: MEAS-GATE — /distill se niega sin intención medible y alineada  (determinista · estructural)
```gherkin
Given .claude/skills/distill/SKILL.md
When se lee su procedimiento
Then contiene un Paso 0 que menciona "alignment.md" y "Measurability Gate"
And especifica que solo el veredicto "aligned" permite avanzar
And documenta la excepción de bootstrap para la feature que introduce /align
```

## Criterio: AMEND-ADR — cambios de scope son auditables  (determinista · estructural · [given] audit-logging)
```gherkin
Given memory/north-star/base/amendment-protocol.md y adr-template.md
When se leen
Then documentan que un cambio a scope/pillars requiere un ADR en
  memory/north-star/decisions/NNNN-*.md y aterriza vía PR
And que un cambio sin ADR correspondiente es una violación de gobernanza señalizable
```

## Criterio: COVERAGE-PILLAR — trazabilidad hasta el north star  (determinista · estructural)
```gherkin
Given specs/_template/coverage.md
When se lee su tabla de columnas
Then incluye una columna Pillar que liga cada fila pillar → objetivo → criterio
```

## Criterio: WOW-2LAYER — Way-of-Work de dos capas  (no-determinista → UAT)
_(El README/docs distinguen harness=governance de execution-runtime=adoptante,
de forma genérica, sin nombrar un runtime obligatorio como propio del harness.
Se valida por lectura manual/UAT, no por grep — es contenido de prosa, no
forma estructural.)_

## Criterio: SELFCHECK — la capacidad forma parte de la integridad del harness  (determinista · estructural)
```gherkin
Given la capacidad north-star-governance está instalada completa
When corre bash tests/run.sh
Then tests/check_80_north_star.sh (auto-tomado por el glob) pasa
And los checks 00–70 preexistentes siguen en verde
```

## Criterio: JUDGE-ALIGNMENT — el judge puntúa la alineación con sensatez  (no-determinista → eval case)
_(Un brief in-scope puntúa ≥3 en las 3 dimensiones; un brief plausible-pero-
fuera-de-alcance puntúa <3 específicamente en scope compliance, no como
promedio. Cases en `evals/cases/north-star-judge.md`, puntuados contra
`memory/north-star/base/alignment-rubric.md`.)_

## Deferred (justificado)
- `[given] base/idempotency` — deferred: sin reintentos/webhooks (esta capa es
  markdown de gobernanza).
- `[given] base/rate-limiting` — deferred: sin superficie de red.
