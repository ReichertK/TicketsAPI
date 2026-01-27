using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class MotivosController : BaseApiController
    {
        private readonly IBaseRepository<Motivo> _motivoRepository;

        public MotivosController(
            IBaseRepository<Motivo> motivoRepository,
            ILogger<MotivosController> logger) : base(logger)
        {
            _motivoRepository = motivoRepository;
        }

        /// <summary>
        /// Obtener todos los motivos
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ObtenerMotivos()
        {
            try
            {
                var motivos = await _motivoRepository.GetAllAsync();
                var dtos = motivos.Select(m => new MotivoDTO
                {
                    Id_Motivo = m.Id_Motivo,
                    Nombre = m.Nombre,
                    Categoria = m.Categoria
                }).ToList();

                return Success(dtos, "Motivos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener motivos");
                return Error<object>("Error al obtener motivos", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener motivo por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> ObtenerMotivoPorId(int id)
        {
            try
            {
                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return Error<object>("Motivo no encontrado", statusCode: 404);

                var dto = new MotivoDTO
                {
                    Id_Motivo = motivo.Id_Motivo,
                    Nombre = motivo.Nombre,
                    Categoria = motivo.Categoria
                };

                return Success(dto, "Motivo obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener motivo");
                return Error<object>("Error al obtener motivo", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Crear nuevo motivo
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CrearMotivo([FromBody] CreateUpdateMotivoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var motivo = new Motivo
                {
                    Nombre = dto.Nombre,
                    Categoria = dto.Categoria
                };

                var id = await _motivoRepository.CreateAsync(motivo);
                motivo.Id_Motivo = id;

                return Success(new { id }, "Motivo creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear motivo");
                return Error<object>("Error al crear motivo", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Actualizar motivo
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ActualizarMotivo(int id, [FromBody] CreateUpdateMotivoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return Error<object>("Motivo no encontrado", statusCode: 404);

                motivo.Nombre = dto.Nombre;
                motivo.Categoria = dto.Categoria;

                await _motivoRepository.UpdateAsync(motivo);
                return Success<object>(new { }, "Motivo actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar motivo");
                return Error<object>("Error al actualizar motivo", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Eliminar motivo
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> EliminarMotivo(int id)
        {
            try
            {
                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return Error<object>("Motivo no encontrado", statusCode: 404);

                await _motivoRepository.DeleteAsync(id);
                return Success<object>(new { }, "Motivo eliminado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar motivo");
                return Error<object>("Error al eliminar motivo", new List<string> { ex.Message }, 500);
            }
        }
    }
}
