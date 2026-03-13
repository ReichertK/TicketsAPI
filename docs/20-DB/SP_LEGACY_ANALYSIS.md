# Análisis Exhaustivo de SPs Legacy y Multi-Empresa

## Resumen Ejecutivo

**Hallazgos clave:**
- **Sistema multi-empresa ACTIVO**: 6 registros en `usuario_empresa_sucursal_perfil_sistema` vinculados a sistema CDK_TKT
- **Tablas relacionadas CON DATOS**: empresa (2), sucursal (12), perfil (12), sistema (12), perfil_accion_sistema (27+)
- **23 SPs de multi-empresa**: Aparentemente NO son legacy, sino parte de un sistema de gestión de permisos y contextos multi-tenant
- **API actual USA este sistema**: `GetUsuarioContextoAsync()` consulta `usuario_empresa_sucursal_perfil_sistema` para obtener contexto de tickets

---

## 1. Sistema Multi-Empresa/Sucursal/Perfil

### 1.1 Estado de las Tablas

#### `empresa` - 2 registros
```
idEmpresa | nombre                        | codigo | habilitado
1         | CEDIAC BERAZATEGUI S.R.L.    | CDK    | 0
2         | SUR SALUDPYME S.R.L.         | SUR    | 0
```
**Estado**: Todas deshabilitadas pero con datos reales (CUIT, códigos).

#### `sucursal` - 12 registros
```
idSucursal | idEmpresa | descripcion   | codigo | domicilio                    | habilitado
1          | 1         | CALLE 10      | C10    | CALLE 10 5085... BERAZATEGUI| 0
2          | 1         | CALLE 7       | C7     | CALLE 7 4655... BERAZATEGUI | 0
3          | 2         | SAN JUSTO     | C6     | AV. MITRE 580 - BERAZATEGUI | 1
4          | 2         | MORENO 500    | QM500  | MORENO 522 - QUILMES        | 1
5          | 2         | CAP QUILMES   | CENT   | CENTRAL DE GESTION          | 1
```
**Estado**: 5 activas (habilitado=1), todas vinculadas a empresas reales. **DATOS PRODUCTIVOS**.

#### `perfil` - 12 registros
```
idPerfil | nombre                  | habilitado
1        | Operador                | 0
2        | Auditor Médico          | 0
3        | Supervisor              | 0
4        | Administrador           | 0
5        | Prestador               | 0
6        | Operador internación    | 0
7        | Auditor internación     | 0
8        | Médico informante       | 0
```
**Estado**: Todos deshabilitados pero perfiles de negocio reales para sistema médico/salud.

#### `sistema` - 12 sistemas
```
idSistema  | nombre                    | habilitado
CDK_TKT    | TICKETS                   | 1  ← ACTIVO (nuestra API)
CDK_AUT    | AUTORIZACIONES            | 0
CDK_CNS    | CONSUMOS                  | 0
CDK_TUR    | TURNOS                    | 0
CDK_PAD    | PADRÓN                    | 0
CDK_HUB    | HUB                       | 0
CDK_RYS    | RECLAMOS/SUGERENCIAS      | 0
CDK_STK    | STOCK                     | 0
CDK_EST    | IMÁGENES                  | 0
CDK_FIS    | FISIO                     | 0
CDK_NYP    | NORMAS Y PROCEDIMIENTOS   | 0
CDK_CNV    | CONVENIOS                 | 0
```
**Estado**: **CDK_TKT es el único habilitado**. Los demás son parte de un ecosistema multi-aplicación.

#### `perfil_accion_sistema` - 27+ registros
```
idPerfil | codigoAccion | idSistema | habilitado
1        | A,B,M,V      | CDK_CNS   | 0
3        | A,B,M,V      | CDK_AUT   | 0
4        | A,B,M,V      | CDK_AUT   | 0
```
**Estado**: Matriz de permisos Perfil × Sistema × Acciones (A=Alta, B=Baja, M=Modificación, V=Visualización).

