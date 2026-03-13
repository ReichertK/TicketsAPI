using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class PrioridadRepository : BaseRepository, IPrioridadRepository
    {
        private const string SQL_SELECT_ALL = @"
            SELECT
                Id_Prioridad,
                NombrePrioridad AS Nombre_Prioridad,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo
            FROM prioridad
            ORDER BY Id_Prioridad";

        private const string SQL_SELECT_ACTIVE = @"
            SELECT
                Id_Prioridad,
                NombrePrioridad AS Nombre_Prioridad,
                COALESCE(Descripcion, '') AS Descripcion,
                1 AS Activo
            FROM prioridad
            WHERE Habilitado = 1
            ORDER BY Id_Prioridad";

        private const string SQL_SELECT_BY_ID = @"
            SELECT
                Id_Prioridad,
                NombrePrioridad AS Nombre_Prioridad,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo
            FROM prioridad
            WHERE Id_Prioridad = @id";

        private const string SQL_SELECT_BY_NOMBRE = @"
            SELECT
                Id_Prioridad,
                NombrePrioridad AS Nombre_Prioridad,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo
            FROM prioridad
            WHERE NombrePrioridad = @nombre";

        public PrioridadRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Prioridad entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_nombre_prioridad", entity.Nombre_Prioridad);
            parameters.Add("p_id", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 100, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_prioridad_crear", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado");
            if (resultado.StartsWith("Error:"))
                throw new Exception(resultado);

            return parameters.Get<int>("p_id");
        }

        /// <summary>
        /// Soft-delete: toggle Habilitado.
        /// </summary>
        public async Task<bool> DeleteAsync(int id)
        {
            return await ToggleStatusAsync(id);
        }

        public async Task<List<Prioridad>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var result = await conn.QueryAsync<Prioridad>(SQL_SELECT_ALL);
            return result.ToList();
        }

        public async Task<List<Prioridad>> GetAllActiveAsync()
        {
            using var conn = CreateConnection();
            var result = await conn.QueryAsync<Prioridad>(SQL_SELECT_ACTIVE);
            return result.ToList();
        }

        public async Task<Prioridad?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            return await conn.QueryFirstOrDefaultAsync<Prioridad>(SQL_SELECT_BY_ID, new { id });
        }

        public async Task<Prioridad?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            return await conn.QueryFirstOrDefaultAsync<Prioridad>(SQL_SELECT_BY_NOMBRE, new { nombre });
        }

        public async Task<bool> UpdateAsync(Prioridad entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id", entity.Id_Prioridad);
            parameters.Add("p_nombre", entity.Nombre_Prioridad);
            parameters.Add("p_descripcion", entity.Descripcion ?? string.Empty);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 255, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_editar_prioridad", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado") ?? string.Empty;
            if (!resultado.Equals("OK", StringComparison.OrdinalIgnoreCase))
                throw new Exception(resultado);

            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            using var conn = CreateConnection();
            var count = await conn.ExecuteScalarAsync<int>(
                "SELECT COUNT(*) FROM prioridad WHERE Id_Prioridad = @id", new { id });
            return count > 0;
        }

        /// <summary>
        /// Toggle soft-delete: si Habilitado = 1 → pone 0 + fecha; si 0 → pone 1 + limpia fecha.
        /// </summary>
        public async Task<bool> ToggleStatusAsync(int id)
        {
            using var conn = CreateConnection();

            var current = await conn.ExecuteScalarAsync<int?>(
                "SELECT Habilitado FROM prioridad WHERE Id_Prioridad = @id", new { id });

            if (current == null)
                return false;

            if (current == 1)
            {
                await conn.ExecuteAsync(
                    "UPDATE prioridad SET Habilitado = 0, fechaBaja = NOW() WHERE Id_Prioridad = @id",
                    new { id });
            }
            else
            {
                await conn.ExecuteAsync(
                    "UPDATE prioridad SET Habilitado = 1, fechaBaja = NULL WHERE Id_Prioridad = @id",
                    new { id });
            }

            return true;
        }
    }
}
