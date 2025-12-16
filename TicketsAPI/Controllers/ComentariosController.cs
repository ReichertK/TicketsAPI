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
    public class ComentariosController : ControllerBase
    {
        private readonly IBaseRepository<Comentario> _comentarioRepository;
        private readonly IBaseRepository<Ticket> _ticketRepository;
        private readonly INotificacionService _notificacionService;
        private readonly ILogger<ComentariosController> _logger;

        public ComentariosController(
            IBaseRepository<Comentario> comentarioRepository,
            IBaseRepository<Ticket> ticketRepository,
            INotificacionService notificacionService,
            ILogger<ComentariosController> logger)
        {
            _comentarioRepository = comentarioRepository;
            _ticketRepository = ticketRepository;
            _notificacionService = notificacionService;
            _logger = logger;
        }

        /// <summary>
        /// Obtener comentarios de un ticket
        /// </summary>
        [HttpGet("Tickets/{ticketId}/Comments")]
        public async Task<ActionResult<List<ComentarioDTO>>> GetComentariosPorTicket(int ticketId)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return NotFound(new { message = "Ticket no encontrado" });

                var comentarios = await _comentarioRepository.GetAllAsync();
                var comentariosTicket = comentarios
                    .Where(c => c.Id_Ticket == ticketId)
                    .OrderByDescending(c => c.Fecha_Creacion)
                    .ToList();

                var dtos = comentariosTicket.Select(c => new ComentarioDTO
                {
                    Id_Comentario = c.Id_Comentario,
                    Id_Ticket = c.Id_Ticket,
                    Id_Usuario = c.Id_Usuario,
                    Contenido = c.Contenido,
                    Fecha_Creacion = c.Fecha_Creacion,
                    Privado = c.Privado
                }).ToList();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener comentarios: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener comentarios" });
            }
        }

        /// <summary>
        /// Crear nuevo comentario en un ticket
        /// </summary>
        [HttpPost("Tickets/{ticketId}/Comments")]
        public async Task<ActionResult> CrearComentario(int ticketId, [FromBody] CreateUpdateComentarioDTO dto)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return NotFound(new { message = "Ticket no encontrado" });

                var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");

                var comentario = new Comentario
                {
                    Id_Ticket = ticketId,
                    Id_Usuario = usuarioId,
                    Contenido = dto.Contenido,
                    Privado = dto.Privado,
                    Fecha_Creacion = DateTime.Now
                };

                var id = await _comentarioRepository.CreateAsync(comentario);
                comentario.Id_Comentario = id;

                // Notificar nuevo comentario
                await _notificacionService.NuevoComentarioAsync(ticketId, usuarioId, dto.Contenido);

                return CreatedAtAction(nameof(GetComentarioPorId), new { id }, comentario);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al crear comentario: {ex.Message}");
                return StatusCode(500, new { message = "Error al crear comentario" });
            }
        }

        /// <summary>
        /// Obtener comentario por ID
        /// </summary>
        [HttpGet("Comments/{id}")]
        public async Task<ActionResult<ComentarioDTO>> GetComentarioPorId(int id)
        {
            try
            {
                var comentario = await _comentarioRepository.GetByIdAsync(id);
                if (comentario == null)
                    return NotFound(new { message = "Comentario no encontrado" });

                var dto = new ComentarioDTO
                {
                    Id_Comentario = comentario.Id_Comentario,
                    Id_Ticket = comentario.Id_Ticket,
                    Id_Usuario = comentario.Id_Usuario,
                    Contenido = comentario.Contenido,
                    Fecha_Creacion = comentario.Fecha_Creacion,
                    Privado = comentario.Privado
                };

                return Ok(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener comentario: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener comentario" });
            }
        }

        /// <summary>
        /// Actualizar comentario
        /// </summary>
        [HttpPut("Comments/{id}")]
        public async Task<ActionResult> ActualizarComentario(int id, [FromBody] CreateUpdateComentarioDTO dto)
        {
            try
            {
                var comentario = await _comentarioRepository.GetByIdAsync(id);
                if (comentario == null)
                    return NotFound(new { message = "Comentario no encontrado" });

                var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
                if (comentario.Id_Usuario != usuarioId)
                    return Forbid("No tiene permiso para editar este comentario");

                comentario.Contenido = dto.Contenido;
                comentario.Privado = dto.Privado;
                comentario.Fecha_Actualizacion = DateTime.Now;
                await _comentarioRepository.UpdateAsync(comentario);

                return Ok(new { message = "Comentario actualizado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al actualizar comentario: {ex.Message}");
                return StatusCode(500, new { message = "Error al actualizar comentario" });
            }
        }

        /// <summary>
        /// Eliminar comentario
        /// </summary>
        [HttpDelete("Comments/{id}")]
        public async Task<ActionResult> EliminarComentario(int id)
        {
            try
            {
                var comentario = await _comentarioRepository.GetByIdAsync(id);
                if (comentario == null)
                    return NotFound(new { message = "Comentario no encontrado" });

                var usuarioId = int.Parse(User.FindFirst("sub")?.Value ?? "0");
                if (comentario.Id_Usuario != usuarioId)
                    return Forbid("No tiene permiso para eliminar este comentario");

                await _comentarioRepository.DeleteAsync(id);
                return Ok(new { message = "Comentario eliminado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al eliminar comentario: {ex.Message}");
                return StatusCode(500, new { message = "Error al eliminar comentario" });
            }
        }
    }
}
