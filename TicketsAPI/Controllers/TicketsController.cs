using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Exceptions;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controlador para gestión de tickets
    /// </summary>
    [Authorize]
    public class TicketsController : BaseApiController
    {
        private readonly ITicketService _ticketService;
        private readonly IEstadoService _estadoService;
        private readonly INotificacionService _notificacionService;
        private readonly ITicketRepository _ticketRepository;
        private readonly IExportService _exportService;

        public TicketsController(
            ILogger<TicketsController> logger,
            ITicketService ticketService,
            IEstadoService estadoService,
            INotificacionService notificacionService,
            ITicketRepository ticketRepository,
            IExportService exportService) : base(logger)
        {
            _ticketService = ticketService;
            _estadoService = estadoService;
            _notificacionService = notificacionService;
            _ticketRepository = ticketRepository;
            _exportService = exportService;
        }

        /// <summary>
        /// Obtener todos los tickets filtrados
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetTickets([FromQuery] TicketFiltroDTO filtro)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                filtro ??= new TicketFiltroDTO();
                filtro.Id_Usuario = userId;

                var result = await _ticketService.GetFilteredAsync(filtro);
                return Success(result, "Tickets obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener tickets");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Búsqueda avanzada de tickets con soporte para búsqueda en comentarios
        /// </summary>
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
                filtro.Id_Usuario = userId;

                var result = await _ticketService.GetFilteredAsync(filtro);
                return Success(result, $"Búsqueda completada: {result.TotalRegistros} tickets encontrados");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en búsqueda avanzada");
                return Error<object>("Error al realizar búsqueda", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener un ticket por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetTicket(int id)
        {
            try
            {
                var ticket = await _ticketService.GetByIdAsync(id);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                return Success(ticket, "Ticket obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener ticket");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Crear un nuevo ticket
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> CreateTicket([FromBody] CreateUpdateTicketDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var userId = GetCurrentUserId();
                var id = await _ticketService.CreateAsync(dto, userId);

                // Notificar en tiempo real
                await _notificacionService.NotificarNuevoTicketAsync(id);

                return Success(new { id }, "Ticket creado exitosamente", 201);
            }
            catch (ValidationException ex)
            {
                _logger.LogWarning(ex, "Validación fallida al crear ticket");
                return Error<object>(ex.Message, statusCode: 400);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear ticket");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Actualizar un ticket
        /// </summary>
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
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Transicionar el estado de un ticket
        /// </summary>
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
                var esSuperAdmin = User.IsInRole("ADMIN") || User.HasClaim("permiso", "TKT_ADMIN");
                
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
                    // Mapear status codes dinámicamente según el mensaje de error de la SP
                    var message = result.Message ?? "Error en la transición de estado";
                    int statusCode = 403;  // Por defecto: permiso denegado
                    
                    if (message.Contains("Ticket no encontrado"))
                        statusCode = 404;
                    else if (message.Contains("Comentario requerido"))
                        statusCode = 400;
                    // Para "Transición no permitida" y "Solo el asignado..." se mantiene 403
                    
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
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Asignar un ticket a un usuario
        /// </summary>
        [HttpPatch("{id}/asignar/{usuarioId}")]
        public async Task<IActionResult> AssignTicket(int id, int usuarioId)
        {
            try
            {
                var result = await _ticketService.AsignarAsync(id, usuarioId);
                if (!result)
                    return Error<object>("Error al asignar el ticket", statusCode: 400);

                await _notificacionService.NotificarActualizacionTicketAsync(id);

                return Success<object>(new { }, "Ticket asignado exitosamente");
            }
            catch (NotFoundException ex)
            {
                _logger.LogWarning(ex, "Ticket no encontrado al asignar");
                return Error<object>(ex.Message, statusCode: 404);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al asignar ticket");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Cerrar un ticket
        /// </summary>
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
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener transiciones de estado permitidas para el ticket actual
        /// </summary>
        [HttpGet("{id}/transiciones-permitidas")]
        public async Task<IActionResult> GetPermittedTransitions(int id)
        {
            try
            {
                var ticket = await _ticketService.GetByIdAsync(id);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                var userRole = GetCurrentUserRole();
                int roleId = 0;
                if (!string.IsNullOrWhiteSpace(userRole))
                {
                    if (!int.TryParse(userRole, out roleId))
                    {
                        // Si el rol viene por nombre (p.ej. "Admin"/"Administrador"),
                        // no forzamos parseo numérico; dejamos roleId=0 (no usado en consulta actual)
                        roleId = 0;
                    }
                }

                var transitions = await _estadoService.GetTransicionesPermitidas(ticket.Id_Estado ?? 1, roleId);
                return Success(transitions, "Transiciones obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener transiciones");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener historial completo de un ticket (transiciones + comentarios)
        /// </summary>
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
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Exportar tickets a CSV
        /// </summary>
        [HttpGet("exportar-csv")]
        public async Task<IActionResult> ExportCsv([FromQuery] TicketFiltroDTO filtro)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                filtro ??= new TicketFiltroDTO();
                filtro.Id_Usuario = userId;

                // Obtener tickets filtrados (sin paginación para exportar todos)
                filtro.TamañoPagina = int.MaxValue; // Obtener todos los resultados
                filtro.Pagina = 1;

                var result = await _ticketService.GetFilteredAsync(filtro);
                
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
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }
    }
}

// NOTA: Agregar using para los servicios cuando estén implementados
