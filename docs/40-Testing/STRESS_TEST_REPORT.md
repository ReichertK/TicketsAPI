# Reporte de Stress Test — Concurrencia, Sesión y Carga Masiva

> **Fecha**: Enero 2025  
> **Entorno**: ASP.NET Core 6 + Dapper + MySQL 5.5 · localhost:5000  
> **Base de datos**: `cdk_tkt_dev` · 6 008 tickets (5 000 stress + 1 000 orphan + 8 originales)

---

## Resumen Ejecutivo

| Test | Descripción | Resultado | Severidad |
|------|-------------|-----------|-----------|
| T1 | Concurrencia PUT departamento | ✅ PASS | — |
| T2 | Sesión usuario desactivado | 🔴 **FAIL** | **CRÍTICA** |
| T3 | Datos huérfanos (motivo + 1000 tkts) | ✅ PASS | — |
| T4 | Performance dashboard 6000+ tickets | ✅ PASS | BAJA |
| T5a | Permiso fantasma (ID inexistente) | ⚠️ **WARN** | MEDIA |
| T5b | Rol zombie (nombre reutilizable) | ✅ PASS | — |

**Vulnerabilidades encontradas: 2** (1 Crítica, 1 Media)  
**Cuellos de botella: 1** (Cold-start dashboard)

---

## T1 — Concurrencia: PUT Simultáneo a Departamento

### Escenario
Dos peticiones PUT simultáneas al departamento id=84:
- **Thread A**: nombre → `CONCURRENCY_A`
- **Thread B**: nombre → `CONCURRENCY_B`

### Resultado: ✅ PASS — Sin deadlocks

| Métrica | Thread A | Thread B |
|---------|----------|----------|
| Status HTTP | 200 | 200 |
| Latencia | 1 266 ms | 505 ms |

**Estado final en BD**: `nombre = CONCURRENCY_B` (last-write-wins)

### Análisis
- El SP `sp_departamento_actualizar` es atómico dentro de su transacción implícita.
- MySQL InnoDB maneja el bloqueo de fila sin escalación a deadlock.
- El middleware `ExceptionHandlingMiddleware` está preparado para deadlocks (MySQL errors 1213/1205 → HTTP 503 `TRANSIENT_ERROR`), pero no fue necesario activarlo.
- **Comportamiento**: Last-write-wins sin control optimista de concurrencia (no hay `rowversion`/`timestamp`). Aceptable para operaciones administrativas de baja frecuencia.

### Hallazgo menor
No se genera entrada en `audit_config` para actualizaciones de departamento. La auditoría de cambios administrativos no está integrada en este controlador.

---

## T2 — Sesión: Usuario Desactivado con Token Vigente

### Escenario
1. Operador (id=3) obtiene JWT válido
2. Se verifica acceso normal: `POST /Tickets` → 201 ✅
3. Se desactiva en BD: `UPDATE usuario SET fechaBaja = NOW() WHERE idUsuario = 3`
4. Se reutiliza el mismo JWT

### Resultado: 🔴 **FAIL — VULNERABILIDAD CRÍTICA**

| Endpoint | Método | Status | Esperado |
|-----------|--------|--------|----------|
| `/api/v1/Tickets` | POST | **403** | 401/403 ✅ |
| `/api/v1/Departamentos` | GET | **200** (83 deptos) | 401 ❌ |
| `/api/v1/Tickets` | GET | **200** (listado completo) | 401 ❌ |

### Causa Raíz
**No existe middleware que valide el estado activo del usuario contra la BD.**

El flujo actual es:
```
Request → JWT Middleware (valida firma/expiración)
        → Controller (confía ciegamente en los claims del JWT)
        → Solo endpoints que llaman ValidarPermisoAsync consultan la BD
```

El POST /Tickets devolvió 403 porque `ValidarPermisoAsync` internamente valida contra la BD y encuentra el usuario desactivado. Sin embargo, todos los endpoints de solo lectura (GET) que no llaman a este método pasan sin verificación.

### Impacto
- Un usuario despedido/desactivado conserva **acceso completo de lectura** hasta que expire su JWT (típicamente 24h–7d según configuración).
- Puede ver tickets, departamentos, motivos, grupos, y toda la información del sistema.
- No puede crear/modificar/eliminar datos (protegido por `ValidarPermisoAsync`).

### Solución Recomendada
Crear `UserActiveValidationMiddleware` que en cada request:
1. Extraiga `idUsuario` del JWT
2. Consulte `SELECT fechaBaja FROM usuario WHERE idUsuario = @id`
3. Si `fechaBaja IS NOT NULL` → responda `401 Unauthorized`

```csharp
// Middleware/UserActiveValidationMiddleware.cs
public class UserActiveValidationMiddleware
{
    private readonly RequestDelegate _next;
    
    public UserActiveValidationMiddleware(RequestDelegate next) => _next = next;
    
    public async Task InvokeAsync(HttpContext context, IDbConnection db)
    {
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var userId = context.User.FindFirst("idUsuario")?.Value;
            if (userId != null)
            {
                var fechaBaja = await db.QuerySingleOrDefaultAsync<DateTime?>(
                    "SELECT fechaBaja FROM usuario WHERE idUsuario = @id",
                    new { id = int.Parse(userId) });
                    
                if (fechaBaja.HasValue)
                {
                    context.Response.StatusCode = 401;
                    await context.Response.WriteAsJsonAsync(new { 
                        exitoso = false, 
                        mensaje = "Usuario desactivado" 
                    });
                    return;
                }
            }
        }
        await _next(context);
    }
}
```

