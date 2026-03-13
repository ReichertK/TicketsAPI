using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using Dapper;
using System.Data;
using System.Text.RegularExpressions;
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
        private readonly string _connectionString;

        // Regex para detectar @menciones (nombre con letras, espacios internos, acentos)
        private static readonly Regex MentionRegex = new(@"@([\w\sáéíóúñÁÉÍÓÚÑ]+?)(?=\s|$|[.,;!?])", RegexOptions.Compiled);

        public ComentariosController(
            IComentarioRepository comentarioRepository,
            IBaseRepository<Ticket> ticketRepository,
            INotificacionService notificacionService,
            IConfiguration configuration,
            ILogger<ComentariosController> logger) : base(logger)
        {
            _comentarioRepository = comentarioRepository;
            _ticketRepository = ticketRepository;
            _notificacionService = notificacionService;
            _connectionString = configuration.GetConnectionString("DbTkt")
                ?? configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("ConnectionString no configurada.");
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

                // D1: Filtrado directo en DB con WHERE id_tkt, elimina carga completa de tabla
                var comentariosTicket = await _comentarioRepository.GetByTicketAsync(ticketId);

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
                return Error<object>("Error al obtener comentarios", statusCode: 500);
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

                // ── Procesar @menciones ──────────────────────────────
                if (result.IdComentario.HasValue && result.IdComentario > 0)
                {
                    _ = Task.Run(async () =>
                    {
                        try
                        {
                            await ProcesarMencionesAsync(dto.Contenido, ticketId, result.IdComentario.Value, usuarioId);
                        }
                        catch (Exception exMention)
                        {
                            _logger.LogWarning(exMention, "Error al procesar @menciones en comentario {IdComentario}", result.IdComentario);
                        }
                    });
                }

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
                return Error<object>("Error al crear comentario", statusCode: 500);
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
                return Error<object>("Error al obtener comentario", statusCode: 500);
            }
        }

        /// <summary>
        /// Actualizar comentario
        /// </summary>
        [HttpPut("Comments/{id}")]
        [HttpPut("Tickets/{ticketId}/Comments/{id}")]
        public async Task<IActionResult> ActualizarComentario(int id, [FromBody] CreateUpdateComentarioDTO dto, int? ticketId = null)
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
                return Error<object>("Error al actualizar comentario", statusCode: 500);
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
                return Error<object>("Error al eliminar comentario", statusCode: 500);
            }
        }

        /// <summary>
        /// Busca @menciones en el texto del comentario, resuelve los nombres a idUsuario,
        /// persiste la alerta en notificacion_alerta (vía SP) y envía SignalR al destino.
        /// </summary>
        private async Task ProcesarMencionesAsync(string contenido, int idTicket, long idComentario, int idUsuarioAutor)
        {
            if (string.IsNullOrWhiteSpace(contenido)) return;

            var matches = MentionRegex.Matches(contenido);
            if (matches.Count == 0) return;

            // Extraer nombres únicos mencionados (trim y lowercase para comparar)
            var nombres = matches
                .Select(m => m.Groups[1].Value.Trim())
                .Where(n => n.Length >= 2)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .Take(10) // Limitar a 10 menciones por comentario
                .ToList();

            if (!nombres.Any()) return;

            using var conn = new MySqlConnection(_connectionString);
            await conn.OpenAsync();

            foreach (var nombre in nombres)
            {
                // Buscar usuario activo por nombre (case-insensitive)
                var usuario = await conn.QueryFirstOrDefaultAsync<(long IdUsuario, string Nombre)>(
                    "SELECT idUsuario, nombre FROM usuario WHERE nombre LIKE @Nombre AND fechaBaja IS NULL LIMIT 1",
                    new { Nombre = $"%{nombre}%" });

                if (usuario.IdUsuario <= 0 || usuario.IdUsuario == idUsuarioAutor) continue;

                // Persistir alerta con SP
                var pAlerta = new DynamicParameters();
                pAlerta.Add("p_id_usuario_destino", usuario.IdUsuario);
                pAlerta.Add("p_id_ticket", idTicket);
                pAlerta.Add("p_id_comentario", idComentario);
                pAlerta.Add("p_mensaje", $"Te mencionaron en el ticket #{idTicket}");
                pAlerta.Add("p_id_alerta", dbType: System.Data.DbType.Int64, direction: System.Data.ParameterDirection.Output);

                await conn.ExecuteAsync("sp_crear_alerta_mencion", pAlerta, commandType: CommandType.StoredProcedure);

                // Enviar notificación SignalR al usuario mencionado
                await _notificacionService.MencionUsuarioAsync(
                    (int)usuario.IdUsuario, idTicket, idComentario,
                    $"Te mencionaron en el ticket #{idTicket}");

                _logger.LogInformation("@Mención: {NombreMencionado} (id={IdUsuario}) en ticket #{TicketId}",
                    usuario.Nombre, usuario.IdUsuario, idTicket);
            }
        }
    }
}
