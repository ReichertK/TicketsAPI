using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Services.Interfaces
{
    public interface IReporteService
    {
        /// <summary>
        /// Obtener métricas del dashboard
        /// </summary>
        Task<DashboardDTO> GetDashboardAsync(int? idUsuario = null, int? idDepartamento = null);

        /// <summary>
        /// Obtener reporte de tickets agrupados por estado
        /// </summary>
        Task<List<ReporteEstadoDTO>> GetReportePorEstadoAsync(FiltroReporteDTO? filtro = null);

        /// <summary>
        /// Obtener reporte de tickets agrupados por prioridad
        /// </summary>
        Task<List<ReportePrioridadDTO>> GetReportePorPrioridadAsync(FiltroReporteDTO? filtro = null);

        /// <summary>
        /// Obtener reporte de tickets agrupados por departamento
        /// </summary>
        Task<List<ReporteDepartamentoDTO>> GetReportePorDepartamentoAsync(FiltroReporteDTO? filtro = null);

        /// <summary>
        /// Obtener tendencias de tickets por periodo
        /// </summary>
        Task<List<TendenciaDTO>> GetTendenciasAsync(FiltroReporteDTO filtro);
    }
}
