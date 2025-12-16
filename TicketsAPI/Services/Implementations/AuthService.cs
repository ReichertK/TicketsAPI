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
        private readonly JwtSettings _jwtSettings;

        public AuthService(
            IUsuarioRepository usuarioRepository, 
            IRolRepository rolRepository,
            IPermisoRepository permisoRepository,
            IOptions<JwtSettings> jwtOptions)
        {
            _usuarioRepository = usuarioRepository;
            _rolRepository = rolRepository;
            _permisoRepository = permisoRepository;
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

            // Cargar rol con permisos
            var rol = usuario.Id_Rol > 0 
                ? await _rolRepository.GetWithPermisosAsync(usuario.Id_Rol) 
                : null;

            // Cargar permisos del rol
            var permisos = usuario.Id_Rol > 0 
                ? await _permisoRepository.GetByRolAsync(usuario.Id_Rol) 
                : new List<Models.Entities.Permiso>();

            var token = GenerateJwtToken(usuario.Id_Usuario, usuario.Nombre, usuario.Email, usuario.Id_Rol.ToString());
            var response = new LoginResponse
            {
                Id_Usuario = usuario.Id_Usuario,
                Nombre = usuario.Nombre,
                Email = usuario.Email,
                Token = token,
                RefreshToken = Guid.NewGuid().ToString(),
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

        public Task<LoginResponse?> RefreshTokenAsync(string refreshToken)
        {
            // Pendiente: validar refresh token y emitir nuevo JWT
            return Task.FromResult<LoginResponse?>(null);
        }

        public Task LogoutAsync(int idUsuario)
        {
            // Opcional: invalidar refresh tokens, registrar auditoría
            return Task.CompletedTask;
        }

        public Task<bool> ValidarPermisoAsync(int idUsuario, string codigoPermiso)
        {
            // Pendiente: integrar con repositorio/servicio de permisos
            return Task.FromResult(false);
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

        private string GenerateJwtToken(int userId, string name, string email, string role)
        {
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
                new Claim(JwtRegisteredClaimNames.UniqueName, name),
                new Claim(JwtRegisteredClaimNames.Email, email),
                new Claim("role", role)
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