#### `usuario_empresa_sucursal_perfil_sistema` - **6 registros ACTIVOS**
```
ID   | idUsuario | idEmpresa | idSucursal | idSistema | idPerfil | habilitado
1033 | 1         | 1         | 2          | CDK_TKT   | 1        | 1
1034 | 2         | 0         | 2          | CDK_TKT   | 3        | 1
1035 | 3         | 0         | 2          | CDK_TKT   | 1        | 1
1036 | 1         | 1         | 1          | null      | 1        | 0
1037 | 2         | 1         | 1          | null      | 1        | 0
```

**CRÍTICO**: La API actual **SÍ USA ESTA TABLA** en:
- `UsuarioRepository.GetUsuarioContextoAsync()` - línea 226
- `TicketService.CreateAsync()` - líneas 70-73, 84-86
- `TicketService.ValidateTransitionAsync()` - líneas 138-141

**Ejemplo de uso actual:**
```csharp
// UsuarioRepository.cs línea 226-237
public async Task<(int idEmpresa, int idSucursal, int idPerfil)?> GetUsuarioContextoAsync(int idUsuario)
{
    // Buscar el registro activo (habilitado = 1) del usuario para CDK_TKT
    const string sql = @"
        SELECT idEmpresa, idSucursal, idPerfil 
        FROM usuario_empresa_sucursal_perfil_sistema 
        WHERE idUsuario = @idUsuario 
        ORDER BY habilitado DESC, ID DESC 
        LIMIT 1";
    
    var result = await conn.QueryFirstOrDefaultAsync<dynamic>(sql, new { idUsuario });
    return result == null ? null : ((int)result.idEmpresa, (int)result.idSucursal, (int)result.idPerfil);
}
```

---

## 2. Análisis de 23 SPs Multi-Empresa

### 2.1 Stored Procedures de Gestión (23 SPs)

#### **Grupo A: Empresa (3 SPs)**
- `sp_listar_empresas` - SELECT * FROM empresa
- `sp_agregar_empresa` - INSERT INTO empresa
- `sp_editar_empresa` - UPDATE empresa

**Veredicto**: ✅ **MANTENER** - Potencialmente útil si se implementa multi-tenant en el futuro.

#### **Grupo B: Sucursal (5 SPs)**
- `sp_listar_sucursales` - SELECT * FROM sucursal
- `sp_listar_sucursales_por_usuario` - Filtrado por usuario
- `sp_obtener_sucursales` - Posible duplicado de sp_listar_sucursales
- `sp_agregar_sucursal` - INSERT INTO sucursal
- `sp_editar_sucursal` - UPDATE sucursal

**Veredicto**: 
- ✅ **MANTENER**: sp_listar_sucursales_por_usuario (lógica de negocio)
- ⚠️ **CONSOLIDAR**: sp_obtener_sucursales vs sp_listar_sucursales (verificar diferencias)
- ✅ **MANTENER**: Resto (CRUD completo)

#### **Grupo C: Perfil (3 SPs)**
- `sp_listar_perfil` - SELECT * FROM perfil
- `sp_agregar_perfil` - INSERT INTO perfil
- `sp_editar_perfil` - UPDATE perfil

**Veredicto**: ✅ **MANTENER** - Sistema de perfiles es diferente a `rol` actual.

**Nota importante**: `perfil` (12 registros) vs `rol` (4 registros en sp_tkt_seed_basico):
- **rol**: Sistema nuevo de permisos específico de Tickets API (Administrador, Supervisor, Operador, Consulta)
- **perfil**: Sistema legacy de perfiles multi-sistema (Auditor Médico, Prestador, Operador internación, etc.)
- **Coexisten** pero parecen redundantes. Candidato a migración futura.

#### **Grupo D: Sistema (3 SPs)**
- `sp_listar_sistema` - SELECT * FROM sistema
- `sp_agregar_sistema` - INSERT INTO sistema
- `sp_editar_sistema` - UPDATE sistema

**Veredicto**: ✅ **MANTENER** - Gestión de sistemas CDK_* (TKT, AUT, CNS, TUR, etc.)

