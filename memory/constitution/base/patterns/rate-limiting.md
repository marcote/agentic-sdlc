# Pattern: Rate Limiting (given practice)

**Principio:** toda superficie expuesta a red tiene límite de tasa.
**Aplica a:** cualquier feature con endpoints públicos o semi-públicos.
**Criterios inyectados:**
- `[given]` cada endpoint expuesto responde `429` al exceder el límite configurado.
  → mapea a `eval: rate-limit`.