**Mitigación alternativa rápida**: Reducir la expiración del JWT a 15–30 minutos + implementar refresh tokens.

---

## T3 — Datos Huérfanos: Eliminar Motivo con 1 000 Tickets

### Escenario
1. Se creó motivo id=61 (`Motivo_Stress_XXXXXXXX`)
2. Se insertaron 1 000 tickets vinculados vía `Id_Motivo = 61`
3. Se ejecutó `DELETE /api/v1/Motivos/61`

### Resultado: ✅ PASS — Soft-delete preserva vínculo histórico

| Verificación | Resultado |
|-------------|-----------|
| DELETE response | 200 — "Motivo desactivado exitosamente" |
| Motivo.Habilitado después del DELETE | 0 (soft-delete) |
| Tickets vinculados siguen en BD | ✅ 1 000 tickets intactos |
| JOIN histórico (tkt ↔ motivo) | ✅ Nombre del motivo visible |
| Motivo aparece en listas activas | ❌ Filtrado por Habilitado=1 |

### Análisis
El sistema usa correctamente **soft-delete** (toggle `Habilitado = 0/1`) para motivos, departamentos y catálogos. Esto:
- Preserva la integridad referencial sin necesidad de CASCADE
- Permite reactivar el motivo después (toggle back)
- Los reportes históricos siguen mostrando el nombre correcto del motivo

---

## T4 — Performance: Dashboard con 6 000+ Tickets

### Escenario
1. Se insertaron 5 000 tickets aleatorios distribuidos en 12 meses
2. Total en BD: 6 008 tickets
3. Benchmark: 5 ejecuciones de `GET /api/v1/Reportes/Dashboard`

### Resultado: ✅ PASS — AVG < 500ms

| Ejecución | Latencia |
|-----------|----------|
| Run 1 (cold) | **566 ms** |
| Run 2 | 123 ms |
| Run 3 | 150 ms |
| Run 4 | 176 ms |
| Run 5 | 182 ms |
| **Promedio** | **239 ms** |
| **Máximo** | **566 ms** |
| **Umbral** | **500 ms** |

### Análisis de Índices
La tabla `tkt` tiene **+20 índices** que cubren los patrones de consulta del dashboard:

| Índice | Columnas |
|--------|----------|
| `IX_tkt_Filtros` | Estado, Prioridad, Departamento, Date_Creado |
| `ix_tkt_estado_hab_fecha` | Estado, Habilitado, Fecha |
| `ix_tkt_usuario_fecha` | Usuario, Fecha |
| `ix_tkt_asignado_estado` | Asignado, Estado |
| `idx_tkt_depto_estado_fecha` | Departamento, Estado, Fecha |
| `idx_tkt_motivo_estado_fecha` | Motivo, Estado, Fecha |
| `idx_tkt_prioridad_estado_fecha` | Prioridad, Estado, Fecha |
| `idx_tkt_contenido_prefix` | Contenido (prefix, texto) |

**No se requiere indexación adicional.** El esquema de índices es exhaustivo.

### Cuello de Botella: Cold Start
La primera ejecución (566 ms) excede el umbral de 500 ms. Esto se debe al calentamiento de:
- Buffer pool de InnoDB
- Connection pool de .NET
- Compilación JIT del endpoint

**Recomendación**: Considerar pre-calentamiento del dashboard en el arranque de la aplicación (health check que ejecute la consulta en `Program.cs` después de `app.Run()`).

---

## T5a — RBAC: Permiso Fantasma (ID Inexistente)

### Escenario
`POST /api/v1/Roles/3/permisos` con body:
```json
{ "PermisoIds": [1, 8, 9, 10, 3, 5, 9999] }
```
(Permiso 9999 no existe en la BD)

### Resultado: ⚠️ WARN — Silent Drop sin feedback

| Métrica | Valor |
|---------|-------|
| Status HTTP | **200** |
| `totalAsignados` | **6** (no 7) |
| Permiso 9999 en BD | **NO insertado** ✅ |

### Análisis
El SP `sp_rol_permiso_gestionar` procesa los IDs via CSV y hace INSERT con JOIN contra la tabla `permiso`. Los IDs inexistentes simplemente no matchean el JOIN y se descartan silenciosamente.

### Impacto
- **Seguridad**: No hay riesgo — los IDs fantasma no se insertan ✅
- **Transparencia**: La API devuelve `200 OK` sin indicar qué IDs fueron inválidos ⚠️
- Un administrador que asigna permisos podría no darse cuenta de que algunos IDs no existen

### Solución Recomendada
Modificar el SP o la lógica del servicio para devolver un campo `idsInvalidos` en la respuesta:

