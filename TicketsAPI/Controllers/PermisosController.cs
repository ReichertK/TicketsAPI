using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;

namespace TicketsAPI.Controllers
{
    /// Controlador para gestión del catálogo de permisos RBAC
    [Authorize(Roles = "Administrador")]
    public class PermisosController : BaseApiController
    {
        private readonly IPermisoRepository _permisoRepo;

        public PermisosController(
            ILogger<PermisosController> logger,
            IPermisoRepository permisoRepo) : base(logger)
        {
            _permisoRepo = permisoRepo;
        }

        /// Listar todos los permisos del catálogo
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var permisos = await _permisoRepo.ListarPermisosAsync();
                return Success(permisos, "Permisos obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al listar permisos");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Crear un nuevo permiso
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateUpdatePermisoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var id = await _permisoRepo.GuardarPermisoAsync(null, dto.Codigo, dto.Descripcion ?? "");
                return Success(new { idPermiso = id }, "Permiso creado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear permiso");
                return Error<object>("Error al guardar permiso", statusCode: 500);
            }
        }

        /// Actualizar un permiso existente
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CreateUpdatePermisoDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                await _permisoRepo.GuardarPermisoAsync(id, dto.Codigo, dto.Descripcion ?? "");
                return Success(new { idPermiso = id }, "Permiso actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar permiso {Id}", id);
                return Error<object>("Error al actualizar permiso", statusCode: 500);
            }
        }
    }
}
