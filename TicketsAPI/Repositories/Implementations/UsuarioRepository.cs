using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class UsuarioRepository : BaseRepository, IUsuarioRepository
    {
        public UsuarioRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Usuario entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_nombre", entity.Nombre);
            parameters.Add("p_email", entity.Email);
            parameters.Add("p_password", entity.Contraseña);
            parameters.Add("p_id_departamento", entity.Id_Departamento);
            parameters.Add("p_id_rol", entity.Id_Rol);
            parameters.Add("p_id", dbType: System.Data.DbType.Int64, direction: System.Data.ParameterDirection.Output);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 100, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_agregar_usuario", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado");
            if (resultado.StartsWith("Error:"))
            {
                throw new Exception(resultado);
            }

            return (int)parameters.Get<long>("p_id");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id_usuario", id);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 100, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_eliminar_usuario", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado");
            if (resultado.StartsWith("Error:"))
            {
                throw new Exception(resultado);
            }

            return resultado == "success";
        }

        public async Task<List<Usuario>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var result = await conn.QueryAsync<Usuario>("sp_obtener_usuarios", commandType: System.Data.CommandType.StoredProcedure);
            return result.ToList();
        }

        public async Task<Usuario?> GetByEmailAsync(string email)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    u.idUsuario AS Id_Usuario,
                    u.nombre AS Nombre,
                    u.email AS Email,
                    u.passwordUsuarioEnc AS Contraseña,
                    COALESCE(u.Id_Departamento, u.idKine) AS Id_Departamento,
                    COALESCE(ur.idRol, 0) AS Id_Rol,
                    CASE WHEN u.fechaBaja IS NULL THEN 1 ELSE 0 END AS Activo
                FROM usuario u
                LEFT JOIN usuario_rol ur ON u.idUsuario = ur.idUsuario
                WHERE u.email = @email LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<Usuario>(sql, new { email });
        }

        public async Task<Usuario?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    u.idUsuario AS Id_Usuario,
                    u.nombre AS Nombre,
                    u.email AS Email,
                    u.passwordUsuarioEnc AS Contraseña,
                    COALESCE(u.Id_Departamento, u.idKine) AS Id_Departamento,
                    COALESCE(ur.idRol, 0) AS Id_Rol,
                    CASE WHEN u.fechaBaja IS NULL THEN 1 ELSE 0 END AS Activo
                FROM usuario u
                LEFT JOIN usuario_rol ur ON u.idUsuario = ur.idUsuario
                WHERE u.idUsuario = @id";
            return await conn.QuerySingleOrDefaultAsync<Usuario>(sql, new { id });
        }

        public async Task<Usuario?> GetByUsuarioAsync(string usuario)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    u.idUsuario AS Id_Usuario,
                    u.nombre AS Nombre,
                    u.email AS Email,
                    u.passwordUsuarioEnc AS Contraseña,
                    COALESCE(u.Id_Departamento, u.idKine) AS Id_Departamento,
                    COALESCE(ur.idRol, 0) AS Id_Rol,
                    CASE WHEN u.fechaBaja IS NULL THEN 1 ELSE 0 END AS Activo
                FROM usuario u
                LEFT JOIN usuario_rol ur ON u.idUsuario = ur.idUsuario
                WHERE u.nombre = @usuario LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<Usuario>(sql, new { usuario });
        }

        public async Task<List<Usuario>> GetByRolAsync(int idRol)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    idUsuario AS Id_Usuario,
                    nombre AS Nombre,
                    email AS Email,
                    passwordUsuarioEnc AS Contraseña,
                    idKine AS Id_Departamento,
                    CAST(CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END AS SIGNED) AS Id_Rol
                FROM usuario WHERE CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END = @idRol";
            var result = await conn.QueryAsync<Usuario>(sql, new { idRol });
            return result.ToList();
        }

        public async Task<List<Usuario>> GetByDepartamentoAsync(int idDepartamento)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    idUsuario AS Id_Usuario,
                    nombre AS Nombre,
                    email AS Email,
                    passwordUsuarioEnc AS Contraseña,
                    idKine AS Id_Departamento,
                    CAST(CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END AS SIGNED) AS Id_Rol
                FROM usuario WHERE idKine = @idDepartamento";
            var result = await conn.QueryAsync<Usuario>(sql, new { idDepartamento });
            return result.ToList();
        }

        public async Task<List<Usuario>> GetFilteredAsync(string? nombre, string? email, string? tipo, int? habilitado)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("w_nombre", nombre ?? string.Empty);
            parameters.Add("w_email", email ?? string.Empty);
            parameters.Add("w_tipoID", string.IsNullOrWhiteSpace(tipo) ? "0" : tipo);
            parameters.Add("w_habilitado", habilitado ?? -1);

            var result = await conn.QueryAsync<Usuario>(
                "sp_listar_usuario",
                parameters,
                commandType: System.Data.CommandType.StoredProcedure);

            return result.ToList();
        }

        public async Task<bool> UpdateAsync(Usuario entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id_usuario", entity.Id_Usuario);
            parameters.Add("p_nombre", entity.Nombre);
            parameters.Add("p_email", entity.Email);
            parameters.Add("p_password", entity.Contraseña);
            parameters.Add("p_id_departamento", entity.Id_Departamento);
            parameters.Add("p_id_rol", entity.Id_Rol);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 100, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_editar_usuario", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado");
            if (resultado.StartsWith("Error:"))
            {
                throw new Exception(resultado);
            }

            return resultado == "success";
        }

        public async Task<bool> UpdateLastSessionAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "UPDATE usuario SET fechaAlta = NOW() WHERE idUsuario = @idUsuario";
            var rows = await conn.ExecuteAsync(sql, new { idUsuario });
            return rows > 0;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT COUNT(*) FROM usuario WHERE idUsuario = @id";
            var count = await conn.ExecuteScalarAsync<int>(sql, new { id });
            return count > 0;
        }

        public async Task<bool> SaveRefreshTokenAsync(int idUsuario, string refreshTokenHash, DateTime expiresAt)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE usuario SET 
                                refresh_token_hash = @refreshTokenHash, 
                                refresh_token_expires = @expiresAt,
                                last_login = NOW()
                                WHERE idUsuario = @idUsuario";
            var rows = await conn.ExecuteAsync(sql, new { idUsuario, refreshTokenHash, expiresAt });
            return rows > 0;
        }

        public async Task<Usuario?> GetByRefreshTokenAsync(string refreshTokenHash)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    idUsuario AS Id_Usuario,
                    nombre AS Nombre,
                    email AS Email,
                    passwordUsuarioEnc AS Contraseña,
                    idKine AS Id_Departamento,
                    CAST(CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END AS SIGNED) AS Id_Rol,
                    refresh_token_hash AS RefreshTokenHash,
                    refresh_token_expires AS RefreshTokenExpires
                FROM usuario WHERE refresh_token_hash = @refreshTokenHash LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<Usuario>(sql, new { refreshTokenHash });
        }

        public async Task<bool> ClearRefreshTokenAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE usuario SET 
                                refresh_token_hash = NULL, 
                                refresh_token_expires = NULL
                                WHERE idUsuario = @idUsuario";
            var rows = await conn.ExecuteAsync(sql, new { idUsuario });
            return rows > 0;
        }

        public async Task<bool> UpdatePasswordHashAsync(int idUsuario, string newHash)
        {
            using var conn = CreateConnection();
            const string sql = "UPDATE usuario SET passwordUsuarioEnc = @newHash WHERE idUsuario = @idUsuario";
            var rows = await conn.ExecuteAsync(sql, new { idUsuario, newHash });
            return rows > 0;
        }

        /// D2: Trae todos los usuarios con Rol y Departamento en 1 sola consulta JOIN.
        /// Elimina el problema N+1 de GetAllAsync + foreach GetByIdAsync(rol) + GetByIdAsync(depto).
        /// Sintaxis compatible con MySQL 5.5 (sin CTEs ni funciones de ventana).
        public async Task<List<Usuario>> GetAllWithRelationsAsync()
        {
            using var conn = CreateConnection();
            const string sql = @"
                SELECT 
                    u.idUsuario  AS Id_Usuario,
                    u.nombre     AS Nombre,
                    u.email      AS Email,
                    u.passwordUsuarioEnc AS Contraseña,
                    COALESCE(u.Id_Departamento, u.idKine) AS Id_Departamento,
                    COALESCE(ur.idRol, 0) AS Id_Rol,
                    CASE WHEN u.fechaBaja IS NULL THEN 1 ELSE 0 END AS Activo,
                    r.idRol      AS Id_Rol,
                    r.nombre     AS Nombre_Rol,
                    d.Id_Departamento,
                    d.Nombre
                FROM usuario u
                LEFT JOIN usuario_rol ur ON u.idUsuario = ur.idUsuario
                LEFT JOIN rol r          ON ur.idRol    = r.idRol
                LEFT JOIN departamento d ON COALESCE(u.Id_Departamento, u.idKine) = d.Id_Departamento
                ORDER BY u.idUsuario";

            var usuarios = await conn.QueryAsync<Usuario, Rol, Departamento, Usuario>(
                sql,
                (usuario, rol, departamento) =>
                {
                    usuario.Rol = rol?.Id_Rol > 0 ? rol : null;
                    usuario.Departamento = departamento?.Id_Departamento > 0 ? departamento : null;
                    return usuario;
                },
                splitOn: "Id_Rol,Id_Departamento"
            );

            return usuarios.ToList();
        }

        /// Toggle soft-delete: si fechaBaja IS NULL → CURDATE(); si ya tiene fecha → NULL.
        /// Compatible con MySQL 5.5.
        public async Task<bool> ToggleActiveAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = @"
                UPDATE usuario 
                SET fechaBaja = CASE 
                    WHEN fechaBaja IS NULL THEN CURDATE() 
                    ELSE NULL 
                END 
                WHERE idUsuario = @idUsuario";
            var rows = await conn.ExecuteAsync(sql, new { idUsuario });
            return rows > 0;
        }

        public async Task<(int idEmpresa, int idSucursal, int idPerfil)?> GetUsuarioContextoAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("w_usuarioID", idUsuario);
            parameters.Add("w_empresaID", -1);
            parameters.Add("w_sucursalID", -1);
            parameters.Add("w_sistemaID", "CDK_TKT");
            parameters.Add("w_perfilID", 0);
            parameters.Add("w_habilitado", 1);

            var result = await conn.QueryFirstOrDefaultAsync<dynamic>(
                "sp_listar_UsuEmpSucPerSis",
                parameters,
                commandType: System.Data.CommandType.StoredProcedure);

            if (result == null)
            {
                var fallback = new DynamicParameters();
                fallback.Add("w_usuarioID", idUsuario);
                fallback.Add("w_empresaID", -1);
                fallback.Add("w_sucursalID", -1);
                fallback.Add("w_sistemaID", "CDK_TKT");
                fallback.Add("w_perfilID", 0);
                fallback.Add("w_habilitado", -1);

                result = await conn.QueryFirstOrDefaultAsync<dynamic>(
                    "sp_listar_UsuEmpSucPerSis",
                    fallback,
                    commandType: System.Data.CommandType.StoredProcedure);
            }

            if (result == null)
                return null;

            return ((int)result.idEmpresa, (int)result.idSucursal, (int)result.idPerfil);
        }

        public async Task<bool> ResetPasswordAsync(int idUsuarioTarget, string nuevoPasswordHash, int idUsuarioAdmin)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id_usuario_target", idUsuarioTarget);
            parameters.Add("p_nuevo_password_hash", nuevoPasswordHash);
            parameters.Add("p_id_usuario_admin", idUsuarioAdmin);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 200, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_usuario_reset_password", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado");
            if (resultado.StartsWith("Error:"))
                throw new Exception(resultado);

            return resultado == "success";
        }
    }
}

