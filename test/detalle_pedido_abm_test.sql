USE `tp_bd1`;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE concesionaria;
TRUNCATE TABLE pedido;
TRUNCATE TABLE modelo;
TRUNCATE TABLE detalle_pedido;
SET FOREIGN_KEY_CHECKS = 1;

-- CASO 1: Alta Exitosa
-- INSERT DE DEPENDENCIAS (MODELO Y PEDIDO)
CALL altaConcesionaria(@res, @msg, 1, "Prueba S.A", "Prueba Nombre");
INSERT INTO modelo (id_modelo, descripcion) 
VALUES  (1,"PRUEBA");
CALL altaPedido(@res, @msg,1,20,'2004-11-12','2004-12-25');

CALL altaDetallePedido(@res, @msg, 1,1,1,4);
SELECT 'Caso 1: Alta Exitosa' as Test, @res as Resultado, @msg as Mensaje;
SELECT * FROM detalle_pedido;


-- CASO 2: Alta rechazada por detalle ya cargado
CALL altaDetallePedido(@res, @msg, 1,1,1,4);
SELECT 'Caso 2: Alta Rechazada por duplicado' as Test, @res as Resultado, @msg as Mensaje;


-- CASO 3: Pedido inexistente
CALL altaDetallePedido(@res, @msg, 2,999,1,4);
SELECT 'Caso 3: Alta Rechazada por Pedido inexistente' as Test, @res as Resultado, @msg as Mensaje;


-- CASO 4: Modelo inexistente
CALL altaDetallePedido(@res, @msg, 2,1,999,4);
SELECT 'Caso 4: Alta Rechazada por Modelo inexistente' as Test, @res as Resultado, @msg as Mensaje;


-- CASO 5: Modelo y Pedido ya cargados
CALL altaDetallePedido(@res, @msg, 2,1,1,4);
SELECT 'Caso 5: Alta Rechazada por Modelo y Pedido ya cargados' as Test, @res as Resultado, @msg as Mensaje;


-- CASO 6: Modificación Exitosa
-- Modificamos la cantidad de 4 a 6 en el detalle existente
CALL modificarDetallePedido(@res, @msg, 1, 6);
SELECT 'Caso 6: Modificación Exitosa' as Test, @res as Resultado, @msg as Mensaje;
SELECT * FROM detalle_pedido WHERE id_detalle_pedido = 1;


-- CASO 7: Detalle Inexistente
CALL modificarDetallePedido(@res, @msg, 999, 5);
SELECT 'Caso 7: Detalle Inexistente' as Test, @res as Resultado, @msg as Mensaje;


-- CASO 8: Cantidad Inválida (Menor o igual a 0)
CALL modificarDetallePedido(@res, @msg, 1, -1);
SELECT 'Caso 8: Cantidad Menor o Igual a 0' as Test, @res as Resultado, @msg as Mensaje;


-- CASO 9: Cantidad menor a la cantidad de autos ya fabricados
-- INSERT DE SIMULACIÓN: Asignamos 3 vehículos a este detalle
INSERT INTO vehiculo (nro_chasis, id_modelo, id_detalle_pedido)
VALUES 
    ('AAA001', 1, 1),
    ('AAA002', 1, 1),
    ('AAA003', 1, 1);

-- Intentamos reducir la cantidad a 2 (habiendo ya 3 fabricados)
CALL modificarDetallePedido(@res, @msg, 1, 2);
SELECT 'Caso 9: Rechazada por Vehículos Fabricados' as Test, @res as Resultado, @msg as Mensaje;


-- CASO 10: Modificación Exitosa con Vehículos Existentes (Límite permitido)
-- Ajustamos la cantidad a 3 (igual a la cantidad de autos existentes)
CALL modificarDetallePedido(@res, @msg, 1, 3);
SELECT 'Caso 10: Modificación Exitosa' as Test, @res as Resultado, @msg as Mensaje;
SELECT * FROM detalle_pedido WHERE id_detalle_pedido = 1;


-- CASO 11: Baja rechazada por detalle inexistente
CALL bajaDetallePedido(@res, @msg, 9999);
SELECT 'Caso 11: Detalle Inexistente' AS Test, @res AS Resultado, @msg AS Mensaje;


-- CASO 12: Baja rechazada por tener vehículos asociados
CALL bajaDetallePedido(@res, @msg, 1);
SELECT 'Caso 12: Rechazada con Vehiculos' AS Test, @res AS Resultado, @msg AS Mensaje;


-- CASO 13: Baja Exitosa
-- Eliminamos primero los vehículos de prueba vinculados para liberar el detalle
DELETE FROM vehiculo WHERE id_detalle_pedido = 1;

CALL bajaDetallePedido(@res, @msg, 1);
SELECT 'Caso 13: Baja Exitosa' AS Test, @res AS Resultado, @msg AS Mensaje;


-- Verificación en la tabla física
SELECT * FROM detalle_pedido WHERE id_detalle_pedido = 1;
