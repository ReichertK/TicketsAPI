using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using TicketsAPI.Config;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly IUsuarioRepository _usuarioRepository;
        private readonly IRolRepository _rolRepository;
        private readonly IPermisoRepository _permisoRepository;
        private readonly ILogger<AuthService> _logger;
        private readonly JwtSettings _jwtSettings;
        private const int RefreshTokenExpirationDays = 7;

        public AuthService(
            IUsuarioRepository usuarioRepository, 
            IRolRepository rolRepository,
            IPermisoRepository permisoRepository,
            ILogger<AuthService> logger,
            IOptions<JwtSettings> jwtOptions)
        {
            _usuarioRepository = usuarioRepository;
            _rolRepository = rolRepository;
            _permisoRepository = permisoRepository;
            _logger = logger;
            _jwtSettings = jwtOptions.Value;
        }

        public async Task<LoginResponse?> LoginAsync(LoginRequest request)
        {
            var isEmail = request.Usuario.Contains('@');
            var usuario = isEmail
                ? await _usuarioRepository.GetByEmailAsync(request.Usuario)
                : await _usuarioRepository.GetByUsuarioAsync(request.Usuario);

            if (usuario is null || !usuario.Activo)
                return null;

            if (!PasswordMatches(usuario.Contraseña, request.Contraseña))
                return null;

            // Cargar rol desde BD usando el Id_Rol del usuario
            var rol = usuario.Id_Rol > 0 
                ? await _rolRepository.GetByIdAsync(usuario.Id_Rol) 
                : null;

            // Cargar permisos del rol
            var permisos = usuario.Id_Rol > 0 
                ? await _permisoRepository.GetByRolAsync(usuario.Id_Rol) 
                : new List<Models.Entities.Permiso>();

            var roleValue = rol?.Nombre_Rol ?? usuario.Id_Rol.ToString();
            var token = GenerateJwtToken(usuario.Id_Usuario, usuario.Nombre, usuario.Email, roleValue);
            
            // Generar refresh token
            var refreshToken = GenerateRefreshToken();
            var refreshTokenHash = HashToken(refreshToken);
            var refreshTokenExpires = DateTime.UtcNow.AddDays(RefreshTokenExpirationDays);
            
            // Guardar refresh token hash en BD
            await _usuarioRepository.SaveRefreshTokenAsync(usuario.Id_Usuario, refreshTokenHash, refreshTokenExpires);
            
            var response = new LoginResponse
            {
                Id_Usuario = usuario.Id_Usuario,
                Nombre = usuario.Nombre,
                Email = usuario.Email,
                Token = token,
                RefreshToken = refreshToken,
                Rol = rol != null ? new RolDTO 
                { 
                    Id_Rol = rol.Id_Rol,
                    Nombre_Rol = rol.Nombre_Rol,
                    Descripcion = rol.Descripcion,
                    Activo = rol.Activo
                } : new RolDTO { Id_Rol = usuario.Id_Rol },
                Permisos = permisos.Select(p => p.Codigo).ToList()
            };

            await _usuarioRepository.UpdateLastSessionAsync(usuario.Id_Usuario);
            return response;
        }

        public async Task<LoginResponse?> RefreshTokenAsync(string refreshToken)
        {
            // Validar que el token no esté vacío
            if (string.IsNullOrWhiteSpace(refreshToken))
            {
                _logger.LogWarning("Intento de refresh con token vacío");
                return null;
            }

            var refreshTokenHash = HashToken(refreshToken);
            var usuario = await _usuarioRepository.GetByRefreshTokenAsync(refreshTokenHash);

            if (usuario is null || !usuario.Activo)
            {
                _logger.LogWarning($"Refresh token inválido o usuario inactivo");
                return null;
            }

            // Validar que el token no haya expirado
            if (usuario.RefreshTokenExpires < DateTime.UtcNow)
            {
                _logger.LogWarning($"Refresh token expirado para usuario {usuario.Id_Usuario}");
                // Limpiar token expirado
                await _usuarioRepository.ClearRefreshTokenAsync(usuario.Id_Usuario);
                return null;
            }

            // Cargar rol y permisos
            var rol = usuario.Id_Rol > 0 
                ? await _rolRepository.GetByIdAsync(usuario.Id_Rol) 
                : null;

            var permisos = usuario.Id_Rol > 0 
                ? await _permisoRepository.GetByRolAsync(usuario.Id_Rol) 
                : new List<Models.Entities.Permiso>();

            // Generar nuevo JWT
            var roleValue = rol?.Nombre_Rol ?? usuario.Id_Rol.ToString();
            var newToken = GenerateJwtToken(usuario.Id_Usuario, usuario.Nombre, usuario.Email, roleValue);
            
            // Rotar refresh token (generar uno nuevo)
            var newRefreshToken = GenerateRefreshToken();
            var newRefreshTokenHash = HashToken(newRefreshToken);
            var newRefreshTokenExpires = DateTime.UtcNow.AddDays(RefreshTokenExpirationDays);
            
            await _usuarioRepository.SaveRefreshTokenAsync(usuario.Id_Usuario, newRefreshTokenHash, newRefreshTokenExpires);

            _logger.LogInformation($"Refresh token rotado exitosamente para usuario {usuario.Id_Usuario}");

            return new LoginResponse
            {
                Id_Usuario = usuario.Id_Usuario,
                Nombre = usuario.Nombre,
                Email = usuario.Email,
                Token = newToken,
                RefreshToken = newRefreshToken,
                Rol = rol != null ? new RolDTO 
                { 
                    Id_Rol = rol.Id_Rol,
                    Nombre_Rol = rol.Nombre_Rol,
                    Descripcion = rol.Descripcion,
                    Activo = rol.Activo
                } : new RolDTO { Id_Rol = usuario.Id_Rol },
                Permisos = permisos.Select(p => p.Codigo).ToList()
            };
        }

        public async Task LogoutAsync(int idUsuario)
        {
            // Invalidar refresh token
            await _usuarioRepository.ClearRefreshTokenAsync(idUsuario);
            _logger.LogInformation($"Logout realizado para usuario {idUsuario}");
        }

        public async Task<bool> ValidarPermisoAsync(int idUsuario, string codigoPermiso)
        {
            if (string.IsNullOrWhiteSpace(codigoPermiso))
                return false;

            var usuario = await _usuarioRepository.GetByIdAsync(idUsuario);
            if (usuario is null || !usuario.Activo)
                return false;

            // Obtener permisos del rol del usuario
            var permisos = await _permisoRepository.GetByRolAsync(usuario.Id_Rol);
            var tienePermiso = permisos.Any(p => p.Codigo == codigoPermiso);

            if (!tienePermiso)
            {
                _logger.LogWarning($"Usuario {idUsuario} intentó acceder a permiso no autorizado: {codigoPermiso}");
            }

            return tienePermiso;
        }

        private bool PasswordMatches(string stored, string provided)
        {
            // Acepta coincidencia directa o coincidencia con MD5
            if (string.Equals(stored, provided)) return true;
            var providedMd5 = ComputeMd5(provided);
            return string.Equals(stored, providedMd5, StringComparison.OrdinalIgnoreCase);
        }

        private static string ComputeMd5(string input)
        {
            using var md5 = MD5.Create();
            var bytes = md5.ComputeHash(Encoding.UTF8.GetBytes(input));
            var sb = new StringBuilder();
            foreach (var b in bytes) sb.Append(b.ToString("x2"));
            return sb.ToString();
        }

        /// <summary>
        /// Genera un refresh token criptográficamente seguro
        /// </summary>
        private static string GenerateRefreshToken()
        {
            var randomNumber = new byte[64];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber);
            return Convert.ToBase64String(randomNumber);
        }

        /// <summary>
        /// Hashea un token para almacenamiento seguro (nunca guardar tokens en plano)
        /// </summary>
        private static string HashToken(string token)
        {
            using var sha256 = System.Security.Cryptography.SHA256.Create();
            var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(token));
            return Convert.ToBase64String(hashedBytes);
        }

        private string GenerateJwtToken(int userId, string name, string email, string role)
        {
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
                new Claim(JwtRegisteredClaimNames.UniqueName, name),
                new Claim(JwtRegisteredClaimNames.Email, email),
                new Claim(ClaimTypes.Role, role)
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
                string.IsNullOrWhiteSpace(_jwtSettings.SecretKey)
                    ? "your-super-secret-key-min-32-chars-required-for-production"
                    : _jwtSettings.SecretKey));

            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
            var expires = DateTime.UtcNow.AddMinutes(_jwtSettings.ExpirationMinutes > 0 ? _jwtSettings.ExpirationMinutes : 60);

            var token = new JwtSecurityToken(
                issuer: _jwtSettings.Issuer,
                audience: _jwtSettings.Audience,
                claims: claims,
                expires: expires,
                signingCredentials: creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
