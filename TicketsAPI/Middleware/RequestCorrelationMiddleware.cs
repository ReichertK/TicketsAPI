using System;
using System.Diagnostics;
using Serilog.Context;

namespace TicketsAPI.Middleware
{
    /// Middleware para registrar la correlación de requests
    /// Extrae o genera un X-Request-Id y lo propaga a través de todos los logs
    public class RequestCorrelationMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<RequestCorrelationMiddleware> _logger;
        private const string CorrelationIdHeader = "X-Request-Id";
        private const string CorrelationIdProperty = "CorrelationId";

        public RequestCorrelationMiddleware(RequestDelegate next, ILogger<RequestCorrelationMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // Extraer o generar X-Request-Id
            string correlationId = ExtractCorrelationId(context);
            
            // Agregar a contexto HTTP para uso posterior
            context.Items[CorrelationIdProperty] = correlationId;
            
            // Agregar al response header
            if (!context.Response.HasStarted)
            {
                context.Response.Headers.Add(CorrelationIdHeader, correlationId);
            }

            // Agregar a Serilog context (si está disponible)
            using (LogContext.PushProperty(CorrelationIdProperty, correlationId))
            {
                var stopwatch = Stopwatch.StartNew();

                try
                {
                    _logger.LogInformation(
                        "Iniciando request: {Method} {Path} | CorrelationId: {CorrelationId}",
                        context.Request.Method,
                        context.Request.Path,
                        correlationId);

                    await _next(context);

                    stopwatch.Stop();
                    _logger.LogInformation(
                        "Request completado: {Method} {Path} | Status: {StatusCode} | Duración: {ElapsedMilliseconds}ms | CorrelationId: {CorrelationId}",
                        context.Request.Method,
                        context.Request.Path,
                        context.Response.StatusCode,
                        stopwatch.ElapsedMilliseconds,
                        correlationId);
                }
                catch (Exception ex)
                {
                    stopwatch.Stop();
                    _logger.LogError(
                        ex,
                        "Error en request: {Method} {Path} | Duración: {ElapsedMilliseconds}ms | CorrelationId: {CorrelationId}",
                        context.Request.Method,
                        context.Request.Path,
                        stopwatch.ElapsedMilliseconds,
                        correlationId);
                    throw;
                }
            }
        }

        /// Extrae el X-Request-Id del header o genera uno nuevo
        private string ExtractCorrelationId(HttpContext context)
        {
            const string headerName = CorrelationIdHeader;

            if (context.Request.Headers.TryGetValue(headerName, out var correlationId))
            {
                return correlationId.ToString();
            }

            // Generar nuevo si no existe
            return $"{context.TraceIdentifier}-{Guid.NewGuid():N}";
        }
    }

    /// Extensiones para registrar el middleware
    public static class RequestCorrelationMiddlewareExtensions
    {
        public static IApplicationBuilder UseRequestCorrelation(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<RequestCorrelationMiddleware>();
        }
    }
}
