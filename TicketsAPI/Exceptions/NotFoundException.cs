namespace TicketsAPI.Exceptions
{
    /// Excepción personalizada para recursos no encontrados.
    /// Se usa para indicar que el recurso solicitado no existe.
    /// Debe resultar en HTTP 404 Not Found.
    public class NotFoundException : Exception
    {
        public NotFoundException(string message) : base(message)
        {
        }

        public NotFoundException(string message, Exception innerException) 
            : base(message, innerException)
        {
        }
    }
}
