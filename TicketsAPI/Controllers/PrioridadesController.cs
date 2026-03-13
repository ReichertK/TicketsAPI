using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Implementations;

namespace TicketsAPI.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class PrioridadesController : BaseApiController
    {
        private readonly IPrioridadRepository _prioridadRepository;
        private readonly CacheService _cacheService;

        public PrioridadesController(
            IPrioridadRepository prioridadRepository,
            CacheService cacheService,
            ILogger<PrioridadesController> logger) : base(logger)
        {
            _prioridadRepository = prioridadRepository;
            _cacheService = cacheService;
        }

        /// <summary>
        /// Obtener todas las prioridades (activas e inactivas)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ObtenerPrioridades()
        {
            try
            {
                var prioridades = await _prioridadRepository.GetAllAsync();
                var dtos = prioridades.Select(p => new PrioridadDTO
                {
                    Id_Prioridad = p.Id_Prioridad,
                    Nombre_Prioridad = p.Nombre_Prioridad,
                    Valor = p.Valor,
                    Color = p.Color,
                    Activo = p.Activo
                }).ToList();

                return Success(dtos, "Prioridades obtenidas exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener prioridades");
                return Error<object>("Error al obtener prioridades", statusCode: 500);
            }
        }

        /// <summary>
        /// Obtener prioridad por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> ObtenerPrioridadPorId(int id)
        {
            try
            {
                var prioridad = await _prioridadRepository.GetByIdAsync(id);
                if (prioridad == null)
                    return Error<object>("Prioridad no encontrada", statusCode: 404);

                var dto = new PrioridadDTO
                {
                    Id_Prioridad = prioridad.Id_Prioridad,
                    Nombre_Prioridad = prioridad.Nombre_Prioridad,
                    Valor = prioridad.Valor,
                    Color = prioridad.Color,
                    Activo = prioridad.Activo
                };

                return Success(dto, "Prioridad obtenida exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener prioridad");
                return Error<object>("Error al obtener prioridad", statusCode: 500);
            }
        }

        /// <summary>
        /// Actualizar prioridad (nombre + descripción)
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ActualizarPrioridad(int id, [FromBody] CreateUpdatePrioridadDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var prioridad = await _prioridadRepository.GetByIdAsync(id);
                if (prioridad == null)
                    return Error<object>("Prioridad no encontrada", statusCode: 404);

                prioridad.Nombre_Prioridad = dto.Nombre;
                prioridad.Descripcion = dto.Descripcion ?? string.Empty;

                await _prioridadRepository.UpdateAsync(prioridad);
                _cacheService.InvalidatePrioridadesCache();

                return Success<object>(new { }, "Prioridad actualizada exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar prioridad");
                if (ex.Message.StartsWith("Error:", StringComparison.OrdinalIgnoreCase))
                    return Error<object>(ex.Message, statusCode: 400);
                return Error<object>("Error al actualizar prioridad", statusCode: 500);
            }
        }

        /// <summary>
        /// Toggle habilitado/deshabilitado (soft delete)
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> TogglePrioridad(int id)
        {
            try
            {
                var prioridad = await _prioridadRepository.GetByIdAsync(id);
                if (prioridad == null)
                    return Error<object>("Prioridad no encontrada", statusCode: 404);

                var result = await _prioridadRepository.ToggleStatusAsync(id);
                if (!result)
                    return Error<object>("Error al cambiar estado de la prioridad", statusCode: 500);

                _cacheService.InvalidatePrioridadesCache();

                var msg = prioridad.Activo ? "Prioridad desactivada exitosamente" : "Prioridad reactivada exitosamente";
                return Success<object>(new { }, msg);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cambiar estado de la prioridad");
                return Error<object>("Error al cambiar estado de la prioridad", statusCode: 500);
            }
        }
    }
}
