using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controlador para autenticación y autorización
    /// </summary>
    public class AuthController : BaseApiController
    {
        private readonly IAuthService _authService;

        public AuthController(ILogger<AuthController> logger, IAuthService authService) : base(logger)
        {
            _authService = authService;
        }

        /// <summary>
        /// Login de usuario
        /// </summary>
        /// <param name="request">Credenciales del usuario</param>
        /// <returns>Token JWT y datos del usuario</returns>
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                var result = await _authService.LoginAsync(request);
                
                if (result == null)
                    return Error<object>("Credenciales inválidas", statusCode: 401);

                return Success(result, "Login exitoso", 200);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en login");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Renovar token JWT
        /// </summary>
        /// <param name="request">Token de renovación</param>
        /// <returns>Nuevo token JWT</returns>
        [HttpPost("refresh-token")]
        [AllowAnonymous]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            try
            {
                var result = await _authService.RefreshTokenAsync(request.RefreshToken);
                
                if (result == null)
                    return Error<object>("Token inválido", statusCode: 401);

                return Success(result, "Token renovado exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al renovar token");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Logout del usuario
        /// </summary>
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            try
            {
                var userId = GetCurrentUserId();
                await _authService.LogoutAsync(userId);
                return Success<object>(new { }, "Logout exitoso");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en logout");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }

        /// <summary>
        /// Obtener el usuario autenticado actual
        /// </summary>
        [HttpGet("me")]
        [Authorize]
        public IActionResult GetCurrentUser()
        {
            try
            {
                var userId = GetCurrentUserId();
                var role = GetCurrentUserRole();

                return Success(new { userId, role }, "Usuario obtenido exitosamente");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al obtener usuario actual");
                return Error<object>("Error interno del servidor", new List<string> { ex.Message }, 500);
            }
        }
    }
}

// NOTA: Agregar using para IAuthService cuando esté implementado
