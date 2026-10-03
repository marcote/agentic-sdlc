---
name: batteries-included-scope
description: "Por qué el harness puede hospedar un engine de referencia sin violar \"engine per-stack\""
metadata: 
  node_type: memory
  type: project
  originSessionId: e57ed837-5d37-4fbf-8d1a-c5d4a5c13d70
---

Resolución de scope (2026-07-05, confirmada por Marcos en `/align` de 006): el harness
**sí puede shippear un engine de referencia dependency-free** (p. ej. el north-star engine
en python3) aunque el `out_of_scope` del North Star diga "stack-specific deterministic
engine (provided by the adopter)".

**Why:** un buen vendoring es **batteries-included** — entrega algo que *corre*, no un
contrato que el adopter todavía tiene que cablear. Eso es **productividad**, el objetivo
mayor de este SDLC.

**How to apply:** "engine per-stack" prohíbe *imponer* el engine de un stack a todos los
adopters; NO prohíbe que el harness, como su propio adopter, provea *su* engine en *su*
baseline (python3 stdlib), dejando alternativas (Node de poirot-fe) intactas. Al puntuar
`scope compliance` en `/align` para features que construyen tooling del harness, este es
el criterio. Ver [[feature-006-007-vendoring-thread]] y [[north-star-harness]].
