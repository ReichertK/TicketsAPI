using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using System.Text;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Exceptions;
using TicketsAPI.Config;

namespace TicketsAPI.Controllers
{
    /// Controlador para gestión de tickets
    [Authorize]
    public class TicketsController : BaseApiController
    {
        private readonly ITicketService _ticketService;
        private readonly IEstadoService _estadoService;
        private readonly INotificacionService _notificacionService;
        private readonly ITicketRepository _ticketRepository;
        private readonly IExportService _exportService;
        private readonly INotificacionLecturaRepository _notificacionLecturaRepo;
        private readonly IAuthService _authService;
        private readonly string _connectionString;

        public TicketsController(
            ILogger<TicketsController> logger,
            IConfiguration configuration,
            ITicketService ticketService,
            IEstadoService estadoService,
            INotificacionService notificacionService,
            ITicketRepository ticketRepository,
            IExportService exportService,
            INotificacionLecturaRepository notificacionLecturaRepo,
            IAuthService authService) : base(logger)
        {
            _ticketService = ticketService;
            _estadoService = estadoService;
            _notificacionService = notificacionService;
            _ticketRepository = ticketRepository;
            _exportService = exportService;
            _notificacionLecturaRepo = notificacionLecturaRepo;
            _authService = authService;
            _connectionString = configuration.GetConnectionString("DbTkt")
                ?? configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("ConnectionString no configurada.");
        }

        /// Obtener todos los tickets filtrados
        [HttpGet]
        public async Task<IActionResult> GetTickets([FromQuery] TicketFiltroDTO filtro)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                filtro ??= new TicketFiltroDTO();

                // La visibilidad se aplica en el servicio según permisos (TKT_LIST_ALL)
                var result = await _ticketService.GetFilteredAsync(filtro, userId);
                return Success(result, "Tickets obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener tickets");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Búsqueda avanzada de tickets con soporte para búsqueda en comentarios
        /// <param name="filtro">Filtros de búsqueda avanzada</param>
        /// <returns>Lista paginada de tickets</returns>
        /// <remarks>
        /// Opciones de búsqueda avanzada:
        /// - BuscarEnComentarios: Buscar también en el contenido de comentarios
        /// - BuscarEnContenido: Buscar en el contenido del ticket (default: true)
        /// - TipoBusqueda: "contiene" (default), "exacta", "comienza", "termina"
        /// 
        /// Ejemplo:
        /// GET /api/v1/Tickets/buscar?Busqueda=error&amp;BuscarEnComentarios=true&amp;TipoBusqueda=contiene
        /// </remarks>
        [HttpGet("buscar")]
        [ProducesResponseType(typeof(ApiResponse<PaginatedResponse<TicketDTO>>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 500)]
        public async Task<IActionResult> BuscarAvanzado([FromQuery] TicketFiltroDTO filtro)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                filtro ??= new TicketFiltroDTO();

                // La visibilidad se aplica en el servicio según permisos (TKT_LIST_ALL)
                var result = await _ticketService.GetFilteredAsync(filtro, userId);
                return Success(result, $"Búsqueda completada: {result.TotalRegistros} tickets encontrados");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en búsqueda avanzada");
                return Error<object>("Error al realizar búsqueda", statusCode: 500);
            }
        }

