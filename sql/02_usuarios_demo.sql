-- Usuarios de prueba para iniciar sesión (ejecutar DESPUÉS de grano_de_oro.sql).
-- Las claves se guardan cifradas con PBKDF2 (clase ClaveUtil), nunca en texto plano.
--   propietario / Admin2026*      vendedor1 / Ventas2026*
USE grano_de_oro;
UPDATE usuario SET clave_hash = 'pbkdf2$120000$h4O19c87bJnn3t7YaONNWg==$mVqdFAlahXHHUOm0xf6kzk4eJX8aTK0Tml73lmDgJfM=', nombre = 'Propietario Grano de Oro'
 WHERE nombre_usuario = 'propietario';
INSERT INTO usuario (nombre, nombre_usuario, clave_hash, rol)
VALUES ('Vendedor de mostrador', 'vendedor1', 'pbkdf2$120000$D4JtRLrjrsxfEPIwXrHQOA==$D5SIJLgsZCFrtgeh/13fbBGv0NjNVxSyC7ZFGJviwsE=', 'vendedor');

-- Usuario de la aplicación (solo permisos sobre grano_de_oro) - cambie la clave en producción
CREATE USER IF NOT EXISTS 'grano_app'@'localhost' IDENTIFIED BY 'GranoApp2026';
GRANT SELECT, INSERT, UPDATE, DELETE ON grano_de_oro.* TO 'grano_app'@'localhost';
