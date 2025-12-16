using Microsoft.AspNetCore.SignalR;
using TicketsAPI.Config;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    public class NotificacionService : INotificacionService
    {
        private readonly IHubContext<TicketHub> _hubContext;
        private readonly ILogger<NotificacionService> _logger;

        public NotificacionService(
            IHubContext<TicketHub> hubContext,
            ILogger<NotificacionService> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        // Métodos antiguos para compatibilidad
        public async Task NotificarNuevoTicketAsync(int idTicket)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("NuevoTicket", idTicket);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar nuevo ticket {IdTicket}", idTicket);
            }
        }

        // Nuevos métodos con parámetros extendidos
        public async Task NotificarNuevoTicketAsync(int idTicket, int idUsuarioCreador)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("NuevoTicket", new { idTicket, idUsuarioCreador });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar nuevo ticket {IdTicket}", idTicket);
            }
        }

        public async Task NotificarActualizacionTicketAsync(int idTicket)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("ActualizacionTicket", idTicket);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar actualización de ticket {IdTicket}", idTicket);
            }
        }

        public async Task ActualizacionTicketAsync(int idTicket, int idUsuarioActualizador)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("ActualizacionTicket", new { idTicket, idUsuarioActualizador });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar actualización de ticket {IdTicket}", idTicket);
            }
        }

        public async Task NotificarSolicitudAprobacionAsync(int idTicket)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("SolicitudAprobacion", idTicket);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar solicitud de aprobación {IdTicket}", idTicket);
            }
        }

        public async Task SolicitudAprobacionAsync(int idTicket, int idUsuarioSolicitante, int idUsuarioAprobador)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("SolicitudAprobacion", new { idTicket, idUsuarioSolicitante, idUsuarioAprobador });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar solicitud de aprobación {IdTicket}", idTicket);
            }
        }

        public async Task NotificarTransicionEstadoAsync(int idTicket, string nuevoEstado)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("TransicionEstado", new { idTicket, nuevoEstado });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar transición de estado del ticket {IdTicket}", idTicket);
            }
        }

        public async Task TransicionEstadoAsync(int idTicket, int idUsuario, int idEstadoNuevo)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("TransicionEstado", new { idTicket, idUsuario, idEstadoNuevo });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar transición de estado del ticket {IdTicket}", idTicket);
            }
        }

        public async Task NotificarNuevoComentarioAsync(int idTicket)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("NuevoComentario", idTicket);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar nuevo comentario en ticket {IdTicket}", idTicket);
            }
        }

        public async Task NuevoComentarioAsync(int idTicket, int idUsuario, string comentario)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("NuevoComentario", new { idTicket, idUsuario, comentario });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al notificar nuevo comentario en ticket {IdTicket}", idTicket);
            }
        }
    }
}