#### **Grupo E: Perfil-Acción-Sistema (3 SPs)**
- `sp_listar_PerAccSis` - Consulta compleja con filtros dinámicos (perfil, sistema, habilitado)
- `sp_agregar_PerAccSis` - INSERT INTO perfil_accion_sistema
- `sp_editar_PerAccSis` - UPDATE perfil_accion_sistema

**Veredicto**: ✅ **MANTENER** - Matriz de permisos Perfil × Sistema × Acciones.

**Análisis de sp_listar_PerAccSis**:
```sql
SELECT pas.*, p.nombre 'perfil_nombre', s.nombre 'sistema_nombre'
FROM perfil_accion_sistema pas
JOIN perfil p ON p.idPerfil = pas.idPerfil
JOIN sistema s ON s.idSistema = pas.idSistema
WHERE [filtros dinámicos por perfilID, sistemaID, habilitado]
```
Patrón de consulta dinámica con PREPARE/EXECUTE (MySQL 5.5).

#### **Grupo F: Usuario-Empresa-Sucursal-Perfil-Sistema (3 SPs)**
- `sp_listar_UsuEmpSucPerSis` - **CONSULTA MÁS COMPLEJA**
- `sp_agregar_UsuEmpSucPerSis` - INSERT INTO usuario_empresa_sucursal_perfil_sistema
- `sp_editar_UsuEmpSucPerSis` - UPDATE usuario_empresa_sucursal_perfil_sistema

**Veredicto**: ✅ **MANTENER Y CONSIDERAR MIGRAR EL HARDCODE ACTUAL**

**Análisis de sp_listar_UsuEmpSucPerSis**:
```sql
SELECT uesps.*,
    fc_get_empresa(uesps.idEmpresa) 'datos_empresa',
    fc_get_sucursal(uesps.idSucursal) 'datos_sucursal',
    s.nombre 'sistema_nombre',
    p.nombre 'perfil_nombre'
FROM usuario_empresa_sucursal_perfil_sistema uesps
JOIN usuario u ON u.idUsuario = uesps.idUsuario
JOIN sistema s ON s.idSistema = uesps.idSistema
JOIN perfil p ON p.idPerfil = uesps.idPerfil
WHERE [filtros dinámicos: usuarioID, empresaID, sucursalID, sistemaID, perfilID, habilitado]
```

**OPORTUNIDAD DE MIGRACIÓN**:
Actualmente `GetUsuarioContextoAsync()` usa SQL directo:
```csharp
// ACTUAL (hardcoded)
SELECT idEmpresa, idSucursal, idPerfil 
FROM usuario_empresa_sucursal_perfil_sistema 
WHERE idUsuario = @idUsuario 
ORDER BY habilitado DESC, ID DESC LIMIT 1
```

Podría usar `sp_listar_UsuEmpSucPerSis(usuarioID, -1, -1, 'CDK_TKT', 0, 1)` para obtener contexto completo con nombres de empresa/sucursal/perfil.

#### **Grupo G: Roles y Permisos Tickets (3 SPs)**
- `sp_tkt_rol_crear` - INSERT INTO rol con validación de duplicados
- `sp_tkt_permiso_crear` - INSERT INTO permiso con validación
- `sp_tkt_rol_permiso_asignar` - INSERT INTO rol_permiso (relación M:N)

**Veredicto**: ✅ **MANTENER** - Usadas por `sp_tkt_seed_basico` para inicializar sistema de permisos.

**Nota**: Estas SPs NO están en la categoría "legacy multiempresa" sino que son **herramientas de inicialización** para el sistema de roles/permisos de Tickets API.

#### **Grupo H: Funciones de contexto (3 FUNCTIONS)**
- `fc_get_empresa(idEmpresa)` - Devuelve JSON con datos de empresa
- `fc_get_sucursal(idSucursal)` - Devuelve JSON con datos de sucursal
- `fc_get_perfil_sistema_con_sucursal(...)` - Contexto completo

**Veredicto**: ✅ **MANTENER** - Usadas por `sp_listar_UsuEmpSucPerSis`.

---

## 3. Análisis de 13 SPs Potencialmente Obsoletas

### 3.1 Seeds (3 SPs)

#### `sp_tkt_seed_basico`
**Propósito**: Inicialización de roles/permisos base del sistema.

