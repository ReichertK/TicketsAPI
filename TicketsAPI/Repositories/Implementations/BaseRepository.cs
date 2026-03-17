using Dapper;
using MySqlConnector;
using Microsoft.Extensions.Logging;

namespace TicketsAPI.Repositories.Implementations
{
    public abstract class BaseRepository
    {
        protected readonly string _connectionString;

        /// Códigos de error MySQL 5.5 que son transitorios y se pueden reintentar:
        /// 1205 = Lock Wait Timeout
        /// 1213 = Deadlock
        /// 1040 = Too many connections
        /// 2006 = MySQL server has gone away
        /// 2013 = Lost connection during query
        private static readonly HashSet<int> TransientMySqlErrors = new() { 1205, 1213, 1040, 2006, 2013 };
        private const int MaxRetries = 3;
        private const int BaseDelayMs = 200; // 200ms, 400ms, 800ms (exponential)

        protected BaseRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        protected MySqlConnection CreateConnection()
        {
            return new MySqlConnection(_connectionString);
        }

        /// Ejecuta una operación de base de datos con reintentos automáticos
        /// ante errores transitorios de MySQL 5.5 (deadlock, lock timeout, conexión perdida).
        /// Usa exponential backoff: 200ms → 400ms → 800ms.
        protected async Task<T> ExecuteWithRetryAsync<T>(Func<Task<T>> operation, string? operationName = null)
        {
            for (int attempt = 1; attempt <= MaxRetries; attempt++)
            {
                try
                {
                    return await operation();
                }
                catch (MySqlException ex) when (IsTransient(ex) && attempt < MaxRetries)
                {
                    var delay = BaseDelayMs * (1 << (attempt - 1)); // exponential backoff
                    // Log como Warning (no Error) porque vamos a reintentar
                    System.Diagnostics.Debug.WriteLine(
                        $"[BaseRepository] Transient MySQL error {ex.Number} on attempt {attempt}/{MaxRetries} " +
                        $"({operationName ?? "operation"}). Retrying in {delay}ms...");
                    await Task.Delay(delay);
                }
            }

            // El último intento se ejecuta sin catch — si falla, la excepción sube al middleware
            return await operation();
        }

        /// Sobrecarga para operaciones sin retorno (void).
        protected async Task ExecuteWithRetryAsync(Func<Task> operation, string? operationName = null)
        {
            await ExecuteWithRetryAsync(async () =>
            {
                await operation();
                return true; // dummy return
            }, operationName);
        }

        private static bool IsTransient(MySqlException ex)
        {
            return TransientMySqlErrors.Contains(ex.Number);
        }
    }
}
