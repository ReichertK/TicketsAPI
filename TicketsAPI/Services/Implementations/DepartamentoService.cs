using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    public class DepartamentoService : IDepartamentoService
    {
        private readonly IDepartamentoRepository _repo;

        public DepartamentoService(IDepartamentoRepository repo)
        {
            _repo = repo;
        }

        public async Task<List<DepartamentoDTO>> GetAllAsync()
        {
            var departamentos = await _repo.GetAllActiveAsync();
            return departamentos.Select(d => new DepartamentoDTO
            {
                Id_Departamento = d.Id_Departamento,
                Nombre = d.Nombre,
                Descripcion = d.Descripcion,
                Activo = d.Activo
            }).ToList();
        }

        public async Task<DepartamentoDTO?> GetByIdAsync(int id)
        {
            var d = await _repo.GetByIdAsync(id);
            if (d == null) return null;
            return new DepartamentoDTO
            {
                Id_Departamento = d.Id_Departamento,
                Nombre = d.Nombre,
                Descripcion = d.Descripcion,
                Activo = d.Activo
            };
        }
    }
}
