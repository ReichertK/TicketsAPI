using System.Data;
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
            // Usar stored procedure sp_agregar_tkt en lugar de INSERT directo
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("@w_id_estado", entity.Id_Estado);
            parameters.Add("@w_id_usuario", entity.Id_Usuario);
            parameters.Add("@w_id_empresa", entity.Id_Empresa ?? 1);
            parameters.Add("@w_id_perfil", entity.Id_Perfil ?? 0);
            parameters.Add("@w_id_motivo", entity.Id_Motivo);
            parameters.Add("@w_id_sucursal", entity.Id_Sucursal ?? 0);
            parameters.Add("@w_id_prioridad", entity.Id_Prioridad);
            parameters.Add("@w_contenido", entity.Contenido);
            parameters.Add("@w_id_departamento", entity.Id_Departamento);
            parameters.Add("@p_resultado", dbType: DbType.String, size: 255, direction: ParameterDirection.Output);

            await conn.ExecuteAsync("sp_agregar_tkt", parameters, commandType: CommandType.StoredProcedure);
            var lastId = await conn.ExecuteScalarAsync<int>("SELECT LAST_INSERT_ID();");
            return lastId;
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

        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        public async Task<List<Ticket>> GetByUsuarioAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Usuario = @idUsuario";
            var result = await conn.QueryAsync<Ticket>(sql, new { idUsuario });
            return result.ToList();
        }

        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        public async Task<List<Ticket>> GetByUsuarioCreadorAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Usuario = @idUsuario AND Habilitado = 1";
            var result = await conn.QueryAsync<Ticket>(sql, new { idUsuario });
            return result.ToList();
        }

        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        public async Task<List<Ticket>> GetByUsuarioAsignadoAsync(int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Usuario_Asignado = @idUsuario";
            var result = await conn.QueryAsync<Ticket>(sql, new { idUsuario });
            return result.ToList();
        }

        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
        public async Task<List<Ticket>> GetByEstadoAsync(int idEstado)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Estado = @idEstado";
            var result = await conn.QueryAsync<Ticket>(sql, new { idEstado });
            return result.ToList();
        }

        [System.Obsolete("No usar: bypass de stored procedures y validaciones de permisos. Usar GetFilteredAsync (sp_listar_tkts).")]
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
            // Ejecutar sp_listar_tkts para respetar filtros/permisos del sistema original
            using var conn = CreateConnection();

            var page = Math.Max(1, filtro.Pagina);
            var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);

            var parameters = new DynamicParameters();
            parameters.Add("@w_Id_Tkt", null, DbType.Int64);
            parameters.Add("@w_Id_Estado", filtro.Id_Estado, DbType.Int32);
            parameters.Add("@w_Date_Creado", filtro.Fecha_Desde?.Date, DbType.Date);
            parameters.Add("@w_Date_Cierre", filtro.Fecha_Hasta, DbType.DateTime);
            parameters.Add("@w_Date_Asignado", null, DbType.DateTime);
            parameters.Add("@w_Date_Cambio_Estado", null, DbType.DateTime);
            parameters.Add("@w_Id_Usuario", filtro.Id_Usuario, DbType.Int32);
            parameters.Add("@w_Nombre_Usuario", null, DbType.String);
            parameters.Add("@w_Id_Empresa", null, DbType.Int32);
            parameters.Add("@w_Id_Perfil", null, DbType.Int32);
            parameters.Add("@w_Id_Motivo", filtro.Id_Motivo, DbType.Int32);
            parameters.Add("@w_Id_Sucursal", null, DbType.Int32);
            parameters.Add("@w_Habilitado", 1, DbType.Int32); // Solo tickets habilitados
            parameters.Add("@w_Id_Prioridad", filtro.Id_Prioridad, DbType.Int32);
            parameters.Add("@w_Contenido", filtro.Busqueda, DbType.String);
            parameters.Add("@w_Id_Departamento", filtro.Id_Departamento, DbType.Int32);
            parameters.Add("@w_Page", page, DbType.Int32);
            parameters.Add("@w_Page_Size", pageSize, DbType.Int32);
            parameters.Add("@totalRecords", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var items = await conn.QueryAsync<TicketDTO>(
                "sp_listar_tkts",
                parameters,
                commandType: CommandType.StoredProcedure);

            var totalRecords = parameters.Get<int>("@totalRecords");
            var totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);

            return new PaginatedResponse<TicketDTO>
            {
                Datos = items.ToList(),
                TotalRegistros = totalRecords,
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

            public async Task<bool> UpdateViaStoredProcedureAsync(
                long idTkt,
                int idEstado,
                int? idUsuario,
                int? idEmpresa,
                int? idPerfil,
                int? idMotivo,
                int? idSucursal,
                int idPrioridad,
                string contenido,
                int idDepartamento,
                int idUsuarioActor)
            {
                using var conn = CreateConnection();
                var parameters = new DynamicParameters();
                parameters.Add("@w_id_tkt", idTkt, DbType.Int64);
                parameters.Add("@w_id_estado", idEstado, DbType.Int32);
                parameters.Add("@w_id_usuario", idUsuario, DbType.Int32);
                parameters.Add("@w_id_empresa", idEmpresa ?? 1, DbType.Int32);
                parameters.Add("@w_id_perfil", idPerfil ?? 0, DbType.Int32);
                parameters.Add("@w_id_motivo", idMotivo, DbType.Int32);
                parameters.Add("@w_id_sucursal", idSucursal ?? 0, DbType.Int32);
                parameters.Add("@w_id_prioridad", idPrioridad, DbType.Int32);
                parameters.Add("@w_contenido", contenido, DbType.String);
                parameters.Add("@w_id_departamento", idDepartamento, DbType.Int32);
                parameters.Add("@w_id_usuario_actor", idUsuarioActor, DbType.Int32);
                parameters.Add("@p_resultado", dbType: DbType.String, size: 255, direction: ParameterDirection.Output);

                await conn.ExecuteAsync("sp_actualizar_tkt", parameters, commandType: CommandType.StoredProcedure);
            
                var resultado = parameters.Get<string>("@p_resultado");
                return resultado == "OK";
            }

        public async Task<TransicionResultDTO> TransicionarEstadoViaStoredProcedureAsync(
            int idTkt,
            int estadoTo,
            int idUsuarioActor,
            string? comentario = null,
            string? motivo = null,
            int? idAsignadoNuevo = null,
            string? metaJson = null,
            bool esSuperAdmin = false)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("@p_id_tkt", idTkt, DbType.Int32);
            parameters.Add("@p_estado_to", estadoTo, DbType.Int32);
            parameters.Add("@p_id_usuario_actor", idUsuarioActor, DbType.Int32);
            parameters.Add("@p_comentario", comentario, DbType.String);
            parameters.Add("@p_motivo", motivo, DbType.String);
            parameters.Add("@p_id_asignado_nuevo", idAsignadoNuevo, DbType.Int32);
            parameters.Add("@p_meta_json", metaJson, DbType.String);
            parameters.Add("@p_es_super_admin", esSuperAdmin ? 1 : 0, DbType.Int32);

            // sp_tkt_transicionar devuelve una fila con success, message, nuevo_estado, id_asignado
            var result = await conn.QuerySingleAsync<TransicionResultDTO>(
                "sp_tkt_transicionar",
                parameters,
                commandType: CommandType.StoredProcedure);

            return result;
        }

        public async Task<List<HistorialTicketDTO>> GetHistorialViaStoredProcedureAsync(int idTkt)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("@p_id_tkt", idTkt, DbType.Int32);

            var records = await conn.QueryAsync(
                "sp_tkt_historial",
                parameters,
                commandType: CommandType.StoredProcedure);

            var historial = new List<HistorialTicketDTO>();

            foreach (var r in records)
            {
                historial.Add(new HistorialTicketDTO
                {
                    Id_Historial = r.orden != null ? (int)r.orden : 0,
                    Id_Ticket = idTkt,
                    Id_Usuario = r.id_usuario != null ? (int)r.id_usuario : 0,
                    Accion = r.tipo as string ?? string.Empty,
                    Campo_Modificado = "Estado",
                    Valor_Anterior = r.estadofrom_nombre as string,
                    Valor_Nuevo = r.estadoto_nombre as string,
                    Fecha_Cambio = r.fecha != null ? (DateTime)r.fecha : DateTime.MinValue,
                    Usuario = new UsuarioDTO
                    {
                        Id_Usuario = r.id_usuario != null ? (int)r.id_usuario : 0,
                        Nombre = r.usuario_nombre as string ?? string.Empty,
                        Email = string.Empty,
                        Activo = true
                    }
                });
            }

            return historial;
        }
    }
}
