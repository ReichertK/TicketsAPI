using Microsoft.AspNetCore.SignalR;
using TicketsAPI.Config;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    /// <summary>
    /// Implementación de INotificationProvider usando SignalR.
    /// Mañana se puede reemplazar por WhatsAppNotificationProvider, EmailNotificationProvider, SlackNotificationProvider, etc.
    /// sin cambiar nada en los servicios de negocio.
    /// </summary>
    public class SignalRNotificationProvider : INotificationProvider
    {
        private readonly IHubContext<TicketHub> _hubContext;
        private readonly ILogger<SignalRNotificationProvider> _logger;

        public string ProviderName => "SignalR";

        public SignalRNotificationProvider(
            IHubContext<TicketHub> hubContext,
            ILogger<SignalRNotificationProvider> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        public async Task BroadcastAsync(string eventName, object payload)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync(eventName, payload);
                _logger.LogDebug("[SignalR] Broadcast '{Event}' enviado", eventName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[SignalR] Error al hacer broadcast del evento '{Event}'", eventName);
            }
        }

        public async Task SendToUserAsync(int userId, string eventName, object payload)
        {
            try
            {
                // SignalR: envía al grupo del usuario (requiere que el cliente se una al grupo "user_{id}")
                await _hubContext.Clients.Group($"user_{userId}").SendAsync(eventName, payload);
                _logger.LogDebug("[SignalR] Evento '{Event}' enviado a user_{UserId}", eventName, userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[SignalR] Error al enviar '{Event}' a user_{UserId}", eventName, userId);
            }
        }

        public async Task SendToGroupAsync(string groupName, string eventName, object payload)
        {
            try
            {
                await _hubContext.Clients.Group(groupName).SendAsync(eventName, payload);
                _logger.LogDebug("[SignalR] Evento '{Event}' enviado al grupo '{Group}'", eventName, groupName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[SignalR] Error al enviar '{Event}' al grupo '{Group}'", eventName, groupName);
            }
        }
    }
}
