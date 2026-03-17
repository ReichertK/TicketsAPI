# Autenticación JWT

## Claims del token

```json
{
  "sub": "1",
  "unique_name": "Admin",
  "email": "admin@demo.com",
  "role": "Administrador",
  "exp": 1707003600,
  "iss": "TicketsAPI",
  "aud": "TicketsClients"
}
```

| Claim         | Tipo JWT                        | Contenido             |
|---------------|---------------------------------|-----------------------|
| `sub`         | `JwtRegisteredClaimNames.Sub`   | ID de usuario         |
| `unique_name` | `JwtRegisteredClaimNames.UniqueName` | Nombre de usuario |
| `email`       | `JwtRegisteredClaimNames.Email` | Email                 |
| `role`        | `ClaimTypes.Role`               | Nombre del rol        |

## Configuración

En `appsettings.json`:

```json
{
  "JwtSettings": {
    "SecretKey": "CLAVE_SECRETA_MINIMO_32_CHARS",
    "Issuer": "TicketsAPI",
    "Audience": "TicketsClients",
    "ExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  }
}
```

- Access token: 60 minutos
- Refresh token: 7 días, hasheado con SHA-256 en BD, rotado en cada uso
- ClockSkew: 5 minutos
- Algoritmo: HS256

## Extracción en controllers

`BaseApiController` expone:

```csharp
protected int GetCurrentUserId()
{
    var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                   ?? User.FindFirst("sub")?.Value;
    return int.TryParse(userIdClaim, out var userId) ? userId : 0;
}

protected string? GetCurrentUserRole()
{
    return User.FindFirst(ClaimTypes.Role)?.Value
        ?? User.FindFirst("role")?.Value;
}
```

## Validación de permisos

Los permisos no viajan en el JWT. Se consultan en la BD vía `IAuthService.ValidarPermisoAsync`:

```csharp
bool tienePermiso = await _authService.ValidarPermisoAsync(userId, "TKT_CREATE");
```

La validación usa las tablas `tkt_usuario_rol` → `tkt_rol_permiso` → `tkt_permiso`.

## Flujo completo

1. `POST /api/v1/Auth/login` — credenciales → access token + refresh token
2. Cada request: header `Authorization: Bearer {token}`
3. Token expirado: `POST /api/v1/Auth/refresh` con el refresh token
4. Refresh token se rota (el anterior queda invalidado)
5. Logout: `POST /api/v1/Auth/logout` revoca el refresh token

## Roles del sistema

Ver [PERMISSIONS_MATRIX.md](PERMISSIONS_MATRIX.md) para la matriz completa de roles, permisos y transiciones.