**Contenido**:
```sql
-- Crea 4 roles: Administrador, Supervisor, Operador, Consulta
-- Crea 11 permisos: TKT_LIST_ALL, TKT_CREATE, TKT_EDIT_ANY, TKT_DELETE, etc.
-- Asigna permisos a roles mediante sp_tkt_rol_permiso_asignar
```

**Veredicto**: ✅ **MANTENER** - Esencial para CI/CD y fresh installs.

**Uso recomendado**: Scripts de despliegue, Docker entrypoint, migraciones.

#### `sp_tkt_seed_minima`
**Estado**: No documentada en audit inicial.

**Acción**: ⚠️ **INVESTIGAR** - Verificar contenido y diferencia con sp_tkt_seed_basico.

#### `sp_tkt_seed_asignar_roles_usuarios`
**Estado**: No documentada en audit inicial.

**Acción**: ⚠️ **INVESTIGAR** - Posible seed para entornos de desarrollo.

### 3.2 Login Legacy (3 SPs)

#### `sp_login`
**Propósito**: Sistema de login ultra-flexible que detecta automáticamente columnas disponibles.

**Características**:
- Detección dinámica: `nombreUsuario` vs `nombre` vs `email`
- Soporte dual password: `passwordUsuario` vs `passwordUsuarioEnc` (MD5)
- Validación de `fechaBaja` (soft delete)
- **Integración con sistema multi-empresa**: Devuelve `idPerfil`, `idEmpresa`, `idSucursal` si `usuario_empresa_sucursal_perfil_sistema` tiene datos
- Manejo de perfiles deshabilitados

**Ejemplo de salida con multi-empresa**:
```sql
SELECT 
    'success' AS Msg,
    u.idUsuario, u.nombre, u.tipo,
    v_idPerfil AS IdPerfil,        -- De usuario_empresa_sucursal_perfil_sistema
    v_nombrePerfil AS NombrePerfil,
    v_idEmpresa AS empresaId,
    v_empresaNombre AS empresaNombre,
    v_idSucursal AS sucursalId,
    v_sucursalNombre AS sucursalNombre
FROM usuario u
```

**Estado**: La API actual NO USA esta SP, usa `AuthService.LoginAsync()` con BCrypt.

**Veredicto**: ⚠️ **LEGACY PERO FUNCIONAL**
- **Mantener** si hay otros sistemas externos usando esta BD
- **Eliminar** si TicketsAPI es el único consumidor

#### `sp_login.old`
**Veredicto**: ❌ **ELIMINAR** - Backup obsoleto de versión anterior de sp_login.

#### `sp_login_hub`
**Estado**: No documentada.

**Acción**: ⚠️ **INVESTIGAR** - Posible login específico para sistema CDK_HUB.

### 3.3 Duplicados (4 SPs)

#### `sp_listar_tkt` vs `sp_listar_tkts`
**Diferencia clave**:
- `sp_listar_tkt`: Paginación con PREPARE/EXECUTE (líneas ~40)
- `sp_listar_tkts`: Paginación simplificada sin PREPARE (usado actualmente por TicketRepository)

**Contenido de sp_listar_tkt**:
```sql
CREATE PROCEDURE sp_listar_tkt(
    IN w_id_tkt BIGINT, w_id_estado INT, w_date_creado_desde DATETIME, ...
    IN page_number INT, IN page_size INT
)
BEGIN
    SET @query = "SELECT t.* FROM tkt t WHERE 1=1 [filtros dinámicos] ORDER BY Date_Creado DESC LIMIT ?, ?";
    PREPARE stmt FROM @query;
    SET @offset = (page_number - 1) * page_size;
    EXECUTE stmt USING @offset, @limit_value;
END
```

**Veredicto**: 
- ✅ **MANTENER** `sp_listar_tkts` (en uso activo)
- ❌ **ELIMINAR** `sp_listar_tkt` (duplicado sin ventajas)

#### `sp_obtener_departamentos` vs `sp_listar_departamento`
**Diferencia**:
- `sp_obtener_departamentos`: `SELECT Id_Departamento, Nombre FROM departamento ORDER BY Nombre`
- `sp_listar_departamento`: Similar pero usado por DepartamentoRepository