```json
{
  "totalAsignados": 6,
  "idsInvalidos": [9999],
  "mensaje": "Se asignaron 6 de 7 permisos. 1 ID no existe."
}
```

---

## T5b — RBAC: Rol Zombie (Nombre Reutilizable)

### Escenario
1. Se creó rol "RolZombie_Test" → id=13
2. Se eliminó vía `DELETE /api/v1/Roles/13` → 200
3. Se volvió a crear "RolZombie_Test" → id=14, 200

### Resultado: ✅ PASS — Comportamiento correcto

| Verificación | Resultado |
|-------------|-----------|
| Hard delete ejecutado | ✅ Rol 13 eliminado físicamente |
| Nombre liberado para reutilización | ✅ UNIQUE constraint satisfecho |
| FK CASCADE en `rol_permiso` | ✅ Permisos eliminados automáticamente |
| FK CASCADE en `usuario_rol` | ✅ Asignaciones eliminadas automáticamente |
| Nuevo rol con mismo nombre | ✅ id=14 creado sin conflicto |

### Análisis
La tabla `rol` solo tiene `idRol` + `nombre` (sin campo `habilitado`). A diferencia de otras tablas del catálogo, los roles usan **hard-delete**. Esto es coherente con el diseño:
- `rol_permiso` y `usuario_rol` tienen `ON DELETE CASCADE` → limpieza automática
- El SP `sp_rol_eliminar` valida que no sea el rol "Administrador" y que no tenga usuarios activos asignados

**Nota**: Si se intentara eliminar un rol con usuarios asignados, el SP debería bloquear la operación (señal 45000). El CASCADE solo actuaría si el SP permite la eliminación, lo cual es un diseño defensivo correcto.

---

## Resumen de Cuellos de Botella

| # | Área | Descripción | Severidad | Solución |
|---|------|-------------|-----------|----------|
| B1 | Dashboard | Cold-start 566ms > 500ms umbral | BAJA | Pre-calentamiento en startup |
| B2 | Auditoría | Departamentos no genera audit_config en PUT | BAJA | Integrar auditoría en `DepartamentosController` |

---

## Resumen de Vulnerabilidades de Lógica

| # | Tipo | Descripción | Severidad | CVSS Est. |
|---|------|-------------|-----------|-----------|
| V1 | **Sesión** | Usuario desactivado mantiene acceso de lectura con JWT vigente | **CRÍTICA** | 7.5 |
| V2 | **Transparencia** | Permisos fantasma descartados silenciosamente (200 sin advertencia) | **MEDIA** | 3.1 |

### V1 — Parche Recomendado (Prioridad Inmediata)

**Opción A — Middleware de validación activa** (recomendada):
```
Program.cs:
  app.UseAuthentication();
  app.UseAuthorization();
+ app.UseMiddleware<UserActiveValidationMiddleware>(); // NUEVO
```
- Impacto en rendimiento: +1 query ligera por request (~1–2ms)
- Mitigable con cache in-memory de 30s para `fechaBaja`

**Opción B — Token blacklist** (más compleja):
- Requiere Redis/cache distribuida
- Al desactivar usuario, agregar su `jti` a la blacklist
- Mayor complejidad operativa

**Opción C — Reducir TTL del JWT** (mitigación temporal):
- Reducir expiración de 24h a 15 minutos
- Implementar refresh token endpoint
- No elimina la vulnerabilidad, solo reduce la ventana de exposición

### V2 — Feedback de Permisos Inválidos (Prioridad Media)

Agregar comparación de IDs enviados vs asignados en `RolesController`:
```csharp
var totalSolicitados = request.PermisoIds.Count;
var totalAsignados = await _rolRepo.GestionarPermisosAsync(id, csv);
var response = new { totalAsignados, totalSolicitados };
if (totalAsignados < totalSolicitados)
{
    response.advertencia = $"{totalSolicitados - totalAsignados} IDs no existen en la BD";
}
```

---

## Datos de Prueba Residuales

| Dato | ID | Estado | Acción sugerida |
|------|-----|--------|-----------------|
| Departamento "CONCURRENCY_B" | 84 | Activo | Eliminar |
| Motivo "Motivo_Stress_*" | 61 | Activo (reactivado) | Eliminar |
| 1 000 tickets de T3 | — | En BD | Eliminar `WHERE Id_Motivo = 61` |
| 5 000 tickets de T4 | — | En BD | Eliminar por rango de fecha o contenido |
| Archivos SQL temporales | t3_insert.sql, t4_stress.sql | En disco | Eliminar |

---

## Conclusión

El sistema TicketsAPI demuestra **robustez** en:
- Manejo de concurrencia (sin deadlocks)
- Integridad referencial (soft-delete para catálogos con FK)
- Performance con volúmenes altos (6000+ tickets, dashboard < 250ms warm)
- Protección RBAC contra inyección de IDs inexistentes
- Manejo correcto de roles eliminados (hard-delete + CASCADE)

La **vulnerabilidad crítica V1** (sesión de usuario desactivado) requiere atención inmediata, ya que permite acceso de lectura prolongado después de la desactivación del usuario. La implementación del middleware propuesto resolvería el problema con impacto mínimo en la arquitectura existente.
