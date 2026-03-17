using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    /// Controlador para gestión de usuarios (CRUD)
    [Authorize]
    public class UsuariosController : BaseApiController
    {
        private readonly IUsuarioService _usuarioService;
        private readonly IAuthService _authService;

        public UsuariosController(ILogger<UsuariosController> logger, IUsuarioService usuarioService, IAuthService authService) 
            : base(logger)
        {
            _usuarioService = usuarioService;
            _authService = authService;
        }

        /// Lista ligera de usuarios activos para el dropdown de asignación.
        /// Accesible para cualquier usuario con el permiso TKT_ASSIGN.
        [HttpGet("para-asignar")]
        public async Task<IActionResult> GetParaAsignar()
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                var tienePermiso = await _authService.ValidarPermisoAsync(currentUserId, "TKT_ASSIGN");
                if (!tienePermiso)
                    return Error<object>("No tiene permiso para asignar tickets", statusCode: 403);

                var usuarios = await _usuarioService.GetAllAsync();
                // Devolver solo usuarios activos
                var activos = usuarios.Where(u => u.Activo).ToList();
                return Success(activos, "Usuarios para asignación obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener usuarios para asignación");
                return Error<object>("Error al obtener usuarios", statusCode: 500);
            }
        }

        /// Listar todos los usuarios (Admin+)
        [HttpGet]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var usuarios = await _usuarioService.GetAllAsync();
                return Success(usuarios, "Usuarios obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener usuarios");
                return Error<object>("Error al obtener usuarios", statusCode: 500);
            }
        }

        /// Búsqueda avanzada de usuarios (Admin+)
        [HttpGet("buscar")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> Buscar([FromQuery] string? nombre, [FromQuery] string? email, [FromQuery] string? tipo, [FromQuery] int? habilitado)
        {
            try
            {
                var usuarios = await _usuarioService.GetFilteredAsync(nombre, email, tipo, habilitado);
                return Success(usuarios, "Usuarios obtenidos exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al buscar usuarios");
                return Error<object>("Error al buscar usuarios", statusCode: 500);
            }
        }

        /// Obtener usuario por ID
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                var currentRole = GetCurrentUserRole();

                // Validar acceso: admin o usuario solicitando sus propios datos
                if (currentUserId != id && currentRole != "Administrador")
                {
                    return Error<object>("No tienes permiso para ver este usuario", statusCode: 403);
                }

                var usuario = await _usuarioService.GetByIdAsync(id);
                if (usuario == null)
                    return Error<object>("Usuario no encontrado", statusCode: 404);

                return Success(usuario, "Usuario obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error al obtener usuario {id}");
                return Error<object>("Error al obtener usuario", statusCode: 500);
            }
        }

        /// Crear nuevo usuario (Admin+)
        [HttpPost]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> Create([FromBody] CreateUpdateUsuarioDTO dto)
        {
            try
            {
                if (!string.IsNullOrWhiteSpace(dto.Password) && string.IsNullOrWhiteSpace(dto.Contraseña))
                    dto.Contraseña = dto.Password;

                if (string.IsNullOrWhiteSpace(dto.Usuario_Correo))
                    dto.Usuario_Correo = dto.Email;

                if (string.IsNullOrWhiteSpace(dto.Apellido))
                    dto.Apellido = "N/A";

                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList(), 400);

                var idNewUser = await _usuarioService.CreateAsync(dto);
                return Success(new { idUsuario = idNewUser }, "Usuario creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear usuario");
                var statusCode = ex.Message.StartsWith("Error:") ? 400 : 500;
                return Error<object>("Error al crear usuario", new List<string> { ex.Message }, statusCode);
            }
        }

        /// Actualizar usuario (Admin o propio usuario)
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CreateUpdateUsuarioDTO dto)
        {
            try
            {
                // Proteger cuenta raíz (id=1): nadie puede modificarla excepto ella misma para cambios básicos
                var currentUserId = GetCurrentUserId();
                if (id == 1 && currentUserId != 1)
                {
                    return Error<object>("La cuenta de administrador raíz no puede ser modificada", statusCode: 403);
                }

                var currentRole = GetCurrentUserRole();
                var esAdmin = currentRole == "Administrador";

                // Validar acceso: admin o usuario actualizando sus propios datos
                if (currentUserId != id && !esAdmin)
                {
                    return Error<object>("No tienes permiso para actualizar este usuario", statusCode: 403);
                }

                // FIX SEGURIDAD: Solo un Admin puede cambiar el rol de cualquier usuario
                if (!esAdmin)
                {
                    // Obtener el rol actual del usuario para verificar si se intenta cambiar
                    var usuarioActual = await _usuarioService.GetByIdAsync(id);
                    if (usuarioActual != null && dto.Id_Rol != usuarioActual.Id_Rol)
                    {
                        return Error<object>("Solo un Administrador puede cambiar el rol de un usuario", statusCode: 403);
                    }
                }

                if (!string.IsNullOrWhiteSpace(dto.Password) && string.IsNullOrWhiteSpace(dto.Contraseña))
                    dto.Contraseña = dto.Password;

                if (string.IsNullOrWhiteSpace(dto.Usuario_Correo))
                    dto.Usuario_Correo = dto.Email;

                if (string.IsNullOrWhiteSpace(dto.Apellido))
                    dto.Apellido = "N/A";

                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList(), 400);

                var success = await _usuarioService.UpdateAsync(id, dto);
                if (!success)
                    return Error<object>("Usuario no encontrado", statusCode: 404);

                return Success(new { }, "Usuario actualizado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error al actualizar usuario {id}");
                var statusCode = ex.Message.StartsWith("Error:") ? 400 : 500;
                return Error<object>("Error al actualizar usuario", new List<string> { ex.Message }, statusCode);
            }
        }

        /// Eliminar usuario (Admin+)
        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                // Proteger cuenta raíz (id=1): nadie puede eliminarla
                if (id == 1)
                {
                    return Error<object>("La cuenta de administrador raíz no puede ser eliminada", statusCode: 403);
                }

                var currentUserId = GetCurrentUserId();
                
                // Prevenir auto-eliminación
                if (currentUserId == id)
                {
                    return Error<object>("No puedes eliminar tu propia cuenta", statusCode: 403);
                }

                var success = await _usuarioService.DeleteAsync(id);
                if (!success)
                    return Error<object>("Usuario no encontrado", statusCode: 404);

                return Success(new { }, "Usuario eliminado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error al eliminar usuario {id}");
                var statusCode = ex.Message.StartsWith("Error:") ? 400 : 500;
                return Error<object>("Error al eliminar usuario", new List<string> { ex.Message }, statusCode);
            }
        }

        /// Cambiar contraseña (propio usuario)
        [HttpPost("{id}/change-password")]
        public async Task<IActionResult> ChangePassword(int id, [FromBody] ChangePasswordDTO dto)
        {
            try
            {
                var currentUserId = GetCurrentUserId();

                // Validar que solo pueda cambiar su propia contraseña
                if (currentUserId != id)
                {
                    return Error<object>("No puedes cambiar la contraseña de otro usuario", statusCode: 403);
                }

                if (string.IsNullOrWhiteSpace(dto.PasswordActual) || string.IsNullOrWhiteSpace(dto.PasswordNueva))
                {
                    return Error<object>("Las contraseñas no pueden estar vacías", statusCode: 400);
                }

                if (dto.PasswordActual == dto.PasswordNueva)
                {
                    return Error<object>("La nueva contraseña debe ser diferente a la actual", statusCode: 400);
                }

                var success = await _usuarioService.ChangePasswordAsync(id, dto.PasswordActual, dto.PasswordNueva);
                if (!success)
                    return Error<object>("Contraseña actual incorrecta o usuario no encontrado", statusCode: 401);

                return Success(new { }, "Contraseña actualizada exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error al cambiar contraseña para usuario {id}");
                return Error<object>("Error al cambiar contraseña", statusCode: 500);
            }
        }

        /// Obtener el perfil del usuario autenticado actual
        [HttpGet("me/profile")]
        public async Task<IActionResult> GetCurrentUserProfile()
        {
            try
            {
                var userId = GetCurrentUserId();
                var usuario = await _usuarioService.GetByIdAsync(userId);

                if (usuario == null)
                    return Error<object>("Perfil de usuario no encontrado", statusCode: 404);

                return Success(usuario, "Perfil obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener perfil del usuario actual");
                return Error<object>("Error al obtener perfil", statusCode: 500);
            }
        }

        /// Restablecer contraseña de un usuario (solo Admin)
        [HttpPost("{id}/reset-password")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> ResetPassword(int id, [FromBody] ResetPasswordRequest request)
        {
            try
            {
                // Proteger cuenta raíz (id=1): solo ella misma puede cambiar su contraseña
                var adminId = GetCurrentUserId();
                if (id == 1 && adminId != 1)
                {
                    return Error<object>("No se puede restablecer la contraseña de la cuenta raíz", statusCode: 403);
                }

                if (string.IsNullOrWhiteSpace(request?.NuevaPassword))
                    return Error<object>("La nueva contraseña es requerida", statusCode: 400);

                if (request.NuevaPassword.Length < 6)
                    return Error<object>("La contraseña debe tener al menos 6 caracteres", statusCode: 400);

                var result = await _usuarioService.ResetPasswordAsync(id, adminId, request.NuevaPassword);

                if (!result)
                    return Error<object>("No se pudo restablecer la contraseña", statusCode: 500);

                return Success<object>(new { }, "Contraseña restablecida exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al restablecer contraseña del usuario {Id}", id);
                return Error<object>("Error al restablecer contraseña", statusCode: 500);
            }
        }
    }
}
