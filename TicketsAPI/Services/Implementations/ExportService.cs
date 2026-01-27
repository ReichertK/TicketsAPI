using System.Globalization;
using System.Text;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    /// <summary>
    /// Servicio para exportación de datos a diferentes formatos
    /// </summary>
    public class ExportService : IExportService
    {
        private readonly ILogger<ExportService> _logger;

        public ExportService(ILogger<ExportService> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Exportar tickets a CSV
        /// </summary>
        public async Task<string> ExportTicketsToCsvAsync(List<TicketDTO> tickets)
        {
            await Task.CompletedTask; // Método sincrónico, pero mantenemos firma async

            var csv = new StringBuilder();

            // Headers
            csv.AppendLine("Id,Estado,Prioridad,Departamento,Contenido,Usuario Creador,Usuario Asignado,Fecha Creacion,Fecha Actualizacion");

            // Rows
            foreach (var ticket in tickets)
            {
                csv.AppendLine(string.Join(",",
                    EscapeCsvValue(ticket.Id_Tkt.ToString()),
                    EscapeCsvValue(ticket.Estado?.Nombre_Estado ?? "N/A"),
                    EscapeCsvValue(ticket.Prioridad?.Nombre_Prioridad ?? "N/A"),
                    EscapeCsvValue(ticket.Departamento?.Nombre ?? "N/A"),
                    EscapeCsvValue(ticket.Contenido ?? ""),
                    EscapeCsvValue(ticket.UsuarioCreador != null ? $"{ticket.UsuarioCreador.Nombre} {ticket.UsuarioCreador.Apellido}" : "N/A"),
                    EscapeCsvValue(ticket.UsuarioAsignado != null ? $"{ticket.UsuarioAsignado.Nombre} {ticket.UsuarioAsignado.Apellido}" : "No asignado"),
                    EscapeCsvValue(ticket.Date_Creado?.ToString("yyyy-MM-dd HH:mm:ss") ?? ""),
                    EscapeCsvValue(ticket.Date_Cambio_Estado?.ToString("yyyy-MM-dd HH:mm:ss") ?? "")
                ));
            }

            return csv.ToString();
        }

        /// <summary>
        /// Exportar cualquier tipo de datos a CSV (genérico)
        /// </summary>
        public async Task<string> ExportToCsvAsync<T>(List<T> datos, string nombreArchivo) where T : class
        {
            await Task.CompletedTask;

            var csv = new StringBuilder();
            var properties = typeof(T).GetProperties();

            // Headers
            csv.AppendLine(string.Join(",", properties.Select(p => EscapeCsvValue(p.Name))));

            // Rows
            foreach (var item in datos)
            {
                var values = properties.Select(p =>
                {
                    var value = p.GetValue(item);
                    return EscapeCsvValue(value?.ToString() ?? "");
                });

                csv.AppendLine(string.Join(",", values));
            }

            return csv.ToString();
        }

        /// <summary>
        /// Escapar valores CSV (manejo de comas, comillas, saltos de línea)
        /// </summary>
        private static string EscapeCsvValue(string value)
        {
            if (string.IsNullOrEmpty(value))
                return "";

            // Si contiene coma, comillas o salto de línea, envolver en comillas y duplicar comillas internas
            if (value.Contains(',') || value.Contains('"') || value.Contains('\n') || value.Contains('\r'))
            {
                return "\"" + value.Replace("\"", "\"\"") + "\"";
            }

            return value;
        }
    }
}
