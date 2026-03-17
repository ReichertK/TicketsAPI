using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Exceptions;
using TicketsAPI.Config;

namespace TicketsAPI.Services.Implementations
{
    public class TicketService : ITicketService
    {
        private readonly ITicketRepository _ticketRepository;
        private readonly IPrioridadRepository _prioridadRepository;
        private readonly IDepartamentoRepository _departamentoRepository;
        private readonly IMotivoRepository _motivoRepository;
        private readonly IUsuarioRepository _usuarioRepository;
        private readonly IAuthService _authService;

        public TicketService(
            ITicketRepository ticketRepository,
            IPrioridadRepository prioridadRepository,
            IDepartamentoRepository departamentoRepository,
            IMotivoRepository motivoRepository,
            IUsuarioRepository usuarioRepository,
            IAuthService authService)
        {
            _ticketRepository = ticketRepository;
            _prioridadRepository = prioridadRepository;
            _departamentoRepository = departamentoRepository;
            _motivoRepository = motivoRepository;
            _usuarioRepository = usuarioRepository;
            _authService = authService;
        }

        public async Task<TicketDTO?> GetByIdAsync(int id)
        {
            // Usar el detalle enriquecido del repositorio para retornar todos los datos relacionados
            return await _ticketRepository.GetDetailAsync(id);
        }

        public async Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro, int idUsuarioActual)
        {
            // Ruteo por Vista: cada vista tiene su propio SP que aplica reglas de negocio
            switch (filtro.Vista?.ToLowerInvariant())
            {
                case "mis-tickets":
                    return await _ticketRepository.GetMisTicketsAsync(idUsuarioActual, filtro);

                case "cola":
                    return await _ticketRepository.GetColaTrabajoAsync(idUsuarioActual, filtro);

                case "todos":
                    return await _ticketRepository.GetTodosTicketsAsync(idUsuarioActual, filtro);

                default:
                    // Backward compatibility: sin Vista → lógica de permisos
                    var tieneRbacAdmin = await _authService.ValidarPermisoAsync(idUsuarioActual, "TKT_RBAC_ADMIN");

                    if (!tieneRbacAdmin)
                    {
                        filtro.VistaUsuarioId = idUsuarioActual;
                        filtro.Id_Usuario = null;

                        // Check for department-level visibility
                        var tieneListAll = await _authService.ValidarPermisoAsync(idUsuarioActual, "TKT_LIST_ALL");
                        var tieneVerDepto = await _authService.ValidarPermisoAsync(idUsuarioActual, "VER_SOLO_DEPARTAMENTO");

                        if (tieneListAll || tieneVerDepto)
                        {
                            var usuario = await _usuarioRepository.GetByIdAsync(idUsuarioActual);
                            filtro.VistaUsuarioDepartamentoId = usuario?.Id_Departamento;
                        }
                    }
                    return await _ticketRepository.GetFilteredAdvancedAsync(filtro);
            }
        }

        public async Task<int> CreateAsync(CreateUpdateTicketDTO dto, int idUsuarioCreador)
        {
            // Validar permisos: TKT_CREATE
            var tienePermisoCrear = await _authService.ValidarPermisoAsync(idUsuarioCreador, "TKT_CREATE");
            if (!tienePermisoCrear)
                throw new UnauthorizedException("No tienes permisos para crear tickets");

            // Validar FK de Prioridad
            if (!await _prioridadRepository.ExistsAsync(dto.Id_Prioridad))
                throw new ValidationException($"La prioridad con ID {dto.Id_Prioridad} no existe");

            // Validar FK de Departamento
            if (!await _departamentoRepository.ExistsAsync(dto.Id_Departamento))
                throw new ValidationException($"El departamento con ID {dto.Id_Departamento} no existe");

            // Validar FK de Motivo (opcional)
            if (dto.Id_Motivo.HasValue && !await _motivoRepository.ExistsAsync(dto.Id_Motivo.Value))
                throw new ValidationException($"El motivo con ID {dto.Id_Motivo} no existe");

            // Validar FK de Usuario Asignado (opcional)
            if (dto.Id_Usuario_Asignado.HasValue && !await _usuarioRepository.ExistsAsync(dto.Id_Usuario_Asignado.Value))
                throw new ValidationException($"El usuario asignado con ID {dto.Id_Usuario_Asignado} no existe");

            // Obtener contexto del usuario (empresa, sucursal, perfil) desde su sesión
            var contexto = await _usuarioRepository.GetUsuarioContextoAsync(idUsuarioCreador);
            if (contexto == null)
                throw new ValidationException($"No se pudo obtener el contexto (empresa/sucursal/perfil) del usuario {idUsuarioCreador}");

            var ticket = new Models.Entities.Ticket
            {
                Contenido = dto.Contenido,
                Id_Estado = TicketStates.Abierto,
                Id_Prioridad = dto.Id_Prioridad,
                Id_Departamento = dto.Id_Departamento,
                Id_Usuario = idUsuarioCreador,
                Id_Usuario_Asignado = dto.Id_Usuario_Asignado,
                Id_Motivo = dto.Id_Motivo,
                Id_Empresa = contexto.Value.idEmpresa,
                Id_Perfil = contexto.Value.idPerfil,
                Id_Sucursal = contexto.Value.idSucursal,
                Habilitado = 1
            };

            return await _ticketRepository.CreateAsync(ticket);
        }

            public async Task<bool> UpdateAsync(int id, CreateUpdateTicketDTO dto, int idUsuarioActual)
        {
                // Validar que el ticket exista
            var ticket = await _ticketRepository.GetByIdAsync(id);
                if (ticket == null) 
                    throw new NotFoundException($"El ticket con ID {id} no existe");

                // FIX: Bloquear edición de tickets cerrados (estado 3) para no-admins
                var esCerrado = ticket.Id_Estado == TicketStates.Cerrado;
                if (esCerrado)
                {
                    var esAdmin = await _authService.ValidarPermisoAsync(idUsuarioActual, "TKT_EDIT_ANY");
                    if (!esAdmin)
                        throw new ValidationException("No se puede modificar un ticket en estado Cerrado. Solo un Administrador puede editar tickets cerrados.");
                }

                // Validar permisos: TKT_EDIT_ANY (4) o TKT_EDIT_ASSIGNED (5)
                var tienePermisoEditarCualquiera = await _authService.ValidarPermisoAsync(idUsuarioActual, "TKT_EDIT_ANY");
                var tienePermisoEditarAsignados = await _authService.ValidarPermisoAsync(idUsuarioActual, "TKT_EDIT_ASSIGNED");

                if (!tienePermisoEditarCualquiera)
                {
                    // Solo puede editar si tiene permiso de editar asignados Y es creador o asignado
                    if (!tienePermisoEditarAsignados)
                        throw new UnauthorizedException("No tienes permisos para editar tickets");

                    bool esCreador = ticket.Id_Usuario == idUsuarioActual;
                    bool esAsignado = ticket.Id_Usuario_Asignado == idUsuarioActual;

                    if (!esCreador && !esAsignado)
                        throw new UnauthorizedException("Solo puedes editar tickets creados por ti o asignados a ti");
                }

            // Validar FK de Prioridad
            if (!await _prioridadRepository.ExistsAsync(dto.Id_Prioridad))
                throw new ValidationException($"La prioridad con ID {dto.Id_Prioridad} no existe");

            // Validar FK de Departamento
            if (!await _departamentoRepository.ExistsAsync(dto.Id_Departamento))
                throw new ValidationException($"El departamento con ID {dto.Id_Departamento} no existe");

            // Validar FK de Motivo (opcional)
            if (dto.Id_Motivo.HasValue && !await _motivoRepository.ExistsAsync(dto.Id_Motivo.Value))
                throw new ValidationException($"El motivo con ID {dto.Id_Motivo} no existe");

            // Validar FK de Usuario Asignado (opcional)
            if (dto.Id_Usuario_Asignado.HasValue && !await _usuarioRepository.ExistsAsync(dto.Id_Usuario_Asignado.Value))
                throw new ValidationException($"El usuario asignado con ID {dto.Id_Usuario_Asignado} no existe");

                // Usar sp_actualizar_tkt en lugar de UPDATE directo
                return await _ticketRepository.UpdateViaStoredProcedureAsync(
                    idTkt: ticket.Id_Tkt,
                    idEstado: ticket.Id_Estado ?? 1,
                    idUsuario: ticket.Id_Usuario,
                    idEmpresa: ticket.Id_Empresa,
                    idPerfil: ticket.Id_Perfil,
                    idMotivo: dto.Id_Motivo,
                    idSucursal: ticket.Id_Sucursal,
                    idPrioridad: dto.Id_Prioridad,
                    contenido: dto.Contenido,
                    idDepartamento: dto.Id_Departamento,
                    idUsuarioActor: idUsuarioActual
                );
        }

        public async Task<bool> TransicionarEstadoAsync(int id, TransicionEstadoDTO dto, int idUsuario)
        {
            // F2: Delegamos exclusivamente al SP que valida permisos, registra historial y notifica
            var result = await _ticketRepository.TransicionarEstadoViaStoredProcedureAsync(
                idTkt: id,
                estadoTo: dto.Id_Estado_Nuevo,
                idUsuarioActor: idUsuario,
                comentario: dto.Comentario,
                motivo: dto.Motivo,
                idAsignadoNuevo: dto.Id_Usuario_Asignado_Nuevo);

            return result.Success == 1;
        }

        public async Task<bool> AsignarAsync(int id, int idUsuarioAsignado, int idUsuarioActor, string? comentario)
        {
            var ticket = await _ticketRepository.GetByIdAsync(id);
            if (ticket == null)
                throw new NotFoundException($"El ticket con ID {id} no existe");

            if (!await _usuarioRepository.ExistsAsync(idUsuarioAsignado))
                throw new ValidationException($"El usuario asignado con ID {idUsuarioAsignado} no existe");

            return await _ticketRepository.AssignViaStoredProcedureAsync(id, idUsuarioAsignado, idUsuarioActor, comentario);
        }

        public async Task<bool> CloseAsync(int id, int idUsuario, string? comentario = null)
        {
            var ticket = await _ticketRepository.GetByIdAsync(id);
            if (ticket == null)
                throw new NotFoundException($"El ticket con ID {id} no existe");

            // F2+F5: Delegamos al SP que usa NOW() de MySQL para la fecha de cierre,
            // evitando discrepancias de timezone con DateTime.UtcNow de C#.
            var result = await _ticketRepository.TransicionarEstadoViaStoredProcedureAsync(
                idTkt: id,
                estadoTo: TicketStates.Cerrado,
                idUsuarioActor: idUsuario,
                comentario: string.IsNullOrWhiteSpace(comentario) ? "Ticket cerrado" : comentario);

            return result.Success == 1;
        }

    }
}
