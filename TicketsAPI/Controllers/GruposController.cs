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
    public class GruposController : BaseApiController
    {
        private readonly IBaseRepository<Grupo> _grupoRepository;

        public GruposController(
            IBaseRepository<Grupo> grupoRepository,
            ILogger<GruposController> logger) : base(logger)
        {
            _grupoRepository = grupoRepository;
        }

        /// <summary>
        /// Obtener todos los grupos activos
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ObtenerGrupos()
        {
            try
            {
                var grupos = await _grupoRepository.GetAllAsync();
                var dtos = grupos.Select(g => new GrupoDTO
                {
                    Id_Grupo = g.Id_Grupo,
                    Tipo_Grupo = g.Tipo_Grupo
                }).ToList();

                return Success(dtos, "Grupos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener grupos");
                return Error<object>("Error al obtener grupos", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener grupo por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> ObtenerGrupoPorId(int id)
        {
            try
            {
                var grupo = await _grupoRepository.GetByIdAsync(id);
                if (grupo == null)
                    return Error<object>("Grupo no encontrado", statusCode: 404);

                var dto = new GrupoDTO
                {
                    Id_Grupo = grupo.Id_Grupo,
                    Tipo_Grupo = grupo.Tipo_Grupo
                };

                return Success(dto, "Grupo obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener grupo");
                return Error<object>("Error al obtener grupo", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Crear nuevo grupo
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CrearGrupo([FromBody] GrupoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var grupo = new Grupo
                {
                    Tipo_Grupo = dto.Tipo_Grupo
                };

                var id = await _grupoRepository.CreateAsync(grupo);
                grupo.Id_Grupo = id;

                return Success(new { id }, "Grupo creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear grupo");
                return Error<object>("Error al crear grupo", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Actualizar grupo
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ActualizarGrupo(int id, [FromBody] GrupoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var grupo = await _grupoRepository.GetByIdAsync(id);
                if (grupo == null)
                    return Error<object>("Grupo no encontrado", statusCode: 404);

                grupo.Tipo_Grupo = dto.Tipo_Grupo;

                await _grupoRepository.UpdateAsync(grupo);
                return Success<object>(new { }, "Grupo actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar grupo");
                return Error<object>("Error al actualizar grupo", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Eliminar grupo
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> EliminarGrupo(int id)
        {
            try
            {
                var deleted = await _grupoRepository.DeleteAsync(id);
                if (!deleted)
                    return Error<object>("Grupo no encontrado", statusCode: 404);

                return Success<object>(new { }, "Grupo eliminado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar grupo");
                return Error<object>("Error al eliminar grupo", new List<string> { ex.Message }, 500);
            }
        }
    }
}
