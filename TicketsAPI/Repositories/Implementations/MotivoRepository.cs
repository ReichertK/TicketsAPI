using Dapper;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class MotivoRepository : BaseRepository, IMotivoRepository
    {
        private const string SQL_SELECT_ALL = @"
            SELECT
                Id_Motivo,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                Categoria,
                Habilitado AS Activo
            FROM motivo
            ORDER BY Nombre ASC";

        private const string SQL_SELECT_ACTIVE = @"
            SELECT
                Id_Motivo,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                Categoria,
                1 AS Activo
            FROM motivo
            WHERE Habilitado = 1
            ORDER BY Nombre ASC";

        private const string SQL_SELECT_BY_ID = @"
            SELECT
                Id_Motivo,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                Categoria,
                Habilitado AS Activo
            FROM motivo
            WHERE Id_Motivo = @id";

        private const string SQL_SELECT_BY_NOMBRE = @"
            SELECT
                Id_Motivo,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                Categoria,
                Habilitado AS Activo
            FROM motivo
            WHERE Nombre = @nombre";

        public MotivoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Motivo entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_nombre", entity.Nombre);
            parameters.Add("p_categoria", entity.Categoria);
            parameters.Add("p_id", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 255, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_motivo_crear", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado") ?? string.Empty;
            if (!resultado.Equals("OK", StringComparison.OrdinalIgnoreCase))
                throw new Exception(resultado);

            var newId = parameters.Get<int>("p_id");

            // Actualizar descripción si fue proporcionada
            if (!string.IsNullOrWhiteSpace(entity.Descripcion))
            {
                await conn.ExecuteAsync(
                    "UPDATE motivo SET Descripcion = @desc WHERE Id_Motivo = @id",
                    new { desc = entity.Descripcion, id = newId });
            }

            return newId;
        }

        /// Soft-delete: toggle Habilitado.
        public async Task<bool> DeleteAsync(int id)
        {
            return await ToggleStatusAsync(id);
        }

        public async Task<List<Motivo>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var result = await conn.QueryAsync<Motivo>(SQL_SELECT_ALL);
            return result.ToList();
        }

        public async Task<List<Motivo>> GetAllActiveAsync()
        {
            using var conn = CreateConnection();
            var result = await conn.QueryAsync<Motivo>(SQL_SELECT_ACTIVE);
            return result.ToList();
        }

        public async Task<Motivo?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            return await conn.QuerySingleOrDefaultAsync<Motivo>(SQL_SELECT_BY_ID, new { id });
        }

        public async Task<Motivo?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            return await conn.QuerySingleOrDefaultAsync<Motivo>(SQL_SELECT_BY_NOMBRE, new { nombre });
        }

        public async Task<List<Motivo>> GetByCategoriaAsync(string categoria)
        {
            using var conn = CreateConnection();
            const string sql = @"
                SELECT Id_Motivo, Nombre, COALESCE(Descripcion,'') AS Descripcion, Categoria, Habilitado AS Activo
                FROM motivo WHERE Categoria = @categoria ORDER BY Nombre";
            var result = await conn.QueryAsync<Motivo>(sql, new { categoria });
            return result.ToList();
        }

        public async Task<bool> UpdateAsync(Motivo entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id", entity.Id_Motivo);
            parameters.Add("p_nombre", entity.Nombre);
            parameters.Add("p_descripcion", entity.Descripcion ?? string.Empty);
            parameters.Add("p_categoria", entity.Categoria);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 255, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_editar_motivo", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado") ?? string.Empty;
            if (!resultado.Equals("OK", StringComparison.OrdinalIgnoreCase))
                throw new Exception(resultado);

            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            using var conn = CreateConnection();
            var count = await conn.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM motivo WHERE Id_Motivo = @id", new { id });
            return count > 0;
        }

        /// Toggle soft-delete: si Habilitado = 1 → pone 0 + fecha; si 0 → pone 1 + limpia fecha.
        public async Task<bool> ToggleStatusAsync(int id)
        {
            using var conn = CreateConnection();

            var current = await conn.ExecuteScalarAsync<int?>(
                "SELECT Habilitado FROM motivo WHERE Id_Motivo = @id", new { id });

            if (current == null)
                return false;

            if (current == 1)
            {
                await conn.ExecuteAsync(
                    "UPDATE motivo SET Habilitado = 0, fechaBaja = NOW() WHERE Id_Motivo = @id",
                    new { id });
            }
            else
            {
                await conn.ExecuteAsync(
                    "UPDATE motivo SET Habilitado = 1, fechaBaja = NULL WHERE Id_Motivo = @id",
                    new { id });
            }

            return true;
        }

        public async Task<List<Motivo>> GetByDepartamentoAsync(int idDepartamento)
        {
            using var conn = CreateConnection();
            var motivos = await conn.QueryAsync<Motivo>(
                "SELECT Id_Motivo, Nombre, COALESCE(Descripcion, '') AS Descripcion, Categoria, Habilitado AS Activo " +
                "FROM motivo WHERE id_departamento = @idDepartamento AND Habilitado = 1 ORDER BY Nombre",
                new { idDepartamento });
            return motivos.ToList();
        }
    }
}
