USE `tp_bd1`;

-- SCRIPT DE PRUEBAS UNITARIAS: ABM INSUMO

-- Aseguramos un proveedor y una estación base para probar dependencias
INSERT IGNORE INTO proveedor (id_proveedor, nombre) VALUES (900, 'Proveedor Test S.A.');
INSERT IGNORE INTO tarea (id_tarea, descripcion) VALUES (900, 'Tarea Test');
INSERT IGNORE INTO modelo (id_modelo, descripcion) VALUES (900, 'Modelo Test');
INSERT IGNORE INTO linea_de_montaje (id_linea_de_montaje, vehiculos_por_mes, id_modelo) VALUES (900, 10, 900);
INSERT IGNORE INTO estacion_de_trabajo (id_estacion_de_trabajo, orden, id_tarea, id_linea_de_montaje) 
VALUES (900, 1, 900, 900);

-- CASO 1: Alta Exitosa
CALL altaInsumo(@res, @msg, 901, 'Optica Delantera LED');
SELECT 'CASO 1: Alta Exitosa' AS Test, @res AS Codigo, @msg AS Mensaje;

SELECT * FROM insumo WHERE id_insumo = 901;


-- CASO 2: Alta Rechazada por ID Repetido
CALL altaInsumo(@res, @msg, 901, 'Otro Insumo');
SELECT 'CASO 2: Alta ID Repetido' AS Test, @res AS Codigo, @msg AS Mensaje;



-- CASO 3: Alta Rechazada por Descripción Repetida (distinto ID)
CALL altaInsumo(@res, @msg, 902, 'optica delantera led');
SELECT 'CASO 3: Alta Descripcion Repetida' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 4: Modificación Exitosa
CALL modificarInsumo(@res, @msg, 901, 'Optica Delantera LED Regulable');
SELECT 'CASO 4: Modificacion Exitosa' AS Test, @res AS Codigo, @msg AS Mensaje;

SELECT * FROM insumo WHERE id_insumo = 901;


-- CASO 5: Modificación Rechazada por ID Inexistente
CALL modificarInsumo(@res, @msg, 99999, 'Insumo Fantasma');
SELECT 'CASO 5: Modificacion ID Inexistente' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 6: Modificación Rechazada por Descripción ya tomada por otro insumo

-- creamos el insumo 902 
CALL altaInsumo(@res, @msg, 902, 'Filtro de Aceite');

-- cambiar el 901 para que tenga la misma descripción del 902
CALL modificarInsumo(@res, @msg, 901, 'Filtro de Aceite');
SELECT 'CASO 6: Modificacion Descripcion Duplicada' AS Test, @res AS Codigo, @msg AS Mensaje;



-- CASO 7: Baja Rechazada por Vinculación con Proveedor
INSERT INTO insumo_proveedor (id_insumo, id_proveedor, precio) VALUES (901, 900, 15000.00);

CALL bajaInsumo(@res, @msg, 901);
SELECT 'CASO 7: Baja con Proveedor' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 8: Baja Rechazada por Asignación a Estación de Trabajo
-- Desvinculamos del proveedor pero lo asignamos a una estación
DELETE FROM insumo_proveedor WHERE id_insumo = 901;
INSERT INTO insumo_estacion_de_trabajo (id_insumo, id_estacion_de_trabajo, cantidad) VALUES (901, 900, 2);

CALL bajaInsumo(@res, @msg, 901);
SELECT 'CASO 8: Baja con Estacion' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 9: Baja Rechazada por ID Inexistente
CALL bajaInsumo(@res, @msg, 99999);
SELECT 'CASO 9: Baja ID Inexistente' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 10: Baja Exitosa
-- Quitamos la asignación a la estación
DELETE FROM insumo_estacion_de_trabajo WHERE id_insumo = 901;

CALL bajaInsumo(@res, @msg, 901);
SELECT 'CASO 10: Baja Exitosa' AS Test, @res AS Codigo, @msg AS Mensaje;

-- Eliminamos también el insumo 902
CALL bajaInsumo(@res, @msg, 902);

-- Verificación: No deben figurar los registros
SELECT * FROM insumo WHERE id_insumo IN (901, 902);