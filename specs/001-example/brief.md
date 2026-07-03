# Brief — Guardar tarjeta con 1-tap

> ORIGEN del desarrollo. Describe el OBJETIVO y el POR QUÉ, no la solución.
> (Ejemplo ilustrativo del Way of Work — no es código real.)

## Objetivo de producto
Permitir que, tras una compra exitosa, el usuario guarde su tarjeta con un solo tap para
que la próxima compra no requiera reingresar los datos.

## Por qué / motivación
Cada campo extra en el checkout móvil cae la conversión. Los competidores ya ofrecen
1-tap. Reducir la fricción de la segunda compra es la palanca de retención más barata que
tenemos este trimestre.

## Métricas de éxito
- ↑ conversión móvil en la 2da compra **+5%** (medido a 30 días).
- Tokenización de tarjeta **p95 < 300ms**.
- **0 incidentes PCI** en el período.

## Fuera de alcance
- Gestión de múltiples tarjetas guardadas (ver *deferred* en `coverage.md`).
- Edición/borrado de tarjeta desde el perfil.
