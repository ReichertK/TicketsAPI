using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    /// Servicio para generación de reportes y analytics
    public class ReporteService : IReporteService
    {
        private readonly ITicketRepository _ticketRepository;
        private readonly IReporteRepository _reporteRepository;
        private readonly IEstadoRepository _estadoRepository;
        private readonly IPrioridadRepository _prioridadRepository;
        private readonly IDepartamentoRepository _departamentoRepository;
        private readonly ILogger<ReporteService> _logger;

        public ReporteService(
            ITicketRepository ticketRepository,
            IReporteRepository reporteRepository,
            IEstadoRepository estadoRepository,
            IPrioridadRepository prioridadRepository,
            IDepartamentoRepository departamentoRepository,
            ILogger<ReporteService> logger)
        {
            _ticketRepository = ticketRepository;
            _reporteRepository = reporteRepository;
            _estadoRepository = estadoRepository;
            _prioridadRepository = prioridadRepository;
            _departamentoRepository = departamentoRepository;
            _logger = logger;
        }

        public async Task<DashboardDTO> GetDashboardAsync(int? idUsuario = null, int? idDepartamento = null)
        {
            return await _reporteRepository.GetDashboardAsync(idUsuario, idDepartamento);
        }

        public async Task<List<ReporteEstadoDTO>> GetReportePorEstadoAsync(FiltroReporteDTO? filtro = null)
        {
            var ticketFiltro = new TicketFiltroDTO
            {
                Fecha_Desde = filtro?.FechaDesde,
                Fecha_Hasta = filtro?.FechaHasta,
                Id_Departamento = filtro?.IdDepartamento,
                Pagina = 1,
                TamañoPagina = int.MaxValue
            };

            var tickets = await _ticketRepository.GetFilteredAsync(ticketFiltro);
            var total = tickets.Datos.Count;

            if (total == 0)
                return new List<ReporteEstadoDTO>();

            var reporte = tickets.Datos
                .GroupBy(t => new
                {
                    Nombre = t.Estado?.Nombre_Estado ?? "Sin Estado",
                    Color = t.Estado?.Color ?? "#CCCCCC"
                })
                .Select(g => new ReporteEstadoDTO
                {
                    NombreEstado = g.Key.Nombre,
                    Cantidad = g.Count(),
                    Porcentaje = Math.Round((double)g.Count() / total * 100, 2),
                    Color = g.Key.Color
                })
                .OrderByDescending(r => r.Cantidad)
                .ToList();

            return reporte;
        }

        public async Task<List<ReportePrioridadDTO>> GetReportePorPrioridadAsync(FiltroReporteDTO? filtro = null)
        {
            var ticketFiltro = new TicketFiltroDTO
            {
                Fecha_Desde = filtro?.FechaDesde,
                Fecha_Hasta = filtro?.FechaHasta,
                Id_Departamento = filtro?.IdDepartamento,
                Id_Estado = filtro?.IdEstado,
                Pagina = 1,
                TamañoPagina = int.MaxValue
            };

            var tickets = await _ticketRepository.GetFilteredAsync(ticketFiltro);
            var total = tickets.Datos.Count;

            if (total == 0)
                return new List<ReportePrioridadDTO>();

            var reporte = tickets.Datos
                .GroupBy(t => new
                {
                    Nombre = t.Prioridad?.Nombre_Prioridad ?? "Sin Prioridad",
                    Color = t.Prioridad?.Color ?? "#CCCCCC"
                })
                .Select(g => new ReportePrioridadDTO
                {
                    NombrePrioridad = g.Key.Nombre,
                    Cantidad = g.Count(),
                    Porcentaje = Math.Round((double)g.Count() / total * 100, 2),
                    Color = g.Key.Color
                })
                .OrderByDescending(r => r.Cantidad)
                .ToList();

            return reporte;
        }

        public async Task<List<ReporteDepartamentoDTO>> GetReportePorDepartamentoAsync(FiltroReporteDTO? filtro = null)
        {
            var ticketFiltro = new TicketFiltroDTO
            {
                Fecha_Desde = filtro?.FechaDesde,
                Fecha_Hasta = filtro?.FechaHasta,
                Id_Estado = filtro?.IdEstado,
                Id_Prioridad = filtro?.IdPrioridad,
                Pagina = 1,
                TamañoPagina = int.MaxValue
            };

            var tickets = await _ticketRepository.GetFilteredAsync(ticketFiltro);
            var total = tickets.Datos.Count;

            if (total == 0)
                return new List<ReporteDepartamentoDTO>();

            var reporte = tickets.Datos
                .GroupBy(t => t.Departamento?.Nombre ?? "Sin Departamento")
                .Select(g => new ReporteDepartamentoDTO
                {
                    NombreDepartamento = g.Key,
                    Cantidad = g.Count(),
                    Porcentaje = Math.Round((double)g.Count() / total * 100, 2),
                    TicketsAbiertos = g.Count(t => t.Date_Cierre == null),
                    TicketsCerrados = g.Count(t => t.Date_Cierre != null)
                })
                .OrderByDescending(r => r.Cantidad)
                .ToList();

            return reporte;
        }

        public async Task<List<TendenciaDTO>> GetTendenciasAsync(FiltroReporteDTO filtro)
        {
            var ticketFiltro = new TicketFiltroDTO
            {
                Fecha_Desde = filtro.FechaDesde ?? DateTime.Now.AddMonths(-1),
                Fecha_Hasta = filtro.FechaHasta ?? DateTime.Now,
                Id_Departamento = filtro.IdDepartamento,
                Id_Estado = filtro.IdEstado,
                Id_Prioridad = filtro.IdPrioridad,
                Pagina = 1,
                TamañoPagina = int.MaxValue
            };

            var tickets = await _ticketRepository.GetFilteredAsync(ticketFiltro);
            var agrupacion = filtro.AgrupacionPeriodo?.ToLower() ?? "dia";

            var tendencias = new List<TendenciaDTO>();

            if (agrupacion == "dia")
            {
                tendencias = tickets.Datos
                    .Where(t => t.Date_Creado.HasValue)
                    .GroupBy(t => t.Date_Creado!.Value.Date)
                    .Select(g => new TendenciaDTO
                    {
                        Periodo = g.Key.ToString("yyyy-MM-dd"),
                        TicketsCreados = g.Count(),
                        TicketsCerrados = g.Count(t => t.Date_Cierre?.Date == g.Key),
                        TicketsAbiertos = g.Count(t => t.Date_Cierre == null),
                        TiempoPromedioResolucionHoras = CalcularTiempoPromedio(g.Where(t => t.Date_Cierre.HasValue).ToList())
                    })
                    .OrderBy(t => t.Periodo)
                    .ToList();
            }
            else if (agrupacion == "semana")
            {
                tendencias = tickets.Datos
                    .Where(t => t.Date_Creado.HasValue)
                    .GroupBy(t => GetWeekNumber(t.Date_Creado!.Value))
                    .Select(g => new TendenciaDTO
                    {
                        Periodo = $"Semana {g.Key}",
                        TicketsCreados = g.Count(),
                        TicketsCerrados = g.Count(t => t.Date_Cierre.HasValue),
                        TicketsAbiertos = g.Count(t => t.Date_Cierre == null),
                        TiempoPromedioResolucionHoras = CalcularTiempoPromedio(g.Where(t => t.Date_Cierre.HasValue).ToList())
                    })
                    .OrderBy(t => t.Periodo)
                    .ToList();
            }
            else // mes
            {
                tendencias = tickets.Datos
                    .Where(t => t.Date_Creado.HasValue)
                    .GroupBy(t => t.Date_Creado!.Value.ToString("yyyy-MM"))
                    .Select(g => new TendenciaDTO
                    {
                        Periodo = g.Key,
                        TicketsCreados = g.Count(),
                        TicketsCerrados = g.Count(t => t.Date_Cierre.HasValue),
                        TicketsAbiertos = g.Count(t => t.Date_Cierre == null),
                        TiempoPromedioResolucionHoras = CalcularTiempoPromedio(g.Where(t => t.Date_Cierre.HasValue).ToList())
                    })
                    .OrderBy(t => t.Periodo)
                    .ToList();
            }

            return tendencias;
        }

        private static double CalcularTiempoPromedio(List<TicketDTO> tickets)
        {
            if (!tickets.Any() || !tickets.Any(t => t.Date_Creado.HasValue && t.Date_Cierre.HasValue))
                return 0;

            var tiempos = tickets
                .Where(t => t.Date_Creado.HasValue && t.Date_Cierre.HasValue)
                .Select(t => (t.Date_Cierre!.Value - t.Date_Creado!.Value).TotalHours);

            return Math.Round(tiempos.Average(), 2);
        }

        private static int GetWeekNumber(DateTime date)
        {
            var culture = System.Globalization.CultureInfo.CurrentCulture;
            return culture.Calendar.GetWeekOfYear(date, 
                System.Globalization.CalendarWeekRule.FirstDay, 
                DayOfWeek.Monday);
        }
    }
}
