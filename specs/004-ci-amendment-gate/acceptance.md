# Acceptance — CI-gate del amendment del North Star

> Criterios de aceptación medibles en BDD. CADA criterio ES simultáneamente el eval y el
> paso de UAT. La porción determinista se materializa como test en `/contract`.
> Todos los criterios del script son deterministas (bash + fixtures). Los dos criterios
> de bloqueo real (`AMEND-BLOCK-REAL`, `AMEND-BLOCK-PUSH`) son config de GitHub → UAT.

## Criterio: AMEND-BLOCK-NO-ADR  (determinista)
```gherkin
Given un rango base..head cuyo diff cambia los sets pillars/scope del bloque JSON de north-star.md
When no hay ningún archivo memory/north-star/decisions/NNNN-*.md nuevo en el rango
Then el amendment-gate falla (exit ≠ 0) citando "amendment de pillars/scope sin ADR"
```

## Criterio: AMEND-PASS-WITH-ADR  (determinista)
```gherkin
Given un rango que cambia pillars/scope y agrega un decisions/NNNN-*.md nuevo
When el bloque JSON resultante es schema-válido y tests/run.sh está verde
Then el amendment-gate pasa (exit 0)
```

## Criterio: AMEND-NO-ADR-FOR-PROSE  (determinista)
```gherkin
Given un diff a north-star.md que solo toca prosa, redacción de mission que no cambia los sets, o alignment.threshold
When no hay ADR nuevo en el rango
Then el amendment-gate pasa (exit 0) — no exige ADR
```

## Criterio: AMEND-SET-SEMANTICS  (determinista)
```gherkin
Given un diff que reordena o reformatea el bloque JSON sin alterar el contenido de los sets pillars/scope
When el amendment-gate corre
Then pasa (exit 0) — la detección es por sets, no por texto, así que no hay falso positivo
```

## Criterio: AMEND-SCHEMA-VALID  (determinista)
```gherkin
Given un cambio de pillars/scope que deja el bloque JSON schema-inválido (statement/signal vacío, scope array vacío, etc.)
When el amendment-gate corre, incluso con un ADR nuevo presente
Then falla (exit ≠ 0) citando "North Star no schema-válido"
```

## Criterio: AMEND-SUITE-GREEN  (determinista)
```gherkin
Given un amendment de pillars/scope con ADR y schema-válido
When tests/run.sh está en rojo
Then el amendment-gate falla (exit ≠ 0) — exige la suite verde además de ADR + schema
```

## Criterio: DEV-UNBLOCKED  (determinista)
```gherkin
Given un rango cuyo diff NO toca los sets pillars/scope de north-star.md (trabajo normal de feature)
When el amendment-gate corre
Then pasa (exit 0, no-aplica) — no bloquea el desarrollo (preserva el principio 4)
```

## Criterio: CONST-EXCEPTION  (determinista)
```gherkin
Given memory/constitution/constitution.md tras el feature
When se lo inspecciona
Then registra que el gate bloqueante de amendments es consistente con la intención productividad-primero del principio 4 — el bloqueo es angosto (solo pillars/scope del North Star), el desarrollo de features no se bloquea
```

## Criterio: DEP-FREE  (determinista)
```gherkin
Given el source tras el feature
When se lo inspecciona
Then no hay package.json/package-lock/node_modules ni toolchain instalable (uv/pip/npm); solo bash/coreutils + python3 stdlib + GitHub Actions
```

## Criterio: SELF-CHECK  (determinista)
```gherkin
Given el harness tras el feature
When corre tests/run.sh
Then está verde y cubre la capa nueva (existencia del script del gate + del workflow, y los escenarios base/head del gate)
```

## Criterio: AMEND-BLOCK-REAL  (determinista en outcome; verificado en UAT — config de GitHub)
```gherkin
Given branch protection en main que exige el status-check del amendment-gate
When un PR tiene el amendment-gate en rojo (cambio de pillars/scope sin ADR)
Then el PR NO es mergeable
```

## Criterio: AMEND-BLOCK-PUSH  (determinista en outcome; verificado en UAT — config de GitHub)
```gherkin
Given branch protection en main que exige el status-check y prohíbe bypass
When se intenta pushear un cambio de pillars/scope directo a main sin pasar el gate
Then el push es rechazado
```
