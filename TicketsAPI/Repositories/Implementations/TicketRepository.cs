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
            const string sql = @"INSERT INTO tkt (Id_Estado, Id_Prioridad, Id_Departamento, Id_Usuario, Id_Usuario_Asignado, Date_Creado, Contenido, Id_Motivo, Habilitado)
                                VALUES (@Id_Estado, @Id_Prioridad, @Id_Departamento, @Id_Usuario, @Id_Usuario_Asignado, NOW(), @Contenido, @Id_Motivo, 1);
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
            const string sql = "SELECT * FROM tkt WHERE Id_Usuario = @idUsuario AND Habilitado = 1";
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
                                Contenido=@Contenido, Id_Estado=@Id_Estado, Id_Prioridad=@Id_Prioridad,
                                Id_Departamento=@Id_Departamento, Id_Usuario_Asignado=@Id_Usuario_Asignado,
                                Date_Cambio_Estado=NOW(), Id_Motivo=@Id_Motivo
                                WHERE Id_Tkt=@Id_Tkt";
            var rows = await conn.ExecuteAsync(sql, entity);
            return rows > 0;
        }

        public async Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro)
        {
            using var conn = CreateConnection();
            var where = new List<string> { "t.Habilitado = 1" };
            var param = new DynamicParameters();
            if (filtro.Id_Estado.HasValue) { where.Add("t.Id_Estado = @Id_Estado"); param.Add("Id_Estado", filtro.Id_Estado); }
            if (filtro.Id_Prioridad.HasValue) { where.Add("t.Id_Prioridad = @Id_Prioridad"); param.Add("Id_Prioridad", filtro.Id_Prioridad); }
            if (filtro.Id_Departamento.HasValue) { where.Add("t.Id_Departamento = @Id_Departamento"); param.Add("Id_Departamento", filtro.Id_Departamento); }
            if (filtro.Id_Usuario_Asignado.HasValue) { where.Add("t.Id_Usuario_Asignado = @Id_Usuario_Asignado"); param.Add("Id_Usuario_Asignado", filtro.Id_Usuario_Asignado); }
            if (!string.IsNullOrWhiteSpace(filtro.Busqueda)) { where.Add("(t.Contenido LIKE @q)"); param.Add("q", "%" + filtro.Busqueda + "%"); }
            if (filtro.Fecha_Desde.HasValue) { where.Add("t.Date_Creado >= @Fecha_Desde"); param.Add("Fecha_Desde", filtro.Fecha_Desde); }
            if (filtro.Fecha_Hasta.HasValue) { where.Add("t.Date_Creado <= @Fecha_Hasta"); param.Add("Fecha_Hasta", filtro.Fecha_Hasta); }

            var whereSql = "WHERE " + string.Join(" AND ", where);

            var countSql = $"SELECT COUNT(*) FROM tkt t {whereSql}";
            var total = await conn.ExecuteScalarAsync<int>(countSql, param);

                 var page = Math.Max(1, filtro.Pagina);
                 var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);
            var offset = (page - 1) * pageSize;

                 var orderBy = !string.IsNullOrWhiteSpace(filtro.Ordenar_Por) ? filtro.Ordenar_Por : "t.Date_Cambio_Estado";
                 var orderDir = filtro.Orden_Descendente == true ? "DESC" : "ASC";

                     var dataSql = $@"SELECT t.Id_Tkt, t.Contenido, t.Id_Estado, t.Id_Prioridad,
                                   t.Id_Departamento, t.Id_Usuario, t.Id_Usuario_Asignado,
                                   t.Id_Empresa, t.Id_Perfil, t.Id_Sucursal,
                                   t.Date_Creado, t.Date_Asignado, t.Date_Cierre, t.Date_Cambio_Estado,
                                   t.Id_Motivo, t.Habilitado
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
            const string sqlTicket = @"SELECT * FROM tkt WHERE Id_Tkt = @id";
            var t = await conn.QuerySingleOrDefaultAsync<Ticket>(sqlTicket, new { id });
            if (t == null) return null;

            var dto = new TicketDTO
            {
                Id_Tkt = t.Id_Tkt,
                Contenido = t.Contenido,
                Id_Estado = t.Id_Estado,
                Id_Prioridad = t.Id_Prioridad,
                Id_Departamento = t.Id_Departamento,
                Id_Usuario = t.Id_Usuario,
                Id_Usuario_Asignado = t.Id_Usuario_Asignado,
                Id_Empresa = t.Id_Empresa,
                Id_Perfil = t.Id_Perfil,
                Id_Sucursal = t.Id_Sucursal,
                Date_Creado = t.Date_Creado,
                Date_Asignado = t.Date_Asignado,
                Date_Cierre = t.Date_Cierre,
                Date_Cambio_Estado = t.Date_Cambio_Estado,
                Id_Motivo = t.Id_Motivo,
                Habilitado = t.Habilitado
            };

            if (t.Id_Estado.HasValue)
            {
                const string sqlEstado = @"SELECT Id_Estado, TipoEstado FROM estado WHERE Id_Estado = @id";
                var est = await conn.QuerySingleOrDefaultAsync(sqlEstado, new { id = t.Id_Estado.Value });
                if (est != null)
                {
                    dto.Estado = new EstadoDTO
                    {
                        Id_Estado = (int)est.Id_Estado,
                        Nombre_Estado = (string)est.TipoEstado,
                        Color = string.Empty,
                        Orden = 0,
                        Activo = true
                    };
                }
            }

            if (t.Id_Prioridad.HasValue)
            {
                const string sqlPri = @"SELECT Id_Prioridad, NombrePrioridad FROM prioridad WHERE Id_Prioridad = @id";
                var pri = await conn.QuerySingleOrDefaultAsync(sqlPri, new { id = t.Id_Prioridad.Value });
                if (pri != null)
                {
                    dto.Prioridad = new PrioridadDTO
                    {
                        Id_Prioridad = (int)pri.Id_Prioridad,
                        Nombre_Prioridad = (string)pri.NombrePrioridad,
                        Valor = 0,
                        Color = string.Empty,
                        Activo = true
                    };
                }
            }

            if (t.Id_Departamento.HasValue)
            {
                const string sqlDep = @"SELECT Id_Departamento, Nombre FROM departamento WHERE Id_Departamento = @id";
                var dep = await conn.QuerySingleOrDefaultAsync(sqlDep, new { id = t.Id_Departamento.Value });
                if (dep != null)
                {
                    dto.Departamento = new DepartamentoDTO
                    {
                        Id_Departamento = (int)dep.Id_Departamento,
                        Nombre = (string)dep.Nombre,
                        Descripcion = string.Empty,
                        Activo = true
                    };
                }
            }

            if (t.Id_Usuario.HasValue)
            {
                const string sqlUsr = @"SELECT idUsuario, nombre, email FROM usuario WHERE idUsuario = @id";
                var usr = await conn.QuerySingleOrDefaultAsync(sqlUsr, new { id = t.Id_Usuario.Value });
                if (usr != null)
                {
                    dto.UsuarioCreador = new UsuarioDTO
                    {
                        Id_Usuario = (int)usr.idUsuario,
                        Nombre = (string)usr.nombre,
                        Email = usr.email as string ?? string.Empty,
                        Activo = true
                    };
                }
            }

            if (t.Id_Usuario_Asignado.HasValue)
            {
                const string sqlUsrAsg = @"SELECT idUsuario, nombre, email FROM usuario WHERE idUsuario = @id";
                var usrAsg = await conn.QuerySingleOrDefaultAsync(sqlUsrAsg, new { id = t.Id_Usuario_Asignado.Value });
                if (usrAsg != null)
                {
                    dto.UsuarioAsignado = new UsuarioDTO
                    {
                        Id_Usuario = (int)usrAsg.idUsuario,
                        Nombre = (string)usrAsg.nombre,
                        Email = usrAsg.email as string ?? string.Empty,
                        Activo = true
                    };
                }
            }

            const string sqlComentarios = @"SELECT c.id_comentario, c.id_tkt, c.id_usuario, c.comentario, c.fecha, u.nombre, u.email
                                           FROM tkt_comentario c
                                           LEFT JOIN usuario u ON u.idUsuario = c.id_usuario
                                           WHERE c.id_tkt = @id
                                           ORDER BY c.fecha ASC";
            var comentarios = await conn.QueryAsync(sqlComentarios, new { id });
            if (comentarios != null)
            {
                dto.Comentarios = comentarios.Select(c => new ComentarioDTO
                {
                    Id_Comentario = (int)c.id_comentario,
                    Id_Ticket = (int)c.id_tkt,
                    Id_Usuario = (int)c.id_usuario,
                    Contenido = (string)c.comentario,
                    Fecha_Creacion = (DateTime)c.fecha,
                    Fecha_Actualizacion = null,
                    Privado = false,
                    Usuario = new UsuarioDTO
                    {
                        Id_Usuario = (int)c.id_usuario,
                        Nombre = c.nombre as string ?? string.Empty,
                        Email = c.email as string ?? string.Empty,
                        Activo = true
                    }
                }).ToList();
            }

            const string sqlHist = @"SELECT id_transicion, id_tkt, estado_from, estado_to, id_usuario_actor, fecha
                                     FROM tkt_transicion
                                     WHERE id_tkt = @id
                                     ORDER BY fecha ASC";
            var hist = await conn.QueryAsync(sqlHist, new { id });
            if (hist != null)
            {
                dto.Historial = hist.Select(h => new HistorialTicketDTO
                {
                    Id_Historial = (int)h.id_transicion,
                    Id_Ticket = (int)h.id_tkt,
                    Id_Usuario = (int)h.id_usuario_actor,
                    Accion = "Transición",
                    Campo_Modificado = "Estado",
                    Valor_Anterior = h.estado_from != null ? h.estado_from.ToString() : null,
                    Valor_Nuevo = h.estado_to != null ? h.estado_to.ToString() : null,
                    Fecha_Cambio = (DateTime)h.fecha
                }).ToList();
            }

            return dto;
        }
    }
}
