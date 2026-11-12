# Datos del proyecto

Los datos no se versionan en este repositorio. Son los que el curso publica en Canvas para el proyecto: el catálogo y las reseñas de Food.com (Kaggle, licencia CC0) y los datos sintéticos del wearable creados por el equipo docente.

## Cómo obtenerlos

1. Descargar desde Canvas el archivo de datos del proyecto INF3862.
2. Descomprimirlo y copiar su contenido dentro de esta carpeta `datos/`, de modo que quede la siguiente estructura:

```
datos/
  README.md            este archivo
  LEEME.md             descripción general entregada por el curso
  foodcom/
    recipes.parquet    522.517 recetas
    reviews.parquet    1.401.982 reseñas
  wearable/
    LEEME.md           diccionario de datos del wearable
    dispositivos.csv   relojes vinculados a usuarios
    comidas.csv        recetas preparadas por los usuarios
    sesiones.jsonl     actividades registradas
    mediciones/
      AAAA-MM-DD/      una carpeta por día de recepción
        HH.jsonl.gz    un archivo por hora de recepción
```

El archivo `.gitignore` excluye todo el contenido de `datos/` salvo este README, así que los archivos pueden quedar en la carpeta sin riesgo de subirlos.

## Tamaño de referencia

| Fuente | Filas | Tamaño |
|---|---|---|
| `foodcom/recipes.parquet` | 522.517 | 178,7 MB |
| `foodcom/reviews.parquet` | 1.401.982 | 173,8 MB |
| `wearable/dispositivos.csv` | 315 | 19,8 KB |
| `wearable/comidas.csv` | 22.106 | 1,0 MB |
| `wearable/sesiones.jsonl` | 4.840 | 0,8 MB |
| `wearable/mediciones/` (1.449 archivos) | 15.540.132 | 115,5 MB comprimidos |

Las mediciones cubren del 16 de diciembre de 2007 al 14 de febrero de 2008 y todas las fechas del wearable están en UTC.
