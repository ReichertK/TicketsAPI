# Mapeo de Autenticación JWT

Este archivo documenta el mapeo de claims JWT para autorización RBAC.

## Claims Estándar

```json
{
  "sub": "1",                    // User ID (subject)
  "email": "user@empresa.com",
  "name": "Juan Pérez",
  "role": "2",                   // Role ID
  "role_name": "Técnico",
  "department": "1",
  "permissions": [
    "tickets.crear",
    "tickets.editar", 
    "tickets.eliminar"
  ],
  "iat": 1707000000,            // Issued at
  "exp": 1707003600,            // Expiration
  "iss": "TicketsAPI",          // Issuer
  "aud": "TicketsClients"       // Audience
}
```

## Extracción en Controladores

```csharp
// En BaseApiController
protected int GetCurrentUserId()
{
    return int.Parse(User.FindFirst("sub")?.Value ?? "0");
}

protected int GetCurrentRoleId()
{
    return int.Parse(User.FindFirst("role")?.Value ?? "0");
}

protected List<string> GetCurrentPermissions()
{
    var permClaim = User.FindFirst("permissions")?.Value;
    return permClaim?.Split(',').ToList() ?? new();
}
```

## Validación de Permisos

```csharp
// Validar permiso específico
[Authorize]
[HttpPost("tickets")]
public async Task<IActionResult> CreateTicket([FromBody] CreateUpdateTicketDTO dto)
{
    // Automático: [Authorize] valida token JWT
    // Manual: validar permisos adicionales
    var permisos = GetCurrentPermissions();
    if (!permisos.Contains("tickets.crear"))
        return Forbid();
    
    // Continuar...
}
```

## Política de Autorización Personalizada

```csharp
// En Program.cs
builder.Services.AddAuthorization(options =>
{
    // Política: solo administradores
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireClaim("role_name", "Administrador"));
    
    // Política: crear tickets
    options.AddPolicy("CanCreateTickets", policy =>
        policy.RequireAssertion(context =>
            context.User.HasClaim("permissions", "tickets.crear")));
});

// En Controller
[Authorize(Policy = "CanCreateTickets")]
[HttpPost("tickets")]
public async Task<IActionResult> CreateTicket(...) { }
```

## Roles Soportados

| ID | Nombre | Descripción |
|----|--------|-----------|
| 1 | Administrador | Control total, gestión de usuarios y configuración |
| 2 | Técnico | Crear, asignar y resolver tickets |
| 3 | Usuario | Crear y ver sus propios tickets |

## Permisos por Rol

### Administrador
- tickets.crear
- tickets.editar
- tickets.eliminar
- tickets.asignar
- tickets.cerrar
- usuarios.crear
- usuarios.editar
- usuarios.eliminar
- reportes.ver
- configuracion.editar

### Técnico
- tickets.crear
- tickets.editar
- tickets.asignar
- tickets.cerrar
- reportes.ver

### Usuario
- tickets.crear
- tickets.ver.propios

## Refresh Token

Los refresh tokens se emiten con expiración extendida (7 días por defecto).

```csharp
// En AuthService
var refreshToken = _jwtTokenHandler.GenerateRefreshToken(userId);
// Guardar en base de datos para validación posterior
```

---

**Versión**: 1.0.0
**Última Actualización**: 9 de Diciembre de 2025
