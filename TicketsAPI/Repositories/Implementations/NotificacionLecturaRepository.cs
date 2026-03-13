using System.Data;
using Dapper;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class NotificacionLecturaRepository : BaseRepository, INotificacionLecturaRepository
    {
        public NotificacionLecturaRepository(string connectionString) : base(connectionString) { }

        public async Task<NotificacionResumenDTO> GetResumenAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("@p_id_usuario", idUsuario, DbType.Int64);

            using var multi = await conn.QueryMultipleAsync(
                "sp_obtener_resumen_notificaciones",
                parameters,
                commandType: CommandType.StoredProcedure);

            var conteo = await multi.ReadSingleOrDefaultAsync<dynamic>();
            var tickets = (await multi.ReadAsync<dynamic>()).ToList();

            var resumen = new NotificacionResumenDTO
            {
                TotalNoLeidos = conteo?.total_no_leidos != null ? (int)(long)conteo.total_no_leidos : 0,
                PendientesAsignados = conteo?.pendientes_asignados != null ? (int)(decimal)conteo.pendientes_asignados : 0,
                UltimosNoLeidos = tickets.Select(t => new NotificacionTicketDTO
                {
                    Id_Ticket = t.id_ticket != null ? (long)t.id_ticket : 0,
                    Contenido = t.contenido as string,
                    Id_Estado = t.id_estado != null ? (int)t.id_estado : 0,
                    Estado_Nombre = t.estado_nombre as string ?? string.Empty,
                    Prioridad_Nombre = t.prioridad_nombre as string,
                    Fecha_Cambio = t.fecha_cambio as DateTime?,
                    Es_Asignado_A_Mi = t.es_asignado_a_mi != null && Convert.ToInt32(t.es_asignado_a_mi) == 1
                }).ToList()
            };

            return resumen;
        }

        public async Task MarcarLeidoAsync(int idTicket, int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = @"
                UPDATE tkt_notificacion_lectura 
                SET leido = 1, fecha_cambio = NOW() 
                WHERE id_ticket = @idTicket AND id_usuario = @idUsuario AND leido = 0";
            await conn.ExecuteAsync(sql, new { idTicket, idUsuario });
        }

        public async Task MarcarTodosLeidosAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = @"
                UPDATE tkt_notificacion_lectura 
                SET leido = 1, fecha_cambio = NOW() 
                WHERE id_usuario = @idUsuario AND leido = 0";
            await conn.ExecuteAsync(sql, new { idUsuario });
        }
    }
}
