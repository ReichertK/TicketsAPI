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
    public class DepartamentosController : BaseApiController
    {
        private readonly IBaseRepository<Departamento> _departamentoRepository;

        public DepartamentosController(
            IBaseRepository<Departamento> departamentoRepository,
            ILogger<DepartamentosController> logger) : base(logger)
        {
            _departamentoRepository = departamentoRepository;
        }

        /// <summary>
        /// Obtener todos los departamentos
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ObtenerDepartamentos()
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

                return Success(dtos, "Departamentos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener departamentos");
                return Error<object>("Error al obtener departamentos", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener departamento por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> ObtenerDepartamentoPorId(int id)
        {
            try
            {
                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return Error<object>("Departamento no encontrado", statusCode: 404);

                var dto = new DepartamentoDTO
                {
                    Id_Departamento = departamento.Id_Departamento,
                    Nombre = departamento.Nombre,
                    Descripcion = departamento.Descripcion
                };

                return Success(dto, "Departamento obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener departamento");
                return Error<object>("Error al obtener departamento", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Crear nuevo departamento
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CrearDepartamento([FromBody] CreateUpdateDepartamentoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var departamento = new Departamento
                {
                    Nombre = dto.Nombre ?? string.Empty,
                    Descripcion = dto.Descripcion ?? string.Empty
                };

                var id = await _departamentoRepository.CreateAsync(departamento);
                departamento.Id_Departamento = id;

                return Success(new { id }, "Departamento creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear departamento");
                return Error<object>("Error al crear departamento", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Actualizar departamento
        /// </summary>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ActualizarDepartamento(int id, [FromBody] CreateUpdateDepartamentoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return Error<object>("Departamento no encontrado", statusCode: 404);

                departamento.Nombre = dto.Nombre ?? string.Empty;
                departamento.Descripcion = dto.Descripcion ?? string.Empty;

                await _departamentoRepository.UpdateAsync(departamento);
                return Success<object>(new { }, "Departamento actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar departamento");
                return Error<object>("Error al actualizar departamento", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Eliminar departamento
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> EliminarDepartamento(int id)
        {
            try
            {
                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return Error<object>("Departamento no encontrado", statusCode: 404);

                await _departamentoRepository.DeleteAsync(id);
                return Success<object>(new { }, "Departamento eliminado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar departamento");
                return Error<object>("Error al eliminar departamento", new List<string> { ex.Message }, 500);
            }
        }
    }
}
