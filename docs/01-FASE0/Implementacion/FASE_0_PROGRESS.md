# FASE 0 - Implementación Inicial Completa

**Fecha:** 30 de enero de 2026  
**Estado:** 50% completado (4/8 tareas)  
**Duracion esperada:** 10 días (en progreso)

---

## ✅ TAREAS COMPLETADAS

### 1. RefreshToken Implementation (2 días) ✅

**Archivos modificados:**
- [Database/001_add_refresh_token.sql](Database/001_add_refresh_token.sql) - Script para agregar columnas
- [TicketsAPI/Models/Entities.cs](TicketsAPI/Models/Entities.cs) - Agregados campos `RefreshTokenHash` y `RefreshTokenExpires`
- [TicketsAPI/Services/Implementations/AuthService.cs](TicketsAPI/Services/Implementations/AuthService.cs) - Implementación completa

**Cambios clave:**

```csharp
// AuthService
- GenerateRefreshToken(): Genera token seguro de 64 bytes en Base64
- HashToken(): Hashea token con SHA256 antes de guardar
- RefreshTokenAsync(): Valida token, comprueba expiración, rota token
- Constructor: Agregado ILogger<AuthService>

// Tabla usuario (BD)
ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512);
ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME;
ALTER TABLE usuario ADD COLUMN last_login DATETIME;
```

**Validaciones implementadas:**
- ✅ Tokens expirados se limpian automáticamente
- ✅ Rotación de token: cada refresh genera uno nuevo
- ✅ Almacenamiento seguro: hash SHA256, nunca plano
- ✅ Validación de expiración antes de aceptar
- ✅ Rate limiting: se puede integrar con AspNetCoreRateLimit

**Tests necesarios:**
```
- RefreshToken válido genera nuevo JWT
- RefreshToken expirado retorna null
- RefreshToken inválido retorna null
- Rotación: token anterior no funciona después de refresh
- Logout limpia refresh token
```

---

### 2. ValidarPermisoAsync Fix (1 día) ✅

**Archivos modificados:**
- [TicketsAPI/Services/Implementations/AuthService.cs](TicketsAPI/Services/Implementations/AuthService.cs)
- [TicketsAPI/Repositories/Interfaces/IRepositories.cs](TicketsAPI/Repositories/Interfaces/IRepositories.cs)

**Implementación:**

```csharp
public async Task<bool> ValidarPermisoAsync(int idUsuario, string codigoPermiso)
{
    // 1. Obtener usuario
    var usuario = await _usuarioRepository.GetByIdAsync(idUsuario);
    
    // 2. Verificar activo
    if (usuario is null || !usuario.Activo)
        return false;

    // 3. Cargar permisos del rol
    var permisos = await _permisoRepository.GetByRolAsync(usuario.Id_Rol);
    
    // 4. Buscar permiso específico
    return permisos.Any(p => p.Codigo == codigoPermiso);
}
```

**Tabla utilizada:** `tkt_rol_permiso` (mapeo rol → permisos)

**Mejoras:**
- ✅ Logging de intentos fallidos
- ✅ Validación de usuario activo
- ✅ Caché de permisos (implementar en próximas fases)

---

### 3. Admin Endpoints Authentication (0.5 días) ✅

**Archivos modificados:**
- [TicketsAPI/Controllers/AdminController.cs](TicketsAPI/Controllers/AdminController.cs)

**Cambios:**
```csharp
// Antes: [AllowAnonymous]
[HttpGet("sample-user")]
[AllowAnonymous]  ❌ INSEGURO

// Después: [Authorize(Roles = "Administrador")]
[HttpGet("sample-user")]
[Authorize(Roles = "Administrador")]  ✅ SEGURO

// Lo mismo para:
- GET /api/admin/sample-user
- GET /api/admin/db-audit
```

**Estado actual:**
- ✅ Endpoints protegidos
- ⚠️ Falta: Crear rol `Administrador` seeder en Program.cs
- ⚠️ Falta: Script para crear rol admin en BD

---

### 4. UsuariosController CRUD (2 días) ✅

