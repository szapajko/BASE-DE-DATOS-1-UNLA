use `tp_bd1`;



DELIMITER //

DROP PROCEDURE IF EXISTS altaDetallePedido //

CREATE PROCEDURE altaDetallePedido(
	OUT nResultado INT,
    OUT cMensaje VARCHAR (100),
    IN dp_id_detalle_pedido INT,
    IN dp_id_pedido INT,
    IN dp_id_modelo INT,
    IN dp_cantidad INT
)
BEGIN
	IF EXISTS (SELECT 1 FROM detalle_pedido where id_detalle_pedido = dp_id_detalle_pedido) THEN
		SET nResultado = -1;
        SET cMensaje ="ERROR, DETALLE YA CARGADO";
	ELSEIF NOT EXISTS (SELECT 1 FROM pedido WHERE id_pedido = dp_id_pedido) THEN
		SET nResultado = -1;
        SET cMensaje ="ERROR, PEDIDO INEXISTENTE";
	ELSEIF NOT EXISTS (SELECT 1 FROM modelo WHERE id_modelo = dp_id_modelo) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, MODELO INEXISTENTE";
	ELSEIF (dp_cantidad < 1) THEN
		SET nResultado = -1;
        SET cMensaje= "ERROR, LA CANTIDAD NO PUEDE SER MENOR O IGUAL A 0";
	ELSEIF EXISTS (SELECT 1 FROM detalle_pedido where id_pedido = dp_id_pedido AND id_modelo = dp_id_modelo) THEN
		SET nResultado = -1;
        SET cMensaje= "ERROR, PEDIDO Y MODELO YA INGRESADOS";	
    ELSE
		INSERT INTO detalle_pedido(id_detalle_pedido, id_pedido, id_modelo, cantidad)
        VALUES (dp_id_detalle_pedido, dp_id_pedido, dp_id_modelo, dp_cantidad);
        SET nResultado = 0;
        SET cMensaje ="";
	END IF;
END //



DROP PROCEDURE IF EXISTS modificarDetallePedido //

CREATE PROCEDURE modificarDetallePedido(
	OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN dp_id_detalle_pedido INT,
    IN dp_cantidad INT
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM detalle_pedido where id_detalle_pedido = dp_id_detalle_pedido) THEN
		SET nResultado = -1;
        SET cMensaje= "ERROR, DETALLE INEXISTENTE";
    -- VERIFICACION DE QUE LA CANTIDAD SEA MAYOR A 0   
    ELSEIF (dp_cantidad <= 0) THEN
		SET nResultado = -1;
        SET cMensaje= "ERROR, LA CANTIDAD DEBE SER MAYOR A 0";
	-- REALIZAR VERIFICACION SOBRE LA EXISTENCIA DE VEHICULOS FABRICADOS DONDE LA NUEVA CANTIDAD NO SEA MENOR (cantFrabricados < dp_cantidad)
    ELSEIF ( dp_cantidad < (SELECT COUNT(*) FROM vehiculo WHERE id_detalle_pedido = dp_id_detalle_pedido)) THEN
		SET nResultado = -1;
        SET cMensaje= "ERROR, LA CANTIDAD NO PUEDE SER MENOR A LA CANTIDAD DE AUTOS FABRICADOS";
    ELSE
		UPDATE detalle_pedido
        SET cantidad = dp_cantidad
		WHERE id_detalle_pedido = dp_id_detalle_pedido;
        SET nResultado = 0;
        SET cMensaje ="";
	END IF;
END //


DROP PROCEDURE IF EXISTS bajaDetallePedido //

CREATE PROCEDURE bajaDetallePedido(
	OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN dp_id_detalle_pedido INT
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM detalle_pedido WHERE id_detalle_pedido = dp_id_detalle_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, DETALLE INEXISTENTE";
	ELSEIF EXISTS(SELECT 1 FROM vehiculo WHERE id_detalle_pedido = dp_id_detalle_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, DETALLE CON VEHICULOS CARGADOS";
	ELSE
		DELETE FROM detalle_pedido WHERE id_detalle_pedido = dp_id_detalle_pedido;
		SET nResultado = 0;
        SET cMensaje ="";       
	END IF;
END//
DELIMITER ;