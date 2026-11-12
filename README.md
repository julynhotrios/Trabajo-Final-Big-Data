# Recetas acordes al gasto energético

Proyecto del curso INF3862 Plataformas Big Data para Data Science, Magíster en Inteligencia Artificial, Pontificia Universidad Católica de Chile.

Autor: Julynho Merlin Toledo Ríos.

## Caso de uso

Una aplicación de recetas construida sobre el catálogo de Food.com integra relojes inteligentes y empieza a recibir la actividad física de sus usuarios. Este proyecto diseña la plataforma de datos necesaria para que la app proponga cada día recetas cuyo aporte de calorías y proteína sea acorde con el gasto energético de cada persona. Para eso combina las mediciones, sesiones, vinculaciones y comidas que llegan desde el reloj y la app con el catálogo de recetas, y se apoya en una estimación del gasto calórico del día siguiente por usuario.

## Entregables

| Entrega | Contenido | Ubicación | Estado |
|---|---|---|---|
| E1: Diseño de datos | Objetivo, fuentes, modelo operacional y analítico, consultas y arquitectura inicial | [entregas/E1/informe.pdf](entregas/E1/informe.pdf) y [anexos](entregas/E1/anexos/) | Entregada |
| E2: Ingesta y procesamiento | Pipeline mínimo sobre datos reales, calidad, formatos y análisis de escala | `entregas/E2/` | Vence el 30 de noviembre de 2026 |
| E3: Datos para ML y arquitectura final | Dataset de modelamiento, arquitectura con plataformas concretas y operación | `entregas/E3/` | Vence el 14 de diciembre de 2026 |

El registro de decisiones del proyecto está en [decisiones.md](decisiones.md) y se actualiza en cada entrega.

## Estructura del repositorio

```
README.md
decisiones.md            registro de decisiones y sus cambios
datos/
  README.md              cómo obtener y ubicar los datos (no se versionan)
entregas/
  E1/
    informe.pdf          informe de la entrega, con sus anexos
    anexos/              diagramas y consultas en archivos separados
```

Las carpetas `entregas/E2/`, `entregas/E3/` y `src/`, junto con `pyproject.toml` y `uv.lock`, se incorporan a partir de la E2.

## Datos

Los datos no forman parte del repositorio. Las instrucciones para descargarlos desde Canvas y dejarlos en la ubicación que espera el proyecto están en [datos/README.md](datos/README.md).

## Cómo reproducir el trabajo

Por ahora no hay nada que ejecutar: la Entrega 1 es de diseño.
