# Spec — Guardar tarjeta con 1-tap

> QUÉ se construye. Producido por `/distill` a partir de `brief.md`. Congelado cuando
> `coverage.md` dejó de tener filas huérfanas.

## Requerimientos funcionales
1. Tras una compra aprobada, ofrecer "guardar tarjeta con 1 tap".
2. Al aceptar, tokenizar la tarjeta y persistir el token (nunca el PAN).
3. En la próxima compra, ofrecer pagar con la tarjeta guardada sin reingresar datos.

## User stories
- Como comprador móvil quiero guardar mi tarjeta con un tap para no reingresarla la
  próxima vez.
- Como comprador quiero confiar en que mis datos de tarjeta no se almacenan en claro.

## Edge cases (80% problem)
- El tokenizador está caído o responde > 300ms → no bloquear el flujo de compra ya
  aprobado; degradar a "no guardada".
- El request de guardado se reintenta (red inestable) → no debe duplicar tokens
  (idempotencia).
- Usuario sin sesión persistente → no ofrecer 1-tap.

## Preguntas abiertas / deferred
- Multi-tarjeta y selección entre varias guardadas → **deferred** (fuera de alcance del
  brief; se retoma en un feature posterior).
