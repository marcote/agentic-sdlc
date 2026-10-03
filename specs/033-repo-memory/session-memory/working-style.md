---
name: working-style
description: "Cómo colaborar con Marcos en este repo — brainstorm-first, dogfood, review honesto"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 3bcf4de8-833f-4ebd-a50c-3fcf13f7be84
---

Cómo trabaja Marcos y qué espera del agente en este repo:

- **Brainstorm/diseño ANTES de codear.** Para capacidades nuevas usa la disciplina de
  brainstorming (explorar → approaches → diseño → aprobación). Una vez que el harness está
  maduro, dogfoodeá construyendo features **por el workflow propio del harness**
  (`/align → /distill → /plan → /contract → /tasks → implement → /verify → /uat → /retro`),
  no por un flujo paralelo.
- **Dogfooding sin piedad.** Construir el harness usando el harness; cada capacidad se
  valida a sí misma. Es el objetivo declarado, no un extra.
- **Review honesto y adversarial > amabilidad.** Valora que le señales tensiones, gaps y
  defectos reales (anti-teatro), incluso en tu propio trabajo. No papelees problemas; el
  patrón "cada cosa que construimos expone la próxima" le gusta.
- **"De a poco", una decisión a la vez.** Preferí forks claros (AskUserQuestion) con una
  **recomendación explícita**, no menús sin opinión.
- **Git:** rama por feature → merge a `main` al cierre ([[git-branch-per-feature]]). Los
  cambios de gobernanza (pillars/scope del North Star) van por **PR real + ADR** (nunca
  commit directo), dogfoodeando el amendment-protocol.
- **Momentum:** cuando dice "seguí", avanzá la siguiente fase completa; cuando duda, frená y
  ofrecé el checkpoint. Te dirá "simple" si querés menos ceremonia.

**Why:** su meta es un SDLC que se autoimpone la disciplina que predica; un agente que no
brainstormea/dogfoodea/es-honesto rompe justo lo que está construyendo.
**How to apply:** ante una tarea nueva, empezá por diseño+alineación, no por implementación.
Relacionado: [[feature-004-ci-amendment-gate]] (feature en vuelo).
