using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    /// Servicio de notificaciones refactorizado para usar INotificationProvider.
    /// Ya no depende directamente de SignalR — se puede inyectar cualquier proveedor.
    public class NotificacionService : INotificacionService
    {
        private readonly INotificationProvider _provider;
        private readonly ILogger<NotificacionService> _logger;

        public NotificacionService(
            INotificationProvider provider,
            ILogger<NotificacionService> logger)
        {
            _provider = provider;
            _logger = logger;
            _logger.LogInformation("NotificacionService inicializado con proveedor: {Provider}", _provider.ProviderName);
        }

        // Métodos antiguos para compatibilidad
        public async Task NotificarNuevoTicketAsync(int idTicket)
        {
            await _provider.BroadcastAsync("NuevoTicket", idTicket);
        }

        // Nuevos métodos con parámetros extendidos
        public async Task NotificarNuevoTicketAsync(int idTicket, int idUsuarioCreador)
        {
            await _provider.BroadcastAsync("NuevoTicket", new { idTicket, idUsuarioCreador });
        }

        public async Task NotificarActualizacionTicketAsync(int idTicket)
        {
            await _provider.BroadcastAsync("ActualizacionTicket", idTicket);
        }

        public async Task ActualizacionTicketAsync(int idTicket, int idUsuarioActualizador)
        {
            await _provider.BroadcastAsync("ActualizacionTicket", new { idTicket, idUsuarioActualizador });
        }

        public async Task NotificarSolicitudAprobacionAsync(int idTicket)
        {
            await _provider.BroadcastAsync("SolicitudAprobacion", idTicket);
        }

        public async Task SolicitudAprobacionAsync(int idTicket, int idUsuarioSolicitante, int idUsuarioAprobador)
        {
            await _provider.BroadcastAsync("SolicitudAprobacion", new { idTicket, idUsuarioSolicitante, idUsuarioAprobador });
        }

        public async Task NotificarTransicionEstadoAsync(int idTicket, string nuevoEstado)
        {
            await _provider.BroadcastAsync("TransicionEstado", new { idTicket, nuevoEstado });
        }

        public async Task TransicionEstadoAsync(int idTicket, int idUsuario, int idEstadoNuevo)
        {
            await _provider.BroadcastAsync("TransicionEstado", new { idTicket, idUsuario, idEstadoNuevo });
        }

        public async Task NotificarNuevoComentarioAsync(int idTicket)
        {
            await _provider.BroadcastAsync("NuevoComentario", idTicket);
        }

        public async Task NuevoComentarioAsync(int idTicket, int idUsuario, string comentario)
        {
            await _provider.BroadcastAsync("NuevoComentario", new { idTicket, idUsuario, comentario });
        }

        public async Task MencionUsuarioAsync(int idUsuarioDestino, int idTicket, long idComentario, string mensaje)
        {
            try
            {
                await _provider.SendToUserAsync(idUsuarioDestino, "MencionUsuario", new
                {
                    idTicket,
                    idComentario,
                    mensaje,
                    fecha = DateTime.UtcNow
                });
                _logger.LogInformation("[Mención] Alerta enviada a user_{UserId} para ticket #{TicketId}", idUsuarioDestino, idTicket);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[Mención] Error al enviar alerta a user_{UserId}", idUsuarioDestino);
            }
        }

        public async Task AsignacionTicketAsync(int idUsuarioDestino, int idTicket, string mensaje)
        {
            try
            {
                await _provider.SendToUserAsync(idUsuarioDestino, "TicketAssigned", new
                {
                    idTicket,
                    mensaje,
                    fecha = DateTime.UtcNow
                });
                _logger.LogInformation("[Asignación] Alerta enviada a user_{UserId} para ticket #{TicketId}", idUsuarioDestino, idTicket);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[Asignación] Error al enviar alerta a user_{UserId}", idUsuarioDestino);
            }
        }
    }
}

