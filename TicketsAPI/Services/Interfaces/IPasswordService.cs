namespace TicketsAPI.Services.Interfaces
{
    public interface IPasswordService
    {
        string Hash(string password);
        bool Verify(string storedHash, string providedPassword);
        bool IsBCrypt(string storedHash);
    }
}
