# ⚡ CHEATSHEET - QUICK REFERENCE (30 Enero 2026)

**Estado:** ✅ IMPLEMENTACIÓN COMPLETADA  
**Base de Datos:** MySQL 5.5.27 (cdk_tkt_dev)  
**Último Update:** 30 de Enero, 2026

---

## 🚀 COMIENZA AQUÍ

### Para Desarrolladores
```bash
# 1. Leer documento clave
📖 GUIA_RAPIDA_IMPLEMENTACION.md

# 2. Ver script ejecutado
📋 FK_TRIGGERS_AUDIT_FIX.sql

# 3. Ejecutar tests
python integration_tests.py

# 4. Verificar cambios
SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'cdk_tkt_dev' AND REFERENCED_TABLE_NAME IS NOT NULL;
-- Debe retornar: 27
```

### Para DBA
```bash
# 1. Validar implementación
📖 VALIDACION_FINAL.md

# 2. Verificar FKs
SELECT * FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'cdk_tkt_dev' 
ORDER BY TABLE_NAME;

# 3. Verificar Triggers
SELECT * FROM INFORMATION_SCHEMA.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'cdk_tkt_dev';

# 4. Monitorear auditoría
SELECT * FROM audit_log ORDER BY fecha_cambio DESC;
```

---

## 📚 DOCUMENTACIÓN CLAVE

| Documento | Propósito | Para Quién |
|-----------|-----------|-----------|
| [GUIA_RAPIDA_IMPLEMENTACION.md](GUIA_RAPIDA_IMPLEMENTACION.md) | Cómo usar nuevas tablas | Devs |
| [VALIDACION_FINAL.md](VALIDACION_FINAL.md) | Checklist completo | Todos |
| [IMPLEMENTACION_COMPLETADA.md](IMPLEMENTACION_COMPLETADA.md) | Detalles técnicos | Todos |
| [FK_TRIGGERS_AUDIT_FIX.sql](FK_TRIGGERS_AUDIT_FIX.sql) | Script SQL ejecutado | DBA |
| [INDEX_MAESTRO_ACTUALIZADO.md](INDEX_MAESTRO_ACTUALIZADO.md) | Índice completo | Todos |

---

## 🗂️ TABLAS NUEVAS

### audit_log
```sql
-- Insertar cambio
INSERT INTO audit_log (tabla, operacion, registro_id, datos_nuevos, usuario_id)
VALUES ('tkt', 'INSERT', 1, 'ticket creado', 100);

-- Consultar cambios
SELECT * FROM audit_log WHERE tabla = 'tkt' ORDER BY fecha_cambio DESC LIMIT 10;

-- Auditoría de ticket
SELECT * FROM audit_log WHERE tabla = 'tkt' AND registro_id = ? 
ORDER BY fecha_cambio DESC;
```

### sesiones
```sql
-- Crear sesión al login
INSERT INTO sesiones (id_usuario, token_refresh, fecha_inicio, fecha_expiracion, ip_address)
VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 24 HOUR), ?);

-- Obtener sesión activa
SELECT * FROM sesiones WHERE id_usuario = ? AND activa = TRUE;

-- Revocar sesión (logout)
UPDATE sesiones SET activa = FALSE WHERE id = ?;
```

### failed_login_attempts
```sql
-- Registrar intento fallido
INSERT INTO failed_login_attempts (email, ip_address, intento_numero, fecha_intento)
VALUES (?, ?, ?, NOW());

-- Contar intentos recientes (últimos 15 min)
SELECT COUNT(*) as intentos FROM failed_login_attempts
WHERE email = ? AND fecha_intento > DATE_SUB(NOW(), INTERVAL 15 MINUTE);

-- Bloquear IP después de 5 intentos
UPDATE failed_login_attempts SET bloqueado = TRUE, fecha_desbloqueado = NULL
WHERE email = ? AND intento_numero >= 5;
```

### tkt_transicion_auditoria
```sql
-- Historial completo de un ticket
SELECT * FROM tkt_transicion_auditoria WHERE id_tkt = ? 
ORDER BY fecha_transicion DESC;

-- Tickets cambiados hoy
SELECT DISTINCT id_tkt FROM tkt_transicion_auditoria 
WHERE DATE(fecha_transicion) = CURDATE();

-- Duración promedio por estado
SELECT estado_nuevo, AVG(TIMESTAMPDIFF(HOUR, fecha_transicion, NOW())) as promedio
FROM tkt_transicion_auditoria GROUP BY estado_nuevo;
```

---

## 🔗 FOREIGN KEYS - QUICK REFERENCE

### tkt (5 FKs)
```
✅ fk_tkt_usuario_creador      → usuario.idUsuario
✅ fk_tkt_usuario_asignado     → usuario.idUsuario
✅ fk_tkt_empresa              → empresa.idEmpresa
✅ fk_tkt_sucursal             → sucursal.idSucursal
✅ fk_tkt_perfil               → perfil.idPerfil
```

### tkt_comentario (2 FKs)
```
✅ fk_comentario_tkt           → tkt.Id_Tkt (CASCADE)
✅ fk_comentario_usuario       → usuario.idUsuario (SET NULL)
```

