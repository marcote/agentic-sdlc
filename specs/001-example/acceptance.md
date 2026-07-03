# Acceptance — Guardar tarjeta con 1-tap

> Criterios de aceptación en BDD. CADA criterio ES simultáneamente el eval y el paso de
> UAT. La porción determinista se materializa como test en `/contract`.

## Criterio: tokenización < 300ms  (determinista)
```gherkin
Given una tarjeta válida y una compra aprobada
When el usuario acepta "guardar con 1 tap"
Then el token se retorna en < 300ms
And la respuesta nunca contiene el PAN en claro
```

## Criterio: idempotencia del guardado  (determinista · [given] base/idempotency)
```gherkin
Given un guardado ya realizado con un idempotency-key
When se reenvía la misma request con igual idempotency-key
Then no se crea un token duplicado
And se retorna el token existente
```

## Criterio: audit-log del guardado  (determinista · [given] base/audit-logging)
```gherkin
Given un guardado de tarjeta
When se persiste el token
Then se emite un audit-log con actor + timestamp + entidad
```

## Criterio: pago con tarjeta guardada en la 2da compra  (determinista)
```gherkin
Given un usuario con una tarjeta guardada
When inicia una nueva compra
Then puede pagar con la tarjeta guardada sin reingresar datos
```

## Criterio: mensaje claro ante rechazo  (no-determinista → eval case)
_(La calidad/claridad del mensaje de error cuando la tokenización falla o la tarjeta es
rechazada se evalúa con un eval case en `evals/cases/`, no con un unit test.)_
