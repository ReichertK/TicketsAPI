using Dapper;
using MySqlConnector;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Repositories.Implementations
{
    public class RolRepository : BaseRepository, IRolRepository
    {
        public RolRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Rol entity)
        {
            using var conn = CreateConnection();
            var result = await conn.QuerySingleAsync<dynamic>(
                "sp_rol_guardar",
                new { p_idRol = (int?)null, p_nombre = entity.Nombre_Rol },
                commandType: System.Data.CommandType.StoredProcedure);
            return Convert.ToInt32(result.idRol);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            await conn.ExecuteAsync(
                "sp_rol_eliminar",
                new { p_idRol = id },
                commandType: System.Data.CommandType.StoredProcedure);
            return true;
        }

        public async Task<List<Rol>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT idRol AS Id_Rol, nombre AS Nombre_Rol FROM rol ORDER BY idRol";
            var list = await conn.QueryAsync<Rol>(sql);
            return list.ToList();
        }

        public async Task<Rol?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT idRol AS Id_Rol, nombre AS Nombre_Rol FROM rol WHERE idRol = @id";
            return await conn.QuerySingleOrDefaultAsync<Rol>(sql, new { id });
        }

        public async Task<Rol?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            var sql = "SELECT idRol AS Id_Rol, nombre AS Nombre_Rol FROM rol WHERE nombre = @nombre";
            return await conn.QuerySingleOrDefaultAsync<Rol>(sql, new { nombre });
        }

        public async Task<Rol?> GetWithPermisosAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT idRol AS Id_Rol, nombre AS Nombre_Rol FROM rol WHERE idRol = @id";
            return await conn.QuerySingleOrDefaultAsync<Rol>(sql, new { id });
        }

        public async Task<bool> UpdateAsync(Rol entity)
        {
            using var conn = CreateConnection();
            await conn.ExecuteAsync(
                "sp_rol_guardar",
                new { p_idRol = entity.Id_Rol, p_nombre = entity.Nombre_Rol },
                commandType: System.Data.CommandType.StoredProcedure);
            return true;
        }

        // ── Nuevos métodos RBAC ──────────────────────────────────────

        public async Task<List<RolListDTO>> ListarRolesAsync()
        {
            using var conn = CreateConnection();
            var list = await conn.QueryAsync<RolListDTO>(
                "sp_rol_listar",
                commandType: System.Data.CommandType.StoredProcedure);
            return list.ToList();
        }

        public async Task<int> GuardarRolAsync(int? idRol, string nombre)
        {
            using var conn = CreateConnection();
            var result = await conn.QuerySingleAsync<dynamic>(
                "sp_rol_guardar",
                new { p_idRol = idRol ?? 0, p_nombre = nombre },
                commandType: System.Data.CommandType.StoredProcedure);
            return Convert.ToInt32(result.idRol);
        }

        public async Task EliminarRolAsync(int idRol)
        {
            using var conn = CreateConnection();
            await conn.ExecuteAsync(
                "sp_rol_eliminar",
                new { p_idRol = idRol },
                commandType: System.Data.CommandType.StoredProcedure);
        }

        public async Task<int> GestionarPermisosAsync(int idRol, string permisosCsv)
        {
            using var conn = CreateConnection();
            var result = await conn.QuerySingleAsync<dynamic>(
                "sp_rol_permiso_gestionar",
                new { p_idRol = idRol, p_permisos_csv = permisosCsv },
                commandType: System.Data.CommandType.StoredProcedure);
            return Convert.ToInt32(result.total_asignados);
        }

        public async Task AsignarRolAUsuarioAsync(int idUsuario, int idRol)
        {
            using var conn = CreateConnection();
            var sql = @"DELETE FROM usuario_rol WHERE idUsuario = @idUsuario;
                        INSERT INTO usuario_rol (idUsuario, idRol) VALUES (@idUsuario, @idRol)";
            await conn.ExecuteAsync(sql, new { idUsuario, idRol });
        }
    }
}
