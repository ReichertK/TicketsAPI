using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controlador para notificaciones de lectura (tickets no leídos)
    /// </summary>
    [Authorize]
    public class NotificacionesController : BaseApiController
    {
        private readonly INotificacionLecturaRepository _notificacionRepo;

        public NotificacionesController(
            INotificacionLecturaRepository notificacionRepo,
            ILogger<NotificacionesController> logger) : base(logger)
        {
            _notificacionRepo = notificacionRepo;
        }

        /// <summary>
        /// Obtener resumen de notificaciones no leídas del usuario actual.
        /// Devuelve conteos + últimos 5 tickets no leídos.
        /// </summary>
        [HttpGet("resumen")]
        public async Task<IActionResult> GetResumen()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                var resumen = await _notificacionRepo.GetResumenAsync(userId);
                return Success(resumen, "Resumen de notificaciones obtenido");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener resumen de notificaciones");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// <summary>
        /// Marcar un ticket específico como leído
        /// </summary>
        [HttpPatch("{idTicket}/leido")]
        public async Task<IActionResult> MarcarLeido(int idTicket)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                await _notificacionRepo.MarcarLeidoAsync(idTicket, userId);
                return Success<object>(new { }, "Ticket marcado como leído");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al marcar ticket como leído");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// <summary>
        /// Marcar todas las notificaciones del usuario como leídas
        /// </summary>
        [HttpPatch("marcar-todos-leidos")]
        public async Task<IActionResult> MarcarTodosLeidos()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Unauthorized(new { message = "Usuario no autenticado" });

                await _notificacionRepo.MarcarTodosLeidosAsync(userId);
                return Success<object>(new { }, "Todas las notificaciones marcadas como leídas");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al marcar todas como leídas");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }
    }
}
