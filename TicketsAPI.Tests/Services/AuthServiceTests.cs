using FluentAssertions;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using TicketsAPI.Config;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Implementations;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Tests.Services
{
    public class AuthServiceTests
    {
        private readonly Mock<IUsuarioRepository> _mockUsuarioRepo;
        private readonly Mock<IRolRepository> _mockRolRepo;
        private readonly Mock<IPermisoRepository> _mockPermisoRepo;
        private readonly Mock<IPasswordService> _mockPasswordService;
        private readonly Mock<BruteForceProtectionService> _mockBruteForce;
        private readonly Mock<ILogger<AuthService>> _mockLogger;
        private readonly IOptions<JwtSettings> _jwtOptions;
        private readonly AuthService _sut;

        public AuthServiceTests()
        {
            _mockUsuarioRepo = new Mock<IUsuarioRepository>();
            _mockRolRepo = new Mock<IRolRepository>();
            _mockPermisoRepo = new Mock<IPermisoRepository>();
            _mockPasswordService = new Mock<IPasswordService>();
            _mockLogger = new Mock<ILogger<AuthService>>();

            _jwtOptions = Options.Create(new JwtSettings
            {
                SecretKey = "TestSecretKeyAtLeast32CharactersLong!!",
                Issuer = "TestIssuer",
                Audience = "TestAudience",
                ExpirationMinutes = 15
            });

            // BruteForceProtectionService: mock with virtual methods (no real DB needed)
            var bfLogger = new Mock<ILogger<BruteForceProtectionService>>();
            _mockBruteForce = new Mock<BruteForceProtectionService>("Server=fake;", bfLogger.Object) { CallBase = false };
            _mockBruteForce.Setup(b => b.VerificarBloqueoAsync(It.IsAny<string>()))
                .ReturnsAsync((false, 5, (DateTime?)null));
            _mockBruteForce.Setup(b => b.RegistrarIntentoFallidoAsync(It.IsAny<string>(), It.IsAny<string>()))
                .Returns(Task.CompletedTask);
            _mockBruteForce.Setup(b => b.LimpiarIntentosAsync(It.IsAny<string>()))
                .Returns(Task.CompletedTask);

            _sut = new AuthService(
                _mockUsuarioRepo.Object,
                _mockRolRepo.Object,
                _mockPermisoRepo.Object,
                _mockPasswordService.Object,
                _mockBruteForce.Object,
                _mockLogger.Object,
                _jwtOptions);
        }

        #region LoginAsync

        [Fact]
        public async Task LoginAsync_CredencialesValidas_RetornaLoginResponse()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            _mockUsuarioRepo.Setup(r => r.GetByEmailAsync("admin@demo.com"))
                .ReturnsAsync(usuario);
            _mockPasswordService.Setup(p => p.Verify(usuario.Contraseña, "admin123"))
                .Returns(true);
            _mockPasswordService.Setup(p => p.IsBCrypt(usuario.Contraseña)).Returns(true);
            _mockRolRepo.Setup(r => r.GetByIdAsync(10))
                .ReturnsAsync(new Rol { Id_Rol = 10, Nombre_Rol = "Administrador" });
            _mockPermisoRepo.Setup(p => p.GetByRolAsync(10))
                .ReturnsAsync(new List<Permiso> { new() { Codigo = "TKT_CREATE" } });
            _mockUsuarioRepo.Setup(r => r.SaveRefreshTokenAsync(It.IsAny<int>(), It.IsAny<string>(), It.IsAny<DateTime>()))
                .ReturnsAsync(true);
            _mockUsuarioRepo.Setup(r => r.UpdateLastSessionAsync(1)).ReturnsAsync(true);

            // Act
            var result = await _sut.LoginAsync(new LoginRequest { Usuario = "admin@demo.com", Contraseña = "admin123" });

            // Assert
            result.Should().NotBeNull();
            result!.Id_Usuario.Should().Be(1);
            result.Nombre.Should().Be("Admin");
            result.Token.Should().NotBeNullOrEmpty();
            result.RefreshToken.Should().NotBeNullOrEmpty();
            result.Permisos.Should().Contain("TKT_CREATE");
        }

        [Fact]
        public async Task LoginAsync_UsuarioNoExiste_RetornaNull()
        {
            // Arrange
            _mockUsuarioRepo.Setup(r => r.GetByEmailAsync(It.IsAny<string>()))
                .ReturnsAsync((Usuario?)null);
            _mockUsuarioRepo.Setup(r => r.GetByUsuarioAsync(It.IsAny<string>()))
                .ReturnsAsync((Usuario?)null);

            // Act
            var result = await _sut.LoginAsync(new LoginRequest { Usuario = "nobody", Contraseña = "wrong" });

            // Assert
            result.Should().BeNull();
            _mockBruteForce.Verify(b => b.RegistrarIntentoFallidoAsync("nobody", It.IsAny<string>()), Times.Once);
        }

        [Fact]
        public async Task LoginAsync_ContraseñaIncorrecta_RetornaNull_YRegistraIntento()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            _mockUsuarioRepo.Setup(r => r.GetByEmailAsync("admin@demo.com"))
                .ReturnsAsync(usuario);
            _mockPasswordService.Setup(p => p.Verify(usuario.Contraseña, "wrongpass"))
                .Returns(false);

            // Act
            var result = await _sut.LoginAsync(new LoginRequest { Usuario = "admin@demo.com", Contraseña = "wrongpass" });

            // Assert
            result.Should().BeNull();
            _mockBruteForce.Verify(b => b.RegistrarIntentoFallidoAsync("admin@demo.com", It.IsAny<string>()), Times.Once);
        }

        [Fact]
        public async Task LoginAsync_CuentaBloqueada_RetornaNull_SinConsultarBD()
        {
            // Arrange
            _mockBruteForce.Setup(b => b.VerificarBloqueoAsync("blocked@demo.com"))
                .ReturnsAsync((true, 0, DateTime.UtcNow.AddMinutes(10)));

            // Act
            var result = await _sut.LoginAsync(new LoginRequest { Usuario = "blocked@demo.com", Contraseña = "any" });

            // Assert
            result.Should().BeNull();
            _mockUsuarioRepo.Verify(r => r.GetByEmailAsync(It.IsAny<string>()), Times.Never);
        }

        [Fact]
        public async Task LoginAsync_UsuarioInactivo_RetornaNull()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            usuario.Activo = false;
            _mockUsuarioRepo.Setup(r => r.GetByEmailAsync("admin@demo.com"))
                .ReturnsAsync(usuario);

            // Act
            var result = await _sut.LoginAsync(new LoginRequest { Usuario = "admin@demo.com", Contraseña = "admin123" });

            // Assert
            result.Should().BeNull();
        }

        [Fact]
        public async Task LoginAsync_ContraseñaLegacy_MigraABCrypt()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            _mockUsuarioRepo.Setup(r => r.GetByEmailAsync("admin@demo.com"))
                .ReturnsAsync(usuario);
            _mockPasswordService.Setup(p => p.Verify(usuario.Contraseña, "admin123")).Returns(true);
            _mockPasswordService.Setup(p => p.IsBCrypt(usuario.Contraseña)).Returns(false); // legacy hash
            _mockPasswordService.Setup(p => p.Hash("admin123")).Returns("$2a$11$newBcryptHash");
            _mockRolRepo.Setup(r => r.GetByIdAsync(10)).ReturnsAsync(new Rol { Id_Rol = 10, Nombre_Rol = "Administrador" });
            _mockPermisoRepo.Setup(p => p.GetByRolAsync(10)).ReturnsAsync(new List<Permiso>());
            _mockUsuarioRepo.Setup(r => r.SaveRefreshTokenAsync(It.IsAny<int>(), It.IsAny<string>(), It.IsAny<DateTime>()))
                .ReturnsAsync(true);
            _mockUsuarioRepo.Setup(r => r.UpdateLastSessionAsync(1)).ReturnsAsync(true);

            // Act
            var result = await _sut.LoginAsync(new LoginRequest { Usuario = "admin@demo.com", Contraseña = "admin123" });

            // Assert
            result.Should().NotBeNull();
            _mockUsuarioRepo.Verify(r => r.UpdatePasswordHashAsync(1, "$2a$11$newBcryptHash"), Times.Once);
        }

        #endregion

        #region RefreshTokenAsync

        [Fact]
        public async Task RefreshTokenAsync_TokenValido_RetornaNuevoTokenYRota()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            usuario.RefreshTokenExpires = DateTime.UtcNow.AddDays(5);
            _mockUsuarioRepo.Setup(r => r.GetByRefreshTokenAsync(It.IsAny<string>()))
                .ReturnsAsync(usuario);
            _mockRolRepo.Setup(r => r.GetByIdAsync(10))
                .ReturnsAsync(new Rol { Id_Rol = 10, Nombre_Rol = "Administrador" });
            _mockPermisoRepo.Setup(p => p.GetByRolAsync(10))
                .ReturnsAsync(new List<Permiso>());
            _mockUsuarioRepo.Setup(r => r.SaveRefreshTokenAsync(It.IsAny<int>(), It.IsAny<string>(), It.IsAny<DateTime>()))
                .ReturnsAsync(true);

            // Act
            var result = await _sut.RefreshTokenAsync("valid-refresh-token");

            // Assert
            result.Should().NotBeNull();
            result!.Token.Should().NotBeNullOrEmpty();
            result.RefreshToken.Should().NotBeNullOrEmpty();
            // Verify token rotation: new token saved
            _mockUsuarioRepo.Verify(r => r.SaveRefreshTokenAsync(1, It.IsAny<string>(), It.IsAny<DateTime>()), Times.Once);
        }

        [Fact]
        public async Task RefreshTokenAsync_TokenVacio_RetornaNull()
        {
            var result = await _sut.RefreshTokenAsync("");
            result.Should().BeNull();
        }

        [Fact]
        public async Task RefreshTokenAsync_TokenExpirado_RetornaNull_YLimpiaToken()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            usuario.RefreshTokenExpires = DateTime.UtcNow.AddDays(-1); // expired
            _mockUsuarioRepo.Setup(r => r.GetByRefreshTokenAsync(It.IsAny<string>()))
                .ReturnsAsync(usuario);

            // Act
            var result = await _sut.RefreshTokenAsync("expired-token");

            // Assert
            result.Should().BeNull();
            _mockUsuarioRepo.Verify(r => r.ClearRefreshTokenAsync(1), Times.Once);
        }

        #endregion

        #region LogoutAsync

        [Fact]
        public async Task LogoutAsync_LimpiaRefreshToken()
        {
            // Arrange & Act
            await _sut.LogoutAsync(1);

            // Assert
            _mockUsuarioRepo.Verify(r => r.ClearRefreshTokenAsync(1), Times.Once);
        }

        #endregion

        #region ValidarPermisoAsync

        [Fact]
        public async Task ValidarPermiso_AdminSiempreTieneAcceso()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            _mockUsuarioRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(usuario);
            _mockRolRepo.Setup(r => r.GetByIdAsync(10))
                .ReturnsAsync(new Rol { Id_Rol = 10, Nombre_Rol = "Administrador" });

            // Act
            var result = await _sut.ValidarPermisoAsync(1, "ANY_PERMISSION");

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task ValidarPermiso_UsuarioSinPermiso_RetornaFalse()
        {
            // Arrange
            var usuario = CrearUsuarioDemo();
            usuario.Id_Rol = 3; // Operador
            _mockUsuarioRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(usuario);
            _mockRolRepo.Setup(r => r.GetByIdAsync(3))
                .ReturnsAsync(new Rol { Id_Rol = 3, Nombre_Rol = "Operador" });
            _mockPermisoRepo.Setup(p => p.GetCodigosByUsuarioAsync(1))
                .ReturnsAsync(new List<string> { "TKT_CREATE", "TKT_COMMENT" });

            // Act
            var result = await _sut.ValidarPermisoAsync(1, "TKT_DELETE");

            // Assert
            result.Should().BeFalse();
        }

        [Fact]
        public async Task ValidarPermiso_CodigoVacio_RetornaFalse()
        {
            var result = await _sut.ValidarPermisoAsync(1, "");
            result.Should().BeFalse();
        }

        #endregion

        private static Usuario CrearUsuarioDemo() => new()
        {
            Id_Usuario = 1,
            Nombre = "Admin",
            Email = "admin@demo.com",
            Contraseña = "hashed_password",
            Id_Rol = 10,
            Activo = true,
            Fecha_Registro = DateTime.UtcNow
        };
    }
}
