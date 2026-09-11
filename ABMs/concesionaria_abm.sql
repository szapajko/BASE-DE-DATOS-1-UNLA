USE `tp_bd1`;

DELIMITER //

DROP PROCEDURE IF EXISTS altaConcesionaria //

CREATE PROCEDURE altaConcesionaria(
    OUT nResultado INT,
    OUT cMensaje VARCHAR(100),
    IN c_razon_social VARCHAR(45),
    IN c_nombre VARCHAR(45)
)
BEGIN 
    IF EXISTS (SELECT 1 FROM concesionaria WHERE razon_social = c_razon_social) THEN
        SET nResultado = -1;
        SET cMensaje = 'RAZON SOCIAL YA REGISTRADA';
    ELSE
        INSERT INTO concesionaria (razon_social, nombre)
        VALUES (c_razon_social, c_nombre);
        
        SET nResultado = 0;
        SET cMensaje = 'ELEMENTO CARGADO CON EXITO';
    END IF;
END //

DELIMITER ;