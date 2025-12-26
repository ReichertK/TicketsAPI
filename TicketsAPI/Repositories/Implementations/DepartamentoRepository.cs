using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;

namespace TicketsAPI.Repositories.Implementations
{
    public class DepartamentoRepository : BaseRepository, IDepartamentoRepository
    {
        public DepartamentoRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Departamento entity)
        {
            using var conn = CreateConnection();
            var sql = "INSERT INTO departamento (Nombre) VALUES (@Nombre); SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "DELETE FROM departamento WHERE Id_Departamento = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Departamento>> GetAllAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Departamento, Nombre FROM departamento";
            var list = await conn.QueryAsync<Departamento>(sql);
            return list.ToList();
        }

        public async Task<List<Departamento>> GetAllActiveAsync()
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Departamento, Nombre FROM departamento";
            var list = await conn.QueryAsync<Departamento>(sql);
            return list.ToList();
        }

        public async Task<Departamento?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Departamento, Nombre FROM departamento WHERE Id_Departamento = @id";
            return await conn.QueryFirstOrDefaultAsync<Departamento>(sql, new { id });
        }

        public async Task<Departamento?> GetByNombreAsync(string nombre)
        {
            using var conn = CreateConnection();
            var sql = "SELECT Id_Departamento, Nombre FROM departamento WHERE Nombre = @nombre";
            return await conn.QueryFirstOrDefaultAsync<Departamento>(sql, new { nombre });
        }

        public async Task<bool> UpdateAsync(Departamento entity)
        {
            using var conn = CreateConnection();
            var sql = "UPDATE departamento SET Nombre=@Nombre WHERE Id_Departamento=@Id_Departamento";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            using var conn = CreateConnection();
            var sql = "SELECT COUNT(*) FROM departamento WHERE Id_Departamento = @id";
            var count = await conn.ExecuteScalarAsync<int>(sql, new { id });
            return count > 0;
        }
    }
}
