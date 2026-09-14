use `tp_bd1`;

DELIMITER //

DROP PROCEDURE IF EXISTS altaInsumo //

CREATE PROCEDURE altaInsumo(
	OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN i_id_insumo INT,
    IN i_descripcion VARCHAR (45)
)
BEGIN
	IF EXISTS(SELECT 1 FROM insumo where id_insumo = i_id_insumo) THEN
		SET nResultado = -1;
        SET cMensaje = "ERORR, INSUMO YA CARGADO";
	ELSEIF EXISTS (SELECT 1 FROM insumo WHERE LOWER(TRIM(descripcion)) = LOWER(TRIM(i_descripcion))) THEN
        SET nResultado = -1;
        SET cMensaje = 'ERROR: YA EXISTE UN INSUMO CON LA MISMA DESCRIPCION';
	ELSE
		INSERT INTO insumo(id_insumo, descripcion) 
        VALUES (i_id_insumo, i_descripcion);
        
        SET nResultado= 0;
        SET cMensaje= "";
	END IF;
END //


DROP PROCEDURE IF EXISTS modificarInsumo //

CREATE PROCEDURE modificarInsumo(
	OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN i_id_insumo INT,
    IN i_descripcion VARCHAR (45)
)
BEGIN 
	IF NOT EXISTS(SELECT 1 FROM insumo WHERE id_insumo= i_id_insumo) THEN
		SET nResultado = -1;
        SET cMensaje = "ERORR, INSUMO INEXISTENTE";
	ELSEIF EXISTS (SELECT 1 FROM insumo WHERE LOWER(TRIM(descripcion)) = LOWER(TRIM(i_descripcion))) THEN
        SET nResultado = -1;
        SET cMensaje = 'ERROR: YA EXISTE UN INSUMO CON LA MISMA DESCRIPCION';
	ELSE
		UPDATE insumo
		SET descripcion= i_descripcion
        WHERE id_insumo= i_id_insumo;
		SET nResultado= 0;
        SET cMensaje= "";
	END IF;
END //



DROP PROCEDURE IF EXISTS bajaInsumo //

CREATE PROCEDURE bajaInsumo(
	OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN i_id_insumo INT
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM insumo WHERE id_insumo= i_id_insumo) THEN
		SET nResultado = -1;
		SET cMensaje = "ERORR, INSUMO INEXISTENTE";
	ELSEIF EXISTS (SELECT 1 FROM insumo_proveedor ip WHERE i_id_insumo = ip.id_insumo)THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, INSUMO CON PROVEEDOR RELACIONADO";
	ELSEIF EXISTS (SELECT 1 FROM insumo_estacion_de_trabajo it WHERE i_id_insumo = it.id_insumo) THEN
		SET nResultado = -1;
		SET cMensaje = "ERROR, INSUMO CON ESTACION DE TRABAJO RELACIONADA";
	ELSE
		DELETE FROM insumo WHERE id_insumo = i_id_insumo;
		SET nResultado= 0;
        SET cMensaje= "";
	END IF;
END //
DELIMITER ;