-- ============================================================================
-- CONSULTA 1 — Vista base del proyecto (INNER JOIN)
-- Propósito: Consolidar el modelo estrella vinculando hechos con sus dimensiones.
--            Esta consulta será la fuente de datos principal en Power BI.
-- ============================================================================
SELECT 
    v.fecha_venta,
    c.nombre AS nombre_cliente,
    -- Como el modelo no incluye tabla 'segmento', usamos la 'ciudad' del cliente
    c.ciudad AS segmento_region, 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria;

-- ============================================================================
-- CONSULTA 2 — Clientes sin ventas (LEFT JOIN con IS NULL)
-- Propósito: Identificar usuarios registrados en la base que aún no compraron.
-- ============================================================================
SELECT 
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_cliente IS NULL;

-- Hallazgo Consulta 2: Al analizar los datos actuales del M3, todos los clientes 
-- registrados (IDs del 1 al 5) tienen al menos una venta asignada, lo que indica 
-- un 100% de conversión inicial en esta muestra.

-- ============================================================================
-- CONSULTA 3 — Productos sin ventas (LEFT JOIN con IS NULL)
-- Propósito: Identificar artículos del catálogo que no registran movimiento.
-- ============================================================================
SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_producto IS NULL;

-- Hallazgo Consulta 3: El catálogo del M3 cuenta con productos totalmente activos 
-- que están cubriendo la demanda actual, sin registrar por ahora stock inmovilizado.

-- ============================================================================
-- CONSULTA 4 — Consolidado por canal (UNION ALL)
-- Propósito: Unificar flujos simulados de venta Online y Presencial mediante 
--            UNION ALL para evaluar el peso del total facturado por origen.
-- ============================================================================
WITH VentasPorCanal AS (
    -- Simulamos Canal Online para las ventas con ID impar
    SELECT 
        id_venta,
        (cantidad * precio_unitario) AS monto_total,
        'Online' AS canal
    FROM ventas
    WHERE id_venta % 2 <> 0

    UNION ALL

    -- Simulamos Canal Presencial para las ventas con ID par
    SELECT 
        id_venta,
        (cantidad * precio_unitario) AS monto_total,
        'Presencial' AS canal
    FROM ventas
    WHERE id_venta % 2 = 0
)
SELECT 
    canal,
    COUNT(id_venta) AS cantidad_transacciones,
    SUM(monto_total) AS total_facturado_por_canal
FROM VentasPorCanal
GROUP BY canal;

-- Hallazgo Consulta 4: La combinación mediante UNION ALL permite estructurar y segmentar 
-- flujos de datos distribuidos bajo las mismas condiciones métricas requeridas por el negocio.
