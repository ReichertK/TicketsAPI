-- ==========================================
-- SCRIPT: Corrección de Registros Huérfanos
-- Base de Datos: cdk_tkt_dev
-- Generado: 30 Enero 2026
-- ==========================================

-- PROBLEMA DETECTADO: 2 tickets con usuario que no existe
-- SOLUCIÓN: Reasignar a usuario válido (ID 1 - Admin)

USE cdk_tkt_dev;

-- ==================== PARTE 1: DIAGNÓSTICO ====================

-- Identificar tickets huérfanos
SELECT 
    t.Id_Tkt,
    t.Id_Usuario AS Usuario_Referenciado,
    t.Contenido,
    t.Date_Creado,
    t.Id_Estado,
    COUNT(DISTINCT tc.id_comentario) as Comentarios,
    COUNT(DISTINCT tt.id_transicion) as Transiciones
FROM tkt t
LEFT JOIN tkt_comentario tc ON t.Id_Tkt = tc.id_tkt
LEFT JOIN tkt_transicion tt ON t.Id_Tkt = tt.id_tkt
LEFT JOIN usuario u ON t.Id_Usuario = u.idUsuario
WHERE t.Id_Usuario IS NOT NULL AND u.idUsuario IS NULL
GROUP BY t.Id_Tkt, t.Id_Usuario, t.Contenido, t.Date_Creado, t.Id_Estado;

-- ==================== PARTE 2: VERIFICAR USUARIOS DISPONIBLES ====================

-- Listar usuarios válidos
SELECT idUsuario, nombre, email FROM usuario ORDER BY idUsuario;

-- ==================== PARTE 3: CORRECCIÓN ====================

-- PASO 1: Reasignar tickets huérfanos a usuario Admin (ID 1)
UPDATE tkt 
SET Id_Usuario = 1
WHERE Id_Usuario IS NOT NULL AND Id_Usuario NOT IN (SELECT idUsuario FROM usuario);

-- PASO 2: Verificar que se reasignaron correctamente
SELECT 
    t.Id_Tkt,
    t.Id_Usuario,
    u.nombre as Usuario_Asignado,
    t.Contenido,
    'CORREGIDO' as Estado
FROM tkt t
JOIN usuario u ON t.Id_Usuario = u.idUsuario
WHERE t.Id_Tkt IN (
    -- Original: estos eran los huérfanos
    SELECT t2.Id_Tkt FROM tkt t2
    WHERE t2.Id_Tkt IN (
        -- Reemplazar con IDs reales si se conocen
        -- Alternativa: buscar por patrones
    )
);

-- PASO 3: Validar integridad completa post-corrección
SELECT 
    'Verificación Final' as Paso,
    COUNT(DISTINCT t.Id_Tkt) as Tickets_Totales,
    COUNT(DISTINCT CASE WHEN u.idUsuario IS NOT NULL THEN t.Id_Tkt END) as Tickets_Con_Usuario_Válido,
    COUNT(DISTINCT CASE WHEN u.idUsuario IS NULL THEN t.Id_Tkt END) as Tickets_Huérfanos
FROM tkt t
LEFT JOIN usuario u ON t.Id_Usuario = u.idUsuario;

-- ==================== PARTE 4: REVALIDAR FKS ====================

-- Buscar cualquier otro huérfano en otras tablas
SELECT 'tkt_comentario' as Tabla_Origen, COUNT(*) as Huérfanos
FROM tkt_comentario tc
LEFT JOIN tkt t ON tc.id_tkt = t.Id_Tkt
WHERE t.Id_Tkt IS NULL

UNION ALL

SELECT 'tkt_comentario' as Tabla_Origen, COUNT(*) as Huérfanos
FROM tkt_comentario tc
LEFT JOIN usuario u ON tc.id_usuario = u.idUsuario
WHERE u.idUsuario IS NULL

UNION ALL

SELECT 'tkt_transicion' as Tabla_Origen, COUNT(*) as Huérfanos
FROM tkt_transicion tt
LEFT JOIN tkt t ON tt.id_tkt = t.Id_Tkt
WHERE t.Id_Tkt IS NULL

UNION ALL

SELECT 'tkt_transicion' as Tabla_Origen, COUNT(*) as Huérfanos
FROM tkt_transicion tt
LEFT JOIN estado e_from ON tt.estado_from = e_from.Id_Estado
WHERE e_from.Id_Estado IS NULL

UNION ALL

SELECT 'tkt_transicion' as Tabla_Origen, COUNT(*) as Huérfanos
FROM tkt_transicion tt
LEFT JOIN estado e_to ON tt.estado_to = e_to.Id_Estado
WHERE e_to.Id_Estado IS NULL;

-- ==================== PARTE 5: REPORTE DE AUDITORÍA ====================

-- Registrar correcciones en audit_log (si se ejecutan los updates)
-- El trigger audit_tkt_update debería registrar estos cambios

-- Verificar entradas en audit_log
SELECT 
    COUNT(*) as Total_Auditoria,
    MAX(Timestamp) as Última_Auditoría
FROM audit_log
WHERE Tabla = 'tkt' AND Acción IN ('INSERT', 'UPDATE');

-- ==================== INSTRUCCIONES ====================

/*
PASOS PARA EJECUTAR:

1. REVISAR DIAGNÓSTICO (arriba):
   - Ejecutar primera SELECT para identificar exactamente cuáles tickets son huérfanos
   - Anotar los IDs

2. OPCIONALMENTE - BACKUP (por seguridad):
   CREATE TABLE tkt_backup_before_correction AS SELECT * FROM tkt;

3. EJECUTAR CORRECCIÓN:
   - Ejecutar UPDATE (PASO 3) después de verificar diagnóstico

4. VERIFICAR RESULTADOS:
   - Ejecutar PASO 2 para confirmar reasignación
   - Ejecutar PARTE 4 para validar no hay otros huérfanos

5. AUDITORÍA:
   - Los triggers registrarán automáticamente los cambios
   - Verificar en audit_log

NOTAS:
- Usuario Admin (ID 1) se ha asignado como propietario por defecto
- Si se prefiere otro usuario, cambiar "SET Id_Usuario = 1" en PASO 1
- Los comentarios y transiciones permanecen intactos
- La corrección se registra en audit_log automáticamente
*/
