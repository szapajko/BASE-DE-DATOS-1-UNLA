USE `tp_bd1`;

DELIMITER //

DROP PROCEDURE IF EXISTS finalizarLabor //

CREATE PROCEDURE finalizarLabor (
	IN p_nro_chasis VARCHAR(7),
    OUT nResultado int,
    OUT cMensaje varchar(255)
    )
BEGIN
	DECLARE v_estacion_actual int;
	DECLARE v_linea_actual int;
	DECLARE v_orden_actual int;
	DECLARE v_ultima_orden int;
	DECLARE v_estacion_siguiente int;
	DECLARE v_chasis_ocupante VARCHAR(7);
	SET nResultado = 0;
    SET cMensaje = '';
  
	SELECT vet.id_estacion_de_trabajo,et.id_linea_de_montaje,et.orden into v_estacion_actual,v_linea_actual,v_orden_actual
	FROM vehiculo_estacion_de_trabajo vet JOIN estacion_de_trabajo et ON vet.id_estacion_de_trabajo = et.id_estacion_de_trabajo
	JOIN linea_de_montaje lm ON et.id_linea_de_montaje = lm.id_linea_de_montaje where vet.nro_chasis = p_nro_chasis AND vet.fecha_de_egreso IS NULL;
    
    if v_estacion_actual is null and v_linea_actual is null and v_orden_actual is null then
		SET nResultado= -1;
        SET cMensaje ='No se encontro el vehiculo';
	ELSE
        
		SELECT id_estacion_de_trabajo INTO v_estacion_siguiente FROM estacion_de_trabajo
		WHERE id_linea_de_montaje = v_linea_actual AND orden = v_orden_actual + 1;
		SELECT max(orden) into v_ultima_orden from estacion_de_trabajo where id_linea_de_montaje = v_linea_actual;
        
		IF (v_orden_actual = v_ultima_orden) THEN
			SET nResultado = 1;
            UPDATE vehiculo_estacion_de_trabajo
			SET fecha_de_egreso=NOW()
            where nro_chasis = p_nro_chasis
            AND id_estacion_de_trabajo = v_estacion_actual
            AND fecha_de_egreso is NULL;
            UPDATE vehiculo
            SET fecha_fin=NOW()
            where nro_chasis = p_nro_chasis;
		ELSEIF EXISTS (SELECT 1 from vehiculo_estacion_de_trabajo WHERE id_estacion_de_trabajo = v_estacion_siguiente and fecha_de_egreso is null) THEN

                SELECT nro_chasis into v_chasis_ocupante from vehiculo_estacion_de_trabajo where id_estacion_de_trabajo = v_estacion_siguiente
                AND fecha_de_egreso is NULL;
				SET cMensaje = CONCAT('Ya hay un vehiculo en la estacion de trabajo ',v_chasis_ocupante);
                SET nResultado = -1;
                
			ELSE
            
				UPDATE vehiculo_estacion_de_trabajo
				SET fecha_de_egreso = now()
				WHERE nro_chasis = p_nro_chasis
				AND id_estacion_de_trabajo = v_estacion_actual
				AND fecha_de_egreso is NULL;
				INSERT into vehiculo_estacion_de_trabajo (nro_chasis,id_estacion_de_trabajo,fecha_de_ingreso)
				VALUES (p_nro_chasis,v_estacion_siguiente,NOW());
				SET nResultado = 1;
                END IF;
			END IF;
END //
DELIMITER ;