using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using MySqlConnector;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controller para consultar y exportar registros de auditoría (audit_log).
    /// Solo accesible por Administradores.
    /// </summary>
    [Authorize(Roles = "Administrador")]
    public class AuditLogsController : BaseApiController
    {
        private readonly string _connectionString;
        private readonly IMemoryCache _cache;
        private static readonly TimeSpan StatsCacheDuration = TimeSpan.FromMinutes(5);

        public AuditLogsController(IConfiguration configuration, ILogger<AuditLogsController> logger, IMemoryCache cache)
            : base(logger)
        {
            _connectionString = configuration.GetConnectionString("DbTkt")
                ?? configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("ConnectionString no configurada.");
            _cache = cache;
        }

        /// <summary>
        /// Obtener registros de auditoría con filtros y paginación.
        /// GET /api/v1/AuditLogs?tabla=usuario&accion=INSERT&fechaDesde=2025-01-01&pagina=1&porPagina=50
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] AuditLogFiltroDTO filtro)
        {
            try
            {
                // Clamp pagination
                if (filtro.Pagina < 1) filtro.Pagina = 1;
                if (filtro.PorPagina < 1) filtro.PorPagina = 10;
                if (filtro.PorPagina > 200) filtro.PorPagina = 200;

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var (whereClause, parameters) = BuildWhereClause(filtro);

                // Count query (with LIMIT to avoid full scan on huge tables)
                var countSql = $"SELECT COUNT(*) FROM (SELECT 1 FROM audit_log {whereClause} LIMIT 10001) t";
                var totalRaw = await conn.ExecuteScalarAsync<long>(countSql, parameters);
                var total = totalRaw > 10000 ? -1 : totalRaw; // -1 means "more than 10000"

                // Data query
                var offset = (filtro.Pagina - 1) * filtro.PorPagina;
                var dataSql = $@"
                    SELECT id_auditoria AS IdAuditoria, tabla AS Tabla, id_registro AS IdRegistro, 
                           accion AS Accion, usuario_id AS UsuarioId, usuario_nombre AS UsuarioNombre,
                           valores_antiguos AS ValoresAntiguos, valores_nuevos AS ValoresNuevos,
                           ip_address AS IpAddress, fecha AS Fecha, descripcion AS Descripcion
                    FROM audit_log
                    {whereClause}
                    ORDER BY fecha DESC, id_auditoria DESC
                    LIMIT @Limit OFFSET @Offset";

                parameters.Add("Limit", filtro.PorPagina);
                parameters.Add("Offset", offset);

                var items = (await conn.QueryAsync<AuditLogDTO>(dataSql, parameters)).ToList();

                return Success(new PaginatedResponse<AuditLogDTO>
                {
                    Datos = items,
                    TotalRegistros = total == -1 ? 10001 : (int)total,
                    PaginaActual = filtro.Pagina,
                    TamañoPagina = filtro.PorPagina,
                    TotalPaginas = total == -1 ? -1 : (int)Math.Ceiling((double)total / filtro.PorPagina),
                    TienePaginaAnterior = filtro.Pagina > 1,
                    TienePaginaSiguiente = items.Count == filtro.PorPagina
                }, "Registros de auditoría obtenidos");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener registros de auditoría");
                return Error<object>("Error al consultar auditoría", statusCode: 500);
            }
        }

        /// <summary>
        /// Obtener estadísticas resumidas del audit_log (cacheadas 5 min para evitar full-scans).
        /// GET /api/v1/AuditLogs/stats
        /// </summary>
        [HttpGet("stats")]
        public async Task<IActionResult> GetStats()
        {
            try
            {
                const string cacheKey = "AuditLogStats";
                if (_cache.TryGetValue(cacheKey, out AuditLogStatsDTO? cached) && cached != null)
                    return Success(cached, "Estadísticas de auditoría (cache)");

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                // Fast estimated count from information_schema
                var estimatedRows = await conn.ExecuteScalarAsync<long>(
                    "SELECT TABLE_ROWS FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='audit_log'");

                // Grouped counts by accion (uses idx_auditoria_accion)
                var accionStats = (await conn.QueryAsync<(string Accion, long Total)>(
                    "SELECT accion, COUNT(*) as Total FROM audit_log USE INDEX(idx_auditoria_accion) GROUP BY accion"))
                    .ToDictionary(x => x.Accion, x => x.Total);

                // Grouped counts by tabla (uses idx_auditoria_tabla_fecha)
                var tablaStats = (await conn.QueryAsync<(string Tabla, long Total)>(
                    "SELECT tabla, COUNT(*) as Total FROM audit_log USE INDEX(idx_auditoria_tabla_fecha) GROUP BY tabla"))
                    .ToDictionary(x => x.Tabla, x => x.Total);

                // Min/max dates — use the new fecha index for fast min/max
                var fechas = await conn.QueryFirstOrDefaultAsync<(DateTime? Min, DateTime? Max)>(
                    "SELECT MIN(fecha), MAX(fecha) FROM audit_log USE INDEX(idx_auditoria_fecha_id)");

                var stats = new AuditLogStatsDTO
                {
                    TotalEstimado = estimatedRows,
                    PorAccion = accionStats,
                    PorTabla = tablaStats,
                    PrimeraFecha = fechas.Min,
                    UltimaFecha = fechas.Max
                };

                _cache.Set(cacheKey, stats, StatsCacheDuration);

                return Success(stats, "Estadísticas de auditoría");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener estadísticas de auditoría");
                return Error<object>("Error al consultar estadísticas", statusCode: 500);
            }
        }

        /// <summary>
        /// Obtener las tablas y acciones distintas para los filtros del frontend.
        /// GET /api/v1/AuditLogs/filters
        /// </summary>
        [HttpGet("filters")]
        public async Task<IActionResult> GetFilterOptions()
        {
            try
            {
                const string cacheKey = "AuditLogFilters";
                if (_cache.TryGetValue(cacheKey, out object? cached) && cached != null)
                    return Success(cached, "Opciones de filtro (cache)");

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var tablas = (await conn.QueryAsync<string>(
                    "SELECT DISTINCT tabla FROM audit_log USE INDEX(idx_auditoria_tabla_fecha) ORDER BY tabla")).ToList();
                var acciones = (await conn.QueryAsync<string>(
                    "SELECT DISTINCT accion FROM audit_log USE INDEX(idx_auditoria_accion) ORDER BY accion")).ToList();

                var result = new { tablas, acciones };
                _cache.Set(cacheKey, result, StatsCacheDuration);

                return Success(result, "Opciones de filtro");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener opciones de filtro");
                return Error<object>("Error al consultar filtros", statusCode: 500);
            }
        }

        /// <summary>
        /// Generar un ciclo INSERT → UPDATE → DELETE de prueba en audit_log para validar DiffTable.
        /// POST /api/v1/AuditLogs/test-cycle
        /// </summary>
        [HttpPost("test-cycle")]
        public async Task<IActionResult> GenerateTestCycle()
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var now = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
                var testUser = "AuditTestBot";
                var testTable = "audit_test";
                var testId = new Random().Next(900000, 999999);

                // 1) INSERT
                var insertNew = System.Text.Json.JsonSerializer.Serialize(new
                {
                    id = testId,
                    nombre = "Usuario de Prueba",
                    email = "test@example.com",
                    activo = true,
                    departamento = "Soporte"
                });
                await conn.ExecuteAsync(
                    @"INSERT INTO audit_log (tabla, id_registro, accion, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
                      VALUES (@Tabla, @IdReg, 'INSERT', @User, NULL, @New, @Fecha, 'Ciclo de prueba: INSERT')",
                    new { Tabla = testTable, IdReg = testId, User = testUser, New = insertNew, Fecha = now });

                // 2) UPDATE
                var updateOld = insertNew;
                var updateNew = System.Text.Json.JsonSerializer.Serialize(new
                {
                    id = testId,
                    nombre = "Usuario Actualizado",
                    email = "updated@example.com",
                    activo = true,
                    departamento = "Ingeniería"
                });
                await conn.ExecuteAsync(
                    @"INSERT INTO audit_log (tabla, id_registro, accion, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
                      VALUES (@Tabla, @IdReg, 'UPDATE', @User, @Old, @New, @Fecha, 'Ciclo de prueba: UPDATE')",
                    new { Tabla = testTable, IdReg = testId, User = testUser, Old = updateOld, New = updateNew, Fecha = now });

                // 3) DELETE
                await conn.ExecuteAsync(
                    @"INSERT INTO audit_log (tabla, id_registro, accion, usuario_nombre, valores_antiguos, valores_nuevos, fecha, descripcion)
                      VALUES (@Tabla, @IdReg, 'DELETE', @User, @Old, NULL, @Fecha, 'Ciclo de prueba: DELETE')",
                    new { Tabla = testTable, IdReg = testId, User = testUser, Old = updateNew, Fecha = now });

                return Success(new { testTable, testId, registrosCreados = 3 },
                    "Ciclo INSERT → UPDATE → DELETE generado. Filtra por tabla 'audit_test' para verlo.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al generar ciclo de prueba");
                return Error<object>("Error al generar ciclo de prueba", statusCode: 500);
            }
        }

        /// <summary>
        /// Exportar registros de auditoría a Excel (.xlsx) con los mismos filtros de la vista.
        /// GET /api/v1/AuditLogs/export?tabla=usuario&accion=INSERT&fechaDesde=2025-01-01
        /// </summary>
        [HttpGet("export")]
        public async Task<IActionResult> ExportToExcel([FromQuery] AuditLogFiltroDTO filtro)
        {
            try
            {
                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var (whereClause, parameters) = BuildWhereClause(filtro);

                // Limitar a 5000 registros para no sobrecargar memoria
                var dataSql = $@"
                    SELECT id_auditoria AS IdAuditoria, tabla AS Tabla, id_registro AS IdRegistro, 
                           accion AS Accion, usuario_id AS UsuarioId, usuario_nombre AS UsuarioNombre,
                           fecha AS Fecha, descripcion AS Descripcion, ip_address AS IpAddress
                    FROM audit_log
                    {whereClause}
                    ORDER BY fecha DESC, id_auditoria DESC
                    LIMIT 5000";

                var items = (await conn.QueryAsync<dynamic>(dataSql, parameters)).ToList();

                if (!items.Any())
                    return Error<object>("No hay registros para exportar con los filtros aplicados", statusCode: 404);

                // Generar Excel con MiniExcel
                var memoryStream = new MemoryStream();
                await MiniExcelLibs.MiniExcel.SaveAsAsync(memoryStream, items);
                memoryStream.Position = 0;

                var fileName = $"auditoria_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx";
                return File(memoryStream, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al exportar auditoría a Excel");
                return Error<object>("Error al exportar auditoría", statusCode: 500);
            }
        }

        private static (string whereClause, DynamicParameters parameters) BuildWhereClause(AuditLogFiltroDTO filtro)
        {
            var conditions = new List<string>();
            var parameters = new DynamicParameters();

            if (!string.IsNullOrWhiteSpace(filtro.Tabla))
            {
                conditions.Add("tabla = @Tabla");
                parameters.Add("Tabla", filtro.Tabla);
            }

            if (!string.IsNullOrWhiteSpace(filtro.Accion))
            {
                conditions.Add("accion = @Accion");
                parameters.Add("Accion", filtro.Accion);
            }

            if (filtro.UsuarioId.HasValue)
            {
                conditions.Add("usuario_id = @UsuarioId");
                parameters.Add("UsuarioId", filtro.UsuarioId.Value);
            }

            if (filtro.FechaDesde.HasValue)
            {
                conditions.Add("fecha >= @FechaDesde");
                parameters.Add("FechaDesde", filtro.FechaDesde.Value);
            }

            if (filtro.FechaHasta.HasValue)
            {
                conditions.Add("fecha <= @FechaHasta");
                parameters.Add("FechaHasta", filtro.FechaHasta.Value);
            }

            if (!string.IsNullOrWhiteSpace(filtro.Busqueda))
            {
                conditions.Add("(usuario_nombre LIKE @Busqueda OR tabla LIKE @Busqueda)");
                parameters.Add("Busqueda", $"%{filtro.Busqueda}%");
            }

            var whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions) : "";
            return (whereClause, parameters);
        }
    }
}
