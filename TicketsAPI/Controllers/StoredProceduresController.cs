using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using System.Data;

namespace TicketsAPI.Controllers
{
    [ApiController]
    [Route("api/sp")]
    [Authorize]
    public class StoredProceduresController : BaseApiController
    {
        private readonly string _connectionString;

        public StoredProceduresController(IConfiguration configuration, ILogger<StoredProceduresController> logger) : base(logger)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection")
                ?? configuration.GetSection("ApiSettings").GetValue<string>("ConnectionString")
                ?? configuration.GetConnectionString("DbTkt")
                ?? configuration.GetValue<string>("ConnectionString")
                ?? throw new InvalidOperationException("ConnectionString no configurada");
        }

        [HttpGet]
        public async Task<IActionResult> ListAsync([FromQuery] string? schema = null)
        {
            try
            {
                schema ??= await GetDefaultDatabaseAsync();
                const string sql = @"SELECT ROUTINE_NAME AS Nombre, CREATED AS Creado, LAST_ALTERED AS Modificado
                                  FROM INFORMATION_SCHEMA.ROUTINES
                                  WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_SCHEMA=@schema
                                  ORDER BY ROUTINE_NAME";

                await using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();
                await using var cmd = new MySqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@schema", schema);
                var list = new List<object>();
                await using var reader = await cmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    list.Add(new
                    {
                        Nombre = reader["Nombre"].ToString(),
                        Creado = reader["Creado"],
                        Modificado = reader["Modificado"]
                    });
                }
                return Success(list, "Procedimientos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al listar procedimientos almacenados");
                return Error<object>("Error al listar procedimientos", new List<string> { ex.Message }, 500);
            }
        }

        [HttpGet("{name}")]
        public async Task<IActionResult> DetailAsync(string name, [FromQuery] string? schema = null)
        {
            try
            {
                schema ??= await GetDefaultDatabaseAsync();
                const string sql = @"SELECT ROUTINE_SCHEMA, ROUTINE_NAME, CREATED, LAST_ALTERED, SQL_MODE, DEFINER
                                  FROM INFORMATION_SCHEMA.ROUTINES
                                  WHERE ROUTINE_TYPE='PROCEDURE' AND ROUTINE_SCHEMA=@schema AND ROUTINE_NAME=@name";

                await using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();
                await using var cmd = new MySqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@schema", schema);
                cmd.Parameters.AddWithValue("@name", name);
                await using var reader = await cmd.ExecuteReaderAsync(CommandBehavior.SingleRow);
                if (!await reader.ReadAsync())
                    return Error<object>("Procedimiento no encontrado", statusCode: 404);

                var detalle = new
                {
                    Schema = reader["ROUTINE_SCHEMA"].ToString(),
                    Nombre = reader["ROUTINE_NAME"].ToString(),
                    Creado = reader["CREATED"],
                    Modificado = reader["LAST_ALTERED"],
                    SqlMode = reader["SQL_MODE"].ToString(),
                    Definer = reader["DEFINER"].ToString()
                };
                return Success(detalle, "Procedimiento obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener detalle de procedimiento");
                return Error<object>("Error al obtener procedimiento", new List<string> { ex.Message }, 500);
            }
        }

        public class ExecuteSpRequest
        {
            public Dictionary<string, object>? Params { get; set; }
        }

        [HttpPost("{name}/execute")]
        public async Task<IActionResult> ExecuteAsync(string name, [FromBody] ExecuteSpRequest request)
        {
            try
            {
                await using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();
                await using var cmd = new MySqlCommand(name, conn) { CommandType = CommandType.StoredProcedure };

                if (request?.Params != null)
                {
                    foreach (var kv in request.Params)
                    {
                        var p = new MySqlParameter(kv.Key, kv.Value ?? DBNull.Value);
                        cmd.Parameters.Add(p);
                    }
                }

                // Try to read result set if any; else return affected rows
                try
                {
                    var results = new List<Dictionary<string, object?>>();
                    await using var reader = await cmd.ExecuteReaderAsync();
                    while (await reader.ReadAsync())
                    {
                        var row = new Dictionary<string, object?>();
                        for (int i = 0; i < reader.FieldCount; i++)
                        {
                            row[reader.GetName(i)] = reader.IsDBNull(i) ? null : reader.GetValue(i);
                        }
                        results.Add(row);
                    }
                    return Success(new { datos = results, filas = results.Count }, "Procedimiento ejecutado exitosamente");
                }
                catch (MySqlException)
                {
                    var affected = await cmd.ExecuteNonQueryAsync();
                    return Success(new { filasAfectadas = affected }, "Procedimiento ejecutado (sin resultset)");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al ejecutar procedimiento almacenado {Name}", name);
                return Error<object>($"Error al ejecutar {name}", new List<string> { ex.Message }, 500);
            }
        }

        private async Task<string> GetDefaultDatabaseAsync()
        {
            await using var conn = new MySqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = new MySqlCommand("SELECT DATABASE()", conn);
            var db = await cmd.ExecuteScalarAsync();
            return db?.ToString() ?? "cdk_tkt";
        }
    }
}
