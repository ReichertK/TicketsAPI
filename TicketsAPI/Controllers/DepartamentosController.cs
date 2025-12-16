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
    public class DepartamentosController : ControllerBase
    {
        private readonly IBaseRepository<Departamento> _departamentoRepository;
        private readonly ILogger<DepartamentosController> _logger;

        public DepartamentosController(
            IBaseRepository<Departamento> departamentoRepository,
            ILogger<DepartamentosController> logger)
        {
            _departamentoRepository = departamentoRepository;
            _logger = logger;
        }

        /// <summary>
        /// Obtener todos los departamentos
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<DepartamentoDTO>>> ObtenerDepartamentos()
        {
            try
            {
                var departamentos = await _departamentoRepository.GetAllAsync();
                var dtos = departamentos.Select(d => new DepartamentoDTO
                {
                    Id_Departamento = d.Id_Departamento,
                    Nombre = d.Nombre,
                    Descripcion = d.Descripcion
                }).ToList();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener departamentos: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener departamentos" });
            }
        }

        /// <summary>
        /// Obtener departamento por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<DepartamentoDTO>> ObtenerDepartamentoPorId(int id)
        {
            try
            {
                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return NotFound(new { message = "Departamento no encontrado" });

                var dto = new DepartamentoDTO
                {
                    Id_Departamento = departamento.Id_Departamento,
                    Nombre = departamento.Nombre,
                    Descripcion = departamento.Descripcion
                };

                return Ok(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener departamento: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener departamento" });
            }
        }

        /// <summary>
        /// Crear nuevo departamento
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> CrearDepartamento([FromBody] CreateUpdateDepartamentoDTO dto)
        {
            try
            {
                var departamento = new Departamento
                {
                    Nombre = dto.Nombre,
                    Descripcion = dto.Descripcion
                };

                var id = await _departamentoRepository.CreateAsync(departamento);
                departamento.Id_Departamento = id;

                return CreatedAtAction(nameof(ObtenerDepartamentoPorId), new { id }, departamento);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al crear departamento: {ex.Message}");
                return StatusCode(500, new { message = "Error al crear departamento" });
            }
        }

        /// <summary>
        /// Actualizar departamento
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> ActualizarDepartamento(int id, [FromBody] CreateUpdateDepartamentoDTO dto)
        {
            try
            {
                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return NotFound(new { message = "Departamento no encontrado" });

                departamento.Nombre = dto.Nombre;
                departamento.Descripcion = dto.Descripcion;

                await _departamentoRepository.UpdateAsync(departamento);
                return Ok(new { message = "Departamento actualizado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al actualizar departamento: {ex.Message}");
                return StatusCode(500, new { message = "Error al actualizar departamento" });
            }
        }

        /// <summary>
        /// Eliminar departamento
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> EliminarDepartamento(int id)
        {
            try
            {
                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return NotFound(new { message = "Departamento no encontrado" });

                await _departamentoRepository.DeleteAsync(id);
                return Ok(new { message = "Departamento eliminado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al eliminar departamento: {ex.Message}");
                return StatusCode(500, new { message = "Error al eliminar departamento" });
            }
        }
    }
}
