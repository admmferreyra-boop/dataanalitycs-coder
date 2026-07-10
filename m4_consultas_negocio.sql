-- Consulta 1 — Resumen ejecutivo mensual
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- Consulta 2 — Ranking de productos
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;

-- Consulta 3 — Clientes recurrentes
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- Consulta 4 — Meses por encima/por debajo del promedio
WITH TotalMensual AS (
    SELECT 
        MONTH(fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM TotalMensual) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_mensual
FROM TotalMensual
ORDER BY mes;

-- 1. Existe una fuerte erosión en el margen debido a que los picos de facturación mensual 
--    coinciden con campañas agresivas de descuentos masivos aplicadas en RetailPro.
-- 2. La baja recurrencia detectada en la tabla de ventas demuestra la necesidad urgente de 
--    analizar el impacto financiero de las promociones sobre la fidelización real de los clientes.
-- 3. El análisis del top de productos vendidos permitirá cruzar datos en el próximo módulo para 
--    aislar si la pérdida de rentabilidad se concentra en categorías específicas o proveedores.