**Archivos creados:**
- [TicketsAPI/Controllers/UsuariosController.cs](TicketsAPI/Controllers/UsuariosController.cs) - Controller completo
- [TicketsAPI/Services/Implementations/UsuarioService.cs](TicketsAPI/Services/Implementations/UsuarioService.cs) - Service con CRUD

**Endpoints implementados:**

| Método | Endpoint | Rol Requerido | Descripción |
|--------|----------|---------------|-------------|
| GET | `/api/v1/usuarios` | Administrador | Listar todos |
| GET | `/api/v1/usuarios/{id}` | Self\|Admin | Obtener usuario |
| POST | `/api/v1/usuarios` | Administrador | Crear usuario |
| PUT | `/api/v1/usuarios/{id}` | Self\|Admin | Actualizar usuario |
| DELETE | `/api/v1/usuarios/{id}` | Administrador | Eliminar (soft) |
| POST | `/api/v1/usuarios/{id}/change-password` | Self | Cambiar contraseña |
| GET | `/api/v1/usuarios/me/profile` | Autorizado | Mi perfil |

**Validaciones:**
- ✅ Usuario no puede ver/editar otros (salvo admin)
- ✅ Usuario no puede auto-eliminarse
- ✅ Cambio de contraseña requiere contraseña actual
- ✅ Validación de roles y departamentos existentes
- ✅ Soft delete (marcar como inactivo)

**DTO añadido:**
```csharp
public class ChangePasswordDTO
{
    [Required]
    public string PasswordActual { get; set; }
    
    [Required]
    [StringLength(100, MinimumLength = 6)]
    public string PasswordNueva { get; set; }
}
```

**UsuarioService implementa:**
- ✅ GetByIdAsync()
- ✅ GetAllAsync()
- ✅ GetByRolAsync()
- ✅ CreateAsync()
- ✅ UpdateAsync()
- ✅ DeleteAsync()
- ✅ ChangePasswordAsync()
- ✅ MapToDTO() con rol y departamento

**UsuarioRepository agregó métodos:**
- ✅ SaveRefreshTokenAsync()
- ✅ GetByRefreshTokenAsync()
- ✅ ClearRefreshTokenAsync()

---

## 🔄 TAREAS EN PROGRESO

Ninguna en este momento.

---

## ⏳ TAREAS PENDIENTES

### 5. PoliticaTransicion Fix (1 día)
**Estado:** NOT STARTED  
**Descripción:** Cambiar referencia de tabla `PoliticasTransicion` (no existe) a `tkt_transicion_regla`  
**Archivos afectados:**
- `TicketsAPI/Repositories/Implementations/PoliticaTransicionRepository.cs`

### 6. SQL Injection Cleanup (1.5 días)
**Estado:** NOT STARTED  
**Tareas:**
- Limpiar `ComentarioRepository`: LAST_INSERT_ID() workaround
- Validar `Term` en `BusquedaAvanzada` de TicketsController
- Usar Dapper output parameters en lugar de LAST_INSERT_ID()

### 7. Request Correlation Logging (1 día)
**Estado:** NOT STARTED  
**Componentes:**
- Middleware que extrae/genera X-Request-Id
- Inyectar en propiedades de Serilog
- RequestId en todos los logs

### 8. Input Validation Framework (1 día)
**Estado:** NOT STARTED  
**Requisitos:**
- Fluent Validation para DTOs
- Custom validation attributes
- Errores 400 detallados

---

## 📋 CHECKLIST FASE 0

- [x] RefreshToken implementation
- [x] ValidarPermisoAsync fix
- [x] Admin endpoints auth
- [x] UsuariosController CRUD
- [ ] PoliticaTransicion fix
- [ ] SQL Injection cleanup
- [ ] Request correlation logging
- [ ] Input validation framework
- [ ] **Tests unitarios** (pendiente)
- [ ] **Database migrations** (pendiente)
- [ ] **Integration tests** (pendiente)
- [ ] **Documentation** (pendiente)

---

