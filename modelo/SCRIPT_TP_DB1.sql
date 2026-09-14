CREATE DATABASE IF NOT EXISTS `tp_bd1`;
USE `tp_bd1`;

CREATE TABLE IF NOT EXISTS modelo (
    id_modelo INT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_modelo)
);

CREATE TABLE IF NOT EXISTS linea_de_montaje (
    id_linea_de_montaje INT NOT NULL AUTO_INCREMENT,
    vehiculos_por_mes INT NOT NULL,
    id_modelo INT NOT NULL,
    PRIMARY KEY (id_linea_de_montaje),
    CONSTRAINT uq_linea_modelo UNIQUE (id_modelo),
    CONSTRAINT fk_linea_modelo
        FOREIGN KEY (id_modelo)
        REFERENCES modelo (id_modelo)
);

CREATE TABLE IF NOT EXISTS tarea (
    id_tarea INT NOT NULL AUTO_INCREMENT,
    descripcion VARCHAR(75) NOT NULL,
    PRIMARY KEY (id_tarea)
);

CREATE TABLE IF NOT EXISTS estacion_de_trabajo (
    id_estacion_de_trabajo INT NOT NULL AUTO_INCREMENT,
    orden INT NOT NULL,
    id_tarea INT NOT NULL,
    id_linea_de_montaje INT NOT NULL,
    PRIMARY KEY (id_estacion_de_trabajo),
    CONSTRAINT fk_estacion_tarea
        FOREIGN KEY (id_tarea)
        REFERENCES tarea (id_tarea),
    CONSTRAINT fk_linea_estacion
        FOREIGN KEY (id_linea_de_montaje)
        REFERENCES linea_de_montaje (id_linea_de_montaje)
);

CREATE TABLE IF NOT EXISTS proveedor (
    id_proveedor INT NOT NULL ,
    nombre VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_proveedor)
);

CREATE TABLE IF NOT EXISTS insumo (
    id_insumo INT NOT NULL ,
    descripcion VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_insumo)
);

CREATE TABLE IF NOT EXISTS insumo_proveedor (
    id_insumo INT NOT NULL,
    id_proveedor INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_insumo, id_proveedor),
    CONSTRAINT fk_insumo_a_proveedor
        FOREIGN KEY (id_insumo)
        REFERENCES insumo (id_insumo),
    CONSTRAINT fk_proveedor_a_insumo
        FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
);

CREATE TABLE IF NOT EXISTS insumo_estacion_de_trabajo (
    id_insumo INT NOT NULL,
    id_estacion_de_trabajo INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_insumo, id_estacion_de_trabajo),
    CONSTRAINT fk_insumo_a_estacion
        FOREIGN KEY (id_insumo)
        REFERENCES insumo (id_insumo),
    CONSTRAINT fk_estacion_a_insumo
        FOREIGN KEY (id_estacion_de_trabajo)
        REFERENCES estacion_de_trabajo (id_estacion_de_trabajo)
);

CREATE TABLE IF NOT EXISTS concesionaria (
    id_concesionaria INT NOT NULL ,
    razon_social VARCHAR(45) NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    PRIMARY KEY (id_concesionaria)
);

CREATE TABLE IF NOT EXISTS pedido (
    id_pedido INT NOT NULL AUTO_INCREMENT,
    id_concesionaria INT NOT NULL,
    num_pedido INT NOT NULL,
    fecha DATE NOT NULL,
    fecha_entrega_estimada DATE NOT NULL,
    PRIMARY KEY (id_pedido),
    CONSTRAINT uq_num_pedido UNIQUE (num_pedido),
    CONSTRAINT fk_concesionaria_pedido
        FOREIGN KEY (id_concesionaria)
        REFERENCES concesionaria (id_concesionaria)
);

CREATE TABLE IF NOT EXISTS detalle_pedido (
    id_detalle_pedido INT NOT NULL AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_modelo INT NOT NULL,
    cantidad INT NOT NULL,
    PRIMARY KEY (id_detalle_pedido),
    CONSTRAINT fk_pedido_detalle
        FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido),
    CONSTRAINT fk_modelo_detalle
        FOREIGN KEY (id_modelo)
        REFERENCES modelo (id_modelo)
);

CREATE TABLE IF NOT EXISTS vehiculo (
    nro_chasis VARCHAR(7) NOT NULL,
    id_modelo INT NOT NULL,
    id_detalle_pedido INT NULL,
    PRIMARY KEY (nro_chasis),
    CONSTRAINT fk_modelo_vehiculo
        FOREIGN KEY (id_modelo)
        REFERENCES modelo (id_modelo),
    CONSTRAINT fk_detalle_pedido_vehiculo
        FOREIGN KEY (id_detalle_pedido)
        REFERENCES detalle_pedido (id_detalle_pedido)
);

CREATE TABLE IF NOT EXISTS vehiculo_estacion_de_trabajo (
    nro_chasis VARCHAR(7) NOT NULL,
    id_estacion_de_trabajo INT NOT NULL,
    fecha_de_ingreso DATETIME NOT NULL,
    fecha_de_egreso DATETIME NULL,
    PRIMARY KEY (nro_chasis, id_estacion_de_trabajo, fecha_de_ingreso),
    CONSTRAINT fk_vehiculo_a_estacion
        FOREIGN KEY (nro_chasis)
        REFERENCES vehiculo (nro_chasis),
    CONSTRAINT fk_estacion_a_vehiculo
        FOREIGN KEY (id_estacion_de_trabajo)
        REFERENCES estacion_de_trabajo (id_estacion_de_trabajo)
);