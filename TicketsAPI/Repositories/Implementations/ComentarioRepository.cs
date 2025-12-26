using Dapper;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Repositories.Implementations
{
    public class ComentarioRepository : BaseRepository, IComentarioRepository
    {
        public ComentarioRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Comentario entity)
        {
            using var conn = CreateConnection();
            const string sql = @"INSERT INTO tkt_comentario (id_tkt, id_usuario, comentario)
                                VALUES (@Id_Ticket, @Id_Usuario, @Contenido);
                                SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "DELETE FROM tkt_comentario WHERE id_comentario = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Comentario>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_comentario AS Id_Comentario,
                                    id_tkt AS Id_Ticket,
                                    id_usuario AS Id_Usuario,
                                    comentario AS Contenido,
                                    fecha AS Fecha_Creacion
                                 FROM tkt_comentario
                                 ORDER BY fecha DESC";
            var result = await conn.QueryAsync<Comentario>(sql);
            return result.ToList();
        }

        public async Task<Comentario?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_comentario AS Id_Comentario,
                                    id_tkt AS Id_Ticket,
                                    id_usuario AS Id_Usuario,
                                    comentario AS Contenido,
                                    fecha AS Fecha_Creacion
                                 FROM tkt_comentario WHERE id_comentario = @id";
            return await conn.QuerySingleOrDefaultAsync<Comentario>(sql, new { id });
        }

        public async Task<bool> UpdateAsync(Comentario entity)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE tkt_comentario SET 
                                comentario = @Contenido
                                WHERE id_comentario = @Id_Comentario";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<List<Comentario>> GetByTicketAsync(int idTicket)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_comentario AS Id_Comentario,
                                    id_tkt AS Id_Ticket,
                                    id_usuario AS Id_Usuario,
                                    comentario AS Contenido,
                                    fecha AS Fecha_Creacion
                                 FROM tkt_comentario 
                                 WHERE id_tkt = @idTicket
                                 ORDER BY fecha DESC";
            var result = await conn.QueryAsync<Comentario>(sql, new { idTicket });
            return result.ToList();
        }

        public async Task<List<Comentario>> GetByUsuarioAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_comentario AS Id_Comentario,
                                    id_tkt AS Id_Ticket,
                                    id_usuario AS Id_Usuario,
                                    comentario AS Contenido,
                                    fecha AS Fecha_Creacion
                                 FROM tkt_comentario 
                                 WHERE id_usuario = @idUsuario
                                 ORDER BY fecha DESC";
            var result = await conn.QueryAsync<Comentario>(sql, new { idUsuario });
            return result.ToList();
        }

        /// <summary>
        /// Crea un comentario usando sp_tkt_comentar
        /// SP no retorna id_comentario, por lo que usamos LAST_INSERT_ID() en la misma conexión
        /// </summary>
        public async Task<ComentarioResultDTO> CrearComentarioViaStoredProcedureAsync(int idTkt, int idUsuario, string comentario)
        {
            using var conn = CreateConnection();
            
            var pSuccess = new DynamicParameters();
            pSuccess.Add("@p_id_tkt", idTkt);
            pSuccess.Add("@p_id_usuario", idUsuario);
            pSuccess.Add("@p_comentario", comentario);
            
            // OUT parameters
            pSuccess.Add("@p_success", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);
            pSuccess.Add("@p_mensaje", dbType: System.Data.DbType.String, size: 500, direction: System.Data.ParameterDirection.Output);

            await conn.ExecuteAsync("sp_tkt_comentar", pSuccess, commandType: System.Data.CommandType.StoredProcedure);

            int success = pSuccess.Get<int?>("@p_success") ?? 0;
            string? mensaje = pSuccess.Get<string?>("@p_mensaje");
            int? idComentario = null;

            // Si la SP fue exitosa, obtener el ID del comentario insertado usando LAST_INSERT_ID()
            // Esto es necesario porque sp_tkt_comentar no retorna el ID
            if (success == 1)
            {
                idComentario = await conn.QuerySingleAsync<int>("SELECT LAST_INSERT_ID()");
            }

            return new ComentarioResultDTO
            {
                Success = success,
                Message = mensaje,
                IdComentario = idComentario
            };
        }
    }
}
