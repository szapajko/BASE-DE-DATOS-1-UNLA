USE `tp_bd1`;

DELIMITER //


DROP PROCEDURE IF EXISTS altaConcesionaria //

CREATE PROCEDURE altaConcesionaria(
    OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN c_id_concesionaria INT,
    IN c_razon_social VARCHAR(45),
    IN c_nombre VARCHAR(45)
)
BEGIN 
    IF EXISTS (SELECT 1 FROM concesionaria WHERE id_concesionaria = c_id_concesionaria) THEN
        SET nResultado = -1;
        SET cMensaje = 'ERROR: CONCESIONARIA YA REGISTRADA CON MISMO ID';
    ELSEIF EXISTS (SELECT 1 FROM concesionaria WHERE razon_social = c_razon_social) THEN
        SET nResultado = -1;
        SET cMensaje = 'ERROR: YA EXISTE UNA CONCESIONARIA CON LA MISMA RAZON SOCIAL';
    ELSE
        INSERT INTO concesionaria (id_concesionaria, razon_social, nombre)
        VALUES (c_id_concesionaria, c_razon_social, c_nombre);
        
        SET nResultado = 0;
        SET cMensaje = ''; 
    END IF;
END //


DROP PROCEDURE IF EXISTS modificarConcesionaria //

CREATE PROCEDURE modificarConcesionaria(
    OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN c_id_concesionaria INT,
    IN c_razon_social VARCHAR(45),
    IN c_nombre VARCHAR(45)
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM concesionaria c where c.id_concesionaria = c_id_concesionaria)THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, CONCESIONARIA INEXISTENTE";
	ELSEIF EXISTS(SELECT 1 FROM concesionaria c where c.razon_social = c_razon_social AND c_id_concesionaria <> c.id_concesionaria) THEN
			SET nResultado = -1;
			SET cMensaje = "ERROR, CONCESIONARIA EXISTENTE CON MISMA RAZON SOCIAL";
	ELSE
		UPDATE concesionaria
        SET razon_social = c_razon_social,
			nombre= c_nombre
		WHERE id_concesionaria = c_id_concesionaria;
		SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //


DROP PROCEDURE IF EXISTS bajaConcesionaria //

CREATE PROCEDURE bajaConcesionaria(
    OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN c_id_concesionaria INT
)
BEGIN
	IF EXISTS (SELECT 1 FROM pedido p WHERE p.id_concesionaria = c_id_concesionaria) THEN
		SET nResultado = -1;
        SET cMensaje = "ERROR, CONCESIONARIA CON PEDIDOS REGISTRADOS";
	ELSEIF NOT EXISTS(SELECT 1 FROM concesionaria where id_concesionaria=c_id_concesionaria) THEN
			SET nResultado = -1;
			SET cMensaje = "ERROR, CONCESIONARIA INEXISTENTE";		
	ELSE
		DELETE FROM concesionaria WHERE id_concesionaria = c_id_concesionaria;
		SET nResultado = 0;
        SET cMensaje = '';
    END IF;
END //
DELIMITER ;