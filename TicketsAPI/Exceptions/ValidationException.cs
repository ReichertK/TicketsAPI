namespace TicketsAPI.Exceptions
{
    /// <summary>
    /// Excepción personalizada para errores de validación de datos.
    /// Se usa para indicar que los datos proporcionados por el cliente son inválidos.
    /// Debe resultar en HTTP 400 Bad Request.
    /// </summary>
    public class ValidationException : Exception
    {
        public ValidationException(string message) : base(message)
        {
        }

        public ValidationException(string message, Exception innerException) 
            : base(message, innerException)
        {
        }
    }
}
