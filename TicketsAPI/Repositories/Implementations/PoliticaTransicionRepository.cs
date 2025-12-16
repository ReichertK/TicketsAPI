using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class PoliticaTransicionRepository : BaseRepository, IPoliticaTransicionRepository
    {
        public PoliticaTransicionRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(PoliticaTransicion entity)
        {
            using var conn = CreateConnection();
            var sql = @"INSERT INTO PoliticasTransicion (Id_Estado_Origen, Id_Estado_Destino, Id_Rol, Permitida)
                        VALUES (@Id_Estado_Origen, @Id_Estado_Destino, @Id_Rol, @Permitida);
                        SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "DELETE FROM PoliticasTransicion WHERE Id_Politica = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<PoliticaTransicion>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Politica, Id_Estado_Origen, Id_Estado_Destino, Id_Rol, Permitida FROM PoliticasTransicion";
            var list = await conn.QueryAsync<PoliticaTransicion>(sql);
            return list.ToList();
        }

        public async Task<PoliticaTransicion?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Politica, Id_Estado_Origen, Id_Estado_Destino, Id_Rol, Permitida FROM PoliticasTransicion WHERE Id_Politica = @id";
            return await conn.QueryFirstOrDefaultAsync<PoliticaTransicion>(sql, new { id });
        }

        public async Task<PoliticaTransicion?> GetTransicionAsync(int idEstadoOrigen, int idEstadoDestino, int idRol)
        {
            using var conn = CreateConnection();
            var sql = @"SELECT Id_Politica, Id_Estado_Origen, Id_Estado_Destino, Id_Rol, Permitida
                        FROM PoliticasTransicion
                        WHERE Id_Estado_Origen = @idEstadoOrigen AND Id_Estado_Destino = @idEstadoDestino AND Id_Rol = @idRol";
            return await conn.QueryFirstOrDefaultAsync<PoliticaTransicion>(sql, new { idEstadoOrigen, idEstadoDestino, idRol });
        }

        public async Task<List<PoliticaTransicion>> GetPosiblesTransicionesAsync(int idEstadoActual, int idRol)
        {
            using var conn = CreateConnection();
            var sql = @"SELECT pt.Id_Politica, pt.Id_Estado_Origen, pt.Id_Estado_Destino, pt.Id_Rol, pt.Permitida,
                               ed.Id_Estado as Id_Estado, ed.Nombre_Estado as Nombre_Estado, ed.Color as Color, ed.Orden as Orden, ed.Activo as Activo
                        FROM PoliticasTransicion pt
                        INNER JOIN Estados ed ON ed.Id_Estado = pt.Id_Estado_Destino
                        WHERE pt.Id_Estado_Origen = @idEstadoActual AND pt.Id_Rol = @idRol AND pt.Permitida = 1";
            var dict = new Dictionary<int, PoliticaTransicion>();
            var list = await conn.QueryAsync<PoliticaTransicion, Estado, PoliticaTransicion>(sql,
                (pt, destino) =>
                {
                    pt.EstadoDestino = destino;
                    return pt;
                }, new { idEstadoActual, idRol });
            return list.ToList();
        }

        public async Task<bool> UpdateAsync(PoliticaTransicion entity)
        {
            using var conn = CreateConnection();
            var sql = @"UPDATE PoliticasTransicion SET Id_Estado_Origen=@Id_Estado_Origen, Id_Estado_Destino=@Id_Estado_Destino,
                        Id_Rol=@Id_Rol, Permitida=@Permitida WHERE Id_Politica=@Id_Politica";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }
    }
}
