-- ============================================================
-- Script de Optimización de Base de Datos - TicketsAPI
-- Fecha: 27 de enero de 2026
-- Propósito: Crear índices para mejorar performance de queries
-- ============================================================

USE tickets_db;

-- ============================================================
-- TABLA: tkt (tickets)
-- ============================================================

-- Índice compuesto para búsquedas por fecha de creación y estado
-- Optimiza: Filtros en reportes, dashboard, búsquedas por rango de fechas
CREATE INDEX IF NOT EXISTS idx_tkt_date_creado_estado 
ON tkt(Date_Creado DESC, Id_Estado) 
COMMENT 'Optimiza búsquedas por fecha y estado';

-- Índice para tickets cerrados (reportes de resolución)
-- Optimiza: Cálculo de tiempo promedio de resolución, reportes de cierre
CREATE INDEX IF NOT EXISTS idx_tkt_date_cierre 
ON tkt(Date_Cierre DESC) 
COMMENT 'Optimiza consultas de tickets cerrados';

-- Índice para búsquedas por estado
-- Optimiza: Filtros por estado, conteo de tickets por estado
CREATE INDEX IF NOT EXISTS idx_tkt_estado 
ON tkt(Id_Estado) 
COMMENT 'Optimiza filtros por estado';

-- Índice para búsquedas por prioridad
-- Optimiza: Filtros por prioridad, reportes por prioridad
CREATE INDEX IF NOT EXISTS idx_tkt_prioridad 
ON tkt(Id_Prioridad) 
COMMENT 'Optimiza filtros por prioridad';

-- Índice para búsquedas por departamento
-- Optimiza: Filtros por departamento, reportes departamentales
CREATE INDEX IF NOT EXISTS idx_tkt_departamento 
ON tkt(Id_Departamento) 
COMMENT 'Optimiza filtros por departamento';

-- Índice para búsquedas por usuario creador
-- Optimiza: Listar tickets de un usuario específico
CREATE INDEX IF NOT EXISTS idx_tkt_usuario 
ON tkt(Id_Usuario) 
COMMENT 'Optimiza búsquedas por usuario creador';

-- Índice para búsquedas por usuario asignado
-- Optimiza: Listar tickets asignados a un usuario
CREATE INDEX IF NOT EXISTS idx_tkt_usuario_asignado 
ON tkt(Id_Usuario_Asignado) 
COMMENT 'Optimiza búsquedas por usuario asignado';

-- Índice compuesto para tickets activos ordenados por fecha
-- Optimiza: Listado principal de tickets habilitados
CREATE INDEX IF NOT EXISTS idx_tkt_habilitado_fecha 
ON tkt(Habilitado, Date_Creado DESC) 
COMMENT 'Optimiza listados de tickets activos';

-- Índice FULLTEXT para búsqueda en contenido (MySQL 5.7+)
-- Optimiza: Búsquedas de texto completo en contenido del ticket
-- Nota: Solo funciona en tablas InnoDB con MySQL 5.6+
CREATE FULLTEXT INDEX IF NOT EXISTS idx_tkt_contenido_fulltext 
ON tkt(Contenido) 
COMMENT 'Optimiza búsquedas full-text en contenido';

-- ============================================================
-- TABLA: tkt_comentario (comentarios)
-- ============================================================

-- Índice para obtener comentarios de un ticket
-- Optimiza: Carga de comentarios al ver detalle de ticket
CREATE INDEX IF NOT EXISTS idx_comentario_ticket 
ON tkt_comentario(Id_Tkt, Fecha_Creacion DESC) 
COMMENT 'Optimiza carga de comentarios por ticket';

-- Índice para búsquedas por usuario en comentarios
-- Optimiza: Listar comentarios de un usuario
CREATE INDEX IF NOT EXISTS idx_comentario_usuario 
ON tkt_comentario(Id_Usuario) 
COMMENT 'Optimiza búsquedas por usuario en comentarios';

-- Índice para búsqueda en contenido de comentarios (prefijo)
-- Optimiza: Búsqueda avanzada en comentarios
CREATE INDEX IF NOT EXISTS idx_comentario_contenido 
ON tkt_comentario(Contenido(255)) 
COMMENT 'Optimiza búsqueda de texto en comentarios';

-- Índice FULLTEXT para búsqueda full-text en comentarios
CREATE FULLTEXT INDEX IF NOT EXISTS idx_comentario_contenido_fulltext 
ON tkt_comentario(Contenido) 
COMMENT 'Optimiza búsquedas full-text en comentarios';

-- ============================================================
-- TABLA: estado
-- ============================================================

-- Índice para búsquedas por nombre de estado
CREATE INDEX IF NOT EXISTS idx_estado_nombre 
ON estado(TipoEstado) 
COMMENT 'Optimiza búsquedas por nombre de estado';

-- ============================================================
-- TABLA: prioridad
-- ============================================================

-- Índice para búsquedas por nombre de prioridad
CREATE INDEX IF NOT EXISTS idx_prioridad_nombre 
ON prioridad(NombrePrioridad) 
COMMENT 'Optimiza búsquedas por nombre de prioridad';