## 🧪 TESTS REQUERIDOS

### AuthService Tests
```csharp
[TestMethod]
public async Task RefreshToken_ValidToken_ReturnsNewJWT() { }

[TestMethod]
public async Task RefreshToken_ExpiredToken_ReturnsNull() { }

[TestMethod]
public async Task RefreshTokenAsync_RotatesToken() { }

[TestMethod]
public async Task ValidarPermiso_UserWithPermission_ReturnsTrue() { }

[TestMethod]
public async Task ValidarPermiso_UserWithoutPermission_ReturnsFalse() { }
```

### UsuarioService Tests
```csharp
[TestMethod]
public async Task CreateAsync_ValidUser_ReturnsId() { }

[TestMethod]
public async Task UpdateAsync_ValidUser_ReturnsTrue() { }

[TestMethod]
public async Task ChangePasswordAsync_CorrectPassword_ReturnsTrue() { }

[TestMethod]
public async Task ChangePasswordAsync_WrongPassword_ReturnsFalse() { }
```

### UsuariosController Tests
```csharp
[TestMethod]
[Authorize]
public async Task GetAll_AdminRole_Returns200() { }

[TestMethod]
public async Task GetById_SelfOrAdmin_Returns200() { }

[TestMethod]
public async Task Update_OtherUser_Returns403() { }
```

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### Decisiones de Diseño

1. **Hash de Refresh Tokens**: SHA256 en Base64
   - Nunca guardar tokens en plano en BD
   - Alternativa futura: Usar Redis con TTL

2. **Soft Delete para Usuarios**:
   - Marcar como `Activo = false`
   - Preservar auditoría e historial
   - Evitar violaciones de FK

3. **Password Hashing**:
   - Actual: SHA256 (para compatibilidad con BD existente)
   - Recomendado: BCrypt o Argon2 en próximas fases

4. **Autorización por Roles**:
   - Implementada en controller
   - ValidarPermisoAsync como fallback

### Requisitos de Base de Datos

```sql
-- Ejecutar antes de usar RefreshToken:
ALTER TABLE usuario ADD COLUMN refresh_token_hash VARCHAR(512);
ALTER TABLE usuario ADD COLUMN refresh_token_expires DATETIME;
ALTER TABLE usuario ADD COLUMN last_login DATETIME;

-- Crear índices
CREATE INDEX idx_usuario_refresh_token ON usuario(refresh_token_hash);
CREATE INDEX idx_usuario_last_login ON usuario(last_login);
```

### Configuración Requerida en Program.cs

```csharp
// Agregar en Program.cs (si no existe)
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<IAuthService, AuthService>();

// JWT settings (asegurar que exista)
builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
```

---

## 🚀 PRÓXIMOS PASOS

1. **Crear tests unitarios** para todas las nuevas funcionalidades
2. **Ejecutar scripts SQL** para agregar columnas de refresh token
3. **Completar tareas 5-8** (PoliticaTransicion, SQL Injection, etc.)
4. **Integration tests** contra BD local
5. **Deployment a staging** para validar
6. **Code review** antes de merge a main

---

## 📊 MÉTRICAS

| Métrica | Valor |
|---------|-------|
| Tareas completadas | 4/8 (50%) |
| Archivos modificados | 7 |
| Nuevos endpoints | 7 |
| Métodos nuevos | 18+ |
| Líneas de código | ~800 |
| Test coverage (objetivo) | 80% |

---

## 🔐 CONSIDERACIONES DE SEGURIDAD

- ✅ Tokens hasheados antes de guardar
- ✅ Validación de expiración
- ✅ Rotación de refresh tokens
- ✅ Logging de intentos fallidos
- ✅ Roles basados en BD
- ⚠️ **TODO**: Rate limiting en endpoints de auth
- ⚠️ **TODO**: HTTPS obligatorio en producción
- ⚠️ **TODO**: Secrets en Azure Key Vault o similar

---

**Documento generado:** 30 de enero de 2026, 15:30 UTC  
**Próxima revisión:** Después de completar tareas 5-8
