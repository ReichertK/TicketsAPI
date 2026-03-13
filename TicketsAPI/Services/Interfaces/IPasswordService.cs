namespace TicketsAPI.Services.Interfaces
{
    /// <summary>
    /// Servicio unificado de hashing y verificación de contraseñas.
    /// Soporta verificación de legado (MD5, SHA256, plaintext) y migración progresiva a BCrypt.
    /// </summary>
    public interface IPasswordService
    {
        /// <summary>
        /// Genera un hash BCrypt a partir de una contraseña en texto plano.
        /// </summary>
        string Hash(string password);

        /// <summary>
        /// Verifica si una contraseña proporcionada coincide con el hash almacenado.
        /// Soporta BCrypt, MD5 (hex), SHA256 (base64) y coincidencia directa (plaintext).
        /// </summary>
        /// <returns>true si la contraseña es válida</returns>
        bool Verify(string storedHash, string providedPassword);

        /// <summary>
        /// Indica si el hash almacenado ya está en formato BCrypt.
        /// Si devuelve false, el hash debería migrarse a BCrypt.
        /// </summary>
        bool IsBCrypt(string storedHash);
    }
}
