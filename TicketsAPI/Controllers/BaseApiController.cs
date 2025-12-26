using Microsoft.AspNetCore.Mvc;
using TicketsAPI.Models.DTOs;
using System.Security.Claims;

namespace TicketsAPI.Controllers
{
    /// <summary>
    /// Controlador base para todos los controladores API
    /// </summary>
    [ApiController]
    [Route("api/v1/[controller]")]
    [Produces("application/json")]
    public class BaseApiController : ControllerBase
    {
        protected readonly ILogger<BaseApiController> _logger;

        public BaseApiController(ILogger<BaseApiController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Obtiene el ID del usuario autenticado
        /// </summary>
        protected int GetCurrentUserId()
        {
            // Prefer standard NameIdentifier (mapped from 'sub' by JWT handler) and fallback to raw 'sub'
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? User.FindFirst("sub")?.Value;
            return int.TryParse(userIdClaim, out var userId) ? userId : 0;
        }

        /// <summary>
        /// Obtiene el rol del usuario autenticado
        /// </summary>
        protected string? GetCurrentUserRole()
        {
            return User.FindFirst("role")?.Value;
        }

        /// <summary>
        /// Crear respuesta exitosa
        /// </summary>
        protected IActionResult Success<T>(T data, string mensaje = "Operación exitosa", int? statusCode = null)
        {
            var response = new ApiResponse<T>
            {
                Exitoso = true,
                Mensaje = mensaje,
                Datos = data
            };

            return StatusCode(statusCode ?? 200, response);
        }

        /// <summary>
        /// Crear respuesta de error
        /// </summary>
        protected IActionResult Error<T>(string mensaje, List<string>? errores = null, int statusCode = 400)
        {
            var response = new ApiResponse<T>
            {
                Exitoso = false,
                Mensaje = mensaje,
                Errores = errores ?? new List<string>()
            };

            return StatusCode(statusCode, response);
        }
    }
}
