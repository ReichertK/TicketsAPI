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
                                SELECT LAST_INSERT_ID() AS id;";
            var result = await conn.QuerySingleAsync<dynamic>(sql, entity);
            return Convert.ToInt32(result.id);
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
        /// Usa parámetros de salida en lugar de LAST_INSERT_ID() para mayor seguridad
        /// </summary>
        public async Task<ComentarioResultDTO> CrearComentarioViaStoredProcedureAsync(int idTkt, int idUsuario, string comentario)
        {
            using var conn = CreateConnection();

            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("p_id_tkt", idTkt);
                parameters.Add("p_id_usuario", idUsuario);
                parameters.Add("p_comentario", comentario);

                var result = await conn.QuerySingleAsync<ComentarioResultDTO>(
                    "sp_tkt_comentar",
                    parameters,
                    commandType: System.Data.CommandType.StoredProcedure);

                if (result.Success == 1)
                {
                    var lastId = await conn.ExecuteScalarAsync<int>("SELECT LAST_INSERT_ID();");
                    result.IdComentario = lastId;
                }

                return result;
            }
            catch (Exception ex)
            {
                return new ComentarioResultDTO
                {
                    Success = 0,
                    Message = $"Error al ejecutar sp_tkt_comentar: {ex.Message}",
                    IdComentario = null
                };
            }
        }
    }
}
