# 🚀 GUÍA RÁPIDA - IMPLEMENTACIÓN DB COMPLETADA

**Fecha:** 30 de Enero, 2026  
**Base de Datos:** cdk_tkt_dev  
**Estado:** ✅ LISTO PARA DESARROLLO

---

## ⚡ CAMBIOS PRINCIPALES (RESUMEN EJECUTIVO)

### Base de Datos
```
✅ 4 nuevas tablas de auditoría
✅ 18 nuevas Foreign Keys (27 total)
✅ 4 nuevos Triggers automáticos
✅ 5 conversiones de tipo INT → BIGINT
```

### Comportamiento Nuevo

| Acción | Ahora | Antes |
|--------|-------|-------|
| Eliminar ticket | Elimina automáticamente comentarios, transiciones, aprobaciones, suscriptores | Requería código manual |
| Insertar ticket | Se registra automáticamente en audit_log | Sin auditoría |
| Cambiar estado | Se registra en tkt_transicion_auditoria | Solo en tkt_transicion |
| Crear comentario | Se registra automáticamente en audit_log | Sin auditoría |

---

## 🔧 TABLAS NUEVAS

### 1. audit_log
**Propósito:** Auditoría centralizada  
**Qué registra:** INSERT/UPDATE en tkt, tkt_comentario, cambios de estado

```sql
-- Consultar cambios recientes
SELECT * FROM audit_log ORDER BY fecha_cambio DESC LIMIT 10;

-- Cambios de un usuario
SELECT * FROM audit_log WHERE usuario_id = ? ORDER BY fecha_cambio DESC;

-- Auditoría de un ticket
SELECT * FROM audit_log WHERE tabla = 'tkt' AND registro_id = ? ORDER BY fecha_cambio DESC;
```

---

### 2. sesiones
**Propósito:** Gestión de sesiones de usuario  
**Qué guarda:** token_refresh, IP, user_agent, fecha_expiracion

```sql
-- Sesiones activas de un usuario
SELECT * FROM sesiones WHERE id_usuario = ? AND activa = TRUE;

-- Revocar sesión (logout)
UPDATE sesiones SET activa = FALSE WHERE id = ?;

-- Limpiar sesiones expiradas
DELETE FROM sesiones WHERE fecha_expiracion < NOW() AND activa = FALSE;
```

---

### 3. failed_login_attempts
**Propósito:** Prevención de fuerza bruta  
**Qué registra:** Intentos fallidos por email/IP

```sql
-- Intentos fallidos recientes
SELECT * FROM failed_login_attempts 
WHERE fecha_intento > DATE_SUB(NOW(), INTERVAL 15 MINUTE)
ORDER BY fecha_intento DESC;

-- Bloquear IP después de 5 intentos
UPDATE failed_login_attempts 
SET bloqueado = TRUE 
WHERE email = ? AND intento_numero >= 5;

-- Desbloquear después de 1 hora
UPDATE failed_login_attempts 
SET bloqueado = FALSE, fecha_desbloqueado = NOW() 
WHERE email = ? AND fecha_intento < DATE_SUB(NOW(), INTERVAL 1 HOUR);
```

---

### 4. tkt_transicion_auditoria
**Propósito:** Historial completo de cambios de estado  
**Qué registra:** estado_anterior → estado_nuevo, usuario, fecha

```sql
-- Historial de un ticket
SELECT * FROM tkt_transicion_auditoria 
WHERE id_tkt = ? 
ORDER BY fecha_transicion DESC;

-- Tickets que cambiaron de estado hoy
SELECT DISTINCT id_tkt FROM tkt_transicion_auditoria 
WHERE DATE(fecha_transicion) = CURDATE();

-- Estados más frecuentes
SELECT estado_nuevo, COUNT(*) as cantidad 
FROM tkt_transicion_auditoria 
GROUP BY estado_nuevo 
ORDER BY cantidad DESC;
```

---

## 🔗 FOREIGN KEYS NUEVAS

### Integridad Garantizada
```sql
-- Esto ahora FALLA (no existe usuario con ID 999999)
INSERT INTO tkt (Id_Tkt, Id_Usuario, Id_Empresa, ...) 
VALUES (1, 999999, 1, ...); 
-- Error: Foreign key constraint fails

-- Esto ahora FALLA (no existe estado con ID 999)
INSERT INTO tkt_transicion (id_tkt, estado_from, estado_to, ...) 
VALUES (1, 1, 999, ...); 
-- Error: Foreign key constraint fails
```

