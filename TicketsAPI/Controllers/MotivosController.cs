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
    public class MotivosController : ControllerBase
    {
        private readonly IBaseRepository<Motivo> _motivoRepository;
        private readonly ILogger<MotivosController> _logger;

        public MotivosController(
            IBaseRepository<Motivo> motivoRepository,
            ILogger<MotivosController> logger)
        {
            _motivoRepository = motivoRepository;
            _logger = logger;
        }

        /// <summary>
        /// Obtener todos los motivos
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<MotivoDTO>>> ObtenerMotivos()
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

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener motivos: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener motivos" });
            }
        }

        /// <summary>
        /// Obtener motivo por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<MotivoDTO>> ObtenerMotivoPorId(int id)
        {
            try
            {
                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return NotFound(new { message = "Motivo no encontrado" });

                var dto = new MotivoDTO
                {
                    Id_Motivo = motivo.Id_Motivo,
                    Nombre = motivo.Nombre,
                    Categoria = motivo.Categoria
                };

                return Ok(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener motivo: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener motivo" });
            }
        }

        /// <summary>
        /// Crear nuevo motivo
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> CrearMotivo([FromBody] CreateUpdateMotivoDTO dto)
        {
            try
            {
                var motivo = new Motivo
                {
                    Nombre = dto.Nombre,
                    Categoria = dto.Categoria
                };

                var id = await _motivoRepository.CreateAsync(motivo);
                motivo.Id_Motivo = id;

                return CreatedAtAction(nameof(ObtenerMotivoPorId), new { id }, motivo);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al crear motivo: {ex.Message}");
                return StatusCode(500, new { message = "Error al crear motivo" });
            }
        }

        /// <summary>
        /// Actualizar motivo
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> ActualizarMotivo(int id, [FromBody] CreateUpdateMotivoDTO dto)
        {
            try
            {
                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return NotFound(new { message = "Motivo no encontrado" });

                motivo.Nombre = dto.Nombre;
                motivo.Categoria = dto.Categoria;

                await _motivoRepository.UpdateAsync(motivo);
                return Ok(new { message = "Motivo actualizado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al actualizar motivo: {ex.Message}");
                return StatusCode(500, new { message = "Error al actualizar motivo" });
            }
        }

        /// <summary>
        /// Eliminar motivo
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> EliminarMotivo(int id)
        {
            try
            {
                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return NotFound(new { message = "Motivo no encontrado" });

                await _motivoRepository.DeleteAsync(id);
                return Ok(new { message = "Motivo eliminado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al eliminar motivo: {ex.Message}");
                return StatusCode(500, new { message = "Error al eliminar motivo" });
            }
        }
    }
}