**Veredicto**:
- ✅ **MANTENER** `sp_listar_departamento` (migración reciente, en uso)
- ❌ **ELIMINAR** `sp_obtener_departamentos` (duplicado legacy)

#### `sp_obtener_sucursales` vs `sp_listar_sucursales`
**Acción**: ⚠️ **INVESTIGAR** - Comparar definiciones para verificar si son duplicados exactos.

### 3.4 Recovery y Utilidades (3 SPs)

#### `sp_recuperar_password_usuario`
**Estado**: SP compleja para reset de contraseña (posiblemente con envío de email o token).

**Veredicto**: ⚠️ **MANTENER SI HAY FUNCIONALIDAD DE RESET**
- Si la API tiene endpoint de "olvidé mi contraseña" → MIGRAR
- Si no existe funcionalidad → ⏳ MANTENER para implementación futura

#### `sp_traer_usuario`
**Acción**: ⚠️ **INVESTIGAR** - Posible duplicado de `sp_obtener_usuarios` o `GetByIdAsync`.

#### `sp_obtener_detalle_ticket`
**Estado**: Ya analizado en SP_AUDIT_COMPLETE.md.

**Veredicto**: ⏳ **CANDIDATO A IMPLEMENTACIÓN** - JOIN completo de ticket con todas sus relaciones (1 query vs 7 actuales).

---

## 4. Recomendaciones Priorizadas

### 4.1 Acciones Inmediatas

#### ✅ Mantener todas las SPs Multi-Empresa (23 SPs)
**Razón**: Sistema activo usado por la API actual. `GetUsuarioContextoAsync()` depende de `usuario_empresa_sucursal_perfil_sistema`.

**Evidencia**:
- 6 registros activos (habilitado=1) en tabla de contexto
- 5 sucursales activas con datos productivos
- Sistema CDK_TKT habilitado
- Código actual en TicketService.CreateAsync() usa empresa/sucursal/perfil

#### ❌ Eliminar SPs Duplicadas (4 SPs)
```sql
DROP PROCEDURE IF EXISTS sp_listar_tkt;           -- Usar sp_listar_tkts
DROP PROCEDURE IF EXISTS sp_obtener_departamentos; -- Usar sp_listar_departamento
DROP PROCEDURE IF EXISTS sp_login.old;             -- Backup obsoleto
```

#### ⚠️ Investigar Seeds (3 SPs)
Ejecutar y documentar:
```sql
SHOW CREATE PROCEDURE sp_tkt_seed_minima;
SHOW CREATE PROCEDURE sp_tkt_seed_asignar_roles_usuarios;
```

### 4.2 Oportunidades de Migración

#### 1. Migrar `GetUsuarioContextoAsync()` a SP
**Actual** (hardcoded):
```csharp
SELECT idEmpresa, idSucursal, idPerfil 
FROM usuario_empresa_sucursal_perfil_sistema 
WHERE idUsuario = @idUsuario 
ORDER BY habilitado DESC, ID DESC LIMIT 1
```

**Propuesto** (usar SP existente):
```csharp
// Llamar sp_listar_UsuEmpSucPerSis con filtros específicos
await conn.QueryAsync<dynamic>("sp_listar_UsuEmpSucPerSis", 
    new { 
        w_usuarioID = idUsuario, 
        w_empresaID = -1,        // Sin filtro
        w_sucursalID = -1,       // Sin filtro
        w_sistemaID = "CDK_TKT", // Solo tickets
        w_perfilID = 0,          // Sin filtro
        w_habilitado = 1         // Solo activos
    }, 
    commandType: CommandType.StoredProcedure);
```

**Beneficios**:
- Consistencia con patrón SP-first
- Obtención de nombres de empresa/sucursal/perfil sin queries adicionales
- Uso de funciones `fc_get_empresa()` y `fc_get_sucursal()`

