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
    public class TransicionesController : ControllerBase
    {
        private readonly IBaseRepository<Transicion> _transicionRepository;
        private readonly IBaseRepository<Ticket> _ticketRepository;
        private readonly INotificacionService _notificacionService;
        private readonly ITicketService _ticketService;
        private readonly ILogger<TransicionesController> _logger;

        public TransicionesController(
            IBaseRepository<Transicion> transicionRepository,
            IBaseRepository<Ticket> ticketRepository,
            INotificacionService notificacionService,
            ITicketService ticketService,
            ILogger<TransicionesController> logger)
        {
            _transicionRepository = transicionRepository;
            _ticketRepository = ticketRepository;
            _notificacionService = notificacionService;
            _ticketService = ticketService;
            _logger = logger;
        }

        /// <summary>
        /// Obtener historial de transiciones de un ticket
        /// </summary>
        [HttpGet("Tickets/{ticketId}/Transitions")]
        public async Task<ActionResult<List<TransicionDTO>>> ObtenerTransicionesPorTicket(int ticketId)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return NotFound(new { message = "Ticket no encontrado" });

                var transiciones = await _transicionRepository.GetAllAsync();
                var transicionesTicket = transiciones
                    .Where(t => t.Id_Tkt == ticketId)
                    .OrderBy(t => t.Fecha)
                    .ToList();

                var dtos = transicionesTicket.Select(t => new TransicionDTO
                {
                    Id_Transicion = t.Id_Transicion,
                    Id_Tkt = t.Id_Tkt,
                    Id_Estado_Anterior = t.Id_Estado_Anterior,
                    Id_Estado_Nuevo = t.Id_Estado_Nuevo,
                    Id_Usuario = t.Id_Usuario,
                    Comentario = t.Comentario,
                    Fecha = t.Fecha
                }).ToList();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener transiciones: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener transiciones" });
            }
        }

        /// <summary>
        /// Realizar transición de estado en un ticket
        /// </summary>
        [HttpPost("Tickets/{ticketId}/Transition")]
        public async Task<ActionResult> RealizarTransicion(int ticketId, [FromBody] TransicionEstadoDTO dto)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return NotFound(new { message = "Ticket no encontrado" });

                var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");

                // Crear DTO para transición
                var transicionDto = new TransicionEstadoDTO
                {
                    Id_Estado_Nuevo = dto.Id_Estado_Nuevo,
                    Comentario = dto.Comentario
                };

                // Llamar al servicio de tickets para manejar la transición
                await _ticketService.TransicionarEstadoAsync(ticketId, transicionDto, usuarioId);

                // Crear registro de transición
                var transicion = new Transicion
                {
                    Id_Tkt = ticketId,
                    Id_Estado_Anterior = ticket.Id_Estado ?? 1,
                    Id_Estado_Nuevo = dto.Id_Estado_Nuevo,
                    Id_Usuario = usuarioId,
                    Comentario = dto.Comentario,
                    Fecha = DateTime.Now
                };

                var id = await _transicionRepository.CreateAsync(transicion);

                // Notificar transición de estado
                await _notificacionService.TransicionEstadoAsync(ticketId, usuarioId, dto.Id_Estado_Nuevo);

                return Ok(new { message = "Transición realizada exitosamente", id });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al realizar transición: {ex.Message}");
                return StatusCode(500, new { message = "Error al realizar transición" });
            }
        }

        /// <summary>
        /// Obtener transición por ID
        /// </summary>
        [HttpGet("Transitions/{id}")]
        public async Task<ActionResult<TransicionDTO>> ObtenerTransicionPorId(int id)
        {
            try
            {
                var transicion = await _transicionRepository.GetByIdAsync(id);
                if (transicion == null)
                    return NotFound(new { message = "Transición no encontrada" });

                var dto = new TransicionDTO
                {
                    Id_Transicion = transicion.Id_Transicion,
                    Id_Tkt = transicion.Id_Tkt,
                    Id_Estado_Anterior = transicion.Id_Estado_Anterior,
                    Id_Estado_Nuevo = transicion.Id_Estado_Nuevo,
                    Id_Usuario = transicion.Id_Usuario,
                    Comentario = transicion.Comentario,
                    Fecha = transicion.Fecha
                };

                return Ok(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener transición: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener transición" });
            }
        }

        /// <summary>
        /// Obtener historial de transiciones de un usuario
        /// </summary>
        [HttpGet("Users/{userId}/Transitions")]
        public async Task<ActionResult<List<TransicionDTO>>> ObtenerTransicionesPorUsuario(int userId)
        {
            try
            {
                var transiciones = await _transicionRepository.GetAllAsync();
                var transicionesUsuario = transiciones
                    .Where(t => t.Id_Usuario == userId)
                    .OrderByDescending(t => t.Fecha)
                    .ToList();

                var dtos = transicionesUsuario.Select(t => new TransicionDTO
                {
                    Id_Transicion = t.Id_Transicion,
                    Id_Tkt = t.Id_Tkt,
                    Id_Estado_Anterior = t.Id_Estado_Anterior,
                    Id_Estado_Nuevo = t.Id_Estado_Nuevo,
                    Id_Usuario = t.Id_Usuario,
                    Comentario = t.Comentario,
                    Fecha = t.Fecha
                }).ToList();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener transiciones del usuario: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener transiciones del usuario" });
            }
        }
    }
}
