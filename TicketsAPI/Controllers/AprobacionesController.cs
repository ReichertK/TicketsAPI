using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    [ApiController]
    [Route("api/v1")]
    [Authorize]
    public class AprobacionesController : ControllerBase
    {
        private readonly IBaseRepository<Aprobacion> _aprobacionRepository;
        private readonly IBaseRepository<Ticket> _ticketRepository;
        private readonly INotificacionService _notificacionService;
        private readonly ILogger<AprobacionesController> _logger;

        public AprobacionesController(
            IBaseRepository<Aprobacion> aprobacionRepository,
            IBaseRepository<Ticket> ticketRepository,
            INotificacionService notificacionService,
            ILogger<AprobacionesController> logger)
        {
            _aprobacionRepository = aprobacionRepository;
            _ticketRepository = ticketRepository;
            _notificacionService = notificacionService;
            _logger = logger;
        }

        /// <summary>
        /// Obtener aprobaciones pendientes para el usuario actual
        /// </summary>
        [HttpGet("Approvals/Pending")]
        public async Task<ActionResult<List<AprobacionDTO>>> ObtenerAprobacionesPendientes()
        {
            try
            {
                var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
                var aprobaciones = await _aprobacionRepository.GetAllAsync();

                var aprobacionesPendientes = aprobaciones
                    .Where(a => a.Id_Usuario_Aprobador == usuarioId && a.Estado == "Pendiente")
                    .OrderBy(a => a.Fecha_Solicitud)
                    .ToList();

                var dtos = aprobacionesPendientes.Select(a => new AprobacionDTO
                {
                    Id_Aprobacion = a.Id_Aprobacion,
                    Id_Tkt = a.Id_Tkt,
                    Id_Usuario_Solicitante = a.Id_Usuario_Solicitante,
                    Id_Usuario_Aprobador = a.Id_Usuario_Aprobador,
                    Estado = a.Estado,
                    Fecha_Solicitud = a.Fecha_Solicitud,
                    Fecha_Respuesta = a.Fecha_Respuesta
                }).ToList();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener aprobaciones: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener aprobaciones" });
            }
        }

        /// <summary>
        /// Solicitar aprobación para un ticket
        /// </summary>
        [HttpPost("Tickets/{ticketId}/Approvals")]
        public async Task<ActionResult> SolicitarAprobacion(int ticketId, [FromBody] CreateAprobacionDTO dto)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return NotFound(new { message = "Ticket no encontrado" });

                var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");

                var aprobacion = new Aprobacion
                {
                    Id_Tkt = ticketId,
                    Id_Usuario_Solicitante = usuarioId,
                    Id_Usuario_Aprobador = dto.Id_Usuario_Aprobador,
                    Estado = "Pendiente",
                    Fecha_Solicitud = DateTime.Now
                };

                var id = await _aprobacionRepository.CreateAsync(aprobacion);

                // Notificar solicitud de aprobación
                await _notificacionService.SolicitudAprobacionAsync(ticketId, usuarioId, dto.Id_Usuario_Aprobador);

                return CreatedAtAction(nameof(ObtenerAprobacionPorId), new { id }, aprobacion);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al solicitar aprobación: {ex.Message}");
                return StatusCode(500, new { message = "Error al solicitar aprobación" });
            }
        }

        /// <summary>
        /// Obtener aprobación por ID
        /// </summary>
        [HttpGet("Approvals/{id}")]
        public async Task<ActionResult<AprobacionDTO>> ObtenerAprobacionPorId(int id)
        {
            try
            {
                var aprobacion = await _aprobacionRepository.GetByIdAsync(id);
                if (aprobacion == null)
                    return NotFound(new { message = "Aprobación no encontrada" });

                var dto = new AprobacionDTO
                {
                    Id_Aprobacion = aprobacion.Id_Aprobacion,
                    Id_Tkt = aprobacion.Id_Tkt,
                    Id_Usuario_Solicitante = aprobacion.Id_Usuario_Solicitante,
                    Id_Usuario_Aprobador = aprobacion.Id_Usuario_Aprobador,
                    Estado = aprobacion.Estado,
                    Fecha_Solicitud = aprobacion.Fecha_Solicitud,
                    Fecha_Respuesta = aprobacion.Fecha_Respuesta
                };

                return Ok(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener aprobación: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener aprobación" });
            }
        }

        /// <summary>
        /// Responder solicitud de aprobación (aprobar o rechazar)
        /// </summary>
        [HttpPut("Approvals/{id}/Respond")]
        public async Task<ActionResult> ResponderAprobacion(int id, [FromBody] ResponderAprobacionDTO dto)
        {
            try
            {
                var aprobacion = await _aprobacionRepository.GetByIdAsync(id);
                if (aprobacion == null)
                    return NotFound(new { message = "Aprobación no encontrada" });

                var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
                if (aprobacion.Id_Usuario_Aprobador != usuarioId)
                    return Forbid("No tiene permiso para responder esta aprobación");

                aprobacion.Estado = dto.Aprobado ? "Aprobada" : "Rechazada";
                aprobacion.Fecha_Respuesta = DateTime.Now;
                aprobacion.Comentario_Respuesta = dto.Comentario;

                await _aprobacionRepository.UpdateAsync(aprobacion);

                return Ok(new { message = $"Aprobación {(dto.Aprobado ? "aprobada" : "rechazada")} exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al responder aprobación: {ex.Message}");
                return StatusCode(500, new { message = "Error al responder aprobación" });
            }
        }

        /// <summary>
        /// Obtener historial de aprobaciones de un ticket
        /// </summary>
        [HttpGet("Tickets/{ticketId}/Approvals")]
        public async Task<ActionResult<List<AprobacionDTO>>> ObtenerAprobacionesPorTicket(int ticketId)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return NotFound(new { message = "Ticket no encontrado" });

                var aprobaciones = await _aprobacionRepository.GetAllAsync();
                var aprobacionesTicket = aprobaciones
                    .Where(a => a.Id_Tkt == ticketId)
                    .OrderByDescending(a => a.Fecha_Solicitud)
                    .ToList();

                var dtos = aprobacionesTicket.Select(a => new AprobacionDTO
                {
                    Id_Aprobacion = a.Id_Aprobacion,
                    Id_Tkt = a.Id_Tkt,
                    Id_Usuario_Solicitante = a.Id_Usuario_Solicitante,
                    Id_Usuario_Aprobador = a.Id_Usuario_Aprobador,
                    Estado = a.Estado,
                    Fecha_Solicitud = a.Fecha_Solicitud,
                    Fecha_Respuesta = a.Fecha_Respuesta
                }).ToList();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener aprobaciones del ticket: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener aprobaciones del ticket" });
            }
        }
    }
}
