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
        private readonly IPasswordService _passwordService;
        private readonly BruteForceProtectionService _bruteForce;
        private readonly ILogger<AuthService> _logger;
        private readonly JwtSettings _jwtSettings;
        private const int RefreshTokenExpirationDays = 7;

        public AuthService(
            IUsuarioRepository usuarioRepository, 
            IRolRepository rolRepository,
            IPermisoRepository permisoRepository,
            IPasswordService passwordService,
            BruteForceProtectionService bruteForce,
            ILogger<AuthService> logger,
            IOptions<JwtSettings> jwtOptions)
        {
            _usuarioRepository = usuarioRepository;
            _rolRepository = rolRepository;
            _permisoRepository = permisoRepository;
            _passwordService = passwordService;
            _bruteForce = bruteForce;
            _logger = logger;
            _jwtSettings = jwtOptions.Value;
        }

        public async Task<LoginResponse?> LoginAsync(LoginRequest request)
        {
            // ── Protección contra fuerza bruta ──
            var (bloqueado, intentosRestantes, bloqueadoHasta) = await _bruteForce.VerificarBloqueoAsync(request.Usuario);
            if (bloqueado)
            {
                _logger.LogWarning("Intento de login para cuenta bloqueada: {User} (hasta {Hasta})",
                    request.Usuario, bloqueadoHasta?.ToString("HH:mm:ss"));
                return null; // Cuenta bloqueada temporalmente
            }

            var isEmail = request.Usuario.Contains('@');
            var usuario = isEmail
                ? await _usuarioRepository.GetByEmailAsync(request.Usuario)
                : await _usuarioRepository.GetByUsuarioAsync(request.Usuario);

            if (usuario is null || !usuario.Activo)
            {
                // Registrar intento fallido incluso si el usuario no existe (evitar enumeración)
                await _bruteForce.RegistrarIntentoFallidoAsync(request.Usuario, "127.0.0.1");
                return null;
            }

            // Verificar contraseña con soporte multi-formato (BCrypt, MD5, SHA256, plaintext)
            if (!_passwordService.Verify(usuario.Contraseña, request.Contraseña))
            {
                await _bruteForce.RegistrarIntentoFallidoAsync(request.Usuario, "127.0.0.1");
                return null;
            }

            // Login exitoso → limpiar contador de intentos
            await _bruteForce.LimpiarIntentosAsync(request.Usuario);

            // ── Migración progresiva: si el hash NO es BCrypt, actualizarlo silenciosamente ──
            if (!_passwordService.IsBCrypt(usuario.Contraseña))
            {
                try
                {
                    var bcryptHash = _passwordService.Hash(request.Contraseña);
                    await _usuarioRepository.UpdatePasswordHashAsync(usuario.Id_Usuario, bcryptHash);
                    _logger.LogInformation("Contraseña migrada a BCrypt para usuario {UserId}", usuario.Id_Usuario);
                }
                catch (Exception ex)
                {
                    // Si la migración falla, loguear pero dejar entrar al usuario
                    _logger.LogError(ex, "Error al migrar contraseña a BCrypt para usuario {UserId}", usuario.Id_Usuario);
                }
            }

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

            // Bypass para administrador
            if (usuario.Id_Rol > 0)
            {
                var rol = await _rolRepository.GetByIdAsync(usuario.Id_Rol);
                if (rol != null && string.Equals(rol.Nombre_Rol, "Administrador", StringComparison.OrdinalIgnoreCase))
                    return true;
            }

            // Obtener permisos del usuario (SP) con fallback al rol
            var codigos = await _permisoRepository.GetCodigosByUsuarioAsync(idUsuario);
            if (codigos == null || codigos.Count == 0)
            {
                var permisos = await _permisoRepository.GetByRolAsync(usuario.Id_Rol);
                codigos = permisos.Select(p => p.Codigo).ToList();
            }

            var tienePermiso = codigos.Any(c => string.Equals(c, codigoPermiso, StringComparison.OrdinalIgnoreCase));

            if (!tienePermiso)
            {
                _logger.LogWarning($"Usuario {idUsuario} intentó acceder a permiso no autorizado: {codigoPermiso}");
            }

            return tienePermiso;
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

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSettings.SecretKey));

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
            using var sha256 = SHA256.Create();
            var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(token));
            return Convert.ToBase64String(hashedBytes);
        }
    }
}
