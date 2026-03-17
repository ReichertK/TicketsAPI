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
    public class EstadosController : BaseApiController
    {
        private readonly IEstadoRepository _estadoRepository;
        private readonly CacheService _cacheService;

        public EstadosController(
            IEstadoRepository estadoRepository,
            CacheService cacheService,
            ILogger<EstadosController> logger) : base(logger)
        {
            _estadoRepository = estadoRepository;
            _cacheService = cacheService;
        }

        /// Obtener todos los estados (activos e inactivos)
        [HttpGet]
        public async Task<IActionResult> ObtenerEstados()
        {
            try
            {
                var estados = await _estadoRepository.GetAllAsync();
                var dtos = estados.Select(e => new EstadoDTO
                {
                    Id_Estado = e.Id_Estado,
                    Nombre_Estado = e.Nombre_Estado,
                    Color = e.Color,
                    Orden = e.Orden,
                    Activo = e.Activo
                }).ToList();

                return Success(dtos, "Estados obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener estados");
                return Error<object>("Error al obtener estados", statusCode: 500);
            }
        }

        /// Obtener estado por ID
        [HttpGet("{id}")]
        public async Task<IActionResult> ObtenerEstadoPorId(int id)
        {
            try
            {
                var estado = await _estadoRepository.GetByIdAsync(id);
                if (estado == null)
                    return Error<object>("Estado no encontrado", statusCode: 404);

                var dto = new EstadoDTO
                {
                    Id_Estado = estado.Id_Estado,
                    Nombre_Estado = estado.Nombre_Estado,
                    Color = estado.Color,
                    Orden = estado.Orden,
                    Activo = estado.Activo
                };

                return Success(dto, "Estado obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener estado");
                return Error<object>("Error al obtener estado", statusCode: 500);
            }
        }

        /// Actualizar estado (nombre + descripción)
        [HttpPut("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ActualizarEstado(int id, [FromBody] CreateUpdateEstadoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var estado = await _estadoRepository.GetByIdAsync(id);
                if (estado == null)
                    return Error<object>("Estado no encontrado", statusCode: 404);

                estado.Nombre_Estado = dto.Nombre;
                estado.Descripcion = dto.Descripcion ?? string.Empty;

                await _estadoRepository.UpdateAsync(estado);
                _cacheService.InvalidateEstadosCache();

                return Success<object>(new { }, "Estado actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar estado");
                if (ex.Message.StartsWith("Error:", StringComparison.OrdinalIgnoreCase))
                    return Error<object>(ex.Message, statusCode: 400);
                return Error<object>("Error al actualizar estado", statusCode: 500);
            }
        }

        /// Toggle habilitado/deshabilitado (soft delete)
        /// Protege estados críticos (Abierto, Cerrado)
        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ToggleEstado(int id)
        {
            try
            {
                var estado = await _estadoRepository.GetByIdAsync(id);
                if (estado == null)
                    return Error<object>("Estado no encontrado", statusCode: 404);

                var result = await _estadoRepository.ToggleStatusAsync(id);
                if (!result)
                    return Error<object>("Error al cambiar estado", statusCode: 500);

                _cacheService.InvalidateEstadosCache();

                var msg = estado.Activo ? "Estado desactivado exitosamente" : "Estado reactivado exitosamente";
                return Success<object>(new { }, msg);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cambiar estado");
                if (ex.Message.StartsWith("Error:", StringComparison.OrdinalIgnoreCase))
                    return Error<object>(ex.Message, statusCode: 400);
                return Error<object>("Error al cambiar estado", statusCode: 500);
            }
        }
    }
}
