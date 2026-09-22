USE `tp_bd1`;

DELIMITER //

DROP FUNCTION IF EXISTS chasisAleatorio //

CREATE FUNCTION chasisAleatorio() RETURNS  varchar(7)
NOT DETERMINISTIC
NO SQL
begin
	DECLARE v_returnStr VARCHAR(7) DEFAULT "";
    DECLARE v_caracteresValidos VARCHAR(50) DEFAULT 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
    DECLARE v_i INT DEFAULT 0;
    
	WHILE v_i < 7 DO
		SET v_returnStr= CONCAT(v_returnStr, SUBSTRING(v_caracteresValidos, FLOOR(RAND()* LENGTH(v_caracteresValidos) + 1),1)); 
		SET v_i = v_i + 1;
    END WHILE;
	RETURN v_returnStr;
END //


DROP TRIGGER IF EXISTS before_vehiculo_insert //

CREATE TRIGGER before_vehiculo_insert
BEFORE INSERT ON vehiculo
FOR EACH ROW
BEGIN
	DECLARE  v_existe INT DEFAULT 1;
    
    WHILE v_existe > 0 DO
		SET NEW.nro_chasis = chasisAleatorio();
		SELECT COUNT(*) INTO v_existe FROM vehiculo WHERE nro_chasis = NEW.nro_chasis;
	END WHILE;
END //

DROP PROCEDURE IF EXISTS cargaVehiculos //

CREATE PROCEDURE cargaVehiculos(
	OUT nResultado int,
	OUT cMensaje VARCHAR(100),
    IN p_num_pedido int
)
BEGIN
	-- DECLARO VARIABLES 
    DECLARE dp_id_detalle_pedido INT;
    DECLARE dp_id_modelo INT;
    DECLARE dp_cantidad INT;
    DECLARE v_cant INT;
    DECLARE v_fin INT DEFAULT 0;
    
    -- DECLARO CURSOR Y HANDLER
    DECLARE cursor_detalle_pedido
		CURSOR FOR
			SELECT dp.id_detalle_pedido, dp.id_modelo, dp.cantidad
			FROM detalle_pedido dp 
            JOIN pedido p ON dp.id_pedido = p.id_pedido
            WHERE p.num_pedido = p_num_pedido;
            
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = 1;           

	-- CONDICIONES
    IF NOT EXISTS(SELECT 1 FROM pedido WHERE num_pedido = p_num_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = 'ERROR, PEDIDO INEXISTENTE';
	ELSEIF NOT EXISTS(SELECT 1 FROM detalle_pedido dp JOIN pedido p on dp.id_pedido = p.id_pedido WHERE p.num_pedido = p_num_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = 'ERROR, DETALLE INEXISTENTE';
	ELSEIF EXISTS (SELECT 1 FROM vehiculo v  JOIN detalle_pedido dp ON dp.id_detalle_pedido = v.id_detalle_pedido JOIN pedido p ON p.id_pedido= dp.id_pedido WHERE p.num_pedido = p_num_pedido) THEN
		SET nResultado = -1;
        SET cMensaje = 'ERROR, VEHICULOS YA CARGADOS';
	ELSEIF EXISTS(SELECT 1 FROM detalle_pedido dp JOIN pedido p on dp.id_pedido = p.id_pedido WHERE p.num_pedido = p_num_pedido AND NOT EXISTS (SELECT 1 FROM linea_de_montaje lm WHERE lm.id_modelo = dp.id_modelo)) THEN
		SET nResultado = -1;
        SET cMensaje = 'ERROR, MODELOS SIN LINEA DE MONTAJE ASIGNADA';
	ELSE
		-- ABRO CURSOR
		OPEN cursor_detalle_pedido;
    
		cargaDetalle: LOOP
			
			FETCH cursor_detalle_pedido INTO dp_id_detalle_pedido, dp_id_modelo, dp_cantidad;
			
            -- SI NO HAY MAS FILAS
			IF v_fin = 1 THEN
				-- TERMINO EL BUCLE
				LEAVE cargaDetalle;
			END IF;
			
			SET v_cant= 0;
			WHILE v_cant < dp_cantidad DO
				INSERT INTO vehiculo(nro_chasis, id_modelo, id_detalle_pedido)
				VALUES ("", dp_id_modelo, dp_id_detalle_pedido);
				SET v_cant = v_cant + 1;
			END WHILE;
		END LOOP cargaDetalle;
		
        -- CIERRO CURSOR
		CLOSE cursor_detalle_pedido;
		SET nResultado = 0;
        SET cMensaje = '';
	END IF;
END //
DELIMITER ;