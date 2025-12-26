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
            const string sql = @"INSERT INTO usuario (nombre, telefono, email, nota, passwordUsuario, passwordUsuarioEnc, firma, firma_aclaracion, fechaAlta, fechaBaja, tipo, idCliente, idKine)
                                VALUES (@Nombre, NULL, @Email, NULL, @Contraseña, NULL, NULL, NULL, @Fecha_Registro, NULL, 'INT', 0, 0);
                                SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "DELETE FROM usuario WHERE idUsuario = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Usuario>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    idUsuario AS Id_Usuario,
                    nombre AS Nombre,
                    email AS Email,
                    passwordUsuarioEnc AS Contraseña,
                    idKine AS Id_Departamento,
                    CAST(CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END AS SIGNED) AS Id_Rol
                FROM usuario";
            var result = await conn.QueryAsync<Usuario>(sql);
            return result.ToList();
        }

        public async Task<Usuario?> GetByEmailAsync(string email)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    idUsuario AS Id_Usuario,
                    nombre AS Nombre,
                    email AS Email,
                    passwordUsuarioEnc AS Contraseña,
                    idKine AS Id_Departamento,
                    CAST(CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END AS SIGNED) AS Id_Rol
                FROM usuario WHERE email = @email LIMIT 1";
            return await conn.QuerySingleOrDefaultAsync<Usuario>(sql, new { email });
        }

        public async Task<Usuario?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    idUsuario AS Id_Usuario,
                    nombre AS Nombre,
                    email AS Email,
                    passwordUsuarioEnc AS Contraseña,
                    idKine AS Id_Departamento,
                    CAST(CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END AS SIGNED) AS Id_Rol
                FROM usuario WHERE idUsuario = @id";
            return await conn.QuerySingleOrDefaultAsync<Usuario>(sql, new { id });
        }

        public async Task<Usuario?> GetByUsuarioAsync(string usuario)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                    idUsuario AS Id_Usuario,
                    nombre AS Nombre,
                    email AS Email,
                    passwordUsuarioEnc AS Contraseña,
                    idKine AS Id_Departamento,
                    CAST(CASE WHEN tipo = 'ADM' THEN 1 WHEN tipo = 'TEC' THEN 2 WHEN tipo = 'USU' THEN 3 ELSE 0 END AS SIGNED) AS Id_Rol
                FROM usuario WHERE nombre = @usuario LIMIT 1";
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

        public async Task<bool> UpdateAsync(Usuario entity)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE usuario SET
                                nombre=@Nombre, email=@Email, passwordUsuario=@Contraseña,
                                fechaAlta=@Fecha_Registro
                                WHERE idUsuario=@Id_Usuario";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
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
    }
}

