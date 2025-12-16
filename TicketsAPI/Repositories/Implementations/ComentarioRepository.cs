using Dapper;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class ComentarioRepository : BaseRepository, IBaseRepository<Comentario>
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
    }
}
