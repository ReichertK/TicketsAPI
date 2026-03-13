using TicketsAPI.Models.DTOs;
using MySqlConnector;

namespace TicketsAPI.Middleware
{
    /// <summary>
    /// Middleware para manejo centralizado de excepciones
    /// </summary>
    public class ExceptionHandlingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<ExceptionHandlingMiddleware> _logger;
        private readonly IHostEnvironment _env;

        public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger, IHostEnvironment env)
        {
            _next = next;
            _logger = logger;
            _env = env;
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

        private Task HandleExceptionAsync(HttpContext context, Exception exception)
        {
            context.Response.ContentType = "application/json";

            // En producción nunca filtrar detalles internos al cliente
            var showDetails = _env.IsDevelopment();
            var safeErrors = showDetails
                ? new List<string> { exception.Message }
                : new List<string>();

            var response = new ApiResponse<object>
            {
                Exitoso = false,
                Mensaje = "Error interno del servidor",
                Errores = safeErrors
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

                case MySqlException mysqlEx:
                    // E1: Errores transitorios de MySQL 5.5 — Deadlock (1213) y Lock Wait Timeout (1205)
                    if (mysqlEx.Number == 1213 || mysqlEx.Number == 1205)
                    {
                        context.Response.StatusCode = StatusCodes.Status503ServiceUnavailable;
                        response.Mensaje = "Servicio temporalmente no disponible. Por favor reintente en unos segundos.";
                        _logger.LogWarning(mysqlEx,
                            "MySQL transient error (retryable) - Number: {Number}, Code: {ErrorCode}, SqlState: {SqlState}",
                            mysqlEx.Number, mysqlEx.ErrorCode, mysqlEx.SqlState);
                        response.Errores = new List<string> { "TRANSIENT_ERROR" };
                    }
                    else
                    {
                        context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                        response.Mensaje = "Error en la base de datos";
                        _logger.LogError(mysqlEx,
                            "MySqlException - Number: {Number}, Code: {ErrorCode}, SqlState: {SqlState}",
                            mysqlEx.Number, mysqlEx.ErrorCode, mysqlEx.SqlState);
                        response.Errores = showDetails
                            ? new List<string> { $"MySQL Error {mysqlEx.ErrorCode}" }
                            : new List<string>();
                    }
                    break;

                default:
                    context.Response.StatusCode = StatusCodes.Status500InternalServerError;
                    break;
            }

            return context.Response.WriteAsJsonAsync(response);
        }
    }
}