### tkt_transicion (4 FKs)
```
✅ fk_transicion_tkt           → tkt.Id_Tkt (CASCADE)
✅ fk_transicion_estado_prev   → estado.Id_Estado
✅ fk_transicion_estado_nuevo  → estado.Id_Estado
✅ fk_transicion_usuario       → usuario.idUsuario (SET NULL)
```

### tkt_aprobacion (3 FKs)
```
✅ fk_aprobacion_tkt           → tkt.Id_Tkt (CASCADE)
✅ fk_aprobacion_solicitante   → usuario.idUsuario (SET NULL)
✅ fk_aprobacion_aprobador     → usuario.idUsuario (SET NULL)
```

### tkt_suscriptor (2 FKs)
```
✅ fk_suscriptor_tkt           → tkt.Id_Tkt (CASCADE)
✅ fk_suscriptor_usuario       → usuario.idUsuario (CASCADE)
```

### usuario_rol (2 FKs)
```
✅ fk_usuario_rol_usuario      → usuario.idUsuario (CASCADE)
✅ fk_usuario_rol_rol          → rol.idRol (CASCADE)
```

### rol_permiso (2 FKs)
```
✅ fk_rol_permiso_rol          → rol.idRol (CASCADE)
✅ fk_rol_permiso_permiso      → permiso.idPermiso (CASCADE)
```

---

## 🧬 TRIGGERS - QUICK REFERENCE

### audit_tkt_insert
```
Evento: AFTER INSERT ON tkt
Acción: Inserta registro en audit_log
Registra: operación INSERT, Id_Tkt, usuario_id, datos_nuevos
```

### audit_tkt_update
```
Evento: AFTER UPDATE ON tkt
Acción: Inserta registro en audit_log
Registra: operación UPDATE, cambios antes/después, usuario_id
```

### audit_transicion_estado
```
Evento: AFTER INSERT ON tkt_transicion
Acción: Inserta registro en tkt_transicion_auditoria
Registra: estado_anterior, estado_nuevo, usuario_id
```

### audit_comentario_insert
```
Evento: AFTER INSERT ON tkt_comentario
Acción: Inserta registro en audit_log
Registra: operación INSERT, id_comentario, usuario_id
```

---

## 💻 CÓDIGO C# - CAMBIOS NECESARIOS

### 1. Manejo de Excepciones
```csharp
try 
{
    // Tu código BD
}
catch (MySqlException ex) when (ex.Number == 1452)
{
    // Foreign key constraint - referencia no existe
    return BadRequest("Referencia inválida");
}
catch (MySqlException ex) when (ex.Number == 1451)
{
    // Child row exists - hay dependencias
    return BadRequest("Tiene dependencias");
}
```

### 2. Eliminar Redundancias
```csharp
// ❌ VIEJO - NO HAGAS ESTO:
await DeleteRelatedComments(id);
await DeleteRelatedTransitions(id);
await DeleteTicket(id);

// ✅ NUEVO - HAZLO ASÍ:
await DeleteTicket(id);  // El trigger y CASCADE hacen el resto
```

### 3. Usar Sesiones
```csharp
// Al login
var sessionId = await _sessions.CreateAsync(new Sesion 
{
    id_usuario = user.idUsuario,
    token_refresh = token,
    fecha_expiracion = DateTime.Now.AddHours(24),
    ip_address = GetClientIP()
});

// Al logout
await _sessions.RevokeAsync(sessionId);

// En validación
var session = await _sessions.GetActiveAsync(userId);
if (session == null || session.fecha_expiracion < DateTime.Now)
    return Unauthorized();
```

### 4. Registrar Intentos Fallidos
```csharp
// En login fallido
await _failedLogins.CreateAsync(new FailedLoginAttempt 
{
    email = request.Email,
    ip_address = GetClientIP(),
    intento_numero = await _failedLogins.CountRecentAsync(request.Email, 15),
    fecha_intento = DateTime.Now
});

// Si hay 5+ intentos
if (await _failedLogins.CountRecentAsync(request.Email, 15) >= 5)
    return Unauthorized("Demasiados intentos");
```

---

## 🧪 TESTING

### Ejecutar Tests
```bash
python integration_tests.py
```

### Tests Que Deben Pasar
```
✅ POST /Tickets/{id}/Comments (sin FK error)
✅ PATCH /Tickets/{id}/cambiar-estado (sin FK error)
✅ GET /Tickets/{id}/historial (auditoría)
✅ DELETE /Tickets/{id} (cascada)
```

### Verificar Auditoría
```sql
-- Después de crear ticket
INSERT INTO tkt (Id_Tkt, Id_Usuario, ...) VALUES (999, 1, ...);

-- Verificar que se registró
SELECT * FROM audit_log WHERE tabla = 'tkt' AND registro_id = 999;
-- Debe retornar: 1 registro
```

---

## 🆘 TROUBLESHOOTING

