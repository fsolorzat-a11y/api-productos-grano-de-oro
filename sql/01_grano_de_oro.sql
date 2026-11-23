-- =====================================================================
-- Base de datos: grano_de_oro
-- Actividad GA6-220501096-AA1 - EV01
-- Aprendiz: Freddyrley Solorza Tabares - Ficha 3336142 - SENA Antioquia
-- Motor: MySQL 8.x (InnoDB)
-- =====================================================================

DROP DATABASE IF EXISTS grano_de_oro;
CREATE DATABASE grano_de_oro
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE grano_de_oro;

-- ---------------------------------------------------------------------
-- 1. Tablas de catalogo
-- ---------------------------------------------------------------------
CREATE TABLE linea_producto (
  id_linea   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre     VARCHAR(40) NOT NULL,
  PRIMARY KEY (id_linea),
  UNIQUE KEY uq_linea_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE categoria_ejemplar (
  id_categoria TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(30) NOT NULL,
  descripcion VARCHAR(150) NULL,
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_categoria_nombre (nombre)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. Productos por unidad de stock (rejones, instalaciones, Frota de Oro)
-- ---------------------------------------------------------------------
CREATE TABLE producto (
  id_producto     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_linea        TINYINT UNSIGNED NOT NULL,
  nombre          VARCHAR(80) NOT NULL,
  medida          VARCHAR(30) NULL,
  descripcion     VARCHAR(200) NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  stock_actual    INT NOT NULL DEFAULT 0,
  stock_minimo    INT NOT NULL DEFAULT 0,
  activo          TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_producto),
  KEY idx_producto_linea (id_linea),
  CONSTRAINT fk_producto_linea FOREIGN KEY (id_linea)
    REFERENCES linea_producto (id_linea)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_producto_precio CHECK (precio_unitario >= 0),
  CONSTRAINT ck_producto_stock CHECK (stock_actual >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Ejemplares (cada ave se controla de forma individual)
-- ---------------------------------------------------------------------
CREATE TABLE ejemplar (
  id_ejemplar      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo           VARCHAR(20) NOT NULL,
  id_categoria     TINYINT UNSIGNED NOT NULL,
  fecha_nacimiento DATE NULL,
  sexo             ENUM('macho','hembra') NOT NULL,
  estado           ENUM('disponible','reservado','vendido') NOT NULL DEFAULT 'disponible',
  precio           DECIMAL(10,2) NOT NULL,
  observaciones    VARCHAR(200) NULL,
  PRIMARY KEY (id_ejemplar),
  UNIQUE KEY uq_ejemplar_codigo (codigo),
  KEY idx_ejemplar_categoria (id_categoria),
  CONSTRAINT fk_ejemplar_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria_ejemplar (id_categoria)

     ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_ejemplar_precio CHECK (precio >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. Clientes y usuarios del sistema
-- ---------------------------------------------------------------------
CREATE TABLE cliente (
  id_cliente     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100) NOT NULL,
  documento      VARCHAR(20) NULL,
  telefono       VARCHAR(20) NULL,
  correo         VARCHAR(100) NULL,
  ciudad         VARCHAR(60) NULL,
  tipo_cliente   ENUM('criador','distribuidor','otro') NOT NULL DEFAULT 'criador',
  fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_cliente),
  UNIQUE KEY uq_cliente_documento (documento),
  KEY idx_cliente_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE usuario (
  id_usuario     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100) NOT NULL,
  nombre_usuario VARCHAR(30) NOT NULL,
  clave_hash     VARCHAR(255) NOT NULL,
  rol            ENUM('propietario','vendedor') NOT NULL DEFAULT 'vendedor',
  activo         TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuario_login (nombre_usuario)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. Ventas, detalles y facturas
-- ---------------------------------------------------------------------
CREATE TABLE venta (
  id_venta    INT UNSIGNED NOT NULL AUTO_INCREMENT,
  fecha_venta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_cliente INT UNSIGNED NOT NULL,
  id_usuario INT UNSIGNED NOT NULL,
  total       DECIMAL(12,2) NOT NULL DEFAULT 0,
  estado      ENUM('registrada','anulada') NOT NULL DEFAULT 'registrada',
  PRIMARY KEY (id_venta),
  KEY idx_venta_cliente (id_cliente),
  KEY idx_venta_usuario (id_usuario),
  KEY idx_venta_fecha (fecha_venta),
  CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_venta_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE detalle_venta_producto (
  id_venta        INT UNSIGNED NOT NULL,
  id_producto     INT UNSIGNED NOT NULL,
  cantidad        INT UNSIGNED NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_venta, id_producto),
  KEY idx_dvp_producto (id_producto),
  CONSTRAINT fk_dvp_venta FOREIGN KEY (id_venta)
    REFERENCES venta (id_venta)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_dvp_producto FOREIGN KEY (id_producto)
    REFERENCES producto (id_producto)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_dvp_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB;

CREATE TABLE detalle_venta_ejemplar (
  id_venta     INT UNSIGNED NOT NULL,
  id_ejemplar INT UNSIGNED NOT NULL,
  precio_venta DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_venta, id_ejemplar),
  UNIQUE KEY uq_dve_ejemplar (id_ejemplar),
  CONSTRAINT fk_dve_venta FOREIGN KEY (id_venta)

     REFERENCES venta (id_venta)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_dve_ejemplar FOREIGN KEY (id_ejemplar)
    REFERENCES ejemplar (id_ejemplar)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE factura (
  id_factura     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_venta       INT UNSIGNED NOT NULL,
  numero         VARCHAR(20) NOT NULL,
  fecha_emision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_factura),
  UNIQUE KEY uq_factura_venta (id_venta),
  UNIQUE KEY uq_factura_numero (numero),
  CONSTRAINT fk_factura_venta FOREIGN KEY (id_venta)
    REFERENCES venta (id_venta)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. Trazabilidad de inventario
-- ---------------------------------------------------------------------
CREATE TABLE movimiento_inventario (
  id_movimiento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_producto    INT UNSIGNED NOT NULL,
  id_usuario     INT UNSIGNED NOT NULL,
  tipo           ENUM('entrada','salida','ajuste') NOT NULL,
  cantidad       INT NOT NULL,
  fecha          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacion    VARCHAR(150) NULL,
  PRIMARY KEY (id_movimiento),
  KEY idx_mov_producto (id_producto),
  KEY idx_mov_usuario (id_usuario),
  CONSTRAINT fk_mov_producto FOREIGN KEY (id_producto)
    REFERENCES producto (id_producto)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_mov_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. Datos de ejemplo (ficticios, solo para probar el modelo)
-- ---------------------------------------------------------------------
INSERT INTO linea_producto (nombre) VALUES
  ('Ejemplares'), ('Rejones'), ('Instalaciones'), ('Frota de Oro');

INSERT INTO categoria_ejemplar (nombre, descripcion) VALUES
  ('Crestón', 'Ave de la categoria crestones'),
  ('En cuido', 'Ave en proceso de cuido'),
  ('De pelea', 'Ave de la categoria de pelea');

INSERT INTO producto (id_linea, nombre, medida, precio_unitario, stock_actual, stock_minimo) VALUES
  (2, 'Rejón',         'Medida 1',        20000, 30, 10),
  (2, 'Rejón',         'Medida 2',        25000, 25, 10),
  (3, 'Jaula',         '60x60',          120000, 6, 2),
  (3, 'Jaula',         '90x120',         220000, 3, 1),
  (3, 'Torre',         '4 puestos',      450000, 2, 1),
  (4, 'Frota de Oro', NULL,               35000, 40, 15);

INSERT INTO ejemplar (codigo, id_categoria, fecha_nacimiento, sexo, precio) VALUES
  ('EJ-0001', 1, '2026-03-10', 'macho', 150000),
  ('EJ-0002', 2, '2026-01-15', 'macho', 300000),
  ('EJ-0003', 3, '2025-11-20', 'macho', 600000);

INSERT INTO cliente (nombre, documento, telefono, ciudad, tipo_cliente) VALUES
  ('Cliente de ejemplo 1', '1000000001', '3000000001', 'Medellín', 'criador'),
  ('Cliente de ejemplo 2', '1000000002', '3000000002', 'Bello',    'distribuidor');

INSERT INTO usuario (nombre, nombre_usuario, clave_hash, rol) VALUES
  ('Propietario de ejemplo', 'propietario', 'HASH_DE_EJEMPLO', 'propietario');

-- Venta de ejemplo: 2 rejones + 1 Frota de Oro + 1 ejemplar
INSERT INTO venta (id_cliente, id_usuario, total) VALUES (1, 1, 225000);
INSERT INTO detalle_venta_producto VALUES (1, 1, 2, 20000), (1, 6, 1, 35000);
INSERT INTO detalle_venta_ejemplar VALUES (1, 1, 150000);

 UPDATE ejemplar SET estado = 'vendido' WHERE id_ejemplar = 1;
INSERT INTO factura (id_venta, numero) VALUES (1, 'FAC-0001');

-- ---------------------------------------------------------------------
-- 8. Consultas de verificacion
-- ---------------------------------------------------------------------
-- Productos con stock por debajo del minimo (alerta RF-009)
SELECT p.nombre, p.medida, p.stock_actual, p.stock_minimo
FROM producto p
WHERE p.stock_actual <= p.stock_minimo;

-- Ejemplares disponibles por categoria (RF-002)
SELECT c.nombre AS categoria, COUNT(*) AS disponibles
FROM ejemplar e
JOIN categoria_ejemplar c ON c.id_categoria = e.id_categoria
WHERE e.estado = 'disponible'
GROUP BY c.nombre;

-- Ventas con cliente y vendedor (RF-008)
SELECT v.id_venta, v.fecha_venta, c.nombre AS cliente, u.nombre AS vendedor, v.total
FROM venta v
JOIN cliente c ON c.id_cliente = v.id_cliente
JOIN usuario u ON u.id_usuario = v.id_usuario;
