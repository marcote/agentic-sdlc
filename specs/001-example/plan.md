# Plan técnico — Guardar tarjeta con 1-tap

> CÓMO se construye. Producido por `/plan`. Grounded en la constitution: no puede violar
> un no-negociable ni un pattern `[given]` sin override justificado.

## Decisiones técnicas
- **Tokenización vía vault externo** (no almacenamos PAN). Trade-off: dependencia de red
  → se mitiga con timeout y degradación a "no guardada" (nunca bloquea una compra
  aprobada). Restringido por el principio *seguridad por defecto* + objetivo PCI.
- **Idempotencia por `idempotency-key`** en el endpoint de guardado. Requerido por el
  pattern `[given] base/idempotency`.
- **Audit-log vía middleware** en toda escritura. Requerido por `[given] base/audit-logging`.

## Componentes / módulos
- `TokenizationClient` — habla con el vault; timeout 300ms; una responsabilidad.
- `SaveCardHandler` — orquesta guardado + idempotencia + audit; interfaz `save(card, key)`.
- `OneTapPayHandler` — recupera token y ejecuta el pago de la 2da compra.

## Riesgos
- Vault lento degrada UX → timeout + fallback "no guardada" (no bloquear compra).
- Colisión de `idempotency-key` entre usuarios → key namespaced por usuario.
