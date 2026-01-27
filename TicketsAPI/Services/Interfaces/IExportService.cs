using TicketsAPI.Models.DTOs;

namespace TicketsAPI.Services.Interfaces
{
    /// <summary>
    /// Interfaz para servicio de exportación de datos
    /// </summary>
    public interface IExportService
    {
        /// <summary>
        /// Exportar tickets a formato CSV
        /// </summary>
        /// <param name="tickets">Lista de tickets a exportar</param>
        /// <returns>Contenido del archivo CSV como string</returns>
        Task<string> ExportTicketsToCsvAsync(List<TicketDTO> tickets);

        /// <summary>
        /// Exportar reportes a formato CSV
        /// </summary>
        /// <typeparam name="T">Tipo de DTO del reporte</typeparam>
        /// <param name="datos">Datos a exportar</param>
        /// <param name="nombreArchivo">Nombre del archivo sin extensión</param>
        /// <returns>Contenido del archivo CSV como string</returns>
        Task<string> ExportToCsvAsync<T>(List<T> datos, string nombreArchivo) where T : class;
    }
}
