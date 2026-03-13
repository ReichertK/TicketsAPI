using Dapper;
using MySqlConnector;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Repositories.Implementations
{
    public class PermisoRepository : BaseRepository, IPermisoRepository
    {
        public PermisoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Permiso entity)
        {
            using var conn = CreateConnection();
            var result = await conn.QuerySingleAsync<dynamic>(
                "sp_permiso_guardar",
                new { p_idPermiso = (int?)null, p_codigo = entity.Codigo, p_descripcion = entity.Descripcion },
                commandType: System.Data.CommandType.StoredProcedure);
            return Convert.ToInt32(result.idPermiso);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "DELETE FROM permiso WHERE idPermiso = @id";
            return await conn.ExecuteAsync(sql, new { id }) > 0;
        }

        public async Task<List<Permiso>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT idPermiso AS Id_Permiso, codigo AS Codigo, descripcion AS Descripcion FROM permiso ORDER BY codigo";
            var list = await conn.QueryAsync<Permiso>(sql);
            return list.ToList();
        }

        public async Task<Permiso?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT idPermiso AS Id_Permiso, codigo AS Codigo, descripcion AS Descripcion FROM permiso WHERE idPermiso = @id";
            return await conn.QuerySingleOrDefaultAsync<Permiso>(sql, new { id });
        }

        public async Task<Permiso?> GetByCodigoAsync(string codigo)
        {
            using var conn = CreateConnection();
            var sql = "SELECT idPermiso AS Id_Permiso, codigo AS Codigo, descripcion AS Descripcion FROM permiso WHERE codigo = @codigo";
            return await conn.QuerySingleOrDefaultAsync<Permiso>(sql, new { codigo });
        }

        public async Task<List<Permiso>> GetByModuloAsync(string modulo)
        {
            using var conn = CreateConnection();
            var sql = "SELECT idPermiso AS Id_Permiso, codigo AS Codigo, descripcion AS Descripcion FROM permiso WHERE Modulo = @modulo";
            var list = await conn.QueryAsync<Permiso>(sql, new { modulo });
            return list.ToList();
        }

        public async Task<List<Permiso>> GetByRolAsync(int idRol)
        {
            using var conn = CreateConnection();
            var sql = @"SELECT p.idPermiso AS Id_Permiso, p.codigo AS Codigo, p.descripcion AS Descripcion
                        FROM permiso p
                        INNER JOIN rol_permiso rp ON p.idPermiso = rp.idPermiso
                        WHERE rp.idRol = @idRol";
            var list = await conn.QueryAsync<Permiso>(sql, new { idRol });
            return list.ToList();
        }

        public async Task<List<string>> GetCodigosByUsuarioAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("w_idUsuario", idUsuario);
            var result = await conn.QueryAsync<string>(
                "sp_tkt_permisos_por_usuario",
                parameters,
                commandType: System.Data.CommandType.StoredProcedure);
            return result.ToList();
        }

        public async Task<bool> UpdateAsync(Permiso entity)
        {
            using var conn = CreateConnection();
            await conn.ExecuteAsync(
                "sp_permiso_guardar",
                new { p_idPermiso = entity.Id_Permiso, p_codigo = entity.Codigo, p_descripcion = entity.Descripcion },
                commandType: System.Data.CommandType.StoredProcedure);
            return true;
        }

        // ── Nuevos métodos RBAC ──────────────────────────────────────

        public async Task<List<PermisoListDTO>> ListarPermisosAsync()
        {
            using var conn = CreateConnection();
            var list = await conn.QueryAsync<PermisoListDTO>(
                "sp_permiso_listar",
                commandType: System.Data.CommandType.StoredProcedure);
            return list.ToList();
        }

        public async Task<PermisoListDTO> GuardarPermisoAsync(int? idPermiso, string codigo, string descripcion)
        {
            using var conn = CreateConnection();
            return await conn.QuerySingleAsync<PermisoListDTO>(
                "sp_permiso_guardar",
                new { p_idPermiso = idPermiso ?? 0, p_codigo = codigo, p_descripcion = descripcion },
                commandType: System.Data.CommandType.StoredProcedure);
        }
    }
}