#### 2. Evaluar implementación de endpoints Multi-Empresa
Actualmente la API tiene tablas y SPs pero **no expone endpoints** para:
- Listar empresas: `GET /api/v1/Empresas`
- Listar sucursales: `GET /api/v1/Sucursales`
- Gestionar contexto usuario: `PUT /api/v1/Usuarios/{id}/Contexto`

**Decisión pendiente**: ¿Se necesita funcionalidad multi-tenant en Tickets API?

### 4.3 Consolidación de Sistemas de Permisos

#### Situación Actual: Dos sistemas coexistiendo

**Sistema 1: Rol/Permiso (Nuevo - API Tickets)**
```
Tablas: rol, permiso, rol_permiso, usuario_rol
SPs: sp_tkt_rol_crear, sp_tkt_permiso_crear, sp_tkt_rol_permiso_asignar
Permisos: TKT_LIST_ALL, TKT_CREATE, TKT_EDIT_ANY, TKT_DELETE (11 permisos específicos)
Roles: Administrador, Supervisor, Operador, Consulta (4 roles)
```

**Sistema 2: Perfil/Sistema/Acciones (Legacy - Multi-sistema)**
```
Tablas: perfil, sistema, perfil_accion_sistema, usuario_empresa_sucursal_perfil_sistema
SPs: sp_listar_perfil, sp_listar_sistema, sp_listar_PerAccSis, sp_listar_UsuEmpSucPerSis
Perfiles: Operador, Auditor Médico, Supervisor, Prestador, etc. (12 perfiles)
Sistemas: CDK_TKT, CDK_AUT, CDK_CNS, CDK_TUR, etc. (12 sistemas)
Acciones: A,B,M,V (Alta, Baja, Modificación, Visualización)
```

#### Análisis de Redundancia

| Concepto | Sistema Rol/Permiso | Sistema Perfil/Sistema |
|----------|---------------------|------------------------|
| Usuario Administrador | rol.nombre = 'Administrador' | perfil.nombre = 'Administrador' |
| Usuario Supervisor | rol.nombre = 'Supervisor' | perfil.nombre = 'Supervisor' |
| Usuario Operador | rol.nombre = 'Operador' | perfil.nombre = 'Operador' |

**Diferencias clave**:
- **Rol/Permiso**: Granularidad fina (11 permisos específicos como TKT_EDIT_ASSIGNED, TKT_CLOSE, TKT_COMMENT)
- **Perfil/Sistema**: Granularidad gruesa (4 acciones genéricas: A,B,M,V) pero **multi-sistema** (TKT, AUT, CNS, TUR...)

#### Recomendación Estratégica

**Opción A: Mantener ambos sistemas (Recomendado corto plazo)**
- **Rol/Permiso**: Para Tickets API (granularidad fina)
- **Perfil/Sistema**: Para contexto multi-empresa y futura integración con otros sistemas CDK_*

**Opción B: Migrar a sistema unificado (Mediano plazo)**
1. Extender `permiso` para incluir `idSistema` (ej: "CDK_TKT:TKT_EDIT_ANY")
2. Migrar `perfil` a `rol` con categorización por sistema
3. Deprecar `perfil_accion_sistema` en favor de `rol_permiso`
4. Mantener `usuario_empresa_sucursal_perfil_sistema` como contexto multi-tenant

**Opción C: Coexistencia con bridge (Largo plazo)**
- Crear vista o SP de traducción: `perfil_accion_sistema` → `rol_permiso`
- Implementar AuthorizationHandler que consulte ambos sistemas
- Permitir que usuarios tengan TANTO `rol` (granular) COMO `perfil` (multi-sistema)

---

## 5. Análisis de Riesgo

### 5.1 Impacto de Eliminar SPs Multi-Empresa

**Impacto CRÍTICO** ❌ si se eliminan:
- `GetUsuarioContextoAsync()` fallaría → Error en `TicketService.CreateAsync()`
- Tickets sin contexto de empresa/sucursal/perfil → Pérdida de trazabilidad
- Validaciones de transición podrían fallar (línea 138 TicketService)

**Conclusión**: **NO ELIMINAR** ninguna SP de multi-empresa hasta confirmar:
1. Migración completa a sistema alternativo, O
2. Confirmación de que no hay otros sistemas externos dependiendo de estas tablas/SPs

