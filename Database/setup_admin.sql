INSERT IGNORE INTO rol (nombre) VALUES ('Administrador');

INSERT INTO usuario (nombre, email, passwordUsuario, fechaAlta, tipo, idRol) 
VALUES ('admin', 'admin@system.com', 'admin123', CURDATE(), 'ADM', 1)
ON DUPLICATE KEY UPDATE email='admin@system.com';

SELECT idUsuario, nombre, email, idRol FROM usuario WHERE nombre = 'admin';
