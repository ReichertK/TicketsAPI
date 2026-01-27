using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using TicketsAPI.Controllers;
using TicketsAPI.Models;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Tests.Helpers;

namespace TicketsAPI.Tests.Controllers
{
    public class AuthControllerTests
    {
        private readonly Mock<IAuthService> _mockAuthService;
        private readonly Mock<ILogger<AuthController>> _mockLogger;
        private readonly AuthController _controller;

        public AuthControllerTests()
        {
            _mockAuthService = new Mock<IAuthService>();
            _mockLogger = ControllerTestHelper.CreateMockLogger<AuthController>();
            _controller = new AuthController(_mockLogger.Object, _mockAuthService.Object);
        }

        #region POST /login

        [Fact]
        public async Task Login_CredencialesValidas_RetornaSuccess200()
        {
            // Arrange
            var request = new LoginRequest { Usuario = "user@test.com", Contraseña = "password123" };
            var loginResponse = new LoginResponse
            {
                Token = "valid-jwt-token",
                RefreshToken = "valid-refresh-token",
                Id_Usuario = 1,
                Nombre = "Test User",
                Email = "user@test.com"
            };

            _mockAuthService.Setup(s => s.LoginAsync(request)).ReturnsAsync(loginResponse);

            // Act
            var result = await _controller.Login(request);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<LoginResponse>;
            response!.Exitoso.Should().BeTrue();
            response.Datos!.Token.Should().Be("valid-jwt-token");
        }

        [Fact]
        public async Task Login_CredencialesInvalidas_RetornaError401()
        {
            // Arrange
            var request = new LoginRequest { Usuario = "user@test.com", Contraseña = "wrongpass" };
            _mockAuthService.Setup(s => s.LoginAsync(request)).ReturnsAsync((LoginResponse?)null);

            // Act
            var result = await _controller.Login(request);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(401);
        }

        [Fact]
        public async Task Login_CuandoExcepcion_RetornaError500()
        {
            // Arrange
            var request = new LoginRequest { Usuario = "user@test.com", Contraseña = "password123" };
            _mockAuthService.Setup(s => s.LoginAsync(request)).ThrowsAsync(new Exception("Database error"));

            // Act
            var result = await _controller.Login(request);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(500);
        }

        #endregion

        #region POST /refresh-token

        [Fact]
        public async Task RefreshToken_TokenValido_RetornaSuccess200()
        {
            // Arrange
            var request = new RefreshTokenRequest { RefreshToken = "valid-refresh-token" };
            var refreshResponse = new LoginResponse
            {
                Token = "new-jwt-token",
                RefreshToken = "new-refresh-token",
                Id_Usuario = 1,
                Nombre = string.Empty,
                Email = string.Empty
            };

            _mockAuthService.Setup(s => s.RefreshTokenAsync(request.RefreshToken)).ReturnsAsync(refreshResponse);

            // Act
            var result = await _controller.RefreshToken(request);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<LoginResponse>;
            response!.Exitoso.Should().BeTrue();
        }

        [Fact]
        public async Task RefreshToken_TokenInvalido_RetornaError401()
        {
            // Arrange
            var request = new RefreshTokenRequest { RefreshToken = "invalid-token" };
            _mockAuthService.Setup(s => s.RefreshTokenAsync(request.RefreshToken)).ReturnsAsync((LoginResponse?)null);

            // Act
            var result = await _controller.RefreshToken(request);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(401);
        }

        #endregion

        #region POST /logout

        [Fact]
        public async Task Logout_UsuarioAutenticado_RetornaSuccess200()
        {
            // Arrange
            var usuarioId = 5;
            _mockAuthService.Setup(s => s.LogoutAsync(usuarioId)).Returns(Task.CompletedTask);
            ControllerTestHelper.SetupAuthenticatedUser(_controller, usuarioId);

            // Act
            var result = await _controller.Logout();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            _mockAuthService.Verify(s => s.LogoutAsync(usuarioId), Times.Once);
        }

        #endregion

        #region GET /me

        [Fact]
        public async Task GetCurrentUser_UsuarioAutenticado_RetornaSuccess200()
        {
            // Arrange
            var usuarioId = 5;
            var role = "User";
            ControllerTestHelper.SetupAuthenticatedUser(_controller, usuarioId, role);

            // Act
            var result = _controller.GetCurrentUser();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);
        }

        #endregion
    }
}
