# 📋 CHEATSHEET - TicketsAPI

Referencia rápida de comandos y patrones usados en TicketsAPI.

## 🛠️ Comandos Básicos

```bash
# Restaurar dependencias
dotnet restore

# Compilar proyecto
dotnet build

# Ejecutar en desarrollo
dotnet run

# Ejecutar con watch (auto-reload)
dotnet watch run

# Publicar para producción
dotnet publish -c Release -o ./publish

# Ejecutar tests
dotnet test

# Agregar nueva dependencia
dotnet add package NombrePaquete

# Crear nuevo controlador
dotnet new controller -n NombreController -o Controllers
```

## 📁 Estructura de Carpetas

```
TicketsAPI/
├── Controllers/       → API endpoints
├── Services/          → Lógica de negocio
│   └── Interfaces/
├── Repositories/      → Acceso a datos
│   └── Interfaces/
├── Models/
│   ├── Entities.cs    → Modelos de BD
│   └── DTOs.cs        → Objetos de transferencia
├── Config/            → Configuración
├── Middleware/        → Procesamiento de requests
├── Utilities/         → Helpers
├── Program.cs         → Punto de entrada
└── appsettings.json   → Configuración
```

## 🔐 JWT Claims

```json
{
  "sub": "1",
  "email": "user@empresa.com",
  "name": "Juan",
  "role": "2",
  "role_name": "Técnico",
  "permissions": ["tickets.crear", "tickets.editar"],
  "iat": 1707000000,
  "exp": 1707003600,
  "iss": "TicketsAPI",
  "aud": "TicketsClients"
}
```

Extracción:
```csharp
int userId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
string role = User.FindFirst("role")?.Value;
```

## 📊 DTOs Principales

```csharp
// Login
POST /api/v1/auth/login
→ LoginRequest { usuario, contraseña }
← LoginResponse { token, refreshToken, rol, permisos }

// Crear Ticket
POST /api/v1/tickets
→ CreateUpdateTicketDTO
← ApiResponse<{ id }>

// Listar Tickets
GET /api/v1/tickets?filtros
← PaginatedResponse<TicketDTO>

// Cambiar Estado
PATCH /api/v1/tickets/{id}/cambiar-estado
→ TransicionEstadoDTO { id_estado_nuevo, motivo }
← ApiResponse<{}>
```

## 🔧 Respuestas de API

```csharp
// Exitosa
{
  "exitoso": true,
  "mensaje": "Operación exitosa",
  "datos": { ... }
}

// Error
{
  "exitoso": false,
  "mensaje": "Descripción del error",
  "datos": null,
  "errores": ["Error 1", "Error 2"]
}
```

## 🛡️ Patrones de Seguridad

```csharp
// 1. Validar autenticación
[Authorize]
public class ProtectedController : ControllerBase { }

// 2. Validar permiso específico
[Authorize(Policy = "CanCreateTickets")]
public IActionResult CreateTicket() { }

// 3. Validar en el servicio
public async Task<bool> CanDeleteAsync(int userId, int ticketId)
{
    var permissions = await _permisoService.GetPermisosAsync(userId);
    return permissions.Contains("tickets.eliminar");
}
```

## 📦 Dependency Injection

```csharp
// En Program.cs
builder.Services.AddScoped<ITicketRepository, TicketRepository>();
builder.Services.AddScoped<ITicketService, TicketService>();
builder.Services.AddSingleton<IConfiguration>(configuration);

// En Controlador
public class TicketsController : ControllerBase
{
    private readonly ITicketService _service;
    
    public TicketsController(ITicketService service)
    {
        _service = service;
    }
}
```

## 🔄 Patrones Async/Await

```csharp
// Siempre usar async en repositorios/servicios
public async Task<TicketDTO?> GetByIdAsync(int id)
{
    try
    {
        using var connection = new MySqlConnection(_connectionString);
        await connection.OpenAsync();
        
        var ticket = await connection.QuerySingleOrDefaultAsync<Ticket>(
            "SELECT * FROM tickets WHERE id_ticket = @id",
            new { id }
        );
        
        return _mapper.Map<TicketDTO>(ticket);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error al obtener ticket {id}", id);
        throw;
    }
}
```

## 💾 Dapper Básico

```csharp
using Dapper;

// SELECT
var ticket = await connection.QuerySingleOrDefaultAsync<Ticket>(
    "SELECT * FROM tickets WHERE id_ticket = @id",
    new { id }
);

// INSERT
await connection.ExecuteAsync(
    "INSERT INTO tickets (titulo, descripcion) VALUES (@titulo, @descripcion)",
    new { titulo, descripcion }
);

// UPDATE
await connection.ExecuteAsync(
    "UPDATE tickets SET titulo = @titulo WHERE id_ticket = @id",
    new { titulo, id }
);

// DELETE
await connection.ExecuteAsync(
    "DELETE FROM tickets WHERE id_ticket = @id",
    new { id }
);

// Stored Procedure
await connection.ExecuteAsync(
    "sp_crear_ticket",
    new { titulo, descripcion },
    commandType: CommandType.StoredProcedure
);
```

