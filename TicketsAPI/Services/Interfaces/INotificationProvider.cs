namespace TicketsAPI.Services.Interfaces
{
    public interface INotificationProvider
    {
        Task BroadcastAsync(string eventName, object payload);
        Task SendToUserAsync(int userId, string eventName, object payload);
        Task SendToGroupAsync(string groupName, string eventName, object payload);
        string ProviderName { get; }
    }
}
