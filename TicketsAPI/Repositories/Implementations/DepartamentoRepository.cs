using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class DepartamentoRepository : BaseRepository, IDepartamentoRepository
    {
        private const string SQL_SELECT_ALL = @"
            SELECT
                Id_Departamento,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo,
                fechaBaja
            FROM departamento
            ORDER BY Nombre ASC";

        private const string SQL_SELECT_ACTIVE = @"
            SELECT
                Id_Departamento,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                1 AS Activo
            FROM departamento
            WHERE Habilitado = 1
            ORDER BY Nombre ASC";

        private const string SQL_SELECT_BY_ID = @"
            SELECT
                Id_Departamento,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo,
                fechaBaja
            FROM departamento
            WHERE Id_Departamento = @id";

        private const string SQL_SELECT_BY_NOMBRE = @"
            SELECT
                Id_Departamento,
                Nombre,
                COALESCE(Descripcion, '') AS Descripcion,
                Habilitado AS Activo,
                fechaBaja
            FROM departamento
            WHERE Nombre = @nombre";

        public DepartamentoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Departamento entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_nombre", entity.Nombre);
            parameters.Add("p_id", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 255, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_departamento_crear", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado") ?? string.Empty;
            if (!resultado.Equals("OK", StringComparison.OrdinalIgnoreCase))
                throw new Exception(resultado);

            var newId = parameters.Get<int>("p_id");

            // Actualizar descripción si fue proporcionada (el SP de crear no la maneja)
            if (!string.IsNullOrWhiteSpace(entity.Descripcion))
            {
                await conn.ExecuteAsync(
                    "UPDATE departamento SET Descripcion = @desc WHERE Id_Departamento = @id",
                    new { desc = entity.Descripcion, id = newId });
            }

            return newId;
        }

        /// Soft-delete: toggle Habilitado 1↔0 y gestiona fechaBaja.
        /// Retorna true si la operación fue exitosa.
        public async Task<bool> DeleteAsync(int id)
        {
            // Usamos ToggleStatusAsync para soft-delete
            return await ToggleStatusAsync(id);
        }

        /// Retorna TODOS los departamentos (activos + inactivos).
        public async Task<List<Departamento>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var list = await conn.QueryAsync<Departamento>(SQL_SELECT_ALL);
            return list.ToList();
        }

        /// Retorna solo los departamentos con Habilitado = 1.
        public async Task<List<Departamento>> GetAllActiveAsync()
        {
            using var conn = CreateConnection();
            var list = await conn.QueryAsync<Departamento>(SQL_SELECT_ACTIVE);
            return list.ToList();
        }

        public async Task<Departamento?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            return await conn.QueryFirstOrDefaultAsync<Departamento>(SQL_SELECT_BY_ID, new { id });
        }

        public async Task<Departamento?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            return await conn.QueryFirstOrDefaultAsync<Departamento>(SQL_SELECT_BY_NOMBRE, new { nombre });
        }

        public async Task<bool> UpdateAsync(Departamento entity)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id", entity.Id_Departamento);
            parameters.Add("p_nombre", entity.Nombre);
            parameters.Add("p_descripcion", entity.Descripcion ?? string.Empty);
            parameters.Add("p_resultado", dbType: System.Data.DbType.String, size: 255, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_departamento_actualizar", parameters, commandType: System.Data.CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado") ?? string.Empty;
            if (!resultado.Equals("OK", StringComparison.OrdinalIgnoreCase))
                throw new Exception(resultado);

            return true;
        }

        /// Toggle soft-delete: si Habilitado = 1 → pone 0 + fecha; si 0 → pone 1 + limpia fecha.
        public async Task<bool> ToggleStatusAsync(int id)
        {
            using var conn = CreateConnection();

            // Obtener estado actual
            var current = await conn.ExecuteScalarAsync<int?>(
                "SELECT Habilitado FROM departamento WHERE Id_Departamento = @id", new { id });

            if (current == null)
                return false;

            if (current == 1)
            {
                await conn.ExecuteAsync(
                    "UPDATE departamento SET Habilitado = 0, fechaBaja = NOW() WHERE Id_Departamento = @id",
                    new { id });
            }
            else
            {
                await conn.ExecuteAsync(
                    "UPDATE departamento SET Habilitado = 1, fechaBaja = NULL WHERE Id_Departamento = @id",
                    new { id });
            }

            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT COUNT(*) FROM departamento WHERE Id_Departamento = @id";
            var count = await conn.ExecuteScalarAsync<int>(sql, new { id });
            return count > 0;
        }
    }
}
