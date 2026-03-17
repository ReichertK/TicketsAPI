using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MySqlConnector;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    /// Controlador para gestión de roles RBAC
    [Authorize(Roles = "Administrador")]
    public class RolesController : BaseApiController
    {
        private readonly IRolRepository _rolRepo;
        private readonly IPermisoRepository _permisoRepo;
        private readonly IConfigAuditService _auditService;

        public RolesController(
            ILogger<RolesController> logger,
            IRolRepository rolRepo,
            IPermisoRepository permisoRepo,
            IConfigAuditService auditService) : base(logger)
        {
            _rolRepo = rolRepo;
            _permisoRepo = permisoRepo;
            _auditService = auditService;
        }

        /// Listar todos los roles con su cantidad de permisos
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var roles = await _rolRepo.ListarRolesAsync();
                return Success(roles, "Roles obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al listar roles");
                return Error<object>("Error interno del servidor", statusCode: 500);
            }
        }

        /// Crear un nuevo rol
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateUpdateRolDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                var id = await _rolRepo.GuardarRolAsync(null, dto.Nombre);

                await _auditService.RegistrarConfiguracionAsync(
                    "rol", id, "INSERT", null, null, dto.Nombre,
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Rol creado: {dto.Nombre}");

                return Success(new { idRol = id }, "Rol creado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear rol");
                return Error<object>("Error al guardar rol", statusCode: 500);
            }
        }

        /// Actualizar un rol existente
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CreateUpdateRolDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", statusCode: 400);

                await _rolRepo.GuardarRolAsync(id, dto.Nombre);

                await _auditService.RegistrarConfiguracionAsync(
                    "rol", id, "UPDATE", "nombre", null, dto.Nombre,
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Rol actualizado: {dto.Nombre}");

                return Success(new { idRol = id }, "Rol actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al actualizar rol {Id}", id);
                return Error<object>("Error al actualizar rol", statusCode: 500);
            }
        }

        /// Eliminar un rol (protege Administrador y roles con usuarios)
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _rolRepo.EliminarRolAsync(id);

                await _auditService.RegistrarConfiguracionAsync(
                    "rol", id, "DELETE", null, null, null,
                    GetCurrentUserId(), GetCurrentUserRole(),
                    $"Rol eliminado: id={id}");

                return Success<object>(null, "Rol eliminado exitosamente");
            }
            catch (MySqlException ex) when (ex.SqlState == "45000")
            {
                return Error<object>(ex.Message, statusCode: 400);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al eliminar rol {Id}", id);
                return Error<object>("Error al eliminar rol", statusCode: 500);
            }
        }

        /// Obtener permisos asignados a un rol
        [HttpGet("{id}/permisos")]
        public async Task<IActionResult> GetPermisos(int id)
        {
            try
            {
                var permisos = await _permisoRepo.GetByRolAsync(id);
                var result = permisos.Select(p => new PermisoListDTO
                {
                    IdPermiso = p.Id_Permiso,
                    Codigo = p.Codigo,
                    Descripcion = p.Descripcion
                }).ToList();
                return Success(result, "Permisos del rol obtenidos");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener permisos del rol {Id}", id);
                return Error<object>("Error interno", statusCode: 500);
            }
        }

        /// Asignar lista de permisos a un rol (sync completo: borra y reinserta)
        [HttpPost("{id}/permisos")]
        public async Task<IActionResult> AsignarPermisos(int id, [FromBody] AsignarPermisosRolDTO dto)
        {
            try
            {
                var csv = dto.PermisoIds.Count > 0
                    ? string.Join(",", dto.PermisoIds)
                    : "";
                var totalSolicitados = dto.PermisoIds.Count;
                var total = await _rolRepo.GestionarPermisosAsync(id, csv);

                string? advertencia = null;
                if (total < totalSolicitados)
                {
                    var ignorados = totalSolicitados - total;
                    advertencia = $"{ignorados} ID(s) de permiso fueron ignorados por no existir en la base de datos";
                    _logger.LogWarning("Asignación de permisos al rol {RolId}: {Ignorados} de {Total} IDs no existen", id, ignorados, totalSolicitados);
                }

                return Success(new { totalAsignados = total, totalSolicitados, advertencia }, $"{total} permisos asignados al rol");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al asignar permisos al rol {Id}", id);
                return Error<object>("Error al asignar permisos", statusCode: 500);
            }
        }

        /// Asignar un rol a un usuario
        [HttpPost("asignar-usuario/{idUsuario}")]
        public async Task<IActionResult> AsignarRolAUsuario(int idUsuario, [FromBody] AsignarRolUsuarioDTO dto)
        {
            try
            {
                await _rolRepo.AsignarRolAUsuarioAsync(idUsuario, dto.IdRol);
                return Success<object>(null, "Rol asignado al usuario exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al asignar rol a usuario {UserId}", idUsuario);
                return Error<object>("Error al asignar rol", statusCode: 500);
            }
        }
    }
}