## 📝 Logging

```csharp
private readonly ILogger<ClassName> _logger;

// Information
_logger.LogInformation("Ticket {id} creado por usuario {userId}", id, userId);

// Warning
_logger.LogWarning("Transición no permitida de {origen} a {destino}", origen, destino);

// Error
_logger.LogError(ex, "Error al procesar ticket {id}", id);

// Debug
_logger.LogDebug("Debug info: {details}", details);
```

## 🎯 Validación de DTOs

```csharp
// En DTO
public class CreateUpdateTicketDTO
{
    [Required(ErrorMessage = "El título es requerido")]
    [StringLength(200, MinimumLength = 5)]
    public string Titulo { get; set; }
    
    [Required]
    [Range(1, 4)]
    public int Id_Prioridad { get; set; }
}

// En Controlador
[HttpPost]
public IActionResult Create([FromBody] CreateUpdateTicketDTO dto)
{
    if (!ModelState.IsValid)
        return BadRequest(ModelState);
    
    // Procesar...
}
```

## 🔔 SignalR Básico

```javascript
// Cliente JS
const connection = new signalR.HubConnectionBuilder()
    .withUrl('/hubs/tickets', {
        accessTokenFactory: () => getToken()
    })
    .withAutomaticReconnect()
    .build();

connection.on('NuevoTicket', ticket => {
    console.log('Nuevo ticket:', ticket);
});

await connection.start();

// Suscribirse
await connection.invoke('SubscribeToTicket', ticketId);

// C# - Server
public class TicketHub : Hub
{
    public async Task SubscribeToTicket(int ticketId)
    {
        await Groups.AddToGroupAsync(
            Context.ConnectionId,
            $"ticket-{ticketId}"
        );
    }
    
    public async Task NotifyUpdate(int ticketId, object data)
    {
        await Clients
            .Group($"ticket-{ticketId}")
            .SendAsync("TicketActualizado", data);
    }
}
```

## 🎨 Patrones de Respuesta

```csharp
// Controlador
protected IActionResult Success<T>(T data, string msg = "Exitoso")
{
    return StatusCode(200, new ApiResponse<T>
    {
        Exitoso = true,
        Mensaje = msg,
        Datos = data
    });
}

protected IActionResult Error<T>(string msg, int statusCode = 400)
{
    return StatusCode(statusCode, new ApiResponse<T>
    {
        Exitoso = false,
        Mensaje = msg
    });
}

// Uso
public async Task<IActionResult> GetTicket(int id)
{
    var ticket = await _service.GetByIdAsync(id);
    if (ticket == null)
        return Error<object>("Ticket no encontrado", 404);
    
    return Success(ticket, "Ticket obtenido");
}
```

## 🧪 Testing Patterns

```csharp
[TestClass]
public class TicketServiceTests
{
    private Mock<ITicketRepository> _mockRepo;
    private TicketService _service;
    
    [TestInitialize]
    public void Setup()
    {
        _mockRepo = new Mock<ITicketRepository>();
        _service = new TicketService(_mockRepo.Object);
    }
    
    [TestMethod]
    public async Task GetById_WithValidId_ReturnsTicket()
    {
        // Arrange
        var ticketId = 1;
        var expectedTicket = new TicketDTO { Id_Ticket = 1 };
        _mockRepo
            .Setup(r => r.GetByIdAsync(ticketId))
            .ReturnsAsync(expectedTicket);
        
        // Act
        var result = await _service.GetByIdAsync(ticketId);
        
        // Assert
        Assert.IsNotNull(result);
        Assert.AreEqual(expectedTicket.Id_Ticket, result.Id_Ticket);
    }
}
```

## 🚀 Deployment Checklist

```markdown
□ Cambiar JwtSettings.SecretKey
□ Configurar ConnectionString correcta
□ Compilar en Release mode
□ Verificar logs están correctos
□ Probar health check
□ Validar CORS origins
□ Configurar SSL/HTTPS
□ Backup de base de datos
□ Tests pasando 100%
□ Performance testing
□ Documentar variables de entorno
```

## 💡 Tips Útiles

1. **Siempre usar async/await**: No bloquear threads
2. **Usar using statements**: Para disposed resources
3. **Logging importante**: INFO, WARNING, ERROR
4. **DTOs para API**: Nunca enviar entidades directamente
5. **Validación en DTOs**: DataAnnotations + FluentValidation
6. **Manejo de excepciones**: Try-catch en servicios
7. **Queries parametrizadas**: Siempre contra SQL Injection
8. **RBAC en 3 capas**: Controller → Service → Database

---

**Última Actualización**: 9 de Diciembre de 2025
