using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    public class TicketService : ITicketService
    {
        private readonly ITicketRepository _ticketRepository;

        public TicketService(ITicketRepository ticketRepository)
        {
            _ticketRepository = ticketRepository;
        }

        public async Task<TicketDTO?> GetByIdAsync(int id)
        {
            // Usar el detalle enriquecido del repositorio para retornar todos los datos relacionados
            return await _ticketRepository.GetDetailAsync(id);
        }

        public async Task<PaginatedResponse<TicketDTO>> GetFilteredAsync(TicketFiltroDTO filtro)
        {
            // El repositorio ya devuelve PaginatedResponse, pero con entidades
            // Por ahora, implementación simplificada que usa GetAllAsync
            var allTickets = await _ticketRepository.GetAllAsync();
            
            // Aplicar filtros básicos
            var filtered = allTickets.AsQueryable();
            
            if (filtro.Id_Estado.HasValue)
                filtered = filtered.Where(t => t.Id_Estado == filtro.Id_Estado.Value);
            
            if (filtro.Id_Prioridad.HasValue)
                filtered = filtered.Where(t => t.Id_Prioridad == filtro.Id_Prioridad.Value);
            
            if (filtro.Id_Departamento.HasValue)
                filtered = filtered.Where(t => t.Id_Departamento == filtro.Id_Departamento.Value);

            var total = filtered.Count();
            var skip = (filtro.Pagina - 1) * filtro.TamañoPagina;
            var tickets = filtered.Skip(skip).Take(filtro.TamañoPagina).ToList();

            var ticketsDto = tickets.Select(t => new TicketDTO
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
                Date_Cambio_Estado = t.Date_Cambio_Estado
            }).ToList();

            var totalPaginas = (int)Math.Ceiling(total / (double)filtro.TamañoPagina);

            return new PaginatedResponse<TicketDTO>
            {
                Datos = ticketsDto,
                TotalRegistros = total,
                TotalPaginas = totalPaginas,
                PaginaActual = filtro.Pagina,
                TamañoPagina = filtro.TamañoPagina,
                TienePaginaAnterior = filtro.Pagina > 1,
                TienePaginaSiguiente = filtro.Pagina < totalPaginas
            };
        }

        public async Task<int> CreateAsync(CreateUpdateTicketDTO dto, int idUsuarioCreador)
        {
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

        public async Task<bool> UpdateAsync(int id, CreateUpdateTicketDTO dto)
        {
            var ticket = await _ticketRepository.GetByIdAsync(id);
            if (ticket == null) return false;

            ticket.Contenido = dto.Contenido;
            ticket.Id_Prioridad = dto.Id_Prioridad;
            ticket.Id_Departamento = dto.Id_Departamento;
            ticket.Id_Usuario_Asignado = dto.Id_Usuario_Asignado;
            ticket.Id_Motivo = dto.Id_Motivo;

            return await _ticketRepository.UpdateAsync(ticket);
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
            if (ticket == null) return false;

            ticket.Id_Usuario_Asignado = idUsuario;
            ticket.Date_Asignado = DateTime.UtcNow;

            return await _ticketRepository.UpdateAsync(ticket);
        }

        public async Task<bool> CloseAsync(int id, int idUsuario)
        {
            var ticket = await _ticketRepository.GetByIdAsync(id);
            if (ticket == null) return false;

            ticket.Date_Cierre = DateTime.UtcNow;

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
