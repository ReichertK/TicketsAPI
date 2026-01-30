using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controlador para gestión de usuarios (CRUD)
    /// </summary>
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

        /// <summary>
        /// Listar todos los usuarios (Admin+)
        /// </summary>
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
                return Error<object>("Error al obtener usuarios", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener usuario por ID
        /// </summary>
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
                return Error<object>("Error al obtener usuario", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Crear nuevo usuario (Admin+)
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> Create([FromBody] CreateUpdateUsuarioDTO dto)
        {
            try
            {
                if (!ModelState.IsValid)
                    return Error<object>("Datos inválidos", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList(), 400);

                var idNewUser = await _usuarioService.CreateAsync(dto);
                return Success(new { idUsuario = idNewUser }, "Usuario creado exitosamente", 201);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al crear usuario");
                return Error<object>("Error al crear usuario", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Actualizar usuario (Admin o propio usuario)
        /// </summary>
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] CreateUpdateUsuarioDTO dto)
        {
            try
            {
                var currentUserId = GetCurrentUserId();
                var currentRole = GetCurrentUserRole();

                // Validar acceso: admin o usuario actualizando sus propios datos
                if (currentUserId != id && currentRole != "Administrador")
                {
                    return Error<object>("No tienes permiso para actualizar este usuario", statusCode: 403);
                }

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
                return Error<object>("Error al actualizar usuario", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Eliminar usuario (Admin+)
        /// </summary>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Administrador")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
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
                return Error<object>("Error al eliminar usuario", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Cambiar contraseña (propio usuario)
        /// </summary>
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
                return Error<object>("Error al cambiar contraseña", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener el perfil del usuario autenticado actual
        /// </summary>
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
                return Error<object>("Error al obtener perfil", new List<string> { ex.Message }, 500);
            }
        }
    }
}
