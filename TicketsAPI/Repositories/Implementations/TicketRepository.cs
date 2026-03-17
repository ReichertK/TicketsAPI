using System.Data;
using Dapper;
using MySqlConnector;
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
            parameters.Add("@w_id_empresa", entity.Id_Empresa > 0 ? entity.Id_Empresa : 1);
            parameters.Add("@w_id_perfil", entity.Id_Perfil ?? 0);
            parameters.Add("@w_id_motivo", entity.Id_Motivo);
            parameters.Add("@w_id_sucursal", entity.Id_Sucursal ?? 0);
            parameters.Add("@w_id_prioridad", entity.Id_Prioridad);
            parameters.Add("@w_contenido", entity.Contenido);
            parameters.Add("@w_id_departamento", entity.Id_Departamento);
            parameters.Add("@p_resultado", dbType: DbType.String, size: 255, direction: ParameterDirection.Output);

            await conn.ExecuteAsync("sp_agregar_tkt", parameters, commandType: CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("@p_resultado");
            if (!string.IsNullOrWhiteSpace(resultado) && resultado.StartsWith("Error:"))
                throw new Exceptions.ValidationException(resultado);

            var lastId = await conn.ExecuteScalarAsync<int>("SELECT LAST_INSERT_ID();");
            return lastId;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("w_id_ticket", id);
            parameters.Add("p_resultado", dbType: DbType.String, size: 255, direction: ParameterDirection.Output);

            await conn.ExecuteAsync("sp_eliminar_ticket", parameters, commandType: CommandType.StoredProcedure);

            var resultado = parameters.Get<string>("p_resultado") ?? string.Empty;
            return resultado.Equals("OK", StringComparison.OrdinalIgnoreCase);
        }

        [System.Obsolete("Evitar uso directo: carga masiva sin filtros. Preferir GetFilteredAsync (sp_listar_tkts) o GetFilteredAdvancedAsync.")]
        public async Task<List<Ticket>> GetAllAsync()
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt LIMIT 1000";
            var result = await conn.QueryAsync<Ticket>(sql);
            return result.ToList();
        }

        public async Task<Ticket?> GetByIdAsync(int id)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT * FROM tkt WHERE Id_Tkt = @id";
            return await conn.QuerySingleOrDefaultAsync<Ticket>(sql, new { id });
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

            var rows = await conn.QueryAsync<dynamic>(
                "sp_listar_tkts",
                parameters,
                commandType: CommandType.StoredProcedure);

            var items = rows.Select(row =>
            {
                var dto = new TicketDTO
                {
                    Id_Tkt = (long)row.Id_Tkt,
                    Id_Estado = row.Id_Estado as int?,
                    Id_Prioridad = row.Id_Prioridad as int?,
                    Id_Departamento = row.Id_Departamento as int?,
                    Id_Usuario = row.Id_Usuario != null ? (int?)Convert.ToInt32(row.Id_Usuario) : null,
                    Id_Empresa = row.Id_Empresa as int?,
                    Id_Perfil = row.Id_Perfil as int?,
                    Id_Sucursal = row.Id_Sucursal as int?,
                    Id_Motivo = row.Id_Motivo as int?,
                    Habilitado = row.Habilitado as int?,
                    Contenido = row.Contenido as string,
                    Date_Creado = row.Date_Creado as DateTime?,
                    Date_Cierre = row.Date_Cierre as DateTime?,
                    Date_Asignado = row.Date_Asignado as DateTime?,
                    Date_Cambio_Estado = row.Date_Cambio_Estado as DateTime?
                };

                // Mapear objetos anidados desde columnas planas del SP
                if (dto.Id_Estado.HasValue)
                {
                    dto.Estado = new EstadoDTO
                    {
                        Id_Estado = dto.Id_Estado.Value,
                        Nombre_Estado = row.TipoEstado as string ?? string.Empty,
                        Color = string.Empty,
                        Orden = 0,
                        Activo = true
                    };
                }

                if (dto.Id_Prioridad.HasValue)
                {
                    dto.Prioridad = new PrioridadDTO
                    {
                        Id_Prioridad = dto.Id_Prioridad.Value,
                        Nombre_Prioridad = row.NombrePrioridad as string ?? string.Empty,
                        Valor = 0,
                        Color = string.Empty,
                        Activo = true
                    };
                }

                if (dto.Id_Departamento.HasValue)
                {
                    dto.Departamento = new DepartamentoDTO
                    {
                        Id_Departamento = dto.Id_Departamento.Value,
                        Nombre = row.Nombre_Departamento as string ?? string.Empty,
                        Descripcion = string.Empty,
                        Activo = true
                    };
                }

                string? nombreUsuario = row.Nombre_Usuario as string;
                if (dto.Id_Usuario.HasValue && !string.IsNullOrEmpty(nombreUsuario))
                {
                    dto.UsuarioCreador = new UsuarioDTO
                    {
                        Id_Usuario = dto.Id_Usuario.Value,
                        Nombre = nombreUsuario,
                        Email = string.Empty,
                        Activo = true
                    };
                }

                // Mapear usuario asignado
                int? idAsignado = row.Id_Usuario_Asignado != null ? (int?)Convert.ToInt32(row.Id_Usuario_Asignado) : null;
                string? nombreAsignado = row.Nombre_Asignado as string;
                if (idAsignado.HasValue && !string.IsNullOrEmpty(nombreAsignado))
                {
                    dto.Id_Usuario_Asignado = idAsignado.Value;
                    dto.UsuarioAsignado = new UsuarioDTO
                    {
                        Id_Usuario = idAsignado.Value,
                        Nombre = nombreAsignado,
                        Email = string.Empty,
                        Activo = true
                    };
                }

                return dto;
            }).ToList();

            var totalRecords = parameters.Get<int>("@totalRecords");
            var totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);

            return new PaginatedResponse<TicketDTO>
            {
                Datos = items,
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
            var row = await conn.QuerySingleOrDefaultAsync(
                "sp_obtener_detalle_ticket",
                new { w_Id_Tkt = id },
                commandType: CommandType.StoredProcedure);

            if (row == null) return null;

            var dto = new TicketDTO
            {
                Id_Tkt = (long)row.Id_Tkt,
                Contenido = row.Contenido as string,
                Id_Estado = row.Id_Estado as int?,
                Id_Prioridad = row.Id_Prioridad as int?,
                Id_Departamento = row.Id_Departamento as int?,
                Id_Usuario = row.Id_Usuario as int?,
                Id_Usuario_Asignado = row.Id_Usuario_Asignado as int?,
                Id_Empresa = row.Id_Empresa as int?,
                Id_Perfil = row.Id_Perfil as int?,
                Id_Sucursal = row.Id_Sucursal as int?,
                Date_Creado = row.Date_Creado as DateTime?,
                Date_Asignado = row.Date_Asignado as DateTime?,
                Date_Cierre = row.Date_Cierre as DateTime?,
                Date_Cambio_Estado = row.Date_Cambio_Estado as DateTime?,
                Id_Motivo = row.Id_Motivo as int?,
                MotivoNombre = row.MotivoNombre as string,
                Habilitado = row.Habilitado as int?
            };

            if (row.EstadoId != null)
            {
                dto.Estado = new EstadoDTO
                {
                    Id_Estado = (int)row.EstadoId,
                    Nombre_Estado = row.EstadoNombre as string ?? string.Empty,
                    Color = string.Empty,
                    Orden = 0,
                    Activo = true
                };
            }

            if (row.PrioridadId != null)
            {
                dto.Prioridad = new PrioridadDTO
                {
                    Id_Prioridad = (int)row.PrioridadId,
                    Nombre_Prioridad = row.PrioridadNombre as string ?? string.Empty,
                    Valor = 0,
                    Color = string.Empty,
                    Activo = true
                };
            }

            if (row.DepartamentoId != null)
            {
                dto.Departamento = new DepartamentoDTO
                {
                    Id_Departamento = (int)row.DepartamentoId,
                    Nombre = row.DepartamentoNombre as string ?? string.Empty,
                    Descripcion = string.Empty,
                    Activo = true
                };
            }

            if (row.U_IdUsuario != null)
            {
                dto.UsuarioCreador = new UsuarioDTO
                {
                    Id_Usuario = (int)row.U_IdUsuario,
                    Nombre = row.UsuarioNombre as string ?? string.Empty,
                    Email = row.UsuarioEmail as string ?? string.Empty,
                    Activo = true
                };
            }

            if (row.U_IdUsuario_Asignado != null)
            {
                dto.UsuarioAsignado = new UsuarioDTO
                {
                    Id_Usuario = (int)row.U_IdUsuario_Asignado,
                    Nombre = row.UsuarioAsignadoNombre as string ?? string.Empty,
                    Email = row.UsuarioAsignadoEmail as string ?? string.Empty,
                    Activo = true
                };
            }

            var comentarios = await conn.QueryAsync(
                "sp_tkt_comentarios_por_ticket",
                new { p_id_tkt = id },
                commandType: CommandType.StoredProcedure);
            if (comentarios != null)
            {
                dto.Comentarios = comentarios.Select(c => new ComentarioDTO
                {
                    Id_Comentario = c.id_comentario != null ? (int)c.id_comentario : 0,
                    Id_Ticket = c.id_tkt != null ? (int)c.id_tkt : 0,
                    Id_Usuario = c.id_usuario != null ? (int)c.id_usuario : 0,
                    Contenido = (string)c.comentario ?? string.Empty,
                    Fecha_Creacion = c.fecha != null ? (DateTime)c.fecha : DateTime.MinValue,
                    Fecha_Actualizacion = null,
                    Privado = false,
                    Usuario = new UsuarioDTO
                    {
                        Id_Usuario = c.id_usuario != null ? (int)c.id_usuario : 0,
                        Nombre = c.nombre as string ?? string.Empty,
                        Email = c.email as string ?? string.Empty,
                        Activo = true
                    }
                }).ToList();
            }

            var hist = await conn.QueryAsync(
                "sp_tkt_historial",
                new { p_id_tkt = id },
                commandType: CommandType.StoredProcedure);
            if (hist != null)
            {
                dto.Historial = hist.Select(h => new HistorialTicketDTO
                {
                    Id_Historial = h.orden != null ? (int)h.orden : 0,
                    Id_Ticket = h.id_tkt != null ? (int)h.id_tkt : 0,
                    Id_Usuario = h.id_usuario != null ? (int)h.id_usuario : 0,
                    Accion = h.tipo as string ?? "Transición",
                    Campo_Modificado = "Estado",
                    Valor_Anterior = h.estadofrom_nombre as string,
                    Valor_Nuevo = h.estadoto_nombre as string,
                    Fecha_Cambio = h.fecha != null ? (DateTime)h.fecha : DateTime.MinValue,
                    Usuario = new UsuarioDTO
                    {
                        Id_Usuario = h.id_usuario != null ? (int)h.id_usuario : 0,
                        Nombre = h.usuario_nombre as string ?? string.Empty,
                        Email = string.Empty,
                        Activo = true
                    }
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

            try
            {
                // sp_tkt_transicionar: SIGNAL en error, SELECT en éxito
                var result = await conn.QuerySingleAsync<TransicionResultDTO>(
                    "sp_tkt_transicionar",
                    parameters,
                    commandType: CommandType.StoredProcedure);
                return result;
            }
            catch (MySqlException ex) when (ex.SqlState == "45000")
            {
                // SIGNAL SQLSTATE '45000' → error de negocio controlado
                return new TransicionResultDTO
                {
                    Success = 0,
                    Message = ex.Message,
                    NuevoEstado = null,
                    IdAsignado = null
                };
            }
        }

        public async Task<bool> AssignViaStoredProcedureAsync(long idTkt, int idUsuarioAsignado, int idUsuarioActor, string? comentario)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("p_id_tkt", idTkt, DbType.Int64);
            parameters.Add("p_id_usuario_asignado", idUsuarioAsignado, DbType.Int32);
            parameters.Add("p_id_usuario_actor", idUsuarioActor, DbType.Int32);
            parameters.Add("p_comentario", comentario, DbType.String);
            parameters.Add("p_resultado", dbType: DbType.String, size: 255, direction: ParameterDirection.Output);

            try
            {
                await conn.ExecuteAsync("sp_asignar_ticket", parameters, commandType: CommandType.StoredProcedure);
            }
            catch (MySqlException ex) when (ex.SqlState == "45000")
            {
                // SIGNAL: comentario obligatorio en reasignación
                throw new Exceptions.ValidationException(ex.Message);
            }

            var resultado = parameters.Get<string>("p_resultado");
            if (!string.IsNullOrWhiteSpace(resultado) && resultado.StartsWith("Error:"))
                throw new Exceptions.ValidationException(resultado);

            return resultado == "OK";
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

        /// Búsqueda avanzada con soporte para búsqueda en comentarios y diferentes tipos de matching
        public async Task<PaginatedResponse<TicketDTO>> GetFilteredAdvancedAsync(TicketFiltroDTO filtro)
        {
            using var conn = CreateConnection();

            var page = Math.Max(1, filtro.Pagina);
            var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);
            var offset = (page - 1) * pageSize;

            // Construir la condición de búsqueda según el tipo
            string searchCondition = "1=1";
            var parameters = new DynamicParameters();

            if (!string.IsNullOrWhiteSpace(filtro.Busqueda))
            {
                var tipoBusqueda = filtro.TipoBusqueda?.ToLower() ?? "contiene";
                var searchPattern = tipoBusqueda switch
                {
                    "exacta" => filtro.Busqueda,
                    "comienza" => $"{filtro.Busqueda}%",
                    "termina" => $"%{filtro.Busqueda}",
                    _ => $"%{filtro.Busqueda}%" // contiene (default)
                };

                var conditions = new List<string>();

                // Buscar en contenido del ticket
                if (filtro.BuscarEnContenido ?? true)
                {
                    conditions.Add("t.Contenido LIKE @searchPattern");
                }

                // Buscar en comentarios
                if (filtro.BuscarEnComentarios ?? false)
                {
                    // Columna real en tkt_comentario es 'comentario'
                    conditions.Add(@"EXISTS (
                        SELECT 1 FROM tkt_comentario tc 
                        WHERE tc.Id_Tkt = t.Id_Tkt 
                        AND tc.comentario LIKE @searchPattern
                    )");
                }

                if (conditions.Any())
                {
                    searchCondition = $"({string.Join(" OR ", conditions)})";
                    parameters.Add("@searchPattern", searchPattern);
                }
            }

            // Construir la query completa
            var whereClause = new List<string> { searchCondition };

            if (filtro.Id_Estado.HasValue)
            {
                whereClause.Add("t.Id_Estado = @IdEstado");
                parameters.Add("@IdEstado", filtro.Id_Estado.Value);
            }

            if (filtro.Id_Prioridad.HasValue)
            {
                whereClause.Add("t.Id_Prioridad = @IdPrioridad");
                parameters.Add("@IdPrioridad", filtro.Id_Prioridad.Value);
            }

            if (filtro.Id_Departamento.HasValue)
            {
                whereClause.Add("t.Id_Departamento = @IdDepartamento");
                parameters.Add("@IdDepartamento", filtro.Id_Departamento.Value);
            }

            if (filtro.Id_Usuario.HasValue)
            {
                whereClause.Add("t.Id_Usuario = @IdUsuario");
                parameters.Add("@IdUsuario", filtro.Id_Usuario.Value);
            }

            if (filtro.Id_Usuario_Asignado.HasValue)
            {
                whereClause.Add("t.Id_Usuario_Asignado = @IdUsuarioAsignado");
                parameters.Add("@IdUsuarioAsignado", filtro.Id_Usuario_Asignado.Value);
            }

            // Filtro compuesto de visibilidad:
            // Muestra tickets creados por el usuario, asignados a él, y opcionalmente de su departamento
            if (filtro.VistaUsuarioId.HasValue)
            {
                if (filtro.VistaUsuarioDepartamentoId.HasValue)
                {
                    // Department-level visibility (VER_SOLO_DEPARTAMENTO or TKT_LIST_ALL)
                    whereClause.Add("(t.Id_Usuario = @VistaUserId OR t.Id_Usuario_Asignado = @VistaUserId OR t.Id_Departamento = @VistaDptoId)");
                    parameters.Add("@VistaUserId", filtro.VistaUsuarioId.Value);
                    parameters.Add("@VistaDptoId", filtro.VistaUsuarioDepartamentoId.Value);
                }
                else
                {
                    // Basic visibility: own created + assigned only
                    whereClause.Add("(t.Id_Usuario = @VistaUserId OR t.Id_Usuario_Asignado = @VistaUserId)");
                    parameters.Add("@VistaUserId", filtro.VistaUsuarioId.Value);
                }
            }

            if (filtro.Id_Motivo.HasValue)
            {
                whereClause.Add("t.Id_Motivo = @IdMotivo");
                parameters.Add("@IdMotivo", filtro.Id_Motivo.Value);
            }

            if (filtro.Fecha_Desde.HasValue)
            {
                whereClause.Add("DATE(t.Date_Creado) >= @FechaDesde");
                parameters.Add("@FechaDesde", filtro.Fecha_Desde.Value.Date);
            }

            if (filtro.Fecha_Hasta.HasValue)
            {
                whereClause.Add("DATE(t.Date_Creado) <= @FechaHasta");
                parameters.Add("@FechaHasta", filtro.Fecha_Hasta.Value.Date);
            }

            whereClause.Add("t.Habilitado = 1");

            var whereSql = string.Join(" AND ", whereClause);

            // Construir ORDER BY
            var orderBy = "t.Date_Creado DESC"; // Default
            if (!string.IsNullOrWhiteSpace(filtro.Ordenar_Por))
            {
                var direction = filtro.Orden_Descendente ?? true ? "DESC" : "ASC";

                // Mapeo de columnas válidas para ORDER BY.
                // Prioridad: IDs no son consecutivos por severidad (1=Alta,2=Media,3=Baja,7=Crítica)
                //   → CASE para orden numérico semántico: Crítica=1, Alta=2, Media=3, Baja=4
                // Estado: Id_Estado numérico (1=Abierto,2=En Proceso,3=Cerrado…)
                var validColumns = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                {
                    ["fecha"] = "t.Date_Creado",
                    ["estado"] = "e.Id_Estado",
                    ["prioridad"] = "CASE p.Id_Prioridad WHEN 7 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 3 WHEN 3 THEN 4 ELSE 5 END",
                    ["departamento"] = "d.Nombre"
                };

                if (validColumns.TryGetValue(filtro.Ordenar_Por, out var column))
                {
                    orderBy = $"{column} {direction}";
                }
            }

            // Query para contar total
            var countSql = $@"
                SELECT COUNT(DISTINCT t.Id_Tkt)
                FROM tkt t
                LEFT JOIN usuario u ON t.Id_Usuario = u.idUsuario
                LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
                LEFT JOIN prioridad p ON t.Id_Prioridad = p.Id_Prioridad
                LEFT JOIN estado e ON t.Id_Estado = e.Id_Estado
                WHERE {whereSql}";

            var totalRecords = await conn.ExecuteScalarAsync<int>(countSql, parameters);
            var totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);

            // Query principal con paginación
            var sql = $@"
                SELECT 
                    -- Campos del ticket (primero para evitar cortes de split)
                    t.Id_Tkt,
                    t.Id_Estado,
                    t.Id_Prioridad,
                    t.Id_Departamento,
                    t.Id_Usuario,
                    t.Id_Usuario_Asignado,
                    t.Id_Empresa,
                    t.Id_Perfil,
                    t.Id_Sucursal,
                    t.Date_Creado,
                    t.Date_Asignado,
                    t.Date_Cierre,
                    t.Date_Cambio_Estado,
                    t.Contenido,
                    t.Id_Motivo,
                    t.Habilitado,
                    -- Estado
                    e.Id_Estado AS Estado_Id,
                    e.Id_Estado AS Id_Estado,
                    e.TipoEstado AS Nombre_Estado,
                    '' AS Color,
                    0 AS Orden,
                    1 AS Activo,
                    -- Prioridad
                    p.Id_Prioridad AS Prioridad_Id,
                    p.Id_Prioridad AS Id_Prioridad,
                    p.NombrePrioridad AS Nombre_Prioridad,
                    0 AS Valor,
                    '' AS Color,
                    1 AS Activo,
                    -- Departamento
                    d.Id_Departamento AS Departamento_Id,
                    d.Id_Departamento AS Id_Departamento,
                    d.Nombre AS Nombre,
                    '' AS Descripcion,
                    1 AS Activo,
                    -- Usuario creador
                    u.idUsuario AS UsuarioCreador_Id,
                    u.idUsuario AS Id_Usuario,
                    u.nombre AS Nombre,
                    '' AS Apellido,
                    u.email AS Email,
                    -- Usuario asignado
                    ua.idUsuario AS UsuarioAsignado_Id,
                    ua.idUsuario AS Id_Usuario,
                    ua.nombre AS Nombre,
                    '' AS Apellido,
                    ua.email AS Email
                FROM tkt t
                LEFT JOIN usuario u ON t.Id_Usuario = u.idUsuario
                LEFT JOIN usuario ua ON t.Id_Usuario_Asignado = ua.idUsuario
                LEFT JOIN departamento d ON t.Id_Departamento = d.Id_Departamento
                LEFT JOIN prioridad p ON t.Id_Prioridad = p.Id_Prioridad
                LEFT JOIN estado e ON t.Id_Estado = e.Id_Estado
                WHERE {whereSql}
                ORDER BY {orderBy}
                LIMIT @Offset, @PageSize";

            parameters.Add("@Offset", offset);
            parameters.Add("@PageSize", pageSize);

            var items = await conn.QueryAsync<TicketDTO, EstadoDTO, PrioridadDTO, DepartamentoDTO, UsuarioDTO, UsuarioDTO, TicketDTO>(
                sql,
                (ticket, estado, prioridad, departamento, usuarioCreador, usuarioAsignado) =>
                {
                    ticket.Estado = estado;
                    ticket.Prioridad = prioridad;
                    ticket.Departamento = departamento;
                    ticket.UsuarioCreador = usuarioCreador;
                    ticket.UsuarioAsignado = usuarioAsignado;
                    return ticket;
                },
                parameters,
                splitOn: "Estado_Id,Prioridad_Id,Departamento_Id,UsuarioCreador_Id,UsuarioAsignado_Id");

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

        // ── Suscripciones ─────────────────────────────────────────────

        public async Task<SuscripcionResultDTO> GestionarSuscripcionAsync(int idTkt, int idUsuario, string accion)
        {
            using var conn = CreateConnection();
            var parameters = new DynamicParameters();
            parameters.Add("@p_id_tkt", idTkt, DbType.Int64);
            parameters.Add("@p_id_usuario", idUsuario, DbType.Int64);
            parameters.Add("@p_accion", accion, DbType.String);

            try
            {
                var result = await conn.QuerySingleAsync<SuscripcionResultDTO>(
                    "sp_tkt_gestionar_suscripcion",
                    parameters,
                    commandType: CommandType.StoredProcedure);
                return result;
            }
            catch (MySqlException ex) when (ex.SqlState == "45000")
            {
                return new SuscripcionResultDTO
                {
                    Success = 0,
                    Message = ex.Message,
                    Total = 0
                };
            }
        }

        public async Task<List<SuscriptorDTO>> GetSuscriptoresAsync(int idTkt)
        {
            using var conn = CreateConnection();
            const string sql = @"
                SELECT s.id_usuario AS Id_Usuario,
                       u.nombre AS Nombre,
                       u.email AS Email,
                       s.fecha_registro AS Fecha_Registro
                FROM tkt_suscriptor s
                INNER JOIN usuario u ON s.id_usuario = u.idUsuario
                WHERE s.id_tkt = @idTkt
                ORDER BY s.fecha_registro DESC";
            var result = await conn.QueryAsync<SuscriptorDTO>(sql, new { idTkt });
            return result.ToList();
        }

        public async Task<bool> EstaSuscritoAsync(int idTkt, int idUsuario)
        {
            using var conn = CreateConnection();
            const string sql = "SELECT COUNT(1) FROM tkt_suscriptor WHERE id_tkt = @idTkt AND id_usuario = @idUsuario";
            var count = await conn.ExecuteScalarAsync<int>(sql, new { idTkt, idUsuario });
            return count > 0;
        }

        // ── Vistas de listado (SPs dedicados) ─────────────────────────

        /// Mapea el nombre de columna del frontend a la clave que acepta la SP.
        /// Las SPs aceptan: 'fecha', 'estado', 'prioridad', 'departamento'.
        private static readonly HashSet<string> _validSortColumns =
            new(StringComparer.OrdinalIgnoreCase) { "fecha", "estado", "prioridad", "departamento" };

        /// Devuelve el valor seguro de p_ordenar_por para enviar a la SP.
        /// Si el frontend envía un valor no válido, usa 'fecha' (default de la SP).
        private static string? SafeSortColumn(string? ordenarPor)
        {
            if (!string.IsNullOrWhiteSpace(ordenarPor) && _validSortColumns.Contains(ordenarPor))
                return ordenarPor.ToLowerInvariant();
            return null; // la SP usará su default (fecha)
        }

        /// Mapea una fila del resultado de un SP de listado a TicketDTO
        private static TicketDTO MapSpRowToTicketDTO(dynamic row)
        {
            var dto = new TicketDTO
            {
                Id_Tkt = (long)row.Id_Tkt,
                Id_Estado = row.Id_Estado as int?,
                Id_Prioridad = row.Id_Prioridad as int?,
                Id_Departamento = row.Id_Departamento as int?,
                Id_Usuario = row.Id_Usuario != null ? (int?)Convert.ToInt32(row.Id_Usuario) : null,
                Id_Usuario_Asignado = row.Id_Usuario_Asignado != null ? (int?)Convert.ToInt32(row.Id_Usuario_Asignado) : null,
                Id_Empresa = row.Id_Empresa != null ? (int?)Convert.ToInt32(row.Id_Empresa) : null,
                Date_Creado = row.Date_Creado as DateTime?,
                Date_Asignado = row.Date_Asignado as DateTime?,
                Date_Cierre = row.Date_Cierre as DateTime?,
                Date_Cambio_Estado = row.Date_Cambio_Estado as DateTime?,
                Contenido = row.Contenido as string,
                Id_Motivo = row.Id_Motivo as int?,
                Habilitado = row.Habilitado as int?
            };

            if (dto.Id_Estado.HasValue)
            {
                dto.Estado = new EstadoDTO
                {
                    Id_Estado = dto.Id_Estado.Value,
                    Nombre_Estado = row.Nombre_Estado as string ?? string.Empty,
                    Color = string.Empty, Orden = 0, Activo = true
                };
            }

            if (dto.Id_Prioridad.HasValue)
            {
                dto.Prioridad = new PrioridadDTO
                {
                    Id_Prioridad = dto.Id_Prioridad.Value,
                    Nombre_Prioridad = row.Nombre_Prioridad as string ?? string.Empty,
                    Valor = 0, Color = string.Empty, Activo = true
                };
            }

            if (dto.Id_Departamento.HasValue)
            {
                dto.Departamento = new DepartamentoDTO
                {
                    Id_Departamento = dto.Id_Departamento.Value,
                    Nombre = row.Nombre_Departamento as string ?? string.Empty,
                    Descripcion = string.Empty, Activo = true
                };
            }

            string? nombreCreador = row.Nombre_Creador as string;
            if (dto.Id_Usuario.HasValue && !string.IsNullOrEmpty(nombreCreador))
            {
                dto.UsuarioCreador = new UsuarioDTO
                {
                    Id_Usuario = dto.Id_Usuario.Value,
                    Nombre = nombreCreador,
                    Email = row.Email_Creador as string ?? string.Empty,
                    Activo = true
                };
            }

            int? idAsignado = row.Id_Asignado != null ? (int?)Convert.ToInt32(row.Id_Asignado) : null;
            if (idAsignado != null)
            {
                dto.UsuarioAsignado = new UsuarioDTO
                {
                    Id_Usuario = idAsignado.Value,
                    Nombre = row.Nombre_Asignado as string ?? string.Empty,
                    Email = row.Email_Asignado as string ?? string.Empty,
                    Activo = true
                };
            }

            return dto;
        }

        public async Task<PaginatedResponse<TicketDTO>> GetMisTicketsAsync(int idUsuario, TicketFiltroDTO filtro)
        {
            using var conn = CreateConnection();
            var page = Math.Max(1, filtro.Pagina);
            var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);

            var parameters = new DynamicParameters();
            parameters.Add("@p_id_usuario", idUsuario, DbType.Int32);
            parameters.Add("@p_id_estado", filtro.Id_Estado, DbType.Int32);
            parameters.Add("@p_id_prioridad", filtro.Id_Prioridad, DbType.Int32);
            parameters.Add("@p_id_departamento", filtro.Id_Departamento, DbType.Int32);
            parameters.Add("@p_busqueda", filtro.Busqueda, DbType.String);
            parameters.Add("@p_page", page, DbType.Int32);
            parameters.Add("@p_page_size", pageSize, DbType.Int32);
            parameters.Add("@p_ordenar_por", SafeSortColumn(filtro.Ordenar_Por), DbType.String);
            parameters.Add("@p_orden_desc", (filtro.Orden_Descendente ?? true) ? 1 : 0, DbType.Int32);
            parameters.Add("@p_total", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var rows = await conn.QueryAsync<dynamic>("sp_tkt_mis_tickets", parameters, commandType: CommandType.StoredProcedure);
            var totalRecords = parameters.Get<int>("@p_total");
            var totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);

            return new PaginatedResponse<TicketDTO>
            {
                Datos = rows.Select(MapSpRowToTicketDTO).ToList(),
                TotalRegistros = totalRecords,
                TotalPaginas = totalPages,
                PaginaActual = page,
                TamañoPagina = pageSize,
                TienePaginaAnterior = page > 1,
                TienePaginaSiguiente = page < totalPages
            };
        }

        public async Task<PaginatedResponse<TicketDTO>> GetColaTrabajoAsync(int idUsuarioActor, TicketFiltroDTO filtro)
        {
            using var conn = CreateConnection();
            var page = Math.Max(1, filtro.Pagina);
            var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);

            var parameters = new DynamicParameters();
            parameters.Add("@p_id_usuario_actor", idUsuarioActor, DbType.Int32);
            parameters.Add("@p_id_estado", filtro.Id_Estado, DbType.Int32);
            parameters.Add("@p_id_prioridad", filtro.Id_Prioridad, DbType.Int32);
            parameters.Add("@p_id_departamento", filtro.Id_Departamento, DbType.Int32);
            parameters.Add("@p_busqueda", filtro.Busqueda, DbType.String);
            parameters.Add("@p_page", page, DbType.Int32);
            parameters.Add("@p_page_size", pageSize, DbType.Int32);
            parameters.Add("@p_ordenar_por", SafeSortColumn(filtro.Ordenar_Por), DbType.String);
            parameters.Add("@p_orden_desc", (filtro.Orden_Descendente ?? true) ? 1 : 0, DbType.Int32);
            parameters.Add("@p_total", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var rows = await conn.QueryAsync<dynamic>("sp_tkt_cola_trabajo", parameters, commandType: CommandType.StoredProcedure);
            var totalRecords = parameters.Get<int>("@p_total");
            var totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);

            return new PaginatedResponse<TicketDTO>
            {
                Datos = rows.Select(MapSpRowToTicketDTO).ToList(),
                TotalRegistros = totalRecords,
                TotalPaginas = totalPages,
                PaginaActual = page,
                TamañoPagina = pageSize,
                TienePaginaAnterior = page > 1,
                TienePaginaSiguiente = page < totalPages
            };
        }

        public async Task<PaginatedResponse<TicketDTO>> GetTodosTicketsAsync(int idUsuarioActor, TicketFiltroDTO filtro)
        {
            using var conn = CreateConnection();
            var page = Math.Max(1, filtro.Pagina);
            var pageSize = Math.Clamp(filtro.TamañoPagina, 1, 100);

            var parameters = new DynamicParameters();
            parameters.Add("@p_id_usuario_actor", idUsuarioActor, DbType.Int32);
            parameters.Add("@p_id_estado", filtro.Id_Estado, DbType.Int32);
            parameters.Add("@p_id_prioridad", filtro.Id_Prioridad, DbType.Int32);
            parameters.Add("@p_id_departamento", filtro.Id_Departamento, DbType.Int32);
            parameters.Add("@p_id_usuario_asignado", filtro.Id_Usuario_Asignado, DbType.Int32);
            parameters.Add("@p_busqueda", filtro.Busqueda, DbType.String);
            parameters.Add("@p_page", page, DbType.Int32);
            parameters.Add("@p_page_size", pageSize, DbType.Int32);
            parameters.Add("@p_ordenar_por", SafeSortColumn(filtro.Ordenar_Por), DbType.String);
            parameters.Add("@p_orden_desc", (filtro.Orden_Descendente ?? true) ? 1 : 0, DbType.Int32);
            parameters.Add("@p_total", dbType: DbType.Int32, direction: ParameterDirection.Output);

            var rows = await conn.QueryAsync<dynamic>("sp_tkt_todos", parameters, commandType: CommandType.StoredProcedure);
            var totalRecords = parameters.Get<int>("@p_total");
            var totalPages = (int)Math.Ceiling(totalRecords / (double)pageSize);

            return new PaginatedResponse<TicketDTO>
            {
                Datos = rows.Select(MapSpRowToTicketDTO).ToList(),
                TotalRegistros = totalRecords,
                TotalPaginas = totalPages,
                PaginaActual = page,
                TamañoPagina = pageSize,
                TienePaginaAnterior = page > 1,
                TienePaginaSiguiente = page < totalPages
            };
        }
    }
}
