using Dapper;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class AprobacionRepository : BaseRepository, IBaseRepository<Aprobacion>
    {
        public AprobacionRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Aprobacion entity)
        {
            using var conn = CreateConnection();
            const string sql = @"INSERT INTO tkt_aprobacion (id_tkt, solicitante_id, aprobador_id, estado)
                                VALUES (@Id_Tkt, @Id_Usuario_Solicitante, @Id_Usuario_Aprobador, @Estado);
                                SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "DELETE FROM tkt_aprobacion WHERE id_aprob = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Aprobacion>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_aprob AS Id_Aprobacion,
                                    id_tkt AS Id_Tkt,
                                    solicitante_id AS Id_Usuario_Solicitante,
                                    aprobador_id AS Id_Usuario_Aprobador,
                                    estado AS Estado,
                                    comentario AS Comentario_Respuesta,
                                    fecha_solicitud AS Fecha_Solicitud,
                                    fecha_respuesta AS Fecha_Respuesta
                                 FROM tkt_aprobacion
                                 ORDER BY fecha_solicitud DESC";
            var result = await conn.QueryAsync<Aprobacion>(sql);
            return result.ToList();
        }

        public async Task<Aprobacion?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_aprob AS Id_Aprobacion,
                                    id_tkt AS Id_Tkt,
                                    solicitante_id AS Id_Usuario_Solicitante,
                                    aprobador_id AS Id_Usuario_Aprobador,
                                    estado AS Estado,
                                    comentario AS Comentario_Respuesta,
                                    fecha_solicitud AS Fecha_Solicitud,
                                    fecha_respuesta AS Fecha_Respuesta
                                 FROM tkt_aprobacion WHERE id_aprob = @id";
            return await conn.QuerySingleOrDefaultAsync<Aprobacion>(sql, new { id });
        }

        public async Task<bool> UpdateAsync(Aprobacion entity)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE tkt_aprobacion SET 
                                estado = @Estado, 
                                fecha_respuesta = @Fecha_Respuesta, 
                                comentario = @Comentario_Respuesta 
                                WHERE id_aprob = @Id_Aprobacion";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<List<Aprobacion>> GetPendientesPorAprobadorAsync(int idUsuarioAprobador)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_aprob AS Id_Aprobacion,
                                    id_tkt AS Id_Tkt,
                                    solicitante_id AS Id_Usuario_Solicitante,
                                    aprobador_id AS Id_Usuario_Aprobador,
                                    estado AS Estado,
                                    comentario AS Comentario_Respuesta,
                                    fecha_solicitud AS Fecha_Solicitud,
                                    fecha_respuesta AS Fecha_Respuesta
                                 FROM tkt_aprobacion 
                                 WHERE aprobador_id = @idUsuario 
                                 AND estado = 'pendiente' 
                                 ORDER BY fecha_solicitud ASC";
            var result = await conn.QueryAsync<Aprobacion>(sql, new { idUsuario = idUsuarioAprobador });
            return result.ToList();
        }

        public async Task<List<Aprobacion>> GetPorTicketAsync(int idTicket)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_aprob AS Id_Aprobacion,
                                    id_tkt AS Id_Tkt,
                                    solicitante_id AS Id_Usuario_Solicitante,
                                    aprobador_id AS Id_Usuario_Aprobador,
                                    estado AS Estado,
                                    comentario AS Comentario_Respuesta,
                                    fecha_solicitud AS Fecha_Solicitud,
                                    fecha_respuesta AS Fecha_Respuesta
                                 FROM tkt_aprobacion 
                                 WHERE id_tkt = @idTicket 
                                 ORDER BY fecha_solicitud DESC";
            var result = await conn.QueryAsync<Aprobacion>(sql, new { idTicket });
            return result.ToList();
        }

        public async Task<List<Aprobacion>> GetPorSolicitanteAsync(int idUsuarioSolicitante)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_aprob AS Id_Aprobacion,
                                    id_tkt AS Id_Tkt,
                                    solicitante_id AS Id_Usuario_Solicitante,
                                    aprobador_id AS Id_Usuario_Aprobador,
                                    estado AS Estado,
                                    comentario AS Comentario_Respuesta,
                                    fecha_solicitud AS Fecha_Solicitud,
                                    fecha_respuesta AS Fecha_Respuesta
                                 FROM tkt_aprobacion 
                                 WHERE solicitante_id = @idUsuario 
                                 ORDER BY fecha_solicitud DESC";
            var result = await conn.QueryAsync<Aprobacion>(sql, new { idUsuario = idUsuarioSolicitante });
            return result.ToList();
        }
    }
}
