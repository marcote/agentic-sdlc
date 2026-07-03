# Acceptance — <feature>

> Criterios de aceptación medibles en BDD. CADA criterio ES simultáneamente el
> eval y el paso de UAT. La porción determinista se materializa como test en `/contract`.

## Criterio: <nombre>  (determinista)
```gherkin
Given <precondición>
When <acción>
Then <resultado observable y medible>
```

## Criterio: <nombre>  (no-determinista → eval case)
_(comportamiento/calidad que no se unit-testea; genera un case en `evals/cases/`)_
