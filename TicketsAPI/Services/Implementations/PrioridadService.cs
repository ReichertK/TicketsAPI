using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    public class PrioridadService : IPrioridadService
    {
        private readonly IPrioridadRepository _repo;

        public PrioridadService(IPrioridadRepository repo)
        {
            _repo = repo;
        }

        public async Task<List<PrioridadDTO>> GetAllAsync()
        {
            var prioridades = await _repo.GetAllActiveAsync();
            return prioridades.Select(p => new PrioridadDTO
            {
                Id_Prioridad = p.Id_Prioridad,
                Nombre_Prioridad = p.Nombre_Prioridad,
                Valor = p.Valor,
                Color = p.Color,
                Activo = p.Activo
            }).ToList();
        }

        public async Task<PrioridadDTO?> GetByIdAsync(int id)
        {
            var p = await _repo.GetByIdAsync(id);
            if (p == null) return null;
            return new PrioridadDTO
            {
                Id_Prioridad = p.Id_Prioridad,
                Nombre_Prioridad = p.Nombre_Prioridad,
                Valor = p.Valor,
                Color = p.Color,
                Activo = p.Activo
            };
        }
    }
}
