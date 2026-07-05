---
extends: base
---

# Cómo funciona la herencia del North-Star

- `base/` es un asset compartido **vendored**: se copia con el template del
  harness, igual que `memory/constitution/base/`.
- El `north-star.md` del proyecto declara `extends: base` en su frontmatter YAML y
  agrega la misión, los pilares y el scope propios del proyecto — el análogo de
  gobernanza de producto de cómo `constitution.md` declara `extends: base` y agrega
  sus deltas.
- `base/schema.md` es la **forma** chequeable compartida que el North Star de todo
  proyecto debe satisfacer. `base/alignment-rubric.md` es el **método de
  puntuación** compartido que aplica el judge de la skill `/align`.
  `base/amendment-protocol.md` es el **proceso de control de cambios** compartido
  para editar scope/pilares. Ninguno de estos tres es específico del proyecto — el
  delta de un proyecto es su misión, pilares y scope solamente, nunca las reglas
  para validarlos/puntuarlos/enmendarlos.
- **Contrato en la plantilla, motor por-stack.** `base/` especifica la forma, la
  rúbrica y el protocolo; el motor determinista ejecutable (validar schema,
  `scopeReject`, `alignVerdict`, `requiresAdr`/`hasAdrFor`) lo provee cada repo
  adoptante en su propio stack — igual que el harness deja el eval-runner al
  adoptante (`evals/README.md`). Reference implementation:
  `poirot-fe scripts/north-star/{schema,align,amendment}.mjs` (Node, ya construida y
  unit-testeada allí).
- Para actualizar `base/`: editalo acá, seguí la misma disciplina que
  `memory/constitution/update-checklist.md` (revisá el cambio y re-copialo a cada
  proyecto que lo hereda — sincronización explícita, sin submodules).
