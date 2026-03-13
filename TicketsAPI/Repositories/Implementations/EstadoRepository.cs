using Dapper;
using MySqlConnector;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class EstadoRepository : BaseRepository, IEstadoRepository
    {
        private const string SQL_SELECT_ALL = @"
            SELECT
                Id_Estado,
                TipoEstado AS Nombre_Estado,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo
            FROM estado
            ORDER BY Id_Estado";

        private const string SQL_SELECT_ACTIVE = @"
            SELECT
                Id_Estado,
                TipoEstado AS Nombre_Estado,
                COALESCE(Descripcion, '') AS Descripcion,
                1 AS Activo
            FROM estado
            WHERE Habilitado = 1
            ORDER BY Id_Estado";

        private const string SQL_SELECT_BY_ID = @"
            SELECT
                Id_Estado,
                TipoEstado AS Nombre_Estado,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo
            FROM estado
            WHERE Id_Estado = @id";

        private const string SQL_SELECT_BY_NOMBRE = @"
            SELECT
                Id_Estado,
                TipoEstado AS Nombre_Estado,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo
            FROM estado
            WHERE TipoEstado = @nombre";

        public EstadoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Estado entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_tipo_estado", entity.Nombre_Estado);
            parameters.Add("p_id", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 100, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_estado_crear", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado");
            if (resultado.StartsWith("Error:"))
                throw new Exception(resultado);

            return parameters.Get<int>("p_id");
        }

        /// <summary>
        /// Soft-delete: toggle Habilitado via SP (protege Abierto/Cerrado).
        /// </summary>
        public async Task<bool> DeleteAsync(int id)
        {
            return await ToggleStatusAsync(id);
        }

        public async Task<List<Estado>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var result = await conn.QueryAsync<Estado>(SQL_SELECT_ALL);
            return result.ToList();
        }

        public async Task<List<Estado>> GetAllActiveAsync()
        {
            using var conn = CreateConnection();
            var result = await conn.QueryAsync<Estado>(SQL_SELECT_ACTIVE);
            return result.ToList();
        }

        public async Task<Estado?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            return await conn.QueryFirstOrDefaultAsync<Estado>(SQL_SELECT_BY_ID, new { id });
        }

        public async Task<Estado?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            return await conn.QueryFirstOrDefaultAsync<Estado>(SQL_SELECT_BY_NOMBRE, new { nombre });
        }

        public async Task<bool> UpdateAsync(Estado entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id", entity.Id_Estado);
            parameters.Add("p_nombre", entity.Nombre_Estado);
            parameters.Add("p_descripcion", entity.Descripcion ?? string.Empty);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 255, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_editar_estado", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado") ?? string.Empty;
            if (!resultado.Equals("OK", StringComparison.OrdinalIgnoreCase))
                throw new Exception(resultado);

            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            using var conn = CreateConnection();
            var count = await conn.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM estado WHERE Id_Estado = @id", new { id });
            return count > 0;
        }

        /// <summary>
        /// Toggle soft-delete via SP sp_toggle_estado.
        /// Protege estados Abierto y Cerrado de ser desactivados.
        /// </summary>
        public async Task<bool> ToggleStatusAsync(int id)
        {
            using var conn = CreateConnection();

            var current = await conn.ExecuteScalarAsync<int?>(
                "SELECT Habilitado FROM estado WHERE Id_Estado = @id", new { id });

            if (current == null)
                return false;

            // Proteger estados críticos
            if (current == 1)
            {
                var nombre = await conn.ExecuteScalarAsync<string>(
                    "SELECT TipoEstado FROM estado WHERE Id_Estado = @id", new { id });
                if (nombre == "Abierto" || nombre == "Cerrado")
                    throw new Exception("Error: No se puede desactivar el estado crítico '" + nombre + "'");
            }

            if (current == 1)
            {
                await conn.ExecuteAsync(
                    "UPDATE estado SET Habilitado = 0, fechaBaja = NOW() WHERE Id_Estado = @id",
                    new { id });
            }
            else
            {
                await conn.ExecuteAsync(
                    "UPDATE estado SET Habilitado = 1, fechaBaja = NULL WHERE Id_Estado = @id",
                    new { id });
            }

            return true;
        }
    }
}
