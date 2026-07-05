# Gobernanza North-Star + Measurability Gate — Diseño

**Fecha:** 2026-07-04
**Estado:** Diseño — pendiente de revisión, luego pasa por el flujo del harness
**Rama:** feature/north-star-governance
**Origen:** capacidad piloteada en `poirot-fe` (rama `feature/north-star-governance`,
PR #24); esto la **upstrea** al harness base como capacidad transversal.

## Resumen

Sumar al harness `agentic-sdlc` una **capa de gobernanza de producto** — el **North
Star** — como **par** de la constitution (que es técnica), más un **gate de intake
`/align`** con un modelo chequeable de 3 capas, y la ley **Measurability Gate**: *si
el North Star no se puede definir, gobernar y cuantificar, el flujo no ejecuta contra
él*. Previene el **drift de producto**: features perfectamente construidas pero fuera
de la misión — algo que un SDLC agéntico amplifica (el agente no tiene el instinto
"¿esto debería existir?").

## Principio rector del port: contrato en la plantilla, motor por-stack

El harness es una **plantilla stack-agnóstica y dependency-free** (su self-check es
bash puro; no asume Node/npm). Por eso portamos el **contrato**, no el motor Node de
poirot:

- La plantilla trae la **especificación** del North-Star: `base/` (schema, rúbrica,
  protocolo de amendment, ADR), el comando+skill `/align` (describiendo el modelo de
  3 capas), el gate en `/distill`, la columna Pillar en el template de coverage, y un
  self-check bash de **presencia/estructura**.
- El **motor determinista ejecutable** (validar schema, `scopeReject`,
  `alignVerdict`, `amendment`) queda **a cargo de cada repo adoptante**, igual que el
  harness ya deja el *eval-runner* al adoptante (`evals/README`). Se cita
  `poirot-fe scripts/north-star/*.mjs` como **reference implementation** (Node).

Idioma: **español**, como el resto del source.

## Alcance

**Incluye:**
1. **North-Star governance** (base + `/align` + gate en `/distill` + columna Pillar +
   self-check), como contrato stack-agnóstico.
2. **Refinar el Way-of-Work** del source con el modelo formal de **dos capas**
   (governance vs execution-runtime), en forma **genérica** (el runtime de
   intake/implement/finish lo elige el adoptante).

**No incluye:** el contenido específico de poirot (`north-star.md` con la misión de
MEXBANK, la API, traducciones a inglés). En el source, `north-star.md` es un
**placeholder** a completar por proyecto (como el `constitution.md` de ejemplo).

## Componentes (aterrizan en el source, en español)

1. **`memory/north-star/base/`** — `schema.md` (forma medible requerida:
   `mission`, `pillars[]` con `id`+`statement`+`signal`, `scope.in/out`, `alignment`
   con `threshold`+`rubric`), `alignment-rubric.md` (3 dimensiones: pillar fit,
   scope compliance, mission advancement; 0–5; pass = todas ≥ threshold, default 3, y
   sin `out_of_scope`), `amendment-protocol.md` (amendment = **ADR + PR**),
   `adr-template.md`, `README.md` (mecanismo `extends: base`), `decisions/.gitkeep`.
2. **`memory/north-star/north-star.md`** — **placeholder** (`extends: base` +
   bloque JSON canónico esqueleto con `_(completar por proyecto)_`).
3. **`.claude/commands/align.md` + `.claude/skills/align/SKILL.md`** — el gate
   `/align`: valida el North Star (fail-closed si no es medible), extrae objetivos
   del brief, corre el modelo de 3 capas (scope predicates deterministas + orphan
   check + LLM-judge cuantificado), escribe `specs/<feature>/alignment.md` con
   veredicto `aligned | needs-amendment | rejected`. Declara que el **checker
   determinista lo provee cada stack** (contrato), citando la reference impl de
   poirot.
4. **Gate en `/distill`** — editar `.claude/skills/distill/SKILL.md`: **Paso 0 —
   Measurability Gate** (lee `alignment.md`; solo `aligned` avanza; falta/`rejected`/
   `needs-amendment` frena; excepción bootstrap para la feature que introduce
   `/align`).
5. **`specs/_template/coverage.md`** — columna **Pillar** (`pillar → objetivo →
   criterio`).
6. **`tests/check_80_north_star.sh`** — self-check bash (el source usa `tests/`):
   base presente, `north-star.md` con `extends: base`, comando+skill `/align`
   existen, y el skill de `distill` contiene el wiring del gate. Auto-tomado por el
   glob de `tests/run.sh`.
7. **Way-of-Work (dos capas)** — enriquecer el README/docs del source: el harness
   **gobierna**; los pasos que no son comandos (intake→brief, implement, finish) los
   provee un **execution-runtime** que elige el adoptante. Genérico (sin nombrar
   superpowers como obligatorio).

## Cómo se construye

**Dogfooding del propio harness del source**: este diseño → `brief.md` en
`specs/002-north-star-governance/` → `/distill → /plan → /contract → /tasks →
implement`. `/align` se **saltea para esta feature** (bootstrap: no puede gatearse a
sí misma), igual que el bootstrap original del harness salteó sus propios gates.
Self-check `tests/run.sh` verde + `check_80` nuevo verde. Rama → **PR**.

## Modelo chequeable (3 capas) — el contrato

1. **Determinista dura — scope predicates:** un objetivo que matchea `out_of_scope`
   (match conservador por frase contigua) → `rejected`.
2. **Determinista dura — orphan check:** todo objetivo mapea a ≥1 pilar; si no →
   bloqueado.
3. **Cuantificada — LLM-judge:** puntúa 3 dimensiones 0–5 contra la rúbrica; pass =
   todas ≥ threshold y sin scope hit → `aligned`; in-scope pero por debajo →
   `needs-amendment`.

Ley por encima (**Measurability Gate**): sin North Star medible, con objetivo
huérfano, o con score por debajo del umbral (sin amendment aprobado) → el flujo no
corre.

## Riesgos / limitaciones

- **Contrato sin motor en la plantilla:** un adoptante debe implementar el checker
  determinista en su stack. Se mitiga con la spec explícita (`schema.md`,
  rúbrica, semántica del veredicto) + la reference impl de poirot citada.
- **Frontera semántica vs determinista:** los scope predicates por keyword no
  capturan drift semántico → la dimensión *scope compliance* del judge es el backstop
  (y `scopeReject` es deliberadamente conservador para no producir falsos rechazos).
- **Bootstrap:** `/align` no puede gatear la feature que lo introduce — documentado
  como única excepción.

## Fuera de alcance

- El motor ejecutable en el source (queda por-stack; poirot es la reference).
- Reescribir el ejemplo `specs/001-example` para pasar por `/align` (predata el gate).
- Cambiar el idioma del source (se mantiene español).
