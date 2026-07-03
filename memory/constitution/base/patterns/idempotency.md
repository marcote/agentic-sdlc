# Pattern: Idempotency (given practice)

**Principio:** las operaciones de escritura repetibles son idempotentes.
**Aplica a:** cualquier feature con reintentos, webhooks o pagos.
**Criterios inyectados:**
- `[given]` reenviar la misma request con igual `idempotency-key` no duplica el efecto.
  → mapea a `eval: idempotency`.
