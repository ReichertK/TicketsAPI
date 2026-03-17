using System.Security.Cryptography;
using System.Text;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    /// Servicio unificado de contraseñas con soporte para legado (MD5/SHA256/Plaintext)
    /// y migración progresiva a BCrypt.
    public class PasswordService : IPasswordService
    {
        private const int BcryptWorkFactor = 11;
        private readonly ILogger<PasswordService> _logger;

        public PasswordService(ILogger<PasswordService> logger)
        {
            _logger = logger;
        }

        /// <inheritdoc />
        public string Hash(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
                throw new ArgumentException("La contraseña no puede estar vacía", nameof(password));

            return BCrypt.Net.BCrypt.HashPassword(password, BcryptWorkFactor);
        }

        /// <inheritdoc />
        public bool Verify(string storedHash, string providedPassword)
        {
            if (string.IsNullOrEmpty(storedHash) || string.IsNullOrEmpty(providedPassword))
                return false;

            // 1. Si ya es BCrypt ($2a$, $2b$, $2y$), usar verificación nativa
            if (IsBCrypt(storedHash))
            {
                try
                {
                    return BCrypt.Net.BCrypt.Verify(providedPassword, storedHash);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error verificando hash BCrypt");
                    return false;
                }
            }

            // 2. Verificar contra MD5 (32 hex chars)
            if (IsMd5Hash(storedHash))
            {
                var providedMd5 = ComputeMd5(providedPassword);
                if (string.Equals(storedHash, providedMd5, StringComparison.OrdinalIgnoreCase))
                    return true;
            }

            // 3. Verificar contra SHA256 (base64, ~44 chars)
            if (IsSha256Base64(storedHash))
            {
                var providedSha256 = ComputeSha256Base64(providedPassword);
                if (string.Equals(storedHash, providedSha256, StringComparison.Ordinal))
                    return true;
            }

            // 4. Coincidencia directa (plaintext legacy)
            if (string.Equals(storedHash, providedPassword, StringComparison.Ordinal))
                return true;

            return false;
        }

        /// <inheritdoc />
        public bool IsBCrypt(string storedHash)
        {
            if (string.IsNullOrEmpty(storedHash))
                return false;

            // BCrypt hashes empiezan con $2a$, $2b$ o $2y$ y tienen 60 caracteres
            return storedHash.Length == 60 &&
                   (storedHash.StartsWith("$2a$") ||
                    storedHash.StartsWith("$2b$") ||
                    storedHash.StartsWith("$2y$"));
        }

        #region Helpers de legado

        /// Detecta si el hash parece ser MD5 (32 caracteres hexadecimales)
        private static bool IsMd5Hash(string hash)
        {
            return hash.Length == 32 && hash.All(c => "0123456789abcdefABCDEF".Contains(c));
        }

        /// Detecta si el hash parece ser SHA256 en Base64 (~44 caracteres, termina en =)
        private static bool IsSha256Base64(string hash)
        {
            if (hash.Length < 40 || hash.Length > 48)
                return false;

            try
            {
                var bytes = Convert.FromBase64String(hash);
                return bytes.Length == 32; // SHA256 = 32 bytes
            }
            catch
            {
                return false;
            }
        }

        private static string ComputeMd5(string input)
        {
            using var md5 = MD5.Create();
            var bytes = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
            var sb = new StringBuilder(32);
            foreach (var b in bytes) sb.Append(b.ToString("x2"));
            return sb.ToString();
        }

        private static string ComputeSha256Base64(string input)
        {
            using var sha256 = SHA256.Create();
            var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
            return Convert.ToBase64String(hashedBytes);
        }

        #endregion
    }
}
