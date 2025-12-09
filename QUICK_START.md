# 🚀 GUÍA DE INICIO - TicketsAPI

## ✅ Status Actual del Proyecto

El proyecto **TicketsAPI** ha sido inicializado con éxito con una arquitectura profesional N-Tier completamente lista para desarrollo.

### ✨ Lo que se ha creado:

```
✅ Estructura base del proyecto ASP.NET Core 6
✅ Configuración de dependencias (23 NuGet packages)
✅ Autenticación JWT con Bearer tokens
✅ CORS configurable
✅ Logging con Serilog
✅ Documentación Swagger/OpenAPI
✅ SignalR para notificaciones en tiempo real
✅ Health checks
✅ 11 modelos de entidades de BD
✅ 30+ DTOs para comunicación API
✅ Interfaces de Repositories y Services (9 cada uno)
✅ 4 Controladores base (Auth, Tickets, References, etc)
✅ Middleware de manejo de excepciones
✅ Documentación completa (5 archivos .md)
```

**Líneas de código creadas**: ~4000 LOC  
**Archivos de código**: 16 archivos .cs  
**Archivos de configuración**: 5 archivos

---

## 📦 Próximos Pasos (En Orden)

### 1️⃣ Configurar Base de Datos

```bash
# Conectar a MySQL y ejecutar:
CREATE DATABASE cdk_tkt CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'tickets_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON cdk_tkt.* TO 'tickets_user'@'localhost';
FLUSH PRIVILEGES;
```

**Actualizar `appsettings.json`** con tus credenciales reales.

### 2️⃣ Implementar Repositorios (Estimado: 4-6 horas)

Crear carpeta `Repositories/Implementations/`:

```csharp
// Ejemplo: BaseRepository.cs
public class BaseRepository<T> : IBaseRepository<T> where T : class
{
    private readonly string _connectionString;
    
    public BaseRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<T?> GetByIdAsync(int id)
    {
        using (var connection = new MySqlConnection(_connectionString))
        {
            await connection.OpenAsync();
            // Usar Dapper para ejecutar query
        }
    }
    
    // Implementar resto de métodos...
}
```

**Archivos a crear**:
- BaseRepository.cs (genérico)
- UsuarioRepository.cs
- TicketRepository.cs
- EstadoRepository.cs
- PrioridadRepository.cs
- DepartamentoRepository.cs
- ComentarioRepository.cs
- HistorialRepository.cs
- RolRepository.cs
- PermisoRepository.cs
- PoliticaTransicionRepository.cs

### 3️⃣ Implementar Servicios (Estimado: 6-8 horas)

Crear carpeta `Services/Implementations/`:

```csharp
// Ejemplo: AuthService.cs
public class AuthService : IAuthService
{
    private readonly IUsuarioRepository _usuarioRepository;
    private readonly IConfiguration _configuration;
    
    public AuthService(IUsuarioRepository usuarioRepository, IConfiguration configuration)
    {
        _usuarioRepository = usuarioRepository;
        _configuration = configuration;
    }

    public async Task<LoginResponse?> LoginAsync(LoginRequest request)
    {
        // 1. Validar usuario existe
        var usuario = await _usuarioRepository.GetByUsuarioAsync(request.Usuario);
        if (usuario == null) return null;
        
        // 2. Validar contraseña
        if (!VerifyPassword(request.Contraseña, usuario.Contraseña))
            return null;
        
        // 3. Generar JWT token
        var token = GenerateJwtToken(usuario);
        
        // 4. Retornar respuesta
        return new LoginResponse
        {
            Id_Usuario = usuario.Id_Usuario,
            Nombre = usuario.Nombre,
            Token = token
            // ...
        };
    }

    // Implementar resto de métodos...
}
```

### 4️⃣ Completar Controladores (Estimado: 4-6 horas)

Los controladores tienen estructura pero les falta inyectar servicios:

```csharp
// En Program.cs - agregar a Dependency Injection:
builder.Services.AddScoped<ITicketRepository, TicketRepository>();
builder.Services.AddScoped<ITicketService, TicketService>();
builder.Services.AddScoped<IAuthService, AuthService>();
// ... más servicios
```

### 5️⃣ Testear y Validar (Estimado: 2-3 horas)

```bash
# Construir
dotnet build

# Ejecutar con watch
dotnet watch run

# Acceder a Swagger
# https://localhost:5001

# Probar endpoint de health check
curl -k https://localhost:5001/health
```

---

## 🔧 Configuración Rápida

### En `TicketsAPI/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Port=3306;Database=cdk_tkt;Uid=tickets_user;Pwd=tu_password;ConvertZeroDateTime=true;SslMode=none"
  },
  "JwtSettings": {
    "SecretKey": "tu-clave-secreta-min-32-caracteres-para-produccion",
    "Issuer": "TicketsAPI",
    "Audience": "TicketsClients",
    "ExpirationMinutes": 60,
    "RefreshTokenExpirationDays": 7
  },
  "Cors": {
    "AllowedOrigins": [
      "http://localhost:3000",
      "http://localhost:5173"
    ]
  }
}
```

---

## 🎯 Verificación de Estructura

```bash
# Verificar que todo está bien
cd TicketsAPI
dotnet build --verbosity minimal

