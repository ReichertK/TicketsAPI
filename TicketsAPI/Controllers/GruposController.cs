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
    public class GruposController : ControllerBase
    {
        private readonly IBaseRepository<Grupo> _grupoRepository;
        private readonly ILogger<GruposController> _logger;

        public GruposController(
            IBaseRepository<Grupo> grupoRepository,
            ILogger<GruposController> logger)
        {
            _grupoRepository = grupoRepository;
            _logger = logger;
        }

        /// <summary>
        /// Obtener todos los grupos activos
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<List<GrupoDTO>>> ObtenerGrupos()
        {
            try
            {
                var grupos = await _grupoRepository.GetAllAsync();
                var dtos = grupos.Select(g => new GrupoDTO
                {
                    Id_Grupo = g.Id_Grupo,
                    Tipo_Grupo = g.Tipo_Grupo
                }).ToList();

                return Ok(dtos);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener grupos: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener grupos" });
            }
        }

        /// <summary>
        /// Obtener grupo por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<GrupoDTO>> ObtenerGrupoPorId(int id)
        {
            try
            {
                var grupo = await _grupoRepository.GetByIdAsync(id);
                if (grupo == null)
                    return NotFound(new { message = "Grupo no encontrado" });

                var dto = new GrupoDTO
                {
                    Id_Grupo = grupo.Id_Grupo,
                    Tipo_Grupo = grupo.Tipo_Grupo
                };

                return Ok(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener grupo: {ex.Message}");
                return StatusCode(500, new { message = "Error al obtener grupo" });
            }
        }

        /// <summary>
        /// Crear nuevo grupo
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> CrearGrupo([FromBody] GrupoDTO dto)
        {
            try
            {
                var grupo = new Grupo
                {
                    Tipo_Grupo = dto.Tipo_Grupo
                };

                var id = await _grupoRepository.CreateAsync(grupo);
                grupo.Id_Grupo = id;

                return CreatedAtAction(nameof(ObtenerGrupoPorId), new { id }, grupo);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al crear grupo: {ex.Message}");
                return StatusCode(500, new { message = "Error al crear grupo" });
            }
        }

        /// <summary>
        /// Actualizar grupo
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> ActualizarGrupo(int id, [FromBody] GrupoDTO dto)
        {
            try
            {
                var grupo = await _grupoRepository.GetByIdAsync(id);
                if (grupo == null)
                    return NotFound(new { message = "Grupo no encontrado" });

                grupo.Tipo_Grupo = dto.Tipo_Grupo;

                await _grupoRepository.UpdateAsync(grupo);
                return Ok(new { message = "Grupo actualizado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al actualizar grupo: {ex.Message}");
                return StatusCode(500, new { message = "Error al actualizar grupo" });
            }
        }

        /// <summary>
        /// Eliminar grupo
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> EliminarGrupo(int id)
        {
            try
            {
                var deleted = await _grupoRepository.DeleteAsync(id);
                if (!deleted)
                    return NotFound(new { message = "Grupo no encontrado" });

                return Ok(new { message = "Grupo eliminado exitosamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al eliminar grupo: {ex.Message}");
                return StatusCode(500, new { message = "Error al eliminar grupo" });
            }
        }
    }
}
