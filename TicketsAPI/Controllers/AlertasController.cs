using Dapper;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using System.Data;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Controllers
{
    /// Controller para alertas y menciones (@usuario).
    /// Los usuarios solo pueden ver/gestionar sus propias alertas.
    [Authorize]
    public class AlertasController : BaseApiController
    {
        private readonly string _connectionString;

        public AlertasController(IConfiguration configuration, ILogger<AlertasController> logger)
            : base(logger)
        {
            _connectionString = configuration.GetConnectionString("DbTkt")
                ?? configuration.GetConnectionString("DefaultConnection")
                ?? throw new InvalidOperationException("ConnectionString no configurada.");
        }

        /// Obtener alertas no leídas del usuario autenticado.
        /// GET /api/v1/Alertas?limite=20
        [HttpGet]
        public async Task<IActionResult> GetAlertasNoLeidas([FromQuery] int limite = 20)
        {
            try
            {
                if (limite < 1) limite = 10;
                if (limite > 100) limite = 100;

                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Error<object>("Usuario no autenticado", statusCode: 401);

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var parameters = new DynamicParameters();
                parameters.Add("p_id_usuario", userId);
                parameters.Add("p_limite", limite);

                var alertas = (await conn.QueryAsync<AlertaDTO>(
                    "sp_alertas_no_leidas", parameters, commandType: CommandType.StoredProcedure)).ToList();

                return Success(alertas, $"{alertas.Count} alerta(s) no leída(s)");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener alertas no leídas");
                return Error<object>("Error al obtener alertas", statusCode: 500);
            }
        }

        /// Marcar una alerta como leída.
        /// PUT /api/v1/Alertas/{id}/leida
        [HttpPut("{id}/leida")]
        public async Task<IActionResult> MarcarLeida(long id)
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Error<object>("Usuario no autenticado", statusCode: 401);

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var parameters = new DynamicParameters();
                parameters.Add("p_id_alerta", id);
                parameters.Add("p_id_usuario", userId);

                await conn.ExecuteAsync(
                    "sp_marcar_alerta_leida", parameters, commandType: CommandType.StoredProcedure);

                return Success<object>(new { }, "Alerta marcada como leída");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al marcar alerta {IdAlerta} como leída", id);
                return Error<object>("Error al marcar alerta", statusCode: 500);
            }
        }

        /// Marcar todas las alertas como leídas.
        /// PUT /api/v1/Alertas/marcar-todas
        [HttpPut("marcar-todas")]
        public async Task<IActionResult> MarcarTodasLeidas()
        {
            try
            {
                var userId = GetCurrentUserId();
                if (userId <= 0)
                    return Error<object>("Usuario no autenticado", statusCode: 401);

                using var conn = new MySqlConnection(_connectionString);
                await conn.OpenAsync();

                var affected = await conn.ExecuteAsync(
                    "UPDATE notificacion_alerta SET leida = 1 WHERE id_usuario = @UserId AND leida = 0",
                    new { UserId = userId });

                return Success(new { marcadas = affected }, $"{affected} alerta(s) marcada(s) como leída(s)");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al marcar todas las alertas como leídas");
                return Error<object>("Error al marcar alertas", statusCode: 500);
            }
        }
    }
}
