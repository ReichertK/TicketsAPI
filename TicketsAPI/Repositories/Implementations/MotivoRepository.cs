using Dapper;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class MotivoRepository : BaseRepository, IBaseRepository<Motivo>
    {
        public MotivoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Motivo entity)
        {
            using var conn = CreateConnection();
            const string sql = @"INSERT INTO motivo (Nombre, Categoria)
                                VALUES (@Nombre, @Categoria);
                                SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "DELETE FROM motivo WHERE Id_Motivo = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Motivo>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM motivo ORDER BY Nombre";
            var result = await conn.QueryAsync<Motivo>(sql);
            return result.ToList();
        }

        public async Task<Motivo?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM motivo WHERE Id_Motivo = @id";
            return await conn.QuerySingleOrDefaultAsync<Motivo>(sql, new { id });
        }

        public async Task<bool> UpdateAsync(Motivo entity)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE motivo SET Nombre = @Nombre, Categoria = @Categoria 
                                WHERE Id_Motivo = @Id_Motivo";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<Motivo?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM motivo WHERE Nombre = @nombre";
            return await conn.QuerySingleOrDefaultAsync<Motivo>(sql, new { nombre });
        }

        public async Task<List<Motivo>> GetByCategoriaAsync(string categoria)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM motivo WHERE Categoria = @categoria ORDER BY Nombre";
            var result = await conn.QueryAsync<Motivo>(sql, new { categoria });
            return result.ToList();
        }
    }
}
