# Brief — Gobernanza North-Star + Measurability Gate (capacidad base)

> ORIGEN del desarrollo. Describe el OBJETIVO y el PORQUÉ, no la solución.
>
> Diseño completo (referencia): `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`

## Objetivo de producto

Dar al harness `agentic-sdlc` una capacidad **transversal** para **prevenir el drift
de producto**: features perfectamente construidas pero fuera de la misión del
proyecto. Sumar una capa **North Star** (gobernanza de producto, **par** de la
constitution técnica) y un **gate de intake `/align`** chequeable, de modo que antes
de destilar una feature se verifique que pertenece a la misión. Hacer cumplir la ley
**Measurability Gate**: si el North Star no se puede definir, gobernar y cuantificar,
el flujo no ejecuta contra él. La capacidad es **stack-agnóstica** (contrato en la
plantilla; el motor determinista lo provee cada repo adoptante).

## Por qué / motivación

Un SDLC agéntico amplifica el drift: el agente no tiene el instinto "¿esto debería
existir?" y produce features rápido, así que el scope creep se acelera con el
throughput. El harness hoy gobierna el drift de intención (bien) y el arquitectónico
(parcial) pero es **ciego al drift de producto** — una feature fuera de alcance pasa
todos los gates. La gobernanza que no está codificada y gateada no sobrevive al
throughput agéntico. Ya piloteado en `poirot-fe` (PR #24); esto lo lleva al harness
base para todo repo adoptante.

## Métricas de éxito

- Un brief cuyo objetivo matchea un predicado `out_of_scope` es **bloqueado**
  (rechazo duro) por el gate — medible, determinista.
- Todo brief aceptado tiene sus objetivos mapeados a ≥1 **pilar** del North Star
  (cero objetivos huérfanos).
- El flujo **se niega a correr** si el North Star del proyecto no es schema-válido /
  medible, o si el score de alineación está por debajo del umbral sin amendment
  aprobado (la Measurability Gate se cumple).
- La alineación se **cuantifica** (score contra rúbrica), no es un sí/no de opinión.
- Los cambios de alcance ocurren **solo** por el protocolo de amendment versionado y
  aprobado por humano (**ADR + PR**), nunca en silencio.
- El self-check del harness cubre la capa nueva (`tests/run.sh` verde); la plantilla
  sigue **stack-agnóstica y dependency-free** (sin Node/npm en el source).

## Fuera de alcance

- El **motor determinista ejecutable** en el source (queda por-stack; `poirot-fe
  scripts/north-star/*.mjs` es la reference implementation citada).
- Contenido específico de un proyecto: `north-star.md` en el source es un
  **placeholder** a completar por proyecto.
- Reescribir `specs/001-example` para pasar por `/align` (predata el gate).
- Cambiar el idioma del source (se mantiene español).
