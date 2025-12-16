using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using System.Data;

namespace TicketsAPI.Controllers
{
    [ApiController]
    [Route("api/sp")]
    [Authorize]
    public class StoredProceduresController : ControllerBase
    {
        private readonly string _connectionString;

        public StoredProceduresController(IConfiguration configuration)
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
            return Ok(list);
        }

        [HttpGet("{name}")]
        public async Task<IActionResult> DetailAsync(string name, [FromQuery] string? schema = null)
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
                return NotFound(new { mensaje = "Procedimiento no encontrado" });

            var detalle = new
            {
                Schema = reader["ROUTINE_SCHEMA"].ToString(),
                Nombre = reader["ROUTINE_NAME"].ToString(),
                Creado = reader["CREATED"],
                Modificado = reader["LAST_ALTERED"],
                SqlMode = reader["SQL_MODE"].ToString(),
                Definer = reader["DEFINER"].ToString()
            };
            return Ok(detalle);
        }

        public class ExecuteSpRequest
        {
            public Dictionary<string, object>? Params { get; set; }
        }

        [HttpPost("{name}/execute")]
        public async Task<IActionResult> ExecuteAsync(string name, [FromBody] ExecuteSpRequest request)
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
                return Ok(new { datos = results, filas = results.Count });
            }
            catch (MySqlException)
            {
                var affected = await cmd.ExecuteNonQueryAsync();
                return Ok(new { filasAfectadas = affected });
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