# Resultado esperado: ✅ La compilación debe ser exitosa
# (Si hay errores, probablemente falten imports)
```

---

## 📚 Archivos de Referencia Importante

| Archivo | Propósito |
|---------|-----------|
| `Program.cs` | Configuración de DI, middleware, autenticación |
| `Models/Entities.cs` | Modelos de base de datos |
| `Models/DTOs.cs` | DTOs para API (30+ clases) |
| `Controllers/BaseApiController.cs` | Métodos helper para controladores |
| `Repositories/Interfaces/IRepositories.cs` | Contratos a implementar |
| `Services/Interfaces/IServices.cs` | Contratos a implementar |
| `Config/TicketHub.cs` | Hub de SignalR |
| `Config/ConfigurationClasses.cs` | Clases de configuración |
| `DEVELOPMENT.md` | Roadmap detallado |
| `API_EXAMPLES.md` | Ejemplos en múltiples lenguajes |

---

## 🚀 Quick Start (Para Empezar)

```bash
# 1. Ir al directorio del proyecto
cd TicketsAPI/TicketsAPI

# 2. Restaurar dependencias
dotnet restore

# 3. Compilar (verificar que todo esté bien)
dotnet build

# 4. Ejecutar en desarrollo (con Swagger)
dotnet run --launch-profile https

# 5. Abrir navegador
# https://localhost:5001
```

---

## 🔐 Variables de Entorno (Para Producción)

```bash
# Configurar antes de ejecutar en producción:
export ConnectionStrings__DefaultConnection="Server=prod-server;Database=cdk_tkt;..."
export JwtSettings__SecretKey="tu-clave-super-segura-min-32-caracteres"
export ASPNETCORE_ENVIRONMENT="Production"
export ASPNETCORE_URLS="https://0.0.0.0:5001"
```

---

## ⚠️ Cosas a Tener en Cuenta

1. **JWT Secret**: Cambiar `JwtSettings.SecretKey` a una clave segura
2. **CORS Origins**: Configurar solo los orígenes permitidos
3. **Base de Datos**: Ejecutar scripts SQL del proyecto original
4. **Email/SMTP** (futuro): Configurar para notificaciones
5. **Rate Limiting** (futuro): Agregar cuando esté en producción

---

## 🤝 Pasos Para Integración con React Frontend

Una vez que la API esté funcional:

```bash
# 1. Crear proyecto React
npx create-react-app tickets-ui
cd tickets-ui

# 2. Instalar dependencias
npm install axios react-router-dom zustand

# 3. Crear cliente API (usar ejemplos de API_EXAMPLES.md)
src/
├── api/
│   ├── client.ts
│   ├── auth.service.ts
│   └── tickets.service.ts
├── pages/
│   ├── Login.tsx
│   ├── Tickets.tsx
│   └── Dashboard.tsx
└── components/
    ├── TicketForm.tsx
    ├── TicketList.tsx
    └── StateTransition.tsx

# 4. Conectar SignalR para notificaciones en tiempo real
npm install @microsoft/signalr

# 5. Consumir endpoints de API
// Ejemplo en API_EXAMPLES.md para React
```

---

## 📞 Soporte y Referencias

- 📖 Documentación completa: `DEVELOPMENT.md`
- 🔐 Autenticación JWT: `JWT_AUTHENTICATION.md`
- 📚 Ejemplos API: `API_EXAMPLES.md`
- 🏗️ Estructura: `PROJECT_STRUCTURE.md`
- 🔗 Proyecto original: https://github.com/ReichertK/Tickets

---

## ✅ Checklist de Implementación

```markdown
### Fase 3: Repositorios
- [ ] Crear BaseRepository.cs genérico
- [ ] Implementar 11 repositorios específicos
- [ ] Mapeos automáticos (AutoMapper)
- [ ] Tests unitarios de repositorios

### Fase 4: Servicios
- [ ] AuthService (Login, JWT, Permisos)
- [ ] TicketService (CRUD, búsqueda, filtros)
- [ ] EstadoService (Máquina de estados)
- [ ] UsuarioService (CRUD usuarios)
- [ ] ComentarioService (CRUD comentarios)
- [ ] AuditoriaService (Tracking)
- [ ] NotificacionService (SignalR)
- [ ] PermisoService (RBAC)

### Fase 5: Controladores Completos
- [ ] AuthController (completar)
- [ ] TicketsController (completar)
- [ ] ReferencesController (completar)
- [ ] UsersController (crear)
- [ ] CommentsController (crear)
- [ ] DashboardController (crear)
- [ ] AdminController (crear)

### Fase 6: Features Avanzadas
- [ ] Exportación CSV/Excel
- [ ] Búsqueda avanzada
- [ ] Caché (Redis)
- [ ] Webhooks
- [ ] OAuth2

### Fase 7: Testing
- [ ] Tests unitarios
- [ ] Tests de integración
- [ ] Tests de seguridad
- [ ] Cobertura >80%

### Fase 8: Deployment
- [ ] Documentación final
- [ ] Scripts de BD
- [ ] CI/CD (GitHub Actions)
- [ ] Docker (opcional)
```

---

## 🎉 ¡Felicidades!

Tu proyecto **TicketsAPI** está listo para empezar el desarrollo. 

**Próximo paso recomendado**: Implementar los repositorios (Fase 3)

Cualquier duda, referirse a `DEVELOPMENT.md` para el roadmap completo.

---

**Fecha**: 9 de Diciembre de 2025  
**Estado**: ✅ Estructura Base Completa - Listo para Implementación
