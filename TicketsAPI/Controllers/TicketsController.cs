using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;

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

        public TicketsController(
            ILogger<TicketsController> logger,
            ITicketService ticketService,
            IEstadoService estadoService,
            INotificacionService notificacionService) : base(logger)
        {
            _ticketService = ticketService;
            _estadoService = estadoService;
            _notificacionService = notificacionService;
        }

        /// <summary>
        /// Obtener todos los tickets filtrados
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetTickets([FromQuery] TicketFiltroDTO filtro)
        {
            try
            {
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

                var result = await _ticketService.UpdateAsync(id, dto);
                if (!result)
                    return Error<object>("Error al actualizar el ticket", statusCode: 400);

                // Notificar en tiempo real
                await _notificacionService.NotificarActualizacionTicketAsync(id);

                return Success<object>(new { }, "Ticket actualizado exitosamente");
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
                var result = await _ticketService.TransicionarEstadoAsync(id, dto, userId);
                
                if (!result)
                    return Error<object>("No tiene permiso para realizar esta transición", statusCode: 403);

                // Notificar en tiempo real
                var ticket = await _ticketService.GetByIdAsync(id);
                if (ticket != null)
                {
                    await _notificacionService.NotificarTransicionEstadoAsync(id, ticket.Estado?.Nombre_Estado ?? "");
                }

                return Success<object>(new { }, "Estado actualizado exitosamente");
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
                var roleId = int.Parse(userRole ?? "0");

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
        /// Exportar tickets a CSV
        /// </summary>
        [HttpGet("exportar-csv")]
        public async Task<IActionResult> ExportCsv([FromQuery] TicketFiltroDTO filtro)
        {
            try
            {
                // TODO: Implementar exportación a CSV
                return Error<object>("Funcionalidad en desarrollo", statusCode: 501);
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
