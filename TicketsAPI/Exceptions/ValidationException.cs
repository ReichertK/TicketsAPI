namespace TicketsAPI.Exceptions
{
    /// Excepción personalizada para errores de validación de datos.
    /// Se usa para indicar que los datos proporcionados por el cliente son inválidos.
    /// Debe resultar en HTTP 400 Bad Request.
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
