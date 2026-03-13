namespace TicketsAPI.Services.Interfaces
{
    /// <summary>
    /// Interfaz de abstracción para proveedores de notificaciones.
    /// Permite intercambiar SignalR por WhatsApp, Email, Slack, etc. sin tocar la lógica de negocio.
    /// </summary>
    public interface INotificationProvider
    {
        /// <summary>
        /// Enviar una notificación a todos los usuarios conectados (broadcast).
        /// </summary>
        Task BroadcastAsync(string eventName, object payload);

        /// <summary>
        /// Enviar una notificación a un usuario específico.
        /// </summary>
        Task SendToUserAsync(int userId, string eventName, object payload);

        /// <summary>
        /// Enviar una notificación a un grupo (ej: suscriptores de un ticket).
        /// </summary>
        Task SendToGroupAsync(string groupName, string eventName, object payload);

        /// <summary>
        /// Nombre del proveedor para logging/diagnóstico.
        /// </summary>
        string ProviderName { get; }
    }
}
