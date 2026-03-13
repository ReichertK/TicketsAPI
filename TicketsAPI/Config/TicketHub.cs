namespace TicketsAPI.Config
{
    /// <summary>
    /// Hub de SignalR para notificaciones en tiempo real
    /// </summary>
    public class TicketHub : Microsoft.AspNetCore.SignalR.Hub
    {
        private readonly ILogger<TicketHub> _logger;

        public TicketHub(ILogger<TicketHub> logger)
        {
            _logger = logger;
        }

        public override async Task OnConnectedAsync()
        {
            var userId = Context.User?.FindFirst("sub")?.Value;
            _logger.LogInformation($"Usuario {userId} conectado a TicketHub");
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.User?.FindFirst("sub")?.Value;
            _logger.LogInformation($"Usuario {userId} desconectado de TicketHub");
            await base.OnDisconnectedAsync(exception);
        }

        /// <summary>
        /// Permite que el usuario se suscriba a actualizaciones de un ticket específico
        /// </summary>
        public async Task SubscribeToTicket(int ticketId)
        {
            var groupName = $"ticket-{ticketId}";
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
            _logger.LogInformation($"Usuario suscrito al ticket {ticketId}");
        }

        /// <summary>
        /// Permite que el usuario se desuscriba de un ticket
        /// </summary>
        public async Task UnsubscribeFromTicket(int ticketId)
        {
            var groupName = $"ticket-{ticketId}";
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
            _logger.LogInformation($"Usuario desuscrito del ticket {ticketId}");
        }

        /// <summary>
        /// Permite que el usuario se suscriba a las notificaciones de aprobación (solo aprobadores)
        /// </summary>
        public async Task SubscribeToApprovals()
        {
            var groupName = "approvals";
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
            _logger.LogInformation($"Usuario suscrito a notificaciones de aprobación");
        }

        /// <summary>
        /// Permite que el usuario se suscriba a sus propias alertas/menciones personales.
        /// El cliente debe invocar esto al conectarse para recibir eventos dirigidos.
        /// </summary>
        public async Task SubscribeToUser()
        {
            var userId = Context.User?.FindFirst("sub")?.Value 
                ?? Context.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userId))
            {
                var groupName = $"user_{userId}";
                await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
                _logger.LogInformation("Usuario {UserId} suscrito a grupo personal {Group}", userId, groupName);
            }
        }
    }
}
