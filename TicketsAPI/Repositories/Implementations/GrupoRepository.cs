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
            const string sql = @"INSERT INTO grupo (Nombre, Descripcion, Activo)
                                VALUES (@Nombre, @Descripcion, @Activo);
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
            const string sql = "SELECT * FROM grupo WHERE Activo = 1 ORDER BY Nombre";
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
            const string sql = @"UPDATE grupo SET Nombre = @Nombre, Descripcion = @Descripcion, Activo = @Activo 
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
