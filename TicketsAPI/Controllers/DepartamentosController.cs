using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Implementations;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    [ApiController]
    [Route("api/v1/[controller]")]
    [Authorize]
    public class DepartamentosController : BaseApiController
    {
        private readonly IDepartamentoRepository _departamentoRepository;
        private readonly CacheService _cacheService;
        private readonly IConfigAuditService _auditService;

        public DepartamentosController(
            IDepartamentoRepository departamentoRepository,
            CacheService cacheService,
            IConfigAuditService auditService,
            ILogger<DepartamentosController> logger) : base(logger)
        {
            _departamentoRepository = departamentoRepository;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        /// Obtener todos los departamentos (activos e inactivos)
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
                    Descripcion = d.Descripcion,
                    Activo = d.Activo
                }).ToList();

                return Success(dtos, "Departamentos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener departamentos");
                return Error<object>("Error al obtener departamentos", statusCode: 500);
            }
        }

        /// Obtener departamento por ID
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
                    Descripcion = departamento.Descripcion,
                    Activo = departamento.Activo
                };

                return Success(dto, "Departamento obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener departamento");
                return Error<object>("Error al obtener departamento", statusCode: 500);
            }
        }

        /// Crear nuevo departamento
        [HttpPost]
        [Authorize(Roles = "Administrador")]
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

                _cacheService.InvalidateDepartamentosCache();

                await _auditService.RegistrarConfiguracionAsync(
                    "departamento", id, "INSERT", null, null, dto.Nombre,
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Departamento creado: {dto.Nombre}");

                return Success(new { id }, "Departamento creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear departamento");
                if (ex.Message.StartsWith("Error:", StringComparison.OrdinalIgnoreCase))
                    return Error<object>(ex.Message, statusCode: 400);
                return Error<object>("Error al crear departamento", statusCode: 500);
            }
        }

        /// Actualizar departamento
        [HttpPut("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ActualizarDepartamento(int id, [FromBody] CreateUpdateDepartamentoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return Error<object>("Departamento no encontrado", statusCode: 404);

                var nombreAnterior = departamento.Nombre;

                if (!string.IsNullOrWhiteSpace(dto.Nombre))
                {
                    var existente = await _departamentoRepository.GetByNombreAsync(dto.Nombre);
                    if (existente != null && existente.Id_Departamento != id)
                        return Error<object>("El nombre del departamento ya existe", statusCode: 400);
                }

                departamento.Nombre = dto.Nombre ?? string.Empty;
                departamento.Descripcion = dto.Descripcion ?? string.Empty;

                await _departamentoRepository.UpdateAsync(departamento);
                _cacheService.InvalidateDepartamentosCache();

                await _auditService.RegistrarConfiguracionAsync(
                    "departamento", id, "UPDATE", "nombre", nombreAnterior, dto.Nombre,
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Departamento actualizado: {dto.Nombre}");

                return Success<object>(new { }, "Departamento actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar departamento");
                if (ex.Message.StartsWith("Error:", StringComparison.OrdinalIgnoreCase))
                    return Error<object>(ex.Message, statusCode: 400);
                return Error<object>("Error al actualizar departamento", statusCode: 500);
            }
        }

        /// Toggle habilitado/deshabilitado (soft delete)
        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ToggleDepartamento(int id)
        {
            try
            {
                var departamento = await _departamentoRepository.GetByIdAsync(id);
                if (departamento == null)
                    return Error<object>("Departamento no encontrado", statusCode: 404);

                var result = await _departamentoRepository.ToggleStatusAsync(id);
                if (!result)
                    return Error<object>("Error al cambiar estado del departamento", statusCode: 500);

                _cacheService.InvalidateDepartamentosCache();

                var nuevoEstado = departamento.Activo ? "Desactivado" : "Activado";
                await _auditService.RegistrarConfiguracionAsync(
                    "departamento", id, "TOGGLE", "activo",
                    departamento.Activo ? "1" : "0", departamento.Activo ? "0" : "1",
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Departamento {nuevoEstado}: {departamento.Nombre}");

                var msg = departamento.Activo ? "Departamento desactivado exitosamente" : "Departamento reactivado exitosamente";
                return Success<object>(new { }, msg);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cambiar estado del departamento");
                return Error<object>("Error al cambiar estado del departamento", statusCode: 500);
            }
        }
    }
}