### Error: "Foreign key constraint fails (1452)"
```
Causa: ID referenciado no existe
Solución: 
  SELECT * FROM usuario WHERE idUsuario = ?
  Si no existe, validar el ID antes de insertar
```

### Error: "Cannot add or update a child row (1451)"
```
Causa: Intenta eliminar tabla padre con hijos
Solución:
  DELETE FROM hijo WHERE padre_id = ?  -- Primero
  DELETE FROM padre WHERE id = ?        -- Después
  O usar: SET NULL en lugar de eliminar
```

### audit_log crece muy rápido
```
Solución:
  CREATE TABLE audit_log_archive LIKE audit_log;
  INSERT INTO audit_log_archive SELECT * FROM audit_log 
  WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 30 DAY);
  DELETE FROM audit_log 
  WHERE fecha_cambio < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### Sesiones expiradas se acumulan
```
Solución (ejecutar cada hora):
  DELETE FROM sesiones 
  WHERE fecha_expiracion < NOW() OR (activa = FALSE AND fecha_expiracion < DATE_SUB(NOW(), INTERVAL 7 DAY));
```

---

## 📊 QUERIES ÚTILES

### Dashboard de Cambios (últimas 24h)
```sql
SELECT 
    DATE(fecha_cambio) as fecha,
    tabla,
    COUNT(*) as cambios
FROM audit_log
WHERE fecha_cambio > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY fecha, tabla
ORDER BY fecha DESC, cambios DESC;
```

### Quién cambió qué
```sql
SELECT 
    a.fecha_cambio,
    u.Email as usuario,
    a.tabla,
    a.operacion,
    a.datos_nuevos
FROM audit_log a
LEFT JOIN usuario u ON a.usuario_id = u.idUsuario
WHERE a.fecha_cambio > DATE_SUB(NOW(), INTERVAL 1 HOUR)
ORDER BY a.fecha_cambio DESC;
```

### Intentos fallidos de login
```sql
SELECT 
    email,
    ip_address,
    COUNT(*) as intentos,
    MAX(fecha_intento) as última_vez,
    bloqueado
FROM failed_login_attempts
WHERE fecha_intento > DATE_SUB(NOW(), INTERVAL 1 HOUR)
GROUP BY email, ip_address
HAVING intentos >= 3
ORDER BY intentos DESC;
```

### Sesiones activas
```sql
SELECT 
    u.Email,
    s.fecha_inicio,
    s.fecha_expiracion,
    TIMESTAMPDIFF(MINUTE, s.fecha_inicio, NOW()) as minutos_activa,
    s.ip_address
FROM sesiones s
JOIN usuario u ON s.id_usuario = u.idUsuario
WHERE s.activa = TRUE
ORDER BY s.fecha_inicio DESC;
```

---

## ✅ CHECKLIST PRE-DEPLOY

### Antes de Deploy a Staging
```
[ ] Leer VALIDACION_FINAL.md
[ ] Verificar 27 FKs activos: SELECT COUNT(*) ...
[ ] Verificar 4 triggers: SELECT COUNT(*) ...
[ ] Ejecutar tests: python integration_tests.py
[ ] Code review de cambios C#
[ ] Backup automático configurado
[ ] Alertas configuradas para audit_log
```

### Antes de Deploy a Producción
```
[ ] Backup completo de base de datos
[ ] Verificar staging 24h sin errores
[ ] Tests de seguridad completados
[ ] Sesiones expiradas limpias
[ ] Tabla failed_login_attempts actualizada
[ ] Documentación de rollback preparada
[ ] Team notificado
```

---

## 🚀 GO-LIVE CHECKLIST

```
[ ] 1. Database backup completado
[ ] 2. Script FK_TRIGGERS_AUDIT_FIX.sql ejecutado (YA HECHO ✅)
[ ] 3. 27 FKs verificados
[ ] 4. 4 Triggers verificados
[ ] 5. Código C# actualizado
[ ] 6. Tests pasando
[ ] 7. Auditoría funcionando
[ ] 8. Sesiones funcionando
[ ] 9. Rate limiting funcionando
[ ] 10. Monitoreo 24h activado
```

---

## 📞 REFERENCIAS RÁPIDAS

```
Documentación Completa:  INDEX_MAESTRO_ACTUALIZADO.md
Guía para Devs:          GUIA_RAPIDA_IMPLEMENTACION.md
Validación:              VALIDACION_FINAL.md
Detalles Técnicos:       IMPLEMENTACION_COMPLETADA.md
Script SQL:              FK_TRIGGERS_AUDIT_FIX.sql
Reporte Final:           REPORTE_FINAL_IMPLEMENTACION.md
Resumen Visual:          RESUMEN_VISUAL_FINAL.md
```

---

## 🎯 PRÓXIMOS PASOS

```
HOY:  Leer documentación
MAÑANA: Actualizar código C#
SEMANA: Pasar tests
MES: Deploy a producción
```

---

**Última actualización:** 30 de Enero, 2026  
**Status:** ✅ LISTO  
**Duración implementación:** 1h 50min  
**Base de Datos:** MySQL 5.5.27 - cdk_tkt_dev
