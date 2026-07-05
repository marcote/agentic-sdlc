# Spec — Gobernanza North-Star + Measurability Gate

> QUÉ se construye. Producido por `/distill` a partir de `brief.md`. Se congela
> cuando `coverage.md` no tiene filas huérfanas.
>
> Diseño: `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`
> Origen: capacidad piloteada en `poirot-fe` (rama `feature/north-star-governance`,
> PR #24) — el motor determinista concreto vive ahí (`scripts/north-star/*.mjs`)
> como **reference implementation**; este spec porta el **contrato**, no el motor.

## Requerimientos funcionales

### Capa North-Star base (`memory/north-star/`, par de la constitution)
1. `memory/north-star/base/`: `schema.md` (forma medible requerida: `mission`,
   `pillars[]` con `id`+`statement`+`signal`, `scope.in_scope`/`scope.out_of_scope`,
   `alignment.threshold`), `alignment-rubric.md` (3 dimensiones — pillar fit, scope
   compliance, mission advancement — 0–5, pass = todas ≥ threshold),
   `amendment-protocol.md` (amendment = ADR + PR), `adr-template.md`, `README.md`
   (documenta el mecanismo `extends: base`), `decisions/.gitkeep`.
2. `memory/north-star/north-star.md`: **placeholder** del proyecto —
   `extends: base` + bloque JSON canónico esqueleto marcado
   `_(completar por proyecto)_`; el contenido real (misión, pilares) lo completa
   cada repo adoptante (no hay contenido MEXBANK/poirot aquí).
3. Un North Star es **medible** ssi es schema-válido: `mission` no vacía, ≥1
   pilar con `id`+`statement`+`signal`, `scope.in_scope`/`out_of_scope` no
   vacíos, `alignment.threshold` presente. Uno no-medible → el flujo se niega a
   correr contra él (Measurability Gate, más abajo).

### Gate de intake `/align` (harness-owned)
4. `.claude/commands/align.md` + `.claude/skills/align/SKILL.md`: entrada
   `specs/<feature>/brief.md` + el North Star del proyecto; salida
   `specs/<feature>/alignment.md` con veredicto, scores, mapping
   objetivo→pilar, y huérfanos.
5. El modelo chequeable de 3 capas (contrato; el motor determinista concreto
   lo implementa cada stack adoptante — ver "Fuera de alcance"):
   (a) **scope predicates** — match conservador por frase contigua contra
   `out_of_scope` → `rejected`; (b) **orphan check** — todo objetivo mapea a
   ≥1 pilar, si no → bloqueado; (c) **LLM-judge cuantificado** — puntúa las 3
   dimensiones de la rúbrica 0–5.
6. Agregación del veredicto (fija, documentada aquí; implementada por-stack):
   un hit de `out_of_scope` → `rejected` (duro, sin importar scores); si no,
   huérfano → bloqueado; si no, las 3 dimensiones ≥ `threshold` (default 3) →
   `aligned`; si no → `needs-amendment`.

### Measurability Gate (la ley) en `/distill`
7. `.claude/skills/distill/SKILL.md` gana un **Paso 0**: lee
   `specs/<feature>/alignment.md`; si falta → frena y pide correr `/align`
   primero; si el veredicto no es `aligned` (`needs-amendment`/`rejected`) →
   frena y señala la ruta (amendment o rechazo); solo `aligned` avanza.
   **Excepción bootstrap:** la feature que introduce `/align`
   (`002-north-star-governance`, esta misma) está exenta — única excepción.

### Drift gobernado (amendments)
8. Cambiar el North Star (`scope`/`pillars`) requiere un **ADR** (contexto,
   decisión, scope-delta, consecuencias) en
   `memory/north-star/decisions/NNNN-*.md`, que aterriza vía **PR** (aprobación
   humana). Un cambio de scope/pillars sin ADR correspondiente es una
   violación de gobernanza (señalizable). Es el rastro auditable
   (`[given] base/audit-logging` aplicado a la gobernanza de producto en vez de
   a endpoints de escritura).

### Trazabilidad
9. `specs/_template/coverage.md` gana una columna **Pillar**; la cadena pasa a
   ser `pillar → objetivo → criterio → test/eval`. Un criterio cuyo objetivo
   no tiene pilar es una señal de drift detectable.

### Integridad
10. `tests/check_80_north_star.sh` (bash, dependency-free, auto-tomado por el
    glob de `tests/run.sh`): capa base presente, `north-star.md` con
    `extends: base`, comando+skill `/align` existen, el skill de `distill`
    contiene el wiring del gate (Paso 0), y el template de coverage contiene
    la columna Pillar.

### Way-of-Work (dos capas)
11. El README/docs del source distinguen explícitamente: el **harness
    gobierna** (comandos + gates + constitution + North-Star); los pasos que
    no son comandos (intake→brief, implement, finish) los provee un
    **execution-runtime** que elige cada adoptante (genérico — el harness no
    nombra ningún runtime como obligatorio).

## User stories
- Como **responsable de producto/tech lead**, quiero que las features fuera de
  alcance se bloqueen en el intake, para que el producto no derive de su
  misión bajo el throughput agéntico.
- Como **agente**, quiero un gate chequeable por máquina que me diga si un
  brief pertenece a la misión antes de destilarlo.
- Como **mantenedor de cualquier repo adoptante**, quiero esto como una
  capacidad reusable del harness, con mi propio North Star como delta de
  proyecto y mi propio motor determinista en mi stack.
- Como **revisor**, quiero que todo cambio de alcance llegue como ADR + PR,
  para que el drift sea deliberado, justificado y auditable.

## Edge cases (80% problem)
- North Star ausente o schema-inválido → el flujo se niega (mensaje claro), no
  un crash silencioso — pero el checker que decide esto es per-stack; aquí solo
  se documenta la regla.
- Brief con objetivos mixtos (uno in-scope, uno out-of-scope) → `rejected` (el
  objetivo fuera de alcance bloquea todo el brief).
- Brief borderline (in-scope, el judge puntúa 2 en una dimensión) →
  `needs-amendment`, nunca un pase silencioso.
- Un objetivo que mapea a un pilar solo débilmente → score bajo del judge →
  se expone, no se oculta.
- Un amendment aterriza sin ADR → señalizado como violación de gobernanza.
- Bootstrap: la feature que introduce `/align` no puede ser gateada por él —
  se saltea solo para esta feature (documentado), igual que el bootstrap
  original del harness salteó sus propios gates.
- Repo adoptante sin motor determinista todavía implementado → la plantilla
  sigue siendo válida (el contrato es completo en prosa/schema), pero el gate
  `/align` no puede ejecutarse de verdad hasta que el adoptante escriba su
  checker — esto es explícito, no un fallback silencioso.

## Preguntas abiertas / deferred
- **Amendment = ADR + PR** (resuelto): el PR es la aprobación, el ADR es el
  registro formal.
- **Threshold** (resuelto): 0–5 por dimensión, pass = todas ≥3, overrideable
  por proyecto vía `alignment.threshold`.
- **Motor determinista concreto** (deferred, fuera de alcance de este repo):
  cada stack adoptante lo implementa; `poirot-fe scripts/north-star/*.mjs` es
  la reference implementation citada (ya construida y unit-testeada allí).
- **`north-star.md` con contenido real de un proyecto** (deferred): en el
  source es un placeholder; cada adoptante completa su misión/pilares.
- `[given] idempotency` + `[given] rate-limiting` → deferred (esta capa es
  markdown de gobernanza; sin reintentos/webhooks ni superficie de red).
- Reescribir `specs/001-example` para pasar por `/align` → fuera de alcance
  (predata el gate).
