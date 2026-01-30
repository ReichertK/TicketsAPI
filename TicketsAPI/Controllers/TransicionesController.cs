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
    public class TransicionesController : BaseApiController
    {
        private readonly IBaseRepository<Transicion> _transicionRepository;
        private readonly IBaseRepository<Ticket> _ticketRepository;
        private readonly INotificacionService _notificacionService;
        private readonly ITicketService _ticketService;
        private readonly IEstadoService _estadoService;

        public TransicionesController(
            IBaseRepository<Transicion> transicionRepository,
            IBaseRepository<Ticket> ticketRepository,
            INotificacionService notificacionService,
            ITicketService ticketService,
            IEstadoService estadoService,
            ILogger<TransicionesController> logger) : base(logger)
        {
            _transicionRepository = transicionRepository;
            _ticketRepository = ticketRepository;
            _notificacionService = notificacionService;
            _ticketService = ticketService;
            _estadoService = estadoService;
        }

        /// <summary>
        /// Obtener historial de transiciones de un ticket
        /// </summary>
        [HttpGet("Tickets/{ticketId}/Transitions")]
        public async Task<IActionResult> ObtenerTransicionesPorTicket(int ticketId)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

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

                return Success(dtos, "Transiciones obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener transiciones");
                return Error<object>("Error al obtener transiciones", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Realizar transición de estado en un ticket
        /// </summary>
        [HttpPost("Tickets/{ticketId}/Transition")]
        public async Task<IActionResult> RealizarTransicion(int ticketId, [FromBody] TransicionEstadoDTO dto)
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

                if (dto == null || dto.Id_Estado_Nuevo <= 0)
                    return Error<object>("Id_Estado_Nuevo es requerido", statusCode: 400);

                // Validar transición con las reglas reales
                int rolId = 0;
                var userRole = GetCurrentUserRole();
                if (!string.IsNullOrWhiteSpace(userRole))
                {
                    int.TryParse(userRole, out rolId);
                }

                var permitido = await _estadoService.ValidarTransicionAsync(ticket.Id_Estado ?? 1, dto.Id_Estado_Nuevo, rolId);
                if (!permitido)
                    return Error<object>("Transición no permitida", statusCode: 403);

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

                return Success(new { id }, "Transición realizada exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al realizar transición");
                return Error<object>("Error al realizar transición", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener transición por ID
        /// </summary>
        [HttpGet("Transitions/{id}")]
        public async Task<IActionResult> ObtenerTransicionPorId(int id)
        {
            try
            {
                var transicion = await _transicionRepository.GetByIdAsync(id);
                if (transicion == null)
                    return Error<object>("Transición no encontrada", statusCode: 404);

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

                return Success(dto, "Transición obtenida exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener transición");
                return Error<object>("Error al obtener transición", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener historial de transiciones de un usuario
        /// </summary>
        [HttpGet("Users/{userId}/Transitions")]
        public async Task<IActionResult> ObtenerTransicionesPorUsuario(int userId)
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

                return Success(dtos, "Transiciones del usuario obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener transiciones del usuario");
                return Error<object>("Error al obtener transiciones del usuario", new List<string> { ex.Message }, 500);
            }
        }
    }
}
