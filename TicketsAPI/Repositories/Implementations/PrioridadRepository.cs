using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class PrioridadRepository : BaseRepository, IPrioridadRepository
    {
        public PrioridadRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Prioridad entity)
        {
            using var conn = CreateConnection();
            var sql = "INSERT INTO prioridad (NombrePrioridad) VALUES (@Nombre_Prioridad); SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "DELETE FROM prioridad WHERE Id_Prioridad = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Prioridad>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Prioridad, NombrePrioridad AS Nombre_Prioridad FROM prioridad";
            var list = await conn.QueryAsync<Prioridad>(sql);
            return list.ToList();
        }

        public async Task<List<Prioridad>> GetAllActiveAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Prioridad, NombrePrioridad AS Nombre_Prioridad FROM prioridad";
            var list = await conn.QueryAsync<Prioridad>(sql);
            return list.ToList();
        }

        public async Task<Prioridad?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Prioridad, NombrePrioridad AS Nombre_Prioridad FROM prioridad WHERE Id_Prioridad = @id";
            return await conn.QueryFirstOrDefaultAsync<Prioridad>(sql, new { id });
        }

        public async Task<Prioridad?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Prioridad, NombrePrioridad AS Nombre_Prioridad FROM prioridad WHERE NombrePrioridad = @nombre";
            return await conn.QueryFirstOrDefaultAsync<Prioridad>(sql, new { nombre });
        }

        public async Task<bool> UpdateAsync(Prioridad entity)
        {
            using var conn = CreateConnection();
            var sql = "UPDATE prioridad SET NombrePrioridad=@Nombre_Prioridad WHERE Id_Prioridad=@Id_Prioridad";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT COUNT(*) FROM prioridad WHERE Id_Prioridad = @id";
            var count = await conn.ExecuteScalarAsync<int>(sql, new { id });
            return count > 0;
        }
    }
}
