using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    /// Controlador para reportes y analytics
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class ReportesController : BaseApiController
    {
        private readonly IReporteService _reporteService;

        public ReportesController(
            IReporteService reporteService,
            ILogger<BaseApiController> logger) : base(logger)
        {
            _reporteService = reporteService;
        }

        /// Obtener métricas del dashboard
        /// <param name="idDepartamento">Filtrar por departamento (opcional)</param>
        /// <returns>Dashboard con métricas generales</returns>
        [HttpGet("Dashboard")]
        [ProducesResponseType(typeof(ApiResponse<DashboardDTO>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 500)]
        public async Task<IActionResult> GetDashboard([FromQuery] int? idDepartamento = null)
        {
            try
            {
                var userId = GetCurrentUserId();
                var dashboard = await _reporteService.GetDashboardAsync(userId, idDepartamento);
                return Success(dashboard, "Dashboard obtenido correctamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener dashboard");
                return Error<object>("Error al obtener dashboard", statusCode: 500);
            }
        }

        /// Obtener reporte de tickets agrupados por estado
        /// <param name="filtro">Filtros del reporte</param>
        /// <returns>Lista de tickets agrupados por estado con porcentajes</returns>
        [HttpGet("PorEstado")]
        [ProducesResponseType(typeof(ApiResponse<List<ReporteEstadoDTO>>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 500)]
        public async Task<IActionResult> GetReportePorEstado([FromQuery] FiltroReporteDTO? filtro = null)
        {
            try
            {
                var reporte = await _reporteService.GetReportePorEstadoAsync(filtro);
                return Success(reporte, "Reporte por estado obtenido correctamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener reporte por estado");
                return Error<object>("Error al obtener reporte por estado", statusCode: 500);
            }
        }

        /// Obtener reporte de tickets agrupados por prioridad
        /// <param name="filtro">Filtros del reporte</param>
        /// <returns>Lista de tickets agrupados por prioridad con porcentajes</returns>
        [HttpGet("PorPrioridad")]
        [ProducesResponseType(typeof(ApiResponse<List<ReportePrioridadDTO>>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 500)]
        public async Task<IActionResult> GetReportePorPrioridad([FromQuery] FiltroReporteDTO? filtro = null)
        {
            try
            {
                var reporte = await _reporteService.GetReportePorPrioridadAsync(filtro);
                return Success(reporte, "Reporte por prioridad obtenido correctamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener reporte por prioridad");
                return Error<object>("Error al obtener reporte por prioridad", statusCode: 500);
            }
        }

        /// Obtener reporte de tickets agrupados por departamento
        /// <param name="filtro">Filtros del reporte</param>
        /// <returns>Lista de tickets agrupados por departamento con porcentajes</returns>
        [HttpGet("PorDepartamento")]
        [ProducesResponseType(typeof(ApiResponse<List<ReporteDepartamentoDTO>>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 500)]
        public async Task<IActionResult> GetReportePorDepartamento([FromQuery] FiltroReporteDTO? filtro = null)
        {
            try
            {
                var reporte = await _reporteService.GetReportePorDepartamentoAsync(filtro);
                return Success(reporte, "Reporte por departamento obtenido correctamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener reporte por departamento");
                return Error<object>("Error al obtener reporte por departamento", statusCode: 500);
            }
        }

        /// Obtener tendencias de tickets por periodo (día, semana o mes)
        /// <param name="filtro">Filtros del reporte con agrupación por periodo</param>
        /// <returns>Lista de tendencias por periodo</returns>
        [HttpGet("Tendencias")]
        [ProducesResponseType(typeof(ApiResponse<List<TendenciaDTO>>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        [ProducesResponseType(typeof(ApiResponse<object>), 401)]
        [ProducesResponseType(typeof(ApiResponse<object>), 500)]
        public async Task<IActionResult> GetTendencias([FromQuery] FiltroReporteDTO filtro)
        {
            try
            {
                if (filtro == null)
                {
                    return Error<object>("Filtro es requerido", statusCode: 400);
                }

                var tendencias = await _reporteService.GetTendenciasAsync(filtro);
                return Success(tendencias, "Tendencias obtenidas correctamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener tendencias");
                return Error<object>("Error al obtener tendencias", statusCode: 500);
            }
        }
    }
}
