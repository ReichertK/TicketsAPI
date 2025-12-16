using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    public class EstadoService : IEstadoService
    {
        private readonly IEstadoRepository _repo;
        private readonly IPoliticaTransicionRepository _politicas;

        public EstadoService(IEstadoRepository repo, IPoliticaTransicionRepository politicas)
        {
            _repo = repo;
            _politicas = politicas;
        }

        public async Task<List<EstadoDTO>> GetAllAsync()
        {
            var estados = await _repo.GetAllActiveAsync();
            return estados.Select(e => new EstadoDTO
            {
                Id_Estado = e.Id_Estado,
                Nombre_Estado = e.Nombre_Estado,
                Color = e.Color,
                Orden = e.Orden,
                Activo = e.Activo
            }).ToList();
        }

        public async Task<EstadoDTO?> GetByIdAsync(int id)
        {
            var e = await _repo.GetByIdAsync(id);
            if (e == null) return null;
            return new EstadoDTO
            {
                Id_Estado = e.Id_Estado,
                Nombre_Estado = e.Nombre_Estado,
                Color = e.Color,
                Orden = e.Orden,
                Activo = e.Activo
            };
        }

        public async Task<List<TransicionPermitidaDTO>> GetTransicionesPermitidas(int idEstadoActual, int idRol)
        {
            var transiciones = await _politicas.GetPosiblesTransicionesAsync(idEstadoActual, idRol);
            return transiciones.Select(t => new TransicionPermitidaDTO
            {
                Id_Estado_Destino = t.Id_Estado_Destino,
                Nombre_Estado = t.EstadoDestino?.Nombre_Estado ?? string.Empty,
                Color = t.EstadoDestino?.Color ?? string.Empty
            }).ToList();
        }

        public async Task<bool> ValidarTransicionAsync(int idEstadoOrigen, int idEstadoDestino, int idRol)
        {
            var politica = await _politicas.GetTransicionAsync(idEstadoOrigen, idEstadoDestino, idRol);
            return politica?.Permitida ?? false;
        }
    }
}
