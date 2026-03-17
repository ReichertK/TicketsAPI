using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using System.Data;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Controllers
{
    /// Controller para búsqueda global (Command Palette / Ctrl+K).
    /// Utiliza sp_global_search con RBAC integrado.
    [Authorize]
    public class SearchController : BaseApiController
    {
        private readonly string _connectionString;

        public SearchController(IConfiguration configuration, ILogger<SearchController> logger)
            : base(logger)
        {
            _connectionString = configuration.GetConnectionString("DbTkt")
                ?? configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("ConnectionString no configurada.");
        }

        /// Búsqueda global: tickets, usuarios, departamentos.
        /// GET /api/v1/Search?q=termino&limite=10
        /// RBAC: usuarios comunes solo ven tickets de su departamento y activos.
        [HttpGet]
        public async Task<IActionResult> GlobalSearch([FromQuery] string q, [FromQuery] int limite = 10)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(q) || q.Trim().Length < 2)
                    return Success(new GlobalSearchResultDTO(), "Ingrese al menos 2 caracteres");

                if (limite < 1) limite = 5;
                if (limite > 50) limite = 50;

                var userId = GetCurrentUserId();
                var role = GetCurrentUserRole();
                var esAdmin = string.Equals(role, "Administrador", StringComparison.OrdinalIgnoreCase) ? 1 : 0;

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var parameters = new DynamicParameters();
                parameters.Add("p_termino", q.Trim());
                parameters.Add("p_id_usuario", userId);
                parameters.Add("p_es_admin", esAdmin);
                parameters.Add("p_limite", limite);

                using var multi = await conn.QueryMultipleAsync(
                    "sp_global_search", parameters, commandType: CommandType.StoredProcedure);

                var tickets = (await multi.ReadAsync<GlobalSearchItemDTO>()).ToList();
                var usuarios = (await multi.ReadAsync<GlobalSearchItemDTO>()).ToList();
                var departamentos = (await multi.ReadAsync<GlobalSearchItemDTO>()).ToList();

                var result = new GlobalSearchResultDTO
                {
                    Tickets = tickets,
                    Usuarios = usuarios,
                    Departamentos = departamentos
                };

                return Success(result, "Búsqueda completada");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en búsqueda global con término '{Termino}'", q);
                return Error<object>("Error al realizar la búsqueda", statusCode: 500);
            }
        }
    }
}