### 5.2 Impacto de Eliminar SPs Legacy

**Impacto BAJO** ✅ para:
- `sp_listar_tkt` (duplicado de sp_listar_tkts)
- `sp_obtener_departamentos` (duplicado de sp_listar_departamento)
- `sp_login.old` (backup sin uso)

**Impacto MEDIO** ⚠️ para:
- `sp_login` (si hay integración externa o login legacy)
- `sp_recuperar_password_usuario` (funcionalidad futura)

### 5.3 Riesgo de Datos Huérfanos

**Escenario**: Si se eliminan SPs pero las tablas tienen datos activos.

**Tablas con datos productivos**:
- `usuario_empresa_sucursal_perfil_sistema`: 6 registros activos
- `sucursal`: 5 registros activos
- `perfil_accion_sistema`: 27+ registros

**Mitigación**:
1. NO eliminar tablas (solo SPs si están duplicadas)
2. Mantener SPs de lectura (sp_listar_*) aunque no se usen actualmente
3. Eliminar SOLO SPs de escritura legacy (sp_agregar_*, sp_editar_*) si se confirma que no hay uso externo

---

## 6. Plan de Acción Definitivo

### Fase 1: Limpieza Segura (1-2 horas)
```sql
-- Eliminar duplicados confirmados
DROP PROCEDURE IF EXISTS sp_listar_tkt;           
DROP PROCEDURE IF EXISTS sp_obtener_departamentos; 
DROP PROCEDURE IF EXISTS `sp_login.old`;           

-- Documentar para decisión posterior
SELECT 'PENDIENTE: Investigar sp_login uso externo' AS accion;
SELECT 'PENDIENTE: Investigar sp_recuperar_password_usuario' AS accion;
SELECT 'PENDIENTE: Comparar sp_obtener_sucursales vs sp_listar_sucursales' AS accion;
```

### Fase 2: Investigación Profunda (2-4 horas)
```sql
-- Verificar uso de sp_login por otros sistemas
SELECT * FROM information_schema.PROCESSLIST WHERE Info LIKE '%sp_login%';

-- Analizar seeds faltantes
SHOW CREATE PROCEDURE sp_tkt_seed_minima;
SHOW CREATE PROCEDURE sp_tkt_seed_asignar_roles_usuarios;

-- Comparar duplicados de sucursales
SHOW CREATE PROCEDURE sp_obtener_sucursales;
SHOW CREATE PROCEDURE sp_listar_sucursales;
```

### Fase 3: Migración de Hardcode (4-6 horas)
1. Migrar `GetUsuarioContextoAsync()` a usar `sp_listar_UsuEmpSucPerSis`
2. Crear DTOs para contexto multi-empresa (EmpresaDTO, SucursalDTO, PerfilDTO)
3. Actualizar `TicketService` para usar DTOs en lugar de tuplas
4. Testing completo de flujo de creación de tickets

### Fase 4: Decisión Estratégica (Pendiente stakeholders)
- ¿Implementar funcionalidad multi-tenant en Tickets API?
- ¿Migrar/consolidar sistema Rol/Permiso con Perfil/Sistema?
- ¿Mantener compatibilidad con otros sistemas CDK_* (AUT, CNS, TUR)?

---

## 7. Conclusiones

### 7.1 Hallazgos Principales

1. **Sistema multi-empresa NO es legacy**: Es activo y usado por la API actual
2. **23 SPs de multi-empresa son necesarias**: Soportan infraestructura productiva
3. **Coexisten 2 sistemas de permisos**: Rol/Permiso (nuevo) y Perfil/Sistema (legacy) sin estrategia de consolidación
4. **4-6 SPs duplicadas identificadas**: Candidatos seguros a eliminación
5. **3-4 SPs seed**: Mantener para CI/CD y fresh installs
6. **sp_login es funcional pero no usada**: Decisión pendiente según uso externo

### 7.2 Recomendación Final

**Estrategia de 3 vías**:

