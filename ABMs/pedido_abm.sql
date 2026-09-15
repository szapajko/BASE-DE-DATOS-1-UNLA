USE `tp_bd1`;

DELIMITER //
DROP PROCEDURE IF EXISTS altaPedido //

CREATE PROCEDURE altaPedido(
	OUT nResultado INT,
    OUT cMensaje VARCHAR (100),
    IN p_id_concesionaria INT,
    IN p_num_pedido INT,
    IN p_fecha DATE,
    IN p_fecha_entrega_estimada DATE
)
BEGIN
	IF EXISTS( SELECT 1 FROM pedido WHERE num_pedido = p_num_pedido)THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, NUMERO DE PEDIDO YA INGRESADO";
	ELSEIF NOT EXISTS (SELECT 1 FROM concesionaria WHERE id_concesionaria = p_id_concesionaria)THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, CONCESIONARIA INEXISTENTE";	
	ELSEIF (p_fecha > p_fecha_entrega_estimada) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, FECHA DE ENTREGA FUERA DE TERMINO";
	ELSE
		INSERT INTO pedido(id_concesionaria, num_pedido, fecha, fecha_entrega_estimada)
        VALUES (p_id_concesionaria, p_num_pedido, p_fecha, p_fecha_entrega_estimada);
        SET nResultado = 0;
        SET cMensaje = "";
    END IF;
END //


DROP PROCEDURE IF EXISTS modificarPedido //

CREATE PROCEDURE modificarPedido(
	OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN p_num_pedido INT,
	IN p_fecha DATE,
    IN p_fecha_entrega_estimada DATE
)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pedido WHERE num_pedido = p_num_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, PEDIDO INEXISTENTE";
	ELSEIF (p_fecha_entrega_estimada < p_fecha) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, FECHA DE ENTREGA FUERA DE TERMINO";
	ELSE
		UPDATE pedido
        SET fecha=p_fecha,
			fecha_entrega_estimada = p_fecha_entrega_estimada
		WHERE num_pedido = p_num_pedido;
		SET nResultado = 0;
        SET cMensaje = '';
	END IF;
END //


DROP PROCEDURE IF EXISTS bajaPedido //

CREATE PROCEDURE bajaPedido(
	OUT nResultado int,
	OUT cMensaje VARCHAR (100),
    IN p_num_pedido INT
)
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM pedido WHERE num_pedido = p_num_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, PEDIDO INEXISTENTE";
	ELSEIF EXISTS(SELECT 1 FROM detalle_pedido dp JOIN pedido p ON dp.id_pedido = p.id_pedido WHERE p.num_pedido = p_num_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, PEDIDO CON DETALLES CARGADOS";
	ELSE
		DELETE FROM pedido WHERE num_pedido = p_num_pedido;
		SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;