### Eliminación en Cascada (Automática)
```sql
-- ANTES: Necesitaba hacer esto manualmente
DELETE FROM tkt_comentario WHERE id_tkt = 1;
DELETE FROM tkt_transicion WHERE id_tkt = 1;
DELETE FROM tkt_aprobacion WHERE id_tkt = 1;
DELETE FROM tkt_suscriptor WHERE id_tkt = 1;
DELETE FROM tkt WHERE Id_Tkt = 1;

-- AHORA: Solo necesita esto (el resto es automático)
DELETE FROM tkt WHERE Id_Tkt = 1;
-- ✅ Automáticamente elimina comentarios, transiciones, aprobaciones, suscriptores
```

---

## 💻 CÓDIGO C# - CAMBIOS NECESARIOS

### 1. Manejo de Excepciones FK
```csharp
try
{
    // Tu operación de base de datos
}
catch (MySqlException ex) when (ex.Number == 1452)
{
    // Foreign key constraint violation - entidad referenciada no existe
    return BadRequest("El usuario/empresa/perfil especificado no existe");
}
catch (MySqlException ex) when (ex.Number == 1451)
{
    // Child row exists - no se puede eliminar
    return BadRequest("No se puede eliminar. Hay registros dependientes");
}
```

### 2. Eliminación de Código Redundante
```csharp
// ANTES (código a REMOVER):
public async Task DeleteTicket(long ticketId)
{
    // Eliminar manualmente dependencias
    await _commentRepository.DeleteByTicket(ticketId);
    await _transitionRepository.DeleteByTicket(ticketId);
    await _approvalRepository.DeleteByTicket(ticketId);
    await _subscriberRepository.DeleteByTicket(ticketId);
    
    // Finalmente eliminar ticket
    await _ticketRepository.Delete(ticketId);
}

// AHORA (código NUEVO - simplificado):
public async Task DeleteTicket(long ticketId)
{
    // El trigger y CASCADE DELETE manejan todo automáticamente
    await _ticketRepository.Delete(ticketId);
}
```

### 3. Usar Sesiones para Auth
```csharp
// En el login, crear sesión
var sessionId = await _sessionRepository.Create(new Sesion
{
    id_usuario = user.idUsuario,
    token_refresh = refreshToken,
    fecha_inicio = DateTime.Now,
    fecha_expiracion = DateTime.Now.AddHours(24),
    ip_address = GetClientIP(),
    user_agent = Request.Headers["User-Agent"]
});

// En validación, verificar sesión activa
var session = await _sessionRepository.GetActive(userId);
if (session == null || session.fecha_expiracion < DateTime.Now)
{
    return Unauthorized("Sesión expirada o no existe");
}

// En logout, revocar sesión
await _sessionRepository.Revoke(sessionId);
```

### 4. Registrar Intentos Fallidos
```csharp
public async Task<IActionResult> Login(LoginRequest request)
{
    var user = await _userRepository.GetByEmail(request.Email);
    
    if (user == null || !VerifyPassword(request.Password, user.Contraseña))
    {
        // Registrar intento fallido
        await _failedLoginRepository.Create(new FailedLoginAttempt
        {
            email = request.Email,
            ip_address = GetClientIP(),
            intento_numero = await _failedLoginRepository.CountRecent(request.Email, 15),
            fecha_intento = DateTime.Now
        });
        
        // Bloquear después de 5 intentos
        if (await _failedLoginRepository.CountRecent(request.Email, 15) >= 5)
        {
            await _failedLoginRepository.Block(request.Email);
            return Unauthorized("Demasiados intentos. Intente más tarde.");
        }
        
        return Unauthorized("Credenciales inválidas");
    }
    
    // Limpiar intentos fallidos
    await _failedLoginRepository.ClearRecent(request.Email);
    
    return Ok(new { token });
}
```

---

## 📊 CONSULTAS ÚTILES PARA REPORTES

### 1. Auditoría de Cambios
```sql
-- Quién cambió qué y cuándo (últimas 24 horas)
SELECT 
    a.fecha_cambio,
    u.Email as usuario,
    a.tabla,
    a.operacion,
    a.datos_nuevos
FROM audit_log a
JOIN usuario u ON a.usuario_id = u.idUsuario
WHERE a.fecha_cambio > DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY a.fecha_cambio DESC;
```

