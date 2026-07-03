-- Prueba funcional de la transicion En Proceso(2) -> Resuelto(6)
SET @actor := 1; -- Admin

INSERT INTO tkt (Id_Estado, Id_Usuario, Id_Usuario_Asignado, Contenido, Date_Creado, Habilitado)
VALUES (1, 1, 1, 'TEST transicion 2->6 (borrar)', NOW(), 1);
SET @tid := LAST_INSERT_ID();
SELECT @tid AS ticket_creado;

-- 1 -> 2 (En Proceso) asignando al admin
CALL sp_tkt_transicionar(@tid, 2, @actor, 'Inicio trabajo', NULL, @actor, NULL, 0);

-- 2 -> 6 (Resuelto) DIRECTO (antes bloqueado)
CALL sp_tkt_transicionar(@tid, 6, @actor, 'Resuelto directo sin aprobacion', NULL, NULL, NULL, 0);

SELECT Id_Tkt, Id_Estado AS estado_final FROM tkt WHERE Id_Tkt = @tid;

-- Limpieza
SET FOREIGN_KEY_CHECKS=0;
DELETE FROM tkt_transicion WHERE id_tkt = @tid;
DELETE FROM tkt_notificacion_lectura WHERE id_ticket = @tid;
DELETE FROM tkt_comentario WHERE id_tkt = @tid;
DELETE FROM tkt_aprobacion WHERE id_tkt = @tid;
DELETE FROM audit_log WHERE tabla IN ('tkt','tkt_transicion','tkt_comentario') AND id_registro = @tid;
DELETE FROM tkt WHERE Id_Tkt = @tid;
SET FOREIGN_KEY_CHECKS=1;
SELECT 'cleanup OK' AS status, (SELECT COUNT(*) FROM tkt WHERE Id_Tkt=@tid) AS tickets_restantes;
