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
    public class MotivosController : BaseApiController
    {
        private readonly IMotivoRepository _motivoRepository;
        private readonly CacheService _cacheService;
        private readonly IConfigAuditService _auditService;

        public MotivosController(
            IMotivoRepository motivoRepository,
            CacheService cacheService,
            IConfigAuditService auditService,
            ILogger<MotivosController> logger) : base(logger)
        {
            _motivoRepository = motivoRepository;
            _cacheService = cacheService;
            _auditService = auditService;
        }

        /// Obtener todos los motivos (activos e inactivos)
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
                    Descripcion = m.Descripcion,
                    Categoria = m.Categoria,
                    Activo = m.Activo
                }).ToList();

                return Success(dtos, "Motivos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener motivos");
                return Error<object>("Error al obtener motivos", statusCode: 500);
            }
        }

        /// Obtener motivo por ID
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
                    Descripcion = motivo.Descripcion,
                    Categoria = motivo.Categoria,
                    Activo = motivo.Activo
                };

                return Success(dto, "Motivo obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener motivo");
                return Error<object>("Error al obtener motivo", statusCode: 500);
            }
        }

        /// Crear nuevo motivo
        [HttpPost]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> CrearMotivo([FromBody] CreateUpdateMotivoDTO dto)
        {
            try
            {
                var nombre = !string.IsNullOrWhiteSpace(dto.Nombre) ? dto.Nombre : dto.Descripcion ?? string.Empty;
                if (string.IsNullOrWhiteSpace(nombre))
                    return Error<object>("Datos inválidos", statusCode: 400);

                var motivo = new Motivo
                {
                    Nombre = nombre,
                    Descripcion = dto.Descripcion ?? string.Empty,
                    Categoria = dto.Categoria
                };

                var id = await _motivoRepository.CreateAsync(motivo);
                motivo.Id_Motivo = id;

                await _auditService.RegistrarConfiguracionAsync(
                    "motivo", id, "INSERT", null, null, nombre,
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Motivo creado: {nombre}");

                return Success(new { id }, "Motivo creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear motivo");
                if (ex.Message.StartsWith("Error:", StringComparison.OrdinalIgnoreCase))
                    return Error<object>(ex.Message, statusCode: 400);
                return Error<object>("Error al crear motivo", statusCode: 500);
            }
        }

        /// Actualizar motivo
        [HttpPut("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ActualizarMotivo(int id, [FromBody] CreateUpdateMotivoDTO dto)
        {
            try
            {
                var nombre = !string.IsNullOrWhiteSpace(dto.Nombre) ? dto.Nombre : dto.Descripcion ?? string.Empty;
                if (string.IsNullOrWhiteSpace(nombre))
                    return Error<object>("Datos inválidos", statusCode: 400);

                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return Error<object>("Motivo no encontrado", statusCode: 404);

                var nombreAnterior = motivo.Nombre;
                motivo.Nombre = nombre;
                motivo.Descripcion = dto.Descripcion ?? string.Empty;
                motivo.Categoria = dto.Categoria;

                await _motivoRepository.UpdateAsync(motivo);

                await _auditService.RegistrarConfiguracionAsync(
                    "motivo", id, "UPDATE", "nombre", nombreAnterior, nombre,
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Motivo actualizado: {nombre}");

                return Success<object>(new { }, "Motivo actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar motivo");
                if (ex.Message.StartsWith("Error:", StringComparison.OrdinalIgnoreCase))
                    return Error<object>(ex.Message, statusCode: 400);
                return Error<object>("Error al actualizar motivo", statusCode: 500);
            }
        }

        /// Toggle habilitado/deshabilitado (soft delete)
        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ToggleMotivo(int id)
        {
            try
            {
                var motivo = await _motivoRepository.GetByIdAsync(id);
                if (motivo == null)
                    return Error<object>("Motivo no encontrado", statusCode: 404);

                var result = await _motivoRepository.ToggleStatusAsync(id);
                if (!result)
                    return Error<object>("Error al cambiar estado del motivo", statusCode: 500);

                var nuevoEstado = motivo.Activo ? "Desactivado" : "Activado";
                await _auditService.RegistrarConfiguracionAsync(
                    "motivo", id, "TOGGLE", "activo",
                    motivo.Activo ? "1" : "0", motivo.Activo ? "0" : "1",
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Motivo {nuevoEstado}: {motivo.Nombre}");

                var msg = motivo.Activo ? "Motivo desactivado exitosamente" : "Motivo reactivado exitosamente";
                return Success<object>(new { }, msg);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al cambiar estado del motivo");
                return Error<object>("Error al cambiar estado del motivo", statusCode: 500);
            }
        }

        /// Obtener motivos activos filtrados por departamento
        [HttpGet("por-departamento/{idDepartamento}")]
        public async Task<IActionResult> ObtenerMotivosPorDepartamento(int idDepartamento)
        {
            try
            {
                var motivos = await _motivoRepository.GetByDepartamentoAsync(idDepartamento);
                var dtos = motivos.Select(m => new MotivoDTO
                {
                    Id_Motivo = m.Id_Motivo,
                    Nombre = m.Nombre,
                    Descripcion = m.Descripcion,
                    Categoria = m.Categoria,
                    Activo = m.Activo
                }).ToList();

                return Success(dtos, "Motivos por departamento obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener motivos por departamento {Id}", idDepartamento);
                return Error<object>("Error al obtener motivos por departamento", statusCode: 500);
            }
        }
    }
}