-- Índice para ordenamiento por valor de prioridad
CREATE INDEX IF NOT EXISTS idx_prioridad_valor 
ON prioridad(Valor DESC) 
COMMENT 'Optimiza ordenamiento por valor de prioridad';

-- ============================================================
-- TABLA: departamento
-- ============================================================

-- Índice para búsquedas por nombre de departamento
CREATE INDEX IF NOT EXISTS idx_departamento_nombre 
ON departamento(Nombre) 
COMMENT 'Optimiza búsquedas por nombre de departamento';

-- ============================================================
-- TABLA: usuario
-- ============================================================

-- Índice para búsquedas por email (login)
-- Ya existe: email es UNIQUE, tiene índice automático

-- Índice para búsquedas por rol
CREATE INDEX IF NOT EXISTS idx_usuario_rol 
ON usuario(Id_Rol) 
COMMENT 'Optimiza filtros por rol de usuario';

-- Índice para búsquedas por departamento
CREATE INDEX IF NOT EXISTS idx_usuario_departamento 
ON usuario(Id_Departamento) 
COMMENT 'Optimiza filtros por departamento de usuario';

-- Índice compuesto para usuarios activos por departamento
CREATE INDEX IF NOT EXISTS idx_usuario_activo_dpto 
ON usuario(Activo, Id_Departamento) 
COMMENT 'Optimiza listado de usuarios activos por departamento';

-- ============================================================
-- TABLA: tkt_historial
-- ============================================================

-- Índice para obtener historial de un ticket
CREATE INDEX IF NOT EXISTS idx_historial_ticket 
ON tkt_historial(Id_Tkt, Fecha DESC) 
COMMENT 'Optimiza carga de historial por ticket';

-- Índice para búsquedas por usuario en historial
CREATE INDEX IF NOT EXISTS idx_historial_usuario 
ON tkt_historial(Id_Usuario) 
COMMENT 'Optimiza búsquedas de acciones de usuario';

-- ============================================================
-- VERIFICACIÓN DE ÍNDICES CREADOS
-- ============================================================

-- Mostrar todos los índices de la tabla tkt
SHOW INDEXES FROM tkt;

-- Mostrar tamaño de índices
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    ROUND(((INDEX_LENGTH) / 1024 / 1024), 2) AS 'Index Size (MB)',
    ROUND(((DATA_LENGTH) / 1024 / 1024), 2) AS 'Data Size (MB)',
    ROUND(((INDEX_LENGTH + DATA_LENGTH) / 1024 / 1024), 2) AS 'Total Size (MB)'
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'tickets_db'
  AND TABLE_NAME IN ('tkt', 'tkt_comentario', 'estado', 'prioridad', 'departamento', 'usuario', 'tkt_historial')
ORDER BY (INDEX_LENGTH + DATA_LENGTH) DESC;

-- ============================================================
-- ANÁLISIS DE QUERIES LENTAS (Opcional - Requiere permisos)
-- ============================================================

-- Habilitar slow query log (ejecutar como root/admin)
-- SET GLOBAL slow_query_log = 'ON';
-- SET GLOBAL long_query_time = 1; -- Queries mayores a 1 segundo

-- Ver queries lentas más frecuentes (requiere sys schema)
-- SELECT * FROM sys.statements_with_runtimes_in_95th_percentile LIMIT 10;

-- ============================================================
-- MANTENIMIENTO DE ÍNDICES
-- ============================================================

-- Analizar tablas después de crear índices (actualiza estadísticas)
ANALYZE TABLE tkt;
ANALYZE TABLE tkt_comentario;
ANALYZE TABLE estado;
ANALYZE TABLE prioridad;
ANALYZE TABLE departamento;
ANALYZE TABLE usuario;
ANALYZE TABLE tkt_historial;

-- ============================================================
-- NOTAS DE IMPLEMENTACIÓN
-- ============================================================

/*
NOTAS IMPORTANTES:

1. FULLTEXT INDEXES:
   - Solo funcionan en MySQL 5.6+ con InnoDB
   - Si la versión es menor, comentar las líneas:
     * idx_tkt_contenido_fulltext
     * idx_comentario_contenido_fulltext

2. IMPACTO EN PERFORMANCE:
   - Los índices mejoran SELECT pero ralentizan INSERT/UPDATE
   - En tablas con muchos writes, considerar solo índices críticos

3. TAMAÑO DE BD:
   - Cada índice ocupa espacio adicional en disco
   - Monitorear crecimiento con query de verificación

4. MANTENIMIENTO:
   - Ejecutar ANALYZE TABLE periódicamente (mensual)
   - Monitorear queries lentas con slow query log

5. ÍNDICES REDUNDANTES:
   - MySQL puede usar índices compuestos para búsquedas simples
   - idx_tkt_date_creado_estado puede usarse para búsquedas solo por Date_Creado

6. PRUEBAS:
   - Antes: Ejecutar EXPLAIN en queries críticas
   - Después: Volver a ejecutar EXPLAIN y comparar
   - Verificar uso de índices con "Using index" en Extra column

EJEMPLO DE ANÁLISIS:
EXPLAIN SELECT * FROM tkt WHERE Id_Estado = 1 ORDER BY Date_Creado DESC LIMIT 20;
-- Debe mostrar "Using index" o "Using where; Using index"
*/

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
