USE `tp_bd1`;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE concesionaria;
TRUNCATE TABLE pedido;
SET FOREIGN_KEY_CHECKS = 1;

-- CASO 1: Alta Exitosa
CALL altaConcesionaria(@res, @msg, 'Auto del Valle S.A.', 'Central Quilmes');
SELECT 'CASO 1: Alta Exitosa' AS Test, @res AS Codigo, @msg AS Mensaje;

SELECT * FROM concesionaria WHERE razon_social = 'Auto del Valle S.A.';


-- CASO 2: Alta Rechazada por Razón Social Duplicada
CALL altaConcesionaria(@res, @msg, 'Auto del Valle S.A.', 'Sucursal Berazategui');
SELECT 'CASO 2: Alta Duplicada' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 3: Modificación Exitosa
SET @id_test = (SELECT id_concesionaria FROM concesionaria WHERE razon_social = 'Auto del Valle S.A.' LIMIT 1);

CALL modificarConcesionaria(@res, @msg, @id_test, 'Auto del Valle Motors S.A.', 'Casa Central');
SELECT 'CASO 3: Modificación Exitosa' AS Test, @res AS Codigo, @msg AS Mensaje;
SELECT * FROM concesionaria WHERE id_concesionaria = @id_test;



-- CASO 4: Modificación Rechazada (ID Inexistente)
CALL modificarConcesionaria(@res, @msg, 99999, 'Fantasma S.A.', 'Sucursal Inexistente');
SELECT 'CASO 4: Modificación ID Inexistente' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 5: Baja Rechazada por Integridad (Tiene Pedidos)
-- Creamos un pedido asociado
INSERT INTO pedido (id_concesionaria, num_pedido, fecha, fecha_entrega_estimada)
VALUES (@id_test, 9001, '2026-09-10', '2026-09-30');

CALL bajaConcesionaria(@res, @msg, @id_test);
SELECT 'CASO 5: Baja con Pedido Asociado' AS Test, @res AS Codigo, @msg AS Mensaje;


-- CASO 6: Baja Exitosa
-- Eliminamos el pedido de prueba
DELETE FROM pedido WHERE num_pedido = 9001;
CALL bajaConcesionaria(@res, @msg, @id_test);
SELECT 'CASO 6: Baja Exitosa' AS Test, @res AS Codigo, @msg AS Mensaje;

-- CASO 7: Baja rechadaza por Concesionaria Inexistente
CALL bajaConcesionaria(@res, @msg, @id_test);
SELECT 'CASO 7: Baja Inexistente' AS Test, @res AS Codigo, @msg AS Mensaje;

-- La tabla debe estar vacía nuevamente
SELECT * FROM concesionaria;