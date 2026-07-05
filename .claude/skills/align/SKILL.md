---
name: align
description: Valida el brief de un feature contra el North Star del proyecto (Measurability Gate) — propone un mapping objetivo→pilar, puntúa la rúbrica de alineación, y escribe alignment.md. Usar antes de /distill sobre el brief.md de cualquier feature.
---

# Align

Entrada: `specs/<feature>/brief.md` + `memory/north-star/north-star.md`. Salida:
`specs/<feature>/alignment.md`. Este es el **Measurability Gate**: `/distill` lee
`alignment.md` y se niega a arrancar salvo que su veredicto sea `aligned`.

## Contrato en la plantilla, motor por-stack

El harness es una plantilla stack-agnóstica y dependency-free. Esta skill describe
el **modelo chequeable de 3 capas** y la **semántica fija del veredicto**, pero el
**motor determinista ejecutable** (validar schema, `scopeReject`, orphan check,
`alignVerdict`, `canDistill`) lo provee cada repo adoptante en su propio stack —
igual que el harness deja el eval-runner al adoptante (`evals/README.md`). **Nunca
reimplementes ese motor inline en esta skill**: un adoptante lo construye una vez y
esta skill lo invoca. Reference implementation:
`poirot-fe scripts/north-star/{schema,align}.mjs` (Node, ya construida y con su
suite `tests/unit/north-star/*.node.spec.js` verde). Mientras un adoptante no tenga
su checker, esta skill sigue siendo válida como contrato, pero `/align` no puede
ejecutarse de verdad hasta que exista — es explícito, no un fallback silencioso.

## Procedimiento

1. **Validar el North Star primero (fail closed).** Leé
   `memory/north-star/north-star.md`, extraé su bloque JSON canónico, y corré el
   validador de schema del stack (equivalente a `validateNorthStar`, ver
   `memory/north-star/base/schema.md`). Si **no** es schema-válido — misión vacía,
   ningún pilar con `id`+`statement`+`signal`, `scope.in_scope`/`out_of_scope`
   vacíos, o `alignment.threshold` ausente — **frená**: no leas el brief, no
   propongas mapping. El Measurability Gate se niega a correr contra un North Star
   no medible (criterio `MEAS-GATE`). Reportá los errores al humano y salí; no
   escribas `alignment.md`.

2. **Extraer los objetivos del brief.** Leé `specs/<feature>/brief.md` y sacá sus
   objetivos/metas distintos como strings de texto cortos y literales (este mismo
   texto es la clave del `mapping`/`scores`; mantenelo verbatim para que el
   `alignment.md` sea trazable de vuelta al brief).

3. **Pre-filtro determinista (rechazo duro de scope).** Para cada objetivo, corré el
   predicado de scope del stack (equivalente a `scopeReject`, match conservador por
   frase contigua contra `northStar.scope.out_of_scope`). Cualquier objetivo que
   dé `true` es un hit `out_of_scope` obvio y de alta confianza — anotalo, pero dejá
   que los pasos 4–6 corran igual para el panorama completo (la agregación del paso
   6 rechaza duro sin importar los scores). No trates de ser más listo que el
   predicado acá: es deliberadamente conservador; las violaciones de scope
   borderline/semánticas son trabajo del judge en la dimensión "scope compliance"
   del paso 5, no de este paso.

4. **Proponer el mapping objetivo→pilar.** Este es el juicio semántico propio de la
   skill — ningún script lo hace. Para cada objetivo, decidí cuál(es) de
   `northStar.pillars[].id` avanza (un objetivo puede mapear a uno, varios, o — si
   está genuinamente huérfano — a ninguno). Construí:
   ```
   mapping = {
     "<texto del objetivo>": ["<pillar-id>", ...],   // o [] / null si es huérfano
     ...
   }
   ```
   Leé el `statement` y el `signal` de cada pilar antes de decidir; un mapping hecho
   solo desde el `id` del pilar no es defendible.

5. **Puntuar la rúbrica.** Según `memory/north-star/base/alignment-rubric.md`,
   puntuá cada objetivo 0–5 en las tres dimensiones — pillar fit, scope compliance,
   mission advancement — de forma **independiente** (no dejes que el score de una
   dimensión sesgue otra). Reducí al **mínimo por dimensión** a través de los
   objetivos antes de agregar — el gate debe cumplirse para el brief como un todo,
   no solo para su mejor objetivo:
   ```
   scores = {
     pillarFit: <mín. a través de objetivos, 0-5>,
     scopeCompliance: <mín. a través de objetivos, 0-5>,
     missionAdvancement: <mín. a través de objetivos, 0-5>,
   }
   ```
   Ante la duda entre dos scores adyacentes, preferí el más bajo — la rúbrica es un
   gate, no un estímulo.

6. **Agregar el veredicto (semántica fija, determinista — motor per-stack).** Dado
   `scores` + `mapping` + el scope-check, aplicá la agregación (equivalente a
   `alignVerdict`, ver `plan.md` decisión 3):
   - un hit de `out_of_scope` → **`rejected`** (gate duro, sin importar los scores);
   - si no, cualquier huérfano → **`blocked`** (no puede ser `aligned`);
   - si no, las 3 dimensiones ≥ `northStar.alignment.threshold` (default 3) →
     **`aligned`**;
   - si no (en alcance, sin huérfano, pero alguna dimensión bajo el umbral) →
     **`needs-amendment`**.

7. **Escribir `specs/<feature>/alignment.md`.** Mismo directorio que `brief.md`.
   Incluí:
   - el `verdict` y los `scores` por dimensión (el score que el gate usó de verdad,
     por el paso 5);
   - el `mapping` objetivo→pilar;
   - los `orphans` (lista vacía si no hay);
   - si `verdict` no es `aligned`, el próximo paso requerido:
     - `rejected` → citá el/los predicado(s) `out_of_scope` matcheado(s); el flujo
       está bloqueado, sin ruta de amendment desde esta skill.
     - `blocked` (huérfano) → nombrá el/los objetivo(s) huérfano(s); o angostá el
       brief o proponé un amendment del North Star para un pilar faltante.
     - `needs-amendment` → nombrá la(s) dimensión(es) bajo el umbral y, por
       `memory/north-star/base/amendment-protocol.md`, que un amendment del North
       Star (ADR en `memory/north-star/decisions/NNNN-*.md` + PR) es la única ruta
       para avanzar si el brief no puede retrabajarse para puntuar más alto.

8. **Gatear `/distill`.** Solo un `verdict` de `aligned` (equivalente a
   `canDistill(alignment)` → `true`) deja que `/distill` avance en este feature.
   Reportá el veredicto al humano en cualquier caso; no continúes en silencio más
   allá de un veredicto no-`aligned`.

## Excepción bootstrap

`/align` no puede gatear la feature que lo introduce
(`002-north-star-governance`, esta misma) — esa corrida se salteó por diseño (ver
`plan.md` decisión 8). Toda feature desde `002-north-star-governance` en adelante
corre `/align` antes de `/distill`, sin excepción.