        /// Obtener un ticket por ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetTicket(int id)
        {
            try
            {
                var userId = GetCurrentUserId();
                var ticket = await _ticketService.GetByIdAsync(id);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                // Auto-marcar como leído al abrir el ticket
                if (userId > 0)
                {
                    try { await _notificacionLecturaRepo.MarcarLeidoAsync(id, userId); }
                    catch (Exception ex) { _logger.LogWarning(ex, "No se pudo marcar notificación como leída para ticket {Id}", id); }
                }

                return Success(ticket, "Ticket obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Crear un nuevo ticket
        [HttpPost]
        public async Task<IActionResult> CreateTicket([FromBody] CreateUpdateTicketDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var userId = GetCurrentUserId();
                var id = await _ticketService.CreateAsync(dto, userId);

                // Notificar en tiempo real (con userId para filtrar al creador)
                await _notificacionService.NotificarNuevoTicketAsync(id, userId);

                return Success(new { id }, "Ticket creado exitosamente", 201);
            }
            catch (ValidationException ex)
            {
                _logger.LogWarning(ex, "Validación fallida al crear ticket");
                return Error<object>(ex.Message, statusCode: 400);
            }
            catch (UnauthorizedException ex)
            {
                _logger.LogWarning(ex, "Permiso denegado al crear ticket");
                return Error<object>(ex.Message, statusCode: 403);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Actualizar un ticket
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTicket(int id, [FromBody] CreateUpdateTicketDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                    var userId = GetCurrentUserId();
                    if (userId <= 0)
                        return Unauthorized(new { message = "Usuario no autenticado" });

                    var result = await _ticketService.UpdateAsync(id, dto, userId);

                // Notificar en tiempo real
                await _notificacionService.NotificarActualizacionTicketAsync(id);

                return Success<object>(new { }, "Ticket actualizado exitosamente");
            }
                catch (NotFoundException ex)
                {
                    _logger.LogWarning(ex, "Ticket no encontrado al actualizar");
                    return Error<object>(ex.Message, statusCode: 404);
                }
                catch (UnauthorizedException ex)
                {
                    _logger.LogWarning(ex, "Permiso denegado al actualizar ticket");
                    return Error<object>(ex.Message, statusCode: 403);
                }
            catch (ValidationException ex)
            {
                _logger.LogWarning(ex, "Validación fallida al actualizar ticket");
                return Error<object>(ex.Message, statusCode: 400);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Eliminar un ticket (Admin)
        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> DeleteTicket(int id)
        {
            try
            {
                var deleted = await _ticketRepository.DeleteAsync(id);
                if (!deleted)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                return Success<object>(new { }, "Ticket eliminado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Transicionar el estado de un ticket
        [HttpPatch("{id}/cambiar-estado")]
        public async Task<IActionResult> ChangeTicketStatus(int id, [FromBody] TransicionEstadoDTO dto)
        {
            try
            {
                var userId = GetCurrentUserId();
                
                // Validar que el usuario esté autenticado correctamente
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });
                
                // Verificar si es super admin (TKT_ADMIN o similar)
                var esSuperAdmin = User.IsInRole("ADMIN") || User.IsInRole("Administrador") || User.HasClaim("permiso", "TKT_ADMIN");
                
                // Llamar directamente a sp_tkt_transicionar para validación de permisos
                var result = await _ticketRepository.TransicionarEstadoViaStoredProcedureAsync(
                    idTkt: id,
                    estadoTo: dto.Id_Estado_Nuevo,
                    idUsuarioActor: userId,
                    comentario: dto.Comentario,
                    motivo: dto.Motivo,
                    idAsignadoNuevo: dto.Id_Usuario_Asignado_Nuevo,
                    metaJson: null,
                    esSuperAdmin: esSuperAdmin);
                
                if (result.Success != 1)
                {
                    // Mapear status codes según el mensaje de error de SIGNAL/SP
                    var message = result.Message ?? "Error en la transición de estado";
                    int statusCode = message switch
                    {
                        var m when m.Contains("no encontrado") => 404,
                        var m when m.Contains("comentario", StringComparison.OrdinalIgnoreCase) => 400,
                        var m when m.Contains("ya se encuentra") => 409,
                        var m when m.Contains("no valido") || m.Contains("no válido") => 400,
                        _ => 403  // Permiso denegado, transición no permitida, etc.
                    };
                    
                    return Error<object>(message, statusCode: statusCode);
                }

                // Notificar en tiempo real sobre el cambio de estado
                // SP retorna nuevo_estado como INT, pero se convierte a string en DTO
                var nuevoEstadoNombre = result.NuevoEstado?.ToString() ?? "";
                if (!string.IsNullOrEmpty(nuevoEstadoNombre))
                {
                    await _notificacionService.NotificarTransicionEstadoAsync(id, nuevoEstadoNombre);
                }

                return Success<object>(new { nuevoEstado = result.NuevoEstado, idAsignado = result.IdAsignado }, 
                    "Estado actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cambiar estado del ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Asignar un ticket a un usuario.
        /// Auto-asignación: PATCH /tickets/{id}/asignar (body vacío o {Id_Usuario_Asignado: self})
        /// Asignación a tercero: PATCH /tickets/{id}/asignar (body con Id_Usuario_Asignado y Comentario opcional)
        /// Reasignación (Admin): requiere Comentario obligatorio (validado por SP).
        [HttpPatch("{id}/asignar")]
        public async Task<IActionResult> AssignTicket(int id, [FromBody] AsignarTicketDTO? dto)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                if (currentUserId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                // Si no se envía body o Id_Usuario_Asignado es 0, se trata de auto-asignación
                var idUsuarioAsignado = (dto?.Id_Usuario_Asignado > 0) ? dto!.Id_Usuario_Asignado : currentUserId;

                // Auto-asignación permitida sin permiso especial; asignar a otro requiere TKT_ASSIGN
                if (idUsuarioAsignado != currentUserId)
                {
                    var tienePermiso = await _authService.ValidarPermisoAsync(currentUserId, "TKT_ASSIGN");
                    if (!tienePermiso)
                        return Error<object>("No tiene permiso para asignar tickets a otros usuarios", statusCode: 403);
                }

                var result = await _ticketService.AsignarAsync(id, idUsuarioAsignado, currentUserId, dto?.Comentario);
                if (!result)
                    return Error<object>("Error al asignar el ticket", statusCode: 400);

                // Broadcast genérico para refrescar listas
                await _notificacionService.NotificarActualizacionTicketAsync(id);

                // Notificación dirigida al usuario asignado (si no es auto-asignación)
                if (idUsuarioAsignado != currentUserId)
                {
                    var mensaje = $"Te asignaron el ticket #{id}";

                    // Persistir alerta en notificacion_alerta
                    try
                    {
                        using var conn = new MySqlConnection(_connectionString);
                        await conn.ExecuteAsync(
                            "INSERT INTO notificacion_alerta (id_usuario, tipo, id_ticket, mensaje) VALUES (@uid, 'asignacion', @tid, @msg)",
                            new { uid = idUsuarioAsignado, tid = id, msg = mensaje });
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "No se pudo persistir la alerta de asignación para usuario {UserId}", idUsuarioAsignado);
                    }

                    // Enviar notificación SignalR al usuario asignado
                    await _notificacionService.AsignacionTicketAsync(idUsuarioAsignado, id, mensaje);
                }

                return Success<object>(new { }, "Ticket asignado exitosamente");
            }
            catch (NotFoundException ex)
            {
                _logger.LogWarning(ex, "Ticket no encontrado al asignar");
                return Error<object>(ex.Message, statusCode: 404);
            }
            catch (ValidationException ex)
            {
                _logger.LogWarning(ex, "Error de validación al asignar ticket");
                return Error<object>(ex.Message, statusCode: 400);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al asignar ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Cerrar un ticket
        [HttpPatch("{id}/cerrar")]
        public async Task<IActionResult> CloseTicket(int id)
        {
            try
            {
                var userId = GetCurrentUserId();
                var result = await _ticketService.CloseAsync(id, userId);
                
                if (!result)
                    return Error<object>("Error al cerrar el ticket", statusCode: 400);

                await _notificacionService.NotificarActualizacionTicketAsync(id);

                return Success<object>(new { }, "Ticket cerrado exitosamente");
            }
            catch (NotFoundException ex)
            {
                _logger.LogWarning(ex, "Ticket no encontrado al cerrar");
                return Error<object>(ex.Message, statusCode: 404);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cerrar ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener transiciones de estado permitidas para el ticket actual.
        /// Incluye metadata de permisos (requiere_propietario, permiso_requerido, requiere_aprobacion).
        /// Si el usuario es admin, devuelve todas las transiciones.
        /// Si requiere_propietario=true, solo se incluye si el usuario es el asignado.
        [HttpGet("{id}/transiciones-permitidas")]
        public async Task<IActionResult> GetPermittedTransitions(int id)
        {
            try
            {
                var ticket = await _ticketService.GetByIdAsync(id);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                var userId = GetCurrentUserId();
                var esSuperAdmin = User.IsInRole("ADMIN") || User.IsInRole("Administrador") || User.HasClaim("permiso", "TKT_ADMIN");

                var userRole = GetCurrentUserRole();
                int roleId = 0;
                if (!string.IsNullOrWhiteSpace(userRole))
                    int.TryParse(userRole, out roleId);

                var transitions = await _estadoService.GetTransicionesPermitidas(ticket.Id_Estado ?? 1, roleId);

                // Filtrar: si requiere_propietario y el usuario NO es el asignado ni admin, excluir
                if (!esSuperAdmin)
                {
                    var isAssigned = ticket.Id_Usuario_Asignado == userId;
                    transitions = transitions
                        .Where(t => !t.Requiere_Propietario || isAssigned)
                        .ToList();
                }

                return Success(transitions, "Transiciones obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener transiciones");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener historial completo de un ticket (transiciones + comentarios)
        [HttpGet("{id}/historial")]
        public async Task<IActionResult> GetHistorial(int id)
        {
            try
            {
                var ticket = await _ticketService.GetByIdAsync(id);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                // Obtener historial usando sp_tkt_historial
                var historial = await _ticketRepository.GetHistorialViaStoredProcedureAsync(id);

                return Success(historial, "Historial obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener historial del ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener historial de transiciones paginado de un ticket.
        /// GET /api/v1/Tickets/{id}/Historial-Transiciones?pagina=1&amp;porPagina=10
        [HttpGet("{id}/Historial-Transiciones")]
        public async Task<IActionResult> GetHistorialTransiciones(int id, [FromQuery] int pagina = 1, [FromQuery] int porPagina = 10)
        {
            try
            {
                var ticket = await _ticketService.GetByIdAsync(id);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                if (pagina < 1) pagina = 1;
                if (porPagina < 1) porPagina = 10;
                if (porPagina > 100) porPagina = 100;

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                // Count
                var total = await conn.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM tkt_transicion WHERE id_tkt = @Id", new { Id = id });

                // Paginated data with JOIN to get names
                var offset = (pagina - 1) * porPagina;
                var sql = @"
                    SELECT 
                        t.id_transicion   AS IdTransicion,
                        t.id_tkt          AS IdTkt,
                        t.estado_from     AS EstadoFromId,
                        ef.TipoEstado     AS EstadoFromNombre,
                        t.estado_to       AS EstadoToId,
                        et.TipoEstado     AS EstadoToNombre,
                        t.id_usuario_actor        AS UsuarioActorId,
                        ua.nombre                 AS UsuarioActorNombre,
                        t.id_usuario_asignado_old AS UsuarioAsignadoOldId,
                        t.id_usuario_asignado_new AS UsuarioAsignadoNewId,
                        t.comentario      AS Comentario,
                        t.motivo          AS Motivo,
                        t.fecha           AS Fecha
                    FROM tkt_transicion t
                    LEFT JOIN estado ef ON ef.Id_Estado = t.estado_from
                    LEFT JOIN estado et ON et.Id_Estado = t.estado_to
                    LEFT JOIN usuario ua ON ua.idUsuario = t.id_usuario_actor
                    WHERE t.id_tkt = @Id
                    ORDER BY t.fecha DESC, t.id_transicion DESC
                    LIMIT @Limit OFFSET @Offset";

                var items = (await conn.QueryAsync<TransicionHistorialDTO>(
                    sql, new { Id = id, Limit = porPagina, Offset = offset })).ToList();

                var totalPages = (int)Math.Ceiling((double)total / porPagina);

                return Success(new PaginatedResponse<TransicionHistorialDTO>
                {
                    Datos = items,
                    TotalRegistros = total,
                    PaginaActual = pagina,
                    TamañoPagina = porPagina,
                    TotalPaginas = totalPages,
                    TienePaginaAnterior = pagina > 1,
                    TienePaginaSiguiente = pagina < totalPages
                }, "Historial de transiciones obtenido");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener historial de transiciones del ticket {Id}", id);
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        // Suscripciones

        /// Suscribirse a un ticket (seguir)
        [HttpPost("{id}/suscribir")]
        public async Task<IActionResult> Suscribir(int id)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                var result = await _ticketRepository.GestionarSuscripcionAsync(id, userId, "suscribir");

                if (result.Success != 1)
                    return Error<object>(result.Message ?? "Error al suscribirse", statusCode: 400);

                return Success(new { total = result.Total }, result.Message ?? "Suscrito exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al suscribirse al ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Desuscribirse de un ticket (dejar de seguir)
        [HttpDelete("{id}/suscribir")]
        public async Task<IActionResult> Desuscribir(int id)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                var result = await _ticketRepository.GestionarSuscripcionAsync(id, userId, "desuscribir");

                if (result.Success != 1)
                    return Error<object>(result.Message ?? "Error al desuscribirse", statusCode: 400);

                return Success(new { total = result.Total }, result.Message ?? "Desuscrito exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al desuscribirse del ticket");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener suscriptores de un ticket + si el usuario actual está suscrito
        [HttpGet("{id}/suscriptores")]
        public async Task<IActionResult> GetSuscriptores(int id)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                var suscriptores = await _ticketRepository.GetSuscriptoresAsync(id);
                var estaSuscrito = await _ticketRepository.EstaSuscritoAsync(id, userId);

                return Success(new { suscriptores, estaSuscrito, total = suscriptores.Count },
                    "Suscriptores obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener suscriptores");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Exportar tickets a CSV
        [HttpGet("exportar-csv")]
        public async Task<IActionResult> ExportCsv([FromQuery] TicketFiltroDTO filtro)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                filtro ??= new TicketFiltroDTO();

                // La visibilidad se aplica en el servicio según permisos (TKT_LIST_ALL)
                // Obtener tickets filtrados (sin paginación para exportar todos)
                filtro.TamañoPagina = int.MaxValue; // Obtener todos los resultados
                filtro.Pagina = 1;

                var result = await _ticketService.GetFilteredAsync(filtro, userId);
                
                if (result.Datos == null || !result.Datos.Any())
                    return Error<object>("No hay tickets para exportar", statusCode: 404);

                // Generar CSV
                var csvContent = await _exportService.ExportTicketsToCsvAsync(result.Datos);

                // Retornar archivo
                var fileName = $"tickets_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                var bytes = Encoding.UTF8.GetBytes(csvContent);

                return File(bytes, "text/csv", fileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al exportar CSV");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Obtener estadísticas rápidas de tickets para el mini-dashboard.
        /// GET /api/v1/Tickets/stats?idEstado=1&idPrioridad=2&idDepartamento=3&busqueda=test
        /// RBAC: filtrado automático por rol del usuario.
        [HttpGet("stats")]
        public async Task<IActionResult> GetTicketStats(
            [FromQuery] int? idEstado = null,
            [FromQuery] int? idPrioridad = null,
            [FromQuery] int? idDepartamento = null,
            [FromQuery] string? busqueda = null)
        {
            try
            {
                var userId = GetCurrentUserId();
                var role = GetCurrentUserRole();
                var esAdmin = string.Equals(role, "Administrador", StringComparison.OrdinalIgnoreCase) ? 1 : 0;

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var parameters = new DynamicParameters();
                parameters.Add("p_id_usuario", userId);
                parameters.Add("p_es_admin", esAdmin);
                parameters.Add("p_id_estado", idEstado);
                parameters.Add("p_id_prioridad", idPrioridad);
                parameters.Add("p_id_departamento", idDepartamento);
                parameters.Add("p_busqueda", string.IsNullOrWhiteSpace(busqueda) ? null : busqueda.Trim());

                var stats = await conn.QueryFirstOrDefaultAsync<TicketStatsDTO>(
                    "sp_ticket_stats", parameters, commandType: System.Data.CommandType.StoredProcedure);

                return Success(stats ?? new TicketStatsDTO(), "Estadísticas obtenidas");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener estadísticas de tickets");
                return Error<object>("Error al obtener estadísticas", statusCode: 500);
            }
        }
    }
}
