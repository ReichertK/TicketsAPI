using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Middleware
{
    /// <summary>
    /// Middleware para manejo centralizado de excepciones
    /// </summary>
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
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
            catch (Exception ex)
            {
                _logger.LogError(ex, "Excepción no manejada");
                await HandleExceptionAsync(context, ex);
            }
        }

        private static Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";

            var response = new ApiResponse<object>
            {
                Exitoso = false,
                Mensaje = "Error interno del servidor",
                Errores = new List<string> { exception.Message }
            };

            switch (exception)
            {
                case UnauthorizedAccessException:
                    context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                    response.Mensaje = "No autorizado";
                    break;

                case KeyNotFoundException:
                    context.Response.StatusCode = StatusCodes.Status404NotFound;
                    response.Mensaje = "Recurso no encontrado";
                    break;

                case ArgumentException:
                    context.Response.StatusCode = StatusCodes.Status400BadRequest;
                    response.Mensaje = "Argumento inválido";
                    break;

                default:
                    context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                    break;
            }

            return context.Response.WriteAsJsonAsync(response);
        }
    }
}