### 2. Historial de Ticket
```sql
-- Vida completa de un ticket
SELECT 
    DATE_FORMAT(a.fecha_cambio, '%Y-%m-%d %H:%i:%s') as fecha,
    u.Email as usuario,
    a.operacion,
    a.datos_nuevos as cambio
FROM audit_log a
LEFT JOIN usuario u ON a.usuario_id = u.idUsuario
WHERE a.tabla = 'tkt' AND a.registro_id = ?
ORDER BY a.fecha_cambio ASC;
```

### 3. Transiciones de Estado
```sql
-- Cuánto tiempo lleva resolver tickets por estado
SELECT 
    e.TipoEstado as estado_actual,
    COUNT(*) as cantidad,
    AVG(TIMESTAMPDIFF(HOUR, a.fecha_transicion, NOW())) as horas_promedio
FROM tkt_transicion_auditoria a
JOIN estado e ON a.estado_nuevo = e.Id_Estado
WHERE a.estado_nuevo IN (6, 7)  -- Estados finales (resuelto/cerrado)
GROUP BY e.TipoEstado
ORDER BY cantidad DESC;
```

### 4. Actividad Reciente
```sql
-- Dashboard: cambios en últimas 2 horas
SELECT 
    a.tabla,
    COUNT(*) as cambios,
    MAX(a.fecha_cambio) as último_cambio
FROM audit_log a
WHERE a.fecha_cambio > DATE_SUB(NOW(), INTERVAL 2 HOUR)
GROUP BY a.tabla
ORDER BY cambios DESC;
```

---

## ✅ CHECKLIST PARA DESARROLLADORES

### Al Actualizar Código
- [ ] Remover código de eliminación manual de comentarios/transiciones
- [ ] Agregar try-catch para MySqlException (errno 1452, 1451)
- [ ] No hacer UPDATE directo en tablas auditadas (los triggers lo hacen)
- [ ] Usar sesiones para validar tokens activos
- [ ] Registrar intentos fallidos de login

### Al Hacer Deploy
- [ ] Verificar que cdk_tkt_dev tiene todas las FKs (27 total)
- [ ] Verificar que hay 4+ triggers activos
- [ ] Probar eliminación de ticket (debe eliminar dependencias)
- [ ] Probar creación de ticket (debe registrarse en audit_log)
- [ ] Ejecutar pruebas de integración: `python integration_tests.py`

### En Monitoreo
- [ ] Revisar audit_log diariamente para cambios sospechosos
- [ ] Limpiar sesiones expiradas (programar tarea cron)
- [ ] Monitorear failed_login_attempts para patrones de ataque
- [ ] Verificar que tkt_transicion_auditoria tiene registros nuevos

---

## 🆘 TROUBLESHOOTING

### Error: Foreign key constraint fails
```
Solución: El ID que intenta referenciar no existe en la tabla destino
Ejemplo: INSERT INTO tkt (..., Id_Usuario = 999, ...)
         → Verificar que usuario con ID 999 existe
```

### Error: Cannot add or update a child row
```
Solución: Intenta eliminar un registro que tiene dependencias
Ejemplo: DELETE FROM usuario WHERE idUsuario = 5
         → Hay tickets, comentarios, etc. que usan ese usuario
         → Considere SET NULL en lugar de eliminar
```

### Tickets desaparecen al eliminar usuario
```
Solución: Las FKs de usuario tienen ON DELETE SET NULL
Comportamiento: Los tickets quedan huérfanos (sin usuario asignado)
Esto es CORRECTO - evita perder datos de tickets
```

### Audit_log crece muy rápido
```
Solución: Hay muchos cambios siendo registrados
Acción: Crear tabla de archivo para logs antiguos
        ALTER TABLE audit_log ADD PARTITION ...
```

---

## 📱 CONTACTO / PREGUNTAS

Si tienes dudas sobre:
- **Estructura de BD:** Ver IMPLEMENTACION_COMPLETADA.md
- **Queries útiles:** Ver FK_TRIGGERS_AUDIT_FIX.sql
- **Manejo en C#:** Ver section "Código C# - Cambios Necesarios"

---

**Versión:** 1.0  
**Última actualización:** 30 de Enero, 2026  
**Base de Datos:** MySQL 5.5.27 - cdk_tkt_dev  
**Estado:** ✅ LISTO
