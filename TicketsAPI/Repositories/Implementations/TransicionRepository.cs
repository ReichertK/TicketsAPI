using Dapper;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Repositories.Implementations
{
    public class TransicionRepository : BaseRepository, IBaseRepository<Transicion>
    {
        public TransicionRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Transicion entity)
        {
            using var conn = CreateConnection();
            const string sql = @"INSERT INTO tkt_transicion (id_tkt, estado_from, estado_to, id_usuario_actor, comentario)
                                VALUES (@Id_Tkt, @Id_Estado_Anterior, @Id_Estado_Nuevo, @Id_Usuario, @Comentario);
                                SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "DELETE FROM tkt_transicion WHERE id_transicion = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Transicion>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_transicion AS Id_Transicion,
                                    id_tkt AS Id_Tkt,
                                    estado_from AS Id_Estado_Anterior,
                                    estado_to AS Id_Estado_Nuevo,
                                    id_usuario_actor AS Id_Usuario,
                                    comentario AS Comentario,
                                    fecha AS Fecha
                                 FROM tkt_transicion
                                 ORDER BY fecha DESC";
            var result = await conn.QueryAsync<Transicion>(sql);
            return result.ToList();
        }

        public async Task<Transicion?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_transicion AS Id_Transicion,
                                    id_tkt AS Id_Tkt,
                                    estado_from AS Id_Estado_Anterior,
                                    estado_to AS Id_Estado_Nuevo,
                                    id_usuario_actor AS Id_Usuario,
                                    comentario AS Comentario,
                                    fecha AS Fecha
                                 FROM tkt_transicion WHERE id_transicion = @id";
            return await conn.QuerySingleOrDefaultAsync<Transicion>(sql, new { id });
        }

        public async Task<bool> UpdateAsync(Transicion entity)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE tkt_transicion SET 
                                comentario = @Comentario
                                WHERE id_transicion = @Id_Transicion";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<List<Transicion>> GetPorTicketAsync(int idTicket)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_transicion AS Id_Transicion,
                                    id_tkt AS Id_Tkt,
                                    estado_from AS Id_Estado_Anterior,
                                    estado_to AS Id_Estado_Nuevo,
                                    id_usuario_actor AS Id_Usuario,
                                    comentario AS Comentario,
                                    fecha AS Fecha
                                 FROM tkt_transicion 
                                 WHERE id_tkt = @idTicket 
                                 ORDER BY fecha ASC";
            var result = await conn.QueryAsync<Transicion>(sql, new { idTicket });
            return result.ToList();
        }

        public async Task<List<Transicion>> GetPorEstadoAsync(int idEstado)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_transicion AS Id_Transicion,
                                    id_tkt AS Id_Tkt,
                                    estado_from AS Id_Estado_Anterior,
                                    estado_to AS Id_Estado_Nuevo,
                                    id_usuario_actor AS Id_Usuario,
                                    comentario AS Comentario,
                                    fecha AS Fecha
                                 FROM tkt_transicion 
                                 WHERE estado_to = @idEstado 
                                 ORDER BY fecha DESC";
            var result = await conn.QueryAsync<Transicion>(sql, new { idEstado });
            return result.ToList();
        }

        public async Task<List<Transicion>> GetHistorialPorUsuarioAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id_transicion AS Id_Transicion,
                                    id_tkt AS Id_Tkt,
                                    estado_from AS Id_Estado_Anterior,
                                    estado_to AS Id_Estado_Nuevo,
                                    id_usuario_actor AS Id_Usuario,
                                    comentario AS Comentario,
                                    fecha AS Fecha
                                 FROM tkt_transicion 
                                 WHERE id_usuario_actor = @idUsuario 
                                 ORDER BY fecha DESC";
            var result = await conn.QueryAsync<Transicion>(sql, new { idUsuario });
            return result.ToList();
        }

        public async Task<List<TransicionRegla>> GetReglasTransicionAsync(int idEstadoActual)
        {
            using var conn = CreateConnection();
            const string sql = @"SELECT 
                                    id AS Id,
                                    estado_from AS Estado_From,
                                    estado_to AS Estado_To,
                                    requiere_propietario AS Requiere_Propietario,
                                    permiso_requerido AS Permiso_Requerido,
                                    requiere_aprobacion AS Requiere_Aprobacion
                                 FROM tkt_transicion_regla 
                                 WHERE (estado_from = @idEstado OR estado_from IS NULL)";
            var result = await conn.QueryAsync<TransicionRegla>(sql, new { idEstado = idEstadoActual });
            return result.ToList();
        }
    }

    public class TransicionRegla
    {
        public int Id { get; set; }
        public int? Estado_From { get; set; }
        public int Estado_To { get; set; }
        public bool Requiere_Propietario { get; set; }
        public string? Permiso_Requerido { get; set; }
        public bool Requiere_Aprobacion { get; set; }
    }
}
