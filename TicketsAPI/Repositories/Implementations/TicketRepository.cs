using Dapper;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Models.Entities;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Repositories.Implementations
{
    public class TicketRepository : BaseRepository, ITicketRepository
    {
        public TicketRepository(string connectionString) : base(connectionString) { }

        public async Task<int> CreateAsync(Ticket entity)
        {
            using var conn = CreateConnection();
            const string sql = @"INSERT INTO tkt (Id_Estado, Id_Prioridad, Id_Departamento, Id_Usuario, Id_Usuario_Asignado, Date_Creado, Contenido)
                                VALUES (@Id_Estado, @Id_Prioridad, @Id_Departamento, @Id_Usuario_Creador, @Id_Usuario_Asignado, @Fecha_Creacion, @Descripcion);
                                SELECT LAST_INSERT_ID();";
            return await conn.ExecuteScalarAsync<int>(sql, entity);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "DELETE FROM tkt WHERE Id_Tkt = @id";
            var rows = await conn.ExecuteAsync(sql, new { id });
            return rows > 0;
        }

        public async Task<List<Ticket>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt";
            var result = await conn.QueryAsync<Ticket>(sql);
            return result.ToList();
        }

        public async Task<Ticket?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Tkt = @id";
            return await conn.QuerySingleOrDefaultAsync<Ticket>(sql, new { id });
        }

        public async Task<List<Ticket>> GetByUsuarioAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Usuario = @idUsuario";
            var result = await conn.QueryAsync<Ticket>(sql, new { idUsuario });
            return result.ToList();
        }

        public async Task<List<Ticket>> GetByUsuarioCreadorAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tickets WHERE Id_Usuario_Creador = @idUsuario";
            var result = await conn.QueryAsync<Ticket>(sql, new { idUsuario });
            return result.ToList();
        }

        public async Task<List<Ticket>> GetByUsuarioAsignadoAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Usuario_Asignado = @idUsuario";
            var result = await conn.QueryAsync<Ticket>(sql, new { idUsuario });
            return result.ToList();
        }

        public async Task<List<Ticket>> GetByEstadoAsync(int idEstado)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Estado = @idEstado";
            var result = await conn.QueryAsync<Ticket>(sql, new { idEstado });
            return result.ToList();
        }

        public async Task<List<Ticket>> GetByDepartamentoAsync(int idDepartamento)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Departamento = @idDepartamento";
            var result = await conn.QueryAsync<Ticket>(sql, new { idDepartamento });
            return result.ToList();
        }

        public async Task<bool> UpdateAsync(Ticket entity)
        {
            using var conn = CreateConnection();
            const string sql = @"UPDATE tkt SET
                                Contenido=@Descripcion, Id_Estado=@Id_Estado, Id_Prioridad=@Id_Prioridad,
                                Id_Departamento=@Id_Departamento, Id_Usuario_Asignado=@Id_Usuario_Asignado,
                                Date_Cambio_Estado=@Fecha_Actualizacion
                                WHERE Id_Tkt=@Id_Ticket";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro)
        {
            using var conn = CreateConnection();
            var where = new List<string>();
            var param = new DynamicParameters();
            if (filtro.Id_Estado.HasValue) { where.Add("t.Id_Estado = @Id_Estado"); param.Add("Id_Estado", filtro.Id_Estado); }
            if (filtro.Id_Prioridad.HasValue) { where.Add("t.Id_Prioridad = @Id_Prioridad"); param.Add("Id_Prioridad", filtro.Id_Prioridad); }
            if (filtro.Id_Departamento.HasValue) { where.Add("t.Id_Departamento = @Id_Departamento"); param.Add("Id_Departamento", filtro.Id_Departamento); }
            if (filtro.Id_Usuario_Asignado.HasValue) { where.Add("t.Id_Usuario_Asignado = @Id_Usuario_Asignado"); param.Add("Id_Usuario_Asignado", filtro.Id_Usuario_Asignado); }
            if (!string.IsNullOrWhiteSpace(filtro.Busqueda)) { where.Add("(t.Titulo LIKE @q OR t.Descripcion LIKE @q)"); param.Add("q", "%" + filtro.Busqueda + "%"); }
            if (filtro.Fecha_Desde.HasValue) { where.Add("t.Fecha_Creacion >= @Fecha_Desde"); param.Add("Fecha_Desde", filtro.Fecha_Desde); }
            if (filtro.Fecha_Hasta.HasValue) { where.Add("t.Fecha_Creacion <= @Fecha_Hasta"); param.Add("Fecha_Hasta", filtro.Fecha_Hasta); }

            var whereSql = where.Count > 0 ? ("WHERE " + string.Join(" AND ", where)) : string.Empty;

            var countSql = $"SELECT COUNT(*) FROM tkt t {whereSql}";
            var total = await conn.ExecuteScalarAsync<int>(countSql, param);

                 var page = Math.Max(1, filtro.Pagina);
                 var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);
            var offset = (page - 1) * pageSize;

                 var orderBy = !string.IsNullOrWhiteSpace(filtro.Ordenar_Por) ? filtro.Ordenar_Por : "t.Fecha_Actualizacion";
                 var orderDir = filtro.Orden_Descendente == true ? "DESC" : "ASC";

                     var dataSql = $@"SELECT t.Id_Tkt AS Id_Ticket, t.Contenido AS Descripcion, t.Id_Estado, t.Id_Prioridad,
                                   t.Id_Departamento, t.Id_Usuario AS Id_Usuario_Creador, t.Id_Usuario_Asignado,
                                   t.Date_Creado AS Fecha_Creacion, t.Date_Cambio_Estado AS Fecha_Actualizacion
                               FROM tkt t
                               {whereSql}
                           ORDER BY {orderBy} {orderDir}
                               LIMIT @PageSize OFFSET @Offset";

            param.Add("PageSize", pageSize);
            param.Add("Offset", offset);

            var items = await conn.QueryAsync<TicketDTO>(dataSql, param);

            var totalPages = (int)Math.Ceiling(total / (double)pageSize);
            return new PaginatedResponse<TicketDTO>
            {
                Datos = items.ToList(),
                TotalRegistros = total,
                TotalPaginas = totalPages,
                PaginaActual = page,
                TamañoPagina = pageSize,
                TienePaginaAnterior = page > 1,
                TienePaginaSiguiente = page < totalPages
            };
        }

        public async Task<TicketDTO?> GetDetailAsync(int id)
        {
            using var conn = CreateConnection();
                 const string sql = @"SELECT t.Id_Tkt AS Id_Ticket, t.Contenido AS Descripcion, t.Id_Estado, t.Id_Prioridad,
                                  t.Id_Departamento, t.Id_Usuario AS Id_Usuario_Creador, t.Id_Usuario_Asignado,
                                  t.Date_Creado AS Fecha_Creacion, t.Date_Cambio_Estado AS Fecha_Actualizacion
                              FROM tkt t
                              WHERE t.Id_Tkt = @id";
            return await conn.QuerySingleOrDefaultAsync<TicketDTO>(sql, new { id });
        }
    }
}
