using Dapper;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class GrupoRepository : BaseRepository, IBaseRepository<Grupo>
    {
        public GrupoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Grupo entity)
        {
            using var conn = CreateConnection();
            const string sql = @"INSERT INTO grupo (Tipo_Grupo)
                                VALUES (@Tipo_Grupo);
                                SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "DELETE FROM grupo WHERE Id_Grupo = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Grupo>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = "SELECT Id_Grupo, Tipo_Grupo FROM grupo ORDER BY Id_Grupo";
            var result = await conn.QueryAsync<Grupo>(sql);
            return result.ToList();
        }

        public async Task<Grupo?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM grupo WHERE Id_Grupo = @id";
            return await conn.QuerySingleOrDefaultAsync<Grupo>(sql, new { id });
        }

        public async Task<bool> UpdateAsync(Grupo entity)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE grupo SET Tipo_Grupo = @Tipo_Grupo 
                                WHERE Id_Grupo = @Id_Grupo";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<Grupo?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM grupo WHERE Nombre = @nombre AND Activo = 1";
            return await conn.QuerySingleOrDefaultAsync<Grupo>(sql, new { nombre });
        }
    }
}
