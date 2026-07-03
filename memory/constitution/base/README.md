# Cómo funciona la herencia de la constitution

- `base/` es un asset compartido **vendored**: se copia con el template.
- El `constitution.md` del proyecto declara `extends: base` y agrega deltas/overrides.
- Cada archivo en `base/patterns/` es una "given practice": además de un principio en
  prosa, declara **criterios de aceptación inyectados** que `/distill` agrega
  automáticamente como filas `[given]` en `coverage.md` de cada feature aplicable.
- Para actualizar la base: editá `base/`, seguí `../update-checklist.md`, y re-copiá
  a los proyectos que la heredan (sincronización explícita, sin submodules).
