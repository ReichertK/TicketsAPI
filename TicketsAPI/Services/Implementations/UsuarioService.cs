using System.Security.Cryptography;
using System.Text;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Services.Implementations
{
    public class UsuarioService : IUsuarioService
    {
        private readonly IUsuarioRepository _usuarioRepository;
        private readonly IRolRepository _rolRepository;
        private readonly IDepartamentoRepository _departamentoRepository;
        private readonly ILogger<UsuarioService> _logger;

        public UsuarioService(
            IUsuarioRepository usuarioRepository,
            IRolRepository rolRepository,
            IDepartamentoRepository departamentoRepository,
            ILogger<UsuarioService> logger)
        {
            _usuarioRepository = usuarioRepository;
            _rolRepository = rolRepository;
            _departamentoRepository = departamentoRepository;
            _logger = logger;
        }

        public async Task<UsuarioDTO?> GetByIdAsync(int id)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id);
            if (usuario is null)
                return null;

            var rol = usuario.Id_Rol > 0 ? await _rolRepository.GetByIdAsync(usuario.Id_Rol) : null;
            var departamento = usuario.Id_Departamento.HasValue ? 
                await _departamentoRepository.GetByIdAsync(usuario.Id_Departamento.Value) : null;

            return MapToDTO(usuario, rol, departamento);
        }

        public async Task<List<UsuarioDTO>> GetAllAsync()
        {
            var usuarios = await _usuarioRepository.GetAllAsync();
            var dtos = new List<UsuarioDTO>();

            foreach (var usuario in usuarios)
            {
                var rol = usuario.Id_Rol > 0 ? await _rolRepository.GetByIdAsync(usuario.Id_Rol) : null;
                var departamento = usuario.Id_Departamento.HasValue ? 
                    await _departamentoRepository.GetByIdAsync(usuario.Id_Departamento.Value) : null;
                
                dtos.Add(MapToDTO(usuario, rol, departamento));
            }

            return dtos;
        }

        public async Task<List<UsuarioDTO>> GetByRolAsync(int idRol)
        {
            var usuarios = await _usuarioRepository.GetByRolAsync(idRol);
            var dtos = new List<UsuarioDTO>();

            foreach (var usuario in usuarios)
            {
                var rol = usuario.Id_Rol > 0 ? await _rolRepository.GetByIdAsync(usuario.Id_Rol) : null;
                var departamento = usuario.Id_Departamento.HasValue ? 
                    await _departamentoRepository.GetByIdAsync(usuario.Id_Departamento.Value) : null;
                
                dtos.Add(MapToDTO(usuario, rol, departamento));
            }

            return dtos;
        }

        public async Task<int> CreateAsync(CreateUpdateUsuarioDTO dto)
        {
            // Validar que el rol exista
            var rol = await _rolRepository.GetByIdAsync(dto.Id_Rol);
            if (rol is null)
                throw new ArgumentException($"El rol con ID {dto.Id_Rol} no existe");

            // Validar que el departamento exista (si es especificado)
            if (dto.Id_Departamento.HasValue)
            {
                var departamento = await _departamentoRepository.GetByIdAsync(dto.Id_Departamento.Value);
                if (departamento is null)
                    throw new ArgumentException($"El departamento con ID {dto.Id_Departamento} no existe");
            }

            var usuario = new Usuario
            {
                Nombre = dto.Nombre,
                Apellido = dto.Apellido,
                Email = dto.Email,
                Usuario_Correo = dto.Usuario_Correo,
                Contraseña = HashPassword(dto.Contraseña ?? ""),
                Id_Rol = dto.Id_Rol,
                Id_Departamento = dto.Id_Departamento,
                Activo = true,
                Fecha_Registro = DateTime.UtcNow
            };

            var idNuevo = await _usuarioRepository.CreateAsync(usuario);
            _logger.LogInformation($"Usuario creado exitosamente con ID: {idNuevo}");
            return idNuevo;
        }

        public async Task<bool> UpdateAsync(int id, CreateUpdateUsuarioDTO dto)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id);
            if (usuario is null)
                return false;

            // Validar que el rol exista
            if (usuario.Id_Rol != dto.Id_Rol)
            {
                var rol = await _rolRepository.GetByIdAsync(dto.Id_Rol);
                if (rol is null)
                    throw new ArgumentException($"El rol con ID {dto.Id_Rol} no existe");
            }

            // Validar que el departamento exista (si es especificado)
            if (dto.Id_Departamento.HasValue && usuario.Id_Departamento != dto.Id_Departamento)
            {
                var departamento = await _departamentoRepository.GetByIdAsync(dto.Id_Departamento.Value);
                if (departamento is null)
                    throw new ArgumentException($"El departamento con ID {dto.Id_Departamento} no existe");
            }

            usuario.Nombre = dto.Nombre;
            usuario.Apellido = dto.Apellido;
            usuario.Email = dto.Email;
            usuario.Usuario_Correo = dto.Usuario_Correo;
            usuario.Id_Rol = dto.Id_Rol;
            usuario.Id_Departamento = dto.Id_Departamento;

            // Solo actualizar contraseña si se proporciona
            if (!string.IsNullOrWhiteSpace(dto.Contraseña))
            {
                usuario.Contraseña = HashPassword(dto.Contraseña);
            }

            var success = await _usuarioRepository.UpdateAsync(usuario);
            if (success)
                _logger.LogInformation($"Usuario {id} actualizado exitosamente");

            return success;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id);
            if (usuario is null)
                return false;

            // Soft delete: marcar como inactivo
            usuario.Activo = false;
            var success = await _usuarioRepository.UpdateAsync(usuario);
            
            if (success)
                _logger.LogInformation($"Usuario {id} marcado como inactivo");

            return success;
        }

        public async Task<bool> ChangePasswordAsync(int id, string passwordActual, string passwordNueva)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id);
            if (usuario is null)
                return false;

            // Verificar que la contraseña actual es correcta
            if (!VerifyPassword(usuario.Contraseña, passwordActual))
            {
                _logger.LogWarning($"Intento fallido de cambio de contraseña para usuario {id}");
                return false;
            }

            // Actualizar contraseña
            usuario.Contraseña = HashPassword(passwordNueva);
            var success = await _usuarioRepository.UpdateAsync(usuario);

            if (success)
                _logger.LogInformation($"Contraseña actualizada para usuario {id}");

            return success;
        }

        private UsuarioDTO MapToDTO(Usuario usuario, Rol? rol, Departamento? departamento)
        {
            return new UsuarioDTO
            {
                Id_Usuario = usuario.Id_Usuario,
                Nombre = usuario.Nombre,
                Apellido = usuario.Apellido,
                Email = usuario.Email,
                Id_Rol = usuario.Id_Rol,
                Id_Departamento = usuario.Id_Departamento,
                Activo = usuario.Activo,
                Fecha_Registro = usuario.Fecha_Registro,
                Ultima_Sesion = usuario.Ultima_Sesion,
                Rol = rol != null ? new RolDTO
                {
                    Id_Rol = rol.Id_Rol,
                    Nombre_Rol = rol.Nombre_Rol,
                    Descripcion = rol.Descripcion,
                    Activo = rol.Activo
                } : null,
                Departamento = departamento != null ? new DepartamentoDTO
                {
                    Id_Departamento = departamento.Id_Departamento,
                    Nombre = departamento.Nombre,
                    Descripcion = departamento.Descripcion,
                    Activo = departamento.Activo
                } : null
            };
        }

        /// <summary>
        /// Hashea una contraseña usando SHA256 (simple, para compatibilidad con BD existente)
        /// En producción, considerar usar BCrypt o Argon2
        /// </summary>
        private static string HashPassword(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
                return string.Empty;

            using var sha256 = SHA256.Create();
            var hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(hashedBytes);
        }

        /// <summary>
        /// Verifica una contraseña contra su hash
        /// </summary>
        private static bool VerifyPassword(string storedHash, string providedPassword)
        {
            // Aceptar coincidencia directa (para usuarios sin hashear en BD)
            if (string.Equals(storedHash, providedPassword))
                return true;

            // Verificar hash SHA256
            var providedHash = HashPassword(providedPassword);
            return string.Equals(storedHash, providedHash);
        }
    }
}
