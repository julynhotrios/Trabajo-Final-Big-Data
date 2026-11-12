-- Consultas de ejemplo de la Entrega 1 (SQL aproximado, no se ejecutan en esta etapa).
-- T = transaccional (OLTP), A = analitica (OLAP), F = de frontera.
-- Los valores precedidos por dos puntos son parametros.

-- [T1] Cambio de reloj de un usuario (OLTP, escribe, con transaccion)
BEGIN;
  -- 1) cierra el vinculo vigente del usuario, si existe
  UPDATE dispositivo
     SET fecha_desvinculacion = :ahora
   WHERE author_id = :usuario
     AND fecha_desvinculacion IS NULL;
  -- 2) abre el vinculo con el reloj nuevo
  INSERT INTO dispositivo (device_id, author_id, modelo, fecha_vinculacion)
  VALUES (:reloj_nuevo, :usuario, :modelo, :ahora);
COMMIT;
-- Si algo falla entre 1) y 2): ROLLBACK, y el vinculo anterior sigue vigente.
-- Regla protegida: indice unico sobre (author_id) donde fecha_desvinculacion IS NULL.

-- [T2] Recepcion de un lote de sincronizacion (OLTP, escribe, idempotente)
BEGIN;
  INSERT INTO medicion
         (device_id, ts_medicion, ts_recepcion, frecuencia_cardiaca, pasos, calorias)
  VALUES (:reloj, :t1, :ahora, :fc1, :pasos1, :kcal1),
         (:reloj, :t2, :ahora, :fc2, :pasos2, :kcal2)   -- ... una fila por lectura del lote
  ON CONFLICT (device_id, ts_medicion) DO NOTHING;      -- reenviar el lote no duplica
COMMIT;                                                 -- solo entonces se confirma al telefono

-- [T3] Recomendacion del dia para un usuario (OLTP, lee por clave)
ids := GET recomendacion:{usuario}:{hoy};        -- almacen clave-valor, una lectura
SELECT recipe_id, nombre, calorias, proteina, tiempo_total
  FROM receta
 WHERE recipe_id IN (ids);                       -- hasta 10 filas por clave primaria

-- [A1] Recetas candidatas segun el gasto reciente de cada usuario (OLAP, responde el objetivo)
WITH gasto_reciente AS (
  SELECT id_usuario, AVG(kcal_dia) AS gasto_7d
    FROM (SELECT id_usuario, fecha_local, SUM(kcal_gastadas) AS kcal_dia
            FROM hechos_actividad_diaria
           WHERE fecha_local BETWEEN :hoy - 7 AND :hoy - 1
           GROUP BY id_usuario, fecha_local)
   GROUP BY id_usuario
)
SELECT g.id_usuario, r.id_receta, r.nombre, r.kcal_porcion, r.proteina_porcion
  FROM gasto_reciente g
  JOIN dim_receta r
    ON r.kcal_porcion BETWEEN :fraccion_min * g.gasto_7d
                          AND :fraccion_max * g.gasto_7d
 WHERE r.calificacion_promedio >= 4
   AND r.n_resenas >= 5
QUALIFY ROW_NUMBER() OVER (PARTITION BY g.id_usuario
                           ORDER BY r.calificacion_promedio DESC, r.n_resenas DESC) <= 10;

-- [A2] Balance diario entre gasto y comidas registradas por usuario (OLAP)
WITH gasto AS (
  SELECT id_usuario, fecha_local,
         SUM(kcal_gastadas) AS kcal_gastadas, SUM(pasos) AS pasos,
         SUM(minutos_sesion) AS minutos_sesion
    FROM hechos_actividad_diaria
   WHERE fecha_local BETWEEN :desde AND :hasta
   GROUP BY id_usuario, fecha_local
),
comidas AS (
  SELECT id_usuario, fecha_local, COUNT(*) AS comidas,
         SUM(kcal_porcion) AS kcal_registradas, SUM(proteina_porcion) AS proteina_registrada
    FROM hechos_comida
   WHERE fecha_local BETWEEN :desde AND :hasta
   GROUP BY id_usuario, fecha_local
)
SELECT g.id_usuario, g.fecha_local, f.dia_semana, g.kcal_gastadas,
       AVG(g.kcal_gastadas) OVER (PARTITION BY g.id_usuario ORDER BY g.fecha_local
                                  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS gasto_media_7d,
       COALESCE(c.comidas, 0) AS comidas, c.kcal_registradas,
       g.kcal_gastadas - c.kcal_registradas AS balance_kcal
  FROM gasto g
  JOIN dim_fecha f ON f.fecha = g.fecha_local
  LEFT JOIN comidas c ON c.id_usuario = g.id_usuario AND c.fecha_local = g.fecha_local
 ORDER BY g.id_usuario, g.fecha_local;

-- [A3] Completitud y atraso de las mediciones por dia y modelo de reloj (OLAP)
SELECT fecha_medicion, modelo, COUNT(*) AS mediciones,
       AVG(CASE WHEN ts_recepcion <= fecha_medicion + INTERVAL '30 hours'
                THEN 1 ELSE 0 END) AS fraccion_disponible_06h,   -- 06:00 UTC del dia siguiente
       QUANTILE(minutos_atraso, 0.5) AS atraso_mediano,
       QUANTILE(minutos_atraso, 0.9) AS atraso_p90
  FROM mediciones_limpias
 WHERE fecha_medicion BETWEEN :desde AND :hasta
 GROUP BY fecha_medicion, modelo
 ORDER BY fecha_medicion, modelo;

-- [F1] Resumen de hoy que el usuario ve al abrir la app (frontera)
SELECT SUM(pasos) AS pasos_hoy, SUM(calorias) AS kcal_hoy, MAX(ts_medicion) AS ultima_medicion
  FROM medicion
 WHERE device_id = :reloj
   AND ts_medicion >= :inicio_del_dia_local;
-- En la practica la app no ejecuta esta suma: lee el valor ya calculado.
valor := GET resumen:{usuario}:{hoy};
