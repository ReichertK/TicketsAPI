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
    public class AprobacionesController : BaseApiController
    {
        private readonly IBaseRepository<Aprobacion> _aprobacionRepository;
        private readonly IBaseRepository<Ticket> _ticketRepository;
        private readonly INotificacionService _notificacionService;

        public AprobacionesController(
            IBaseRepository<Aprobacion> aprobacionRepository,
            IBaseRepository<Ticket> ticketRepository,
            INotificacionService notificacionService,
            ILogger<AprobacionesController> logger) : base(logger)
        {
            _aprobacionRepository = aprobacionRepository;
            _ticketRepository = ticketRepository;
            _notificacionService = notificacionService;
        }

        /// <summary>
        /// Obtener aprobaciones pendientes para el usuario actual
        /// </summary>
        [HttpGet("Approvals/Pending")]
        public async Task<IActionResult> ObtenerAprobacionesPendientes()
        {
            try
            {
                var usuarioId = GetCurrentUserId();
                if (usuarioId <= 0)
                    return Error<object>("Usuario no autenticado", statusCode: 401);

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

                return Success(dtos, "Aprobaciones pendientes obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener aprobaciones");
                return Error<object>("Error al obtener aprobaciones", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Solicitar aprobación para un ticket
        /// </summary>
        [HttpPost("Tickets/{ticketId}/Approvals")]
        public async Task<IActionResult> SolicitarAprobacion(int ticketId, [FromBody] CreateAprobacionDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

                var usuarioId = GetCurrentUserId();
                if (usuarioId <= 0)
                    return Error<object>("Usuario no autenticado", statusCode: 401);

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

                return Success(aprobacion, "Aprobación solicitada exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al solicitar aprobación");
                return Error<object>("Error al solicitar aprobación", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener aprobación por ID
        /// </summary>
        [HttpGet("Approvals/{id}")]
        public async Task<IActionResult> ObtenerAprobacionPorId(int id)
        {
            try
            {
                var aprobacion = await _aprobacionRepository.GetByIdAsync(id);
                if (aprobacion == null)
                    return Error<object>("Aprobación no encontrada", statusCode: 404);

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

                return Success(dto, "Aprobación obtenida exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener aprobación");
                return Error<object>("Error al obtener aprobación", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Responder solicitud de aprobación (aprobar o rechazar)
        /// </summary>
        [HttpPut("Approvals/{id}/Respond")]
        public async Task<IActionResult> ResponderAprobacion(int id, [FromBody] ResponderAprobacionDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var aprobacion = await _aprobacionRepository.GetByIdAsync(id);
                if (aprobacion == null)
                    return Error<object>("Aprobación no encontrada", statusCode: 404);

                var usuarioId = GetCurrentUserId();
                if (usuarioId <= 0)
                    return Error<object>("Usuario no autenticado", statusCode: 401);
                if (aprobacion.Id_Usuario_Aprobador != usuarioId)
                    return Error<object>("No tiene permiso para responder esta aprobación", statusCode: 403);

                aprobacion.Estado = dto.Aprobado ? "Aprobada" : "Rechazada";
                aprobacion.Fecha_Respuesta = DateTime.Now;
                aprobacion.Comentario_Respuesta = dto.Comentario;

                await _aprobacionRepository.UpdateAsync(aprobacion);

                return Success<object>(new { }, $"Aprobación {(dto.Aprobado ? "aprobada" : "rechazada")} exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al responder aprobación");
                return Error<object>("Error al responder aprobación", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener historial de aprobaciones de un ticket
        /// </summary>
        [HttpGet("Tickets/{ticketId}/Approvals")]
        public async Task<IActionResult> ObtenerAprobacionesPorTicket(int ticketId)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

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

                return Success(dtos, "Aprobaciones obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener aprobaciones del ticket");
                return Error<object>("Error al obtener aprobaciones del ticket", new List<string> { ex.Message }, 500);
            }
        }
    }
}
