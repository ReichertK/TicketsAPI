using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class PoliticaTransicionRepository : BaseRepository, IPoliticaTransicionRepository
    {
        public PoliticaTransicionRepository(string connectionString) : base(connectionString) { }

        /// <summary>
        /// DEPRECATED: No usar. Tabla PoliticasTransicion no existe en BD.
        /// Usar métodos GetTransicionAsync y GetPosiblesTransicionesAsync que mapean a tkt_transicion_regla
        /// </summary>
        public async Task<int> CreateAsync(PoliticaTransicion entity)
        {
            using var conn = CreateConnection();
            // Mapear a tkt_transicion_regla (tabla real)
            var sql = @"INSERT INTO tkt_transicion_regla (estado_from, estado_to, permiso_requerido)
                        VALUES (@Id_Estado_Origen, @Id_Estado_Destino, @Permitida);
                        SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            // Eliminar de tabla real
            var sql = "DELETE FROM tkt_transicion_regla WHERE id = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<PoliticaTransicion>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = @"SELECT 
                            id AS Id_Politica,
                            estado_from AS Id_Estado_Origen,
                            estado_to AS Id_Estado_Destino,
                            0 AS Id_Rol,
                            1 AS Permitida
                        FROM tkt_transicion_regla";
            var list = await conn.QueryAsync<PoliticaTransicion>(sql);
            return list.ToList();
        }

        public async Task<PoliticaTransicion?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = @"SELECT 
                            id AS Id_Politica,
                            estado_from AS Id_Estado_Origen,
                            estado_to AS Id_Estado_Destino,
                            0 AS Id_Rol,
                            1 AS Permitida
                        FROM tkt_transicion_regla
                        WHERE id = @id";
            return await conn.QueryFirstOrDefaultAsync<PoliticaTransicion>(sql, new { id });
        }

        public async Task<PoliticaTransicion?> GetTransicionAsync(int idEstadoOrigen, int idEstadoDestino, int idRol)
        {
            using var conn = CreateConnection();
            // Mapear a la tabla real: tkt_transicion_regla
            // Nota: Esta tabla no tiene columna de rol, por lo que todas las reglas aplican a todos los roles
            var sql = @"SELECT 
                            id AS Id_Politica,
                            estado_from AS Id_Estado_Origen,
                            estado_to AS Id_Estado_Destino,
                            0 AS Id_Rol,
                            1 AS Permitida
                        FROM tkt_transicion_regla
                        WHERE estado_from = @idEstadoOrigen 
                          AND estado_to = @idEstadoDestino
                        LIMIT 1";
            return await conn.QueryFirstOrDefaultAsync<PoliticaTransicion>(sql, 
                new { idEstadoOrigen, idEstadoDestino });
        }

        public async Task<List<PoliticaTransicion>> GetPosiblesTransicionesAsync(int idEstadoActual, int idRol)
        {
            using var conn = CreateConnection();
            // Obtener todas las transiciones posibles desde el estado actual
            var sql = @"SELECT DISTINCT 
                            id AS Id_Politica,
                            estado_from AS Id_Estado_Origen,
                            estado_to AS Id_Estado_Destino,
                            0 AS Id_Rol,
                            1 AS Permitida
                       FROM tkt_transicion_regla
                       WHERE estado_from = @idEstadoActual
                       ORDER BY estado_to";
            var list = await conn.QueryAsync<PoliticaTransicion>(sql, new { idEstadoActual });
            return list.ToList();
        }

        public async Task<bool> UpdateAsync(PoliticaTransicion entity)
        {
            using var conn = CreateConnection();
            var sql = @"UPDATE tkt_transicion_regla SET 
                        estado_from = @Id_Estado_Origen,
                        estado_to = @Id_Estado_Destino,
                        permiso_requerido = @Permitida
                        WHERE id = @Id_Politica";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }
    }
}
