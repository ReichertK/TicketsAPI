using Dapper;
using MySqlConnector;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class RolRepository : BaseRepository, IRolRepository
    {
        public RolRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Rol entity)
        {
            using var conn = CreateConnection();
            var sql = "INSERT INTO rol (Rol, Descripcion, Activo) VALUES (@Nombre_Rol, @Descripcion, @Activo); SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "DELETE FROM rol WHERE Id_Rol = @id";
            return await conn.ExecuteAsync(sql, new { id }) > 0;
        }

        public async Task<List<Rol>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Rol, Rol AS Nombre_Rol, Descripcion, Activo FROM rol";
            var list = await conn.QueryAsync<Rol>(sql);
            return list.ToList();
        }

        public async Task<Rol?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Rol, Rol AS Nombre_Rol, Descripcion, Activo FROM rol WHERE Id_Rol = @id";
            return await conn.QuerySingleOrDefaultAsync<Rol>(sql, new { id });
        }

        public async Task<Rol?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Rol, Rol AS Nombre_Rol, Descripcion, Activo FROM rol WHERE Rol = @nombre";
            return await conn.QuerySingleOrDefaultAsync<Rol>(sql, new { nombre });
        }

        public async Task<Rol?> GetWithPermisosAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Rol, Rol AS Nombre_Rol, Descripcion, Activo FROM rol WHERE Id_Rol = @id";
            return await conn.QuerySingleOrDefaultAsync<Rol>(sql, new { id });
        }

        public async Task<bool> UpdateAsync(Rol entity)
        {
            using var conn = CreateConnection();
            var sql = "UPDATE rol SET Rol = @Nombre_Rol, Descripcion = @Descripcion, Activo = @Activo WHERE Id_Rol = @Id_Rol";
            return await conn.ExecuteAsync(sql, entity) > 0;
        }
    }
}
