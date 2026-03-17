using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Services.Interfaces
{
    public interface IReporteService
    {
        /// Obtener métricas del dashboard
        Task<DashboardDTO> GetDashboardAsync(int? idUsuario = null, int? idDepartamento = null);

        /// Obtener reporte de tickets agrupados por estado
        Task<List<ReporteEstadoDTO>> GetReportePorEstadoAsync(FiltroReporteDTO? filtro = null);

        /// Obtener reporte de tickets agrupados por prioridad
        Task<List<ReportePrioridadDTO>> GetReportePorPrioridadAsync(FiltroReporteDTO? filtro = null);

        /// Obtener reporte de tickets agrupados por departamento
        Task<List<ReporteDepartamentoDTO>> GetReportePorDepartamentoAsync(FiltroReporteDTO? filtro = null);

        /// Obtener tendencias de tickets por periodo
        Task<List<TendenciaDTO>> GetTendenciasAsync(FiltroReporteDTO filtro);
    }
}
