using Dapper;
using MySqlConnector;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class PermisoRepository : BaseRepository, IPermisoRepository
    {
        public PermisoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Permiso entity)
        {
            using var conn = CreateConnection();
            var sql = "INSERT INTO permiso (Codigo, Descripcion, Modulo, Activo) VALUES (@Codigo, @Descripcion, @Modulo, @Activo); SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "DELETE FROM permiso WHERE Id_Permiso = @id";
            return await conn.ExecuteAsync(sql, new { id }) > 0;
        }

        public async Task<List<Permiso>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Permiso, Codigo, Descripcion, Modulo, Activo FROM permiso";
            var list = await conn.QueryAsync<Permiso>(sql);
            return list.ToList();
        }

        public async Task<Permiso?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Permiso, Codigo, Descripcion, Modulo, Activo FROM permiso WHERE Id_Permiso = @id";
            return await conn.QuerySingleOrDefaultAsync<Permiso>(sql, new { id });
        }

        public async Task<Permiso?> GetByCodigoAsync(string codigo)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Permiso, Codigo, Descripcion, Modulo, Activo FROM permiso WHERE Codigo = @codigo";
            return await conn.QuerySingleOrDefaultAsync<Permiso>(sql, new { codigo });
        }

        public async Task<List<Permiso>> GetByModuloAsync(string modulo)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Permiso, Codigo, Descripcion, Modulo, Activo FROM permiso WHERE Modulo = @modulo";
            var list = await conn.QueryAsync<Permiso>(sql, new { modulo });
            return list.ToList();
        }

        public async Task<List<Permiso>> GetByRolAsync(int idRol)
        {
            using var conn = CreateConnection();
            var sql = @"SELECT p.Id_Permiso, p.Codigo, p.Descripcion, p.Modulo, p.Activo 
                        FROM permiso p
                        INNER JOIN rolpermiso rp ON p.Id_Permiso = rp.Id_Permiso
                        WHERE rp.Id_Rol = @idRol AND p.Activo = 1";
            var list = await conn.QueryAsync<Permiso>(sql, new { idRol });
            return list.ToList();
        }

        public async Task<bool> UpdateAsync(Permiso entity)
        {
            using var conn = CreateConnection();
            var sql = "UPDATE permiso SET Codigo = @Codigo, Descripcion = @Descripcion, Modulo = @Modulo, Activo = @Activo WHERE Id_Permiso = @Id_Permiso";
            return await conn.ExecuteAsync(sql, entity) > 0;
        }
    }
}
