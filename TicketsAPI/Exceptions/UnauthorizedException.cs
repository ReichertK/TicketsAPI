namespace TicketsAPI.Exceptions
{
    /// Excepción personalizada para errores de autorización (permisos insuficientes).
    /// Se usa para indicar que el usuario autenticado no tiene permisos para realizar la acción.
    /// Debe resultar en HTTP 403 Forbidden.
    public class UnauthorizedException : Exception
    {
        public UnauthorizedException(string message) : base(message)
        {
        }

        public UnauthorizedException(string message, Exception innerException) 
            : base(message, innerException)
        {
        }
    }
}
