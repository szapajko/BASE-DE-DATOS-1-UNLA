/*
Se requiere crear un procedimiento que al recibir como parámetro la patente del
automóvil, se le dé inicio al montaje del mismo, es decir, que al ejecutar dicho
procedimiento el automóvil con la patente indicada es “posicionado” en la primer
estación de la línea de montaje que le fue asignada al crear el vehículo con el
procedimiento
Nota: No puede ingresarse el vehículo en la estación de trabajo si es que hay otro
automóvil en dicho lugar. En caso de no ser posible la inserción del vehículo en la
primer estación por encontrarse ocupada, deberá retornar un resultado informando esta
situación, además del chasis del vehículo que está ocupando dicha estación.
*/

USE `tp_bd1`;

DELIMITER //

DROP PROCEDURE IF EXISTS inicioLabor //

CREATE PROCEDURE inicioLabor(
	IN p_nro_chasis VARCHAR (7),
    OUT nResultado int,
    OUT cMensaje varchar (255)
    )
BEGIN
    DECLARE v_estacion_de_trabajo int;
    DECLARE linea_montaje_asignada int;
    DECLARE chasis_ocupado VARCHAR(7);
	SET nResultado = 0;
    SET cMensaje = '';
	IF EXISTS (SELECT 1 from vehiculo WHERE nro_chasis = p_nro_chasis) THEN
    
		SELECT id_linea_de_montaje into linea_montaje_asignada from vehiculo v join modelo m on m.id_modelo = v.id_modelo
        JOIN linea_de_montaje lm on lm.id_modelo = m.id_modelo where v.nro_chasis = p_nro_chasis;
        
        SELECT id_estacion_de_trabajo into v_estacion_de_trabajo from estacion_de_trabajo et
        join linea_de_montaje lm on lm.id_linea_de_montaje = et.id_linea_de_montaje
        where lm.id_linea_de_montaje = linea_montaje_asignada and et.orden=1;
        
			IF EXISTS (SELECT 1 FROM vehiculo_estacion_de_trabajo vet
			JOIN estacion_de_trabajo et ON et.id_estacion_de_trabajo = vet.id_estacion_de_trabajo
			JOIN linea_de_montaje lm ON lm.id_linea_de_montaje = et.id_linea_de_montaje
			WHERE et.id_estacion_de_trabajo = v_estacion_de_trabajo
			AND et.id_linea_de_montaje = linea_montaje_asignada
			AND vet.fecha_de_egreso IS NULL) THEN
				SET cMensaje = 'La estacion de trabajo esta ocupada';
                SET nResultado = -1;
                select nro_chasis into chasis_ocupado
                from vehiculo_estacion_de_trabajo
                where id_estacion_de_trabajo = v_estacion_de_trabajo
                and fecha_de_egreso is null;
			ELSE
				INSERT into vehiculo_estacion_de_trabajo (nro_chasis,id_estacion_de_trabajo,fecha_de_ingreso)
                VALUES (p_nro_chasis,v_estacion_de_trabajo,NOW());
			SET nResultado=1;
            END IF;
		ELSE
        SET nResultado=-1;
        SET cMensaje ='No se encontro el vehiculo solicitado';
		END IF;
	END //
    
DELIMITER ;