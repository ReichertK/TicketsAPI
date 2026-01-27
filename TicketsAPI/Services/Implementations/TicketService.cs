using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Exceptions;

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

        public async Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro)
        {
            return await _ticketRepository.GetFilteredAsync(filtro);
        }

        public async Task<int> CreateAsync(CreateUpdateTicketDTO dto, int idUsuarioCreador)
        {
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

            var ticket = new Models.Entities.Ticket
            {
                Contenido = dto.Contenido,
                Id_Estado = 1, // Estado inicial "Nuevo" o "Abierto"
                Id_Prioridad = dto.Id_Prioridad,
                Id_Departamento = dto.Id_Departamento,
                Id_Usuario = idUsuarioCreador,
                Id_Usuario_Asignado = dto.Id_Usuario_Asignado,
                Id_Motivo = dto.Id_Motivo,
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
            var ticket = await _ticketRepository.GetByIdAsync(id);
            if (ticket == null) return false;

            ticket.Id_Estado = dto.Id_Estado_Nuevo;

            return await _ticketRepository.UpdateAsync(ticket);
        }

        public async Task<bool> AsignarAsync(int id, int idUsuario)
        {
            var ticket = await _ticketRepository.GetByIdAsync(id);
            if (ticket == null)
                throw new NotFoundException($"El ticket con ID {id} no existe");

            ticket.Id_Usuario_Asignado = idUsuario;
            ticket.Date_Asignado = DateTime.UtcNow;

            return await _ticketRepository.UpdateAsync(ticket);
        }

        public async Task<bool> CloseAsync(int id, int idUsuario)
        {
            var ticket = await _ticketRepository.GetByIdAsync(id);
            if (ticket == null)
                throw new NotFoundException($"El ticket con ID {id} no existe");

            ticket.Id_Estado = 5; // Estado cerrado
            ticket.Date_Cierre = DateTime.UtcNow;
            ticket.Id_Usuario = idUsuario;

            return await _ticketRepository.UpdateAsync(ticket);
        }

        public async Task<DashboardDTO> GetDashboardAsync(int idUsuario)
        {
            // Implementación básica - se puede expandir con más métricas
            var tickets = await _ticketRepository.GetAllAsync();
            
            return new DashboardDTO
            {
                TicketsTotal = tickets.Count(),
                TicketsAbiertos = tickets.Count(t => t.Id_Estado != 5), // Asumiendo que 5 es "Cerrado"
                TicketsCerrados = tickets.Count(t => t.Id_Estado == 5),
                TicketsEnProceso = tickets.Count(t => t.Id_Estado == 2), // Asumiendo que 2 es "En Proceso"
                TicketsAsignadosAMi = tickets.Count(t => t.Id_Usuario_Asignado == idUsuario),
                TicketsPorEstado = new Dictionary<string, int>(),
                TicketsPorPrioridad = new Dictionary<string, int>(),
                TicketsPorDepartamento = new Dictionary<string, int>(),
                TiempoPromedioResolucion = 0,
                TasaCumplimientoSLA = 0
            };
        }
    }
}
