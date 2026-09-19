USE `tp_bd1`;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE concesionaria;
TRUNCATE TABLE pedido;
TRUNCATE TABLE modelo;
TRUNCATE TABLE detalle_pedido;
SET FOREIGN_KEY_CHECKS = 1;

-- CASO 1: ALTA EXITOSA
CALL altaConcesionaria(@res, @msg, 1,'Auto del Valle S.A.', 'Central Quilmes');

SET @id_concesionaria= (select id_concesionaria from concesionaria where razon_social="auto del valle s.a.");

CALL altaPedido(@res, @msg,  @id_concesionaria, 23, '2024-02-14' , '2024-02-23');
SELECT  @res as Codigo, @msg as Mensaje;

-- CASO 2: ALTA RECHAZADA POR NUMERO DE PEDIDO EXISTENTE
CALL altaPedido(@res, @msg,  @id_concesionaria, 23, '2024-12-14' , '2024-12-30');
SELECT  @res as Codigo, @msg as Mensaje;

-- CASO 3: ALTA RECHAZADA POR CONCESIONARIA INEXISTENTE
CALL altaPedido(@res, @msg, 9003, 11, '2024-12-14' , '2024-12-30');
SELECT  @res as Codigo, @msg as Mensaje;

-- CASO 4 ALTA RECHAZADA POR FECHAS ERRONEAS
CALL altaPedido(@res, @msg, 1, 24, '2024-12-01' , '2024-11-30');
SELECT  @res as Codigo, @msg as Mensaje;

-- CASO 5: MODIFICACION EXITOSA
SELECT * from pedido;
CALL modificarPedido(@res, @msg, 23, '2024-12-15', '2025-01-01');
SELECT  @res as Codigo, @msg as Mensaje;
SELECT * from pedido;

-- CASO 5: MODIFICACION RECHAZADA POR PEDIDO INEXISTENTE
CALL modificarPedido(@res, @msg,  5, '2024-12-14' , '2024-12-30');
SELECT  @res as Codigo, @msg as Mensaje;

-- CASO 6: BAJA EXITOSA
-- Doy de alta un pedido sin dependencias
CALL altaConcesionaria(@res, @msg, 2,'Lirio del Valle S.A.', 'Alburquerque');
CALL altaPedido(@res, @msg, 2, 102, '2025-10-12', '2025-11-30');
SELECT  @res as Codigo, @msg as Mensaje;

SELECT * FROM pedido;

CALL bajaPedido(@res, @msg, 102);
SELECT  @res as Codigo, @msg as Mensaje;
SELECT * FROM pedido;

-- CASO 7: BAJA RECHAZADA POR PEDIDO INEXISTENTE
CALL bajaPedido(@res, @msg, 999);
SELECT  @res as Codigo, @msg as Mensaje;

-- CASO 8: BAJA RECHAZADA POR PEDIDO CON DEPEDENCIAS
-- USO DE PRUEBA EL PRIMER PEDIDO CARGADO (CASO 1)
-- INSERT A DETALLE PEDIDO
INSERT INTO modelo(descripcion) VALUES ('auto prueba');
SET @id_modelo = (SELECT id_modelo FROM modelo LIMIT 1);
SET @id_pedido = (SELECT id_pedido FROM pedido WHERE num_pedido = 23);
INSERT INTO detalle_pedido (id_pedido, id_modelo, cantidad) VALUES(@id_pedido,@id_modelo,3);
CALL bajaPedido(@res, @msg, 23);
SELECT  @res as Codigo, @msg as Mensaje;


