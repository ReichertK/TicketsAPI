using Dapper;
using MySqlConnector;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class EstadoRepository : BaseRepository, IEstadoRepository
    {
        public EstadoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Estado entity)
        {
            using var conn = CreateConnection();
            var sql = "INSERT INTO estado (TipoEstado) VALUES (@Nombre_Estado); SELECT LAST_INSERT_ID();";
            var id = await conn.ExecuteScalarAsync<int>(sql, entity);
            return id;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "DELETE FROM estado WHERE Id_Estado = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Estado>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Estado, TipoEstado AS Nombre_Estado FROM estado";
            var list = await conn.QueryAsync<Estado>(sql);
            return list.ToList();
        }

        public async Task<List<Estado>> GetAllActiveAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Estado, TipoEstado AS Nombre_Estado FROM estado";
            var list = await conn.QueryAsync<Estado>(sql);
            return list.ToList();
        }

        public async Task<Estado?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Estado, TipoEstado AS Nombre_Estado FROM estado WHERE Id_Estado = @id";
            return await conn.QueryFirstOrDefaultAsync<Estado>(sql, new { id });
        }

        public async Task<Estado?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Estado, TipoEstado AS Nombre_Estado FROM estado WHERE TipoEstado = @nombre";
            return await conn.QueryFirstOrDefaultAsync<Estado>(sql, new { nombre });
        }

        public async Task<bool> UpdateAsync(Estado entity)
        {
            using var conn = CreateConnection();
            var sql = "UPDATE estado SET TipoEstado=@Nombre_Estado WHERE Id_Estado=@Id_Estado";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }
    }
}
