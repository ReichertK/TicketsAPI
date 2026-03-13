using System.Data;
using Dapper;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class ReporteRepository : BaseRepository, IReporteRepository
    {
        public ReporteRepository(string connectionString) : base(connectionString) { }

        public async Task<DashboardDTO> GetDashboardAsync(int? idUsuario, int? idDepartamento)
        {
            using var conn = CreateConnection();

            var parameters = new DynamicParameters();
            parameters.Add("@w_id_usuario", idUsuario, DbType.Int32);
            parameters.Add("@w_id_departamento", idDepartamento, DbType.Int32);

            using var multi = await conn.QueryMultipleAsync(
                "sp_dashboard_tickets",
                parameters,
                commandType: CommandType.StoredProcedure);

            var resumen = await multi.ReadSingleAsync<DashboardResumenDb>();
            var porEstado = (await multi.ReadAsync<DashboardGrupoDb>()).ToList();
            var porPrioridad = (await multi.ReadAsync<DashboardGrupoDb>()).ToList();
            var porDepartamento = (await multi.ReadAsync<DashboardGrupoDb>()).ToList();

            return new DashboardDTO
            {
                TicketsTotal = resumen.TicketsTotal,
                TicketsAbiertos = resumen.TicketsAbiertos,
                TicketsCerrados = resumen.TicketsCerrados,
                TicketsEnProceso = resumen.TicketsEnProceso,
                TicketsAsignadosAMi = resumen.TicketsAsignadosAMi,
                TicketsPorEstado = porEstado.ToDictionary(x => x.Nombre, x => x.Cantidad),
                TicketsPorPrioridad = porPrioridad.ToDictionary(x => x.Nombre, x => x.Cantidad),
                TicketsPorDepartamento = porDepartamento.ToDictionary(x => x.Nombre, x => x.Cantidad),
                TiempoPromedioResolucion = resumen.TiempoPromedioResolucion,
                TasaCumplimientoSLA = 0
            };
        }

        private sealed class DashboardResumenDb
        {
            public int TicketsTotal { get; set; }
            public int TicketsAbiertos { get; set; }
            public int TicketsCerrados { get; set; }
            public int TicketsEnProceso { get; set; }
            public int TicketsAsignadosAMi { get; set; }
            public decimal TiempoPromedioResolucion { get; set; }
        }

        private sealed class DashboardGrupoDb
        {
            public string Nombre { get; set; } = string.Empty;
            public int Cantidad { get; set; }
        }
    }
}
