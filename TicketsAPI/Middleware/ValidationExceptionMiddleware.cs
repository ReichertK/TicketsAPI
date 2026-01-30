using FluentValidation;
using System.Text.Json;
using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Middleware
{
    /// <summary>
    /// Middleware para manejar excepciones de validación de FluentValidation
    /// Convierte ValidationExceptions en respuestas JSON consistentes
    /// </summary>
    public class ValidationExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ValidationExceptionMiddleware> _logger;

        public ValidationExceptionMiddleware(RequestDelegate next, ILogger<ValidationExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (ValidationException ex)
            {
                _logger.LogWarning("Validación fallida: {Errors}", 
                    string.Join(", ", ex.Errors.Select(e => e.ErrorMessage)));

                context.Response.StatusCode = StatusCodes.Status400BadRequest;
                context.Response.ContentType = "application/json";

                var response = new ApiResponse<object>
                {
                    Exitoso = false,
                    Mensaje = "Validación fallida",
                    Errores = ex.Errors.Select(e => e.ErrorMessage).ToList()
                };

                await context.Response.WriteAsJsonAsync(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error no manejado");
                throw;
            }
        }
    }

    /// <summary>
    /// Extensiones para registrar el middleware
    /// </summary>
    public static class ValidationExceptionMiddlewareExtensions
    {
        public static IApplicationBuilder UseValidationExceptionHandler(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<ValidationExceptionMiddleware>();
        }
    }
}