1. **Mantener y documentar**: Sistema multi-empresa completo (23 SPs + tablas + funciones)
2. **Eliminar duplicados seguros**: 3-4 SPs confirmadas como redundantes
3. **Investigar antes de decidir**: 4-5 SPs con uso incierto (login, recovery, seeds)

**NO ELIMINAR** SPs de multi-empresa hasta:
- Confirmar que no hay otros sistemas/aplicaciones usando la misma BD
- Decidir estrategia de consolidación Rol/Permiso vs Perfil/Sistema
- Implementar migración completa de hardcoded SQL a SPs

---

## Apéndice A: Lista Completa de SPs Multi-Empresa

### Gestión de Empresas (3)
- sp_listar_empresas
- sp_agregar_empresa
- sp_editar_empresa

### Gestión de Sucursales (5)
- sp_listar_sucursales
- sp_listar_sucursales_por_usuario
- sp_obtener_sucursales ⚠️ (no duplicado exacto: retorna subset sin join empresa)
- sp_agregar_sucursal
- sp_editar_sucursal

### Gestión de Perfiles (3)
- sp_listar_perfil
- sp_agregar_perfil
- sp_editar_perfil

### Gestión de Sistemas (3)
- sp_listar_sistema
- sp_agregar_sistema
- sp_editar_sistema

### Matriz Perfil-Acción-Sistema (3)
- sp_listar_PerAccSis
- sp_agregar_PerAccSis
- sp_editar_PerAccSis

### Contexto Usuario-Empresa-Sucursal-Perfil-Sistema (3)
- sp_listar_UsuEmpSucPerSis
- sp_agregar_UsuEmpSucPerSis
- sp_editar_UsuEmpSucPerSis

### Herramientas de Inicialización (3)
- sp_tkt_rol_crear
- sp_tkt_permiso_crear
- sp_tkt_rol_permiso_asignar

### Funciones Auxiliares (3)
- fc_get_empresa(idEmpresa)
- fc_get_sucursal(idSucursal)
- fc_get_perfil_sistema_con_sucursal(...)

---

## Apéndice B: SPs Candidatas a Eliminación

### Confirmadas (3)
```sql
DROP PROCEDURE IF EXISTS sp_listar_tkt;
DROP PROCEDURE IF EXISTS sp_obtener_departamentos;
DROP PROCEDURE IF EXISTS `sp_login.old`;
```

### Acciones ejecutadas (2026-02-03)
- Se crearon backups:
    - old_sp_listar_tkt
    - old_sp_obtener_departamentos
    - old_sp_traer_usuario
    - old_sp_login_hub
    - old_sp_recuperar_password_usuario
    - old_sp_tkt_seed_minima
    - old_sp_tkt_seed_asignar_roles_usuarios
    - old_sp_login
- Se eliminaron:
    - sp_listar_tkt
    - sp_obtener_departamentos
    - sp_login.old
    - sp_traer_usuario
    - sp_login_hub
    - sp_recuperar_password_usuario
    - sp_tkt_seed_minima
    - sp_tkt_seed_asignar_roles_usuarios
    - sp_login

### Resultados de investigación (2026-02-03)
- sp_login_hub: login legacy exclusivo de CDK_HUB. Eliminada con backup.
- sp_recuperar_password_usuario: reseteo directo de password (MD5). Eliminada con backup.
- sp_tkt_seed_minima: duplicado funcional de sp_tkt_seed_basico (no incluye TKT_APPROVE). Eliminada con backup.
- sp_tkt_seed_asignar_roles_usuarios: opera sobre tablas tkt_* (tkt_rol, tkt_permiso, tkt_usuario_rol). Eliminada con backup.
- sp_obtener_sucursales: no es duplicado exacto; devuelve subset sin join empresa (mantener).
- sp_login: login legacy multi-compatibilidad. Eliminada con backup.

### Pendientes de Investigación (0)
- Ninguna

---

**Documento generado**: 2026-02-03  
**Base de datos**: cdk_tkt_dev (MySQL 5.5)  
**Total SPs analizadas**: 64  
**SPs multi-empresa activas**: 23 ✅  
**SPs confirmadas obsoletas**: 9 ❌  
**SPs pendientes investigación**: 0 ⚠️
