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
    public class ComentariosController : BaseApiController
    {
        private readonly IComentarioRepository _comentarioRepository;
        private readonly IBaseRepository<Ticket> _ticketRepository;
        private readonly INotificacionService _notificacionService;

        public ComentariosController(
            IComentarioRepository comentarioRepository,
            IBaseRepository<Ticket> ticketRepository,
            INotificacionService notificacionService,
            ILogger<ComentariosController> logger) : base(logger)
        {
            _comentarioRepository = comentarioRepository;
            _ticketRepository = ticketRepository;
            _notificacionService = notificacionService;
        }

        /// <summary>
        /// Obtener comentarios de un ticket
        /// </summary>
        [HttpGet("Tickets/{ticketId}/Comments")]
        public async Task<IActionResult> GetComentariosPorTicket(int ticketId)
        {
            try
            {
                var ticket = await _ticketRepository.GetByIdAsync(ticketId);
                if (ticket == null)
                    return Error<object>("Ticket no encontrado", statusCode: 404);

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

                return Success(dtos, "Comentarios obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener comentarios");
                return Error<object>("Error al obtener comentarios", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Crear nuevo comentario en un ticket
        /// </summary>
        [HttpPost("Tickets/{ticketId}/Comments")]
        public async Task<IActionResult> CrearComentario(int ticketId, [FromBody] CreateUpdateComentarioDTO dto)
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

                // Llamar a sp_tkt_comentar para validación
                var result = await _comentarioRepository.CrearComentarioViaStoredProcedureAsync(
                    idTkt: ticketId,
                    idUsuario: usuarioId,
                    comentario: dto.Contenido);

                if (result.Success != 1)
                {
                    return Error<object>(result.Message ?? "Error al crear comentario", statusCode: 400);
                }

                // Notificar nuevo comentario
                await _notificacionService.NuevoComentarioAsync(ticketId, usuarioId, dto.Contenido);

                // Retornar el comentario creado
                // result.IdComentario ahora contiene el ID obtenido vía LAST_INSERT_ID()
                if (!result.IdComentario.HasValue || result.IdComentario <= 0)
                    return Error<object>("Error al recuperar el ID del comentario creado", statusCode: 500);

                var comentarioCreado = await _comentarioRepository.GetByIdAsync(result.IdComentario.Value);
                if (comentarioCreado == null)
                    return Error<object>("Error al recuperar el comentario creado", statusCode: 500);

                var responseDto = new ComentarioDTO
                {
                    Id_Comentario = comentarioCreado.Id_Comentario,
                    Id_Ticket = comentarioCreado.Id_Ticket,
                    Id_Usuario = comentarioCreado.Id_Usuario,
                    Contenido = comentarioCreado.Contenido,
                    Fecha_Creacion = comentarioCreado.Fecha_Creacion,
                    Privado = comentarioCreado.Privado
                };

                return Success(responseDto, "Comentario creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear comentario");
                return Error<object>("Error al crear comentario", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener comentario por ID
        /// </summary>
        [HttpGet("Comments/{id}")]
        public async Task<IActionResult> GetComentarioPorId(int id)
        {
            try
            {
                var comentario = await _comentarioRepository.GetByIdAsync(id);
                if (comentario == null)
                    return Error<object>("Comentario no encontrado", statusCode: 404);

                var dto = new ComentarioDTO
                {
                    Id_Comentario = comentario.Id_Comentario,
                    Id_Ticket = comentario.Id_Ticket,
                    Id_Usuario = comentario.Id_Usuario,
                    Contenido = comentario.Contenido,
                    Fecha_Creacion = comentario.Fecha_Creacion,
                    Privado = comentario.Privado
                };

                return Success(dto, "Comentario obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener comentario");
                return Error<object>("Error al obtener comentario", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Actualizar comentario
        /// </summary>
        [HttpPut("Comments/{id}")]
        public async Task<IActionResult> ActualizarComentario(int id, [FromBody] CreateUpdateComentarioDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var comentario = await _comentarioRepository.GetByIdAsync(id);
                if (comentario == null)
                    return Error<object>("Comentario no encontrado", statusCode: 404);

                var usuarioId = GetCurrentUserId();
                if (comentario.Id_Usuario != usuarioId)
                    return Error<object>("No tiene permiso para editar este comentario", statusCode: 403);

                comentario.Contenido = dto.Contenido;
                comentario.Privado = dto.Privado;
                comentario.Fecha_Actualizacion = DateTime.Now;
                await _comentarioRepository.UpdateAsync(comentario);

                return Success<object>(new { }, "Comentario actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar comentario");
                return Error<object>("Error al actualizar comentario", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Eliminar comentario
        /// </summary>
        [HttpDelete("Comments/{id}")]
        public async Task<IActionResult> EliminarComentario(int id)
        {
            try
            {
                var comentario = await _comentarioRepository.GetByIdAsync(id);
                if (comentario == null)
                    return Error<object>("Comentario no encontrado", statusCode: 404);

                var usuarioId = GetCurrentUserId();
                if (comentario.Id_Usuario != usuarioId)
                    return Error<object>("No tiene permiso para eliminar este comentario", statusCode: 403);

                await _comentarioRepository.DeleteAsync(id);
                return Success<object>(new { }, "Comentario eliminado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar comentario");
                return Error<object>("Error al eliminar comentario", new List<string> { ex.Message }, 500);
            }
        }
    }
}
