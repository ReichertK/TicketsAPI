using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using System.Data;

namespace TicketsAPI.Controllers
{
    [ApiController]
    [Route("api/admin")]
    public class AdminController : ControllerBase
    {
        private readonly string _connectionString;

        public AdminController(IConfiguration configuration)
        {
            // Priorizar DbTkt para entorno local
            _connectionString = configuration.GetConnectionString("DbTkt")
                ?? configuration.GetConnectionString("DefaultConnection")
                ?? configuration.GetSection("ApiSettings").GetValue<string>("ConnectionString")
                ?? configuration.GetValue<string>("ConnectionString")
                ?? throw new InvalidOperationException("ConnectionString no configurada. Defina 'ConnectionStrings:DbTkt' o 'ConnectionStrings:DefaultConnection'.");
        }

        // Endpoint temporal de apoyo para pruebas locales: devuelve un usuario de muestra
        // IMPORTANTE: No exponer en producción
        [HttpGet("sample-user")]
        [AllowAnonymous]
        public async Task<IActionResult> GetSampleUser()
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                using var cmd = new MySqlCommand("SELECT idUsuario, nombre, email, passwordUsuarioEnc FROM usuario ORDER BY idUsuario LIMIT 1", conn);
                using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    var id = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                    var nombre = reader.IsDBNull(1) ? string.Empty : reader.GetString(1);
                    var email = reader.IsDBNull(2) ? string.Empty : reader.GetString(2);
                    var passEnc = reader.IsDBNull(3) ? string.Empty : reader.GetString(3);
                    return Ok(new { Id_Usuario = id, Usuario = nombre, Email = email, PasswordHash = passEnc });
                }

                return NotFound(new { message = "No hay usuarios en la tabla 'usuario'." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("db-audit")] // api/admin/db-audit?detalle=true
        [AllowAnonymous]
        public async Task<IActionResult> AuditDatabase([FromQuery] bool detalle = false)
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                // Versión de MySQL
                var versionCmd = new MySqlCommand("SELECT VERSION()", conn);
                var version = (string?)await versionCmd.ExecuteScalarAsync() ?? "unknown";

                // Listado de tablas
                var tables = new List<string>();
                using (var cmd = new MySqlCommand("SHOW TABLES", conn))
                using (var reader = await cmd.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        tables.Add(reader.GetString(0));
                    }
                }

                object? tablesDetail = null;
                if (detalle)
                {
                    var detailDict = new Dictionary<string, object>();
                    foreach (var table in tables)
                    {
                        // DESCRIBE columns
                        var columns = new List<object>();
                        using (var dcmd = new MySqlCommand($"DESCRIBE `{table}`", conn))
                        using (var r = await dcmd.ExecuteReaderAsync())
                        {
                            while (await r.ReadAsync())
                            {
                                columns.Add(new
                                {
                                    Field = r.GetString(0),
                                    Type = r.GetString(1),
                                    Null = r.GetString(2),
                                    Key = r.GetString(3),
                                    Default = r.IsDBNull(4) ? null : r.GetValue(4),
                                    Extra = r.IsDBNull(5) ? null : r.GetString(5)
                                });
                            }
                        }

                        // SHOW CREATE TABLE
                        string? createSql = null;
                        using (var ccmd = new MySqlCommand($"SHOW CREATE TABLE `{table}`", conn))
                        using (var cr = await ccmd.ExecuteReaderAsync())
                        {
                            if (await cr.ReadAsync())
                            {
                                // Column 1 = Table, Column 2 = Create Table SQL
                                createSql = cr.GetString(1);
                            }
                        }

                        // Foreign keys (information_schema)
                        var foreignKeys = new List<object>();
                        using (var fkcmd = new MySqlCommand(@"SELECT
                                kcu.CONSTRAINT_NAME,
                                kcu.TABLE_NAME,
                                kcu.COLUMN_NAME,
                                kcu.REFERENCED_TABLE_NAME,
                                kcu.REFERENCED_COLUMN_NAME
                            FROM information_schema.KEY_COLUMN_USAGE kcu
                            WHERE kcu.TABLE_SCHEMA = DATABASE()
                              AND kcu.TABLE_NAME = @tbl
                              AND kcu.REFERENCED_TABLE_NAME IS NOT NULL", conn))
                        {
                            fkcmd.Parameters.AddWithValue("@tbl", table);
                            using var fkr = await fkcmd.ExecuteReaderAsync();
                            while (await fkr.ReadAsync())
                            {
                                foreignKeys.Add(new
                                {
                                    Constraint = fkr.GetString(0),
                                    Column = fkr.GetString(2),
                                    ReferencedTable = fkr.GetString(3),
                                    ReferencedColumn = fkr.GetString(4)
                                });
                            }
                        }

                        detailDict[table] = new
                        {
                            Columns = columns,
                            CreateSql = createSql,
                            ForeignKeys = foreignKeys
                        };
                    }

                    tablesDetail = detailDict;
                }

                return Ok(new
                {
                    mysqlVersion = version,
                    tableCount = tables.Count,
                    tables,
                    detail = tablesDetail
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }
}
