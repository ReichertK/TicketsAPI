using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Moq;
using TicketsAPI.Controllers;
using TicketsAPI.Models;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Tests.Helpers;

namespace TicketsAPI.Tests.Controllers
{
    /// Pruebas exhaustivas para todos los endpoints principales
    public class AllEndpointsTests
    {
        // Auth
        public class AuthControllerComprehensiveTests
        {
            private readonly Mock<IAuthService> _mockAuthService = new();
            private readonly Mock<ILogger<AuthController>> _mockLogger = ControllerTestHelper.CreateMockLogger<AuthController>();
            private readonly AuthController _controller;

            public AuthControllerComprehensiveTests()
            {
                _controller = new AuthController(_mockLogger.Object, _mockAuthService.Object);
            }

            [Fact]
            public async Task Login_CredencialesValidas_RetornaTokenJWT()
            {
                var request = new LoginRequest { Usuario = "admin", Contraseña = "changeme" };
                var loginResp = new LoginResponse { Token = "jwt-token", RefreshToken = "refresh-token", Id_Usuario = 1, Nombre = "Admin" };
                _mockAuthService.Setup(s => s.LoginAsync(request)).ReturnsAsync(loginResp);

                var result = await _controller.Login(request);

                result.Should().BeOfType<ObjectResult>();
                (result as ObjectResult)!.StatusCode.Should().Be(200);
            }

            [Fact]
            public async Task RefreshToken_ConTokenValido_RetornaTokenNuevo()
            {
                var request = new RefreshTokenRequest { RefreshToken = "refresh-token" };
                var loginResp = new LoginResponse { Token = "new-jwt-token", RefreshToken = "new-refresh" };
                _mockAuthService.Setup(s => s.RefreshTokenAsync(request.RefreshToken)).ReturnsAsync(loginResp);

                var result = await _controller.RefreshToken(request);

                result.Should().BeOfType<ObjectResult>();
                (result as ObjectResult)!.StatusCode.Should().Be(200);
            }

            [Fact]
            public async Task Logout_UsuarioAutenticado_RetornaSuccess()
            {
                ControllerTestHelper.SetupAuthenticatedUser(_controller, 1);
                _mockAuthService.Setup(s => s.LogoutAsync(1)).Returns(Task.CompletedTask);

                var result = await _controller.Logout();

                result.Should().BeOfType<ObjectResult>();
                (result as ObjectResult)!.StatusCode.Should().Be(200);
            }

            [Fact]
            public void GetCurrentUser_UsuarioAutenticado_RetornaUserInfo()
            {
                ControllerTestHelper.SetupAuthenticatedUser(_controller, 5, "User");

                var result = _controller.GetCurrentUser();

                result.Should().BeOfType<ObjectResult>();
                (result as ObjectResult)!.StatusCode.Should().Be(200);
            }
        }

        // Tickets
        public class TicketsControllerComprehensiveTests
        {
            private readonly Mock<ITicketService> _ticketService = new();
            private readonly Mock<IEstadoService> _estadoService = new();
            private readonly Mock<INotificacionService> _notificacionService = new();
            private readonly Mock<ITicketRepository> _ticketRepository = new();
            private readonly Mock<IExportService> _exportService = new();
            private readonly Mock<INotificacionLecturaRepository> _notificacionLecturaRepo = new();
            private readonly Mock<IAuthService> _authService = new();
            private readonly Mock<ILogger<TicketsController>> _mockLogger = ControllerTestHelper.CreateMockLogger<TicketsController>();
            private readonly TicketsController _controller;

            public TicketsControllerComprehensiveTests()
            {
                var mockConfigSection = new Mock<IConfigurationSection>();
                mockConfigSection.Setup(s => s[It.IsAny<string>()]).Returns("Server=fake;");
                var mockConfig = new Mock<IConfiguration>();
                mockConfig.Setup(c => c.GetSection("ConnectionStrings")).Returns(mockConfigSection.Object);

                _controller = new TicketsController(
                    _mockLogger.Object,
                    mockConfig.Object,
                    _ticketService.Object,
                    _estadoService.Object,
                    _notificacionService.Object,
                    _ticketRepository.Object,
                    _exportService.Object,
                    _notificacionLecturaRepo.Object,
                    _authService.Object);
            }

            [Fact]
            public async Task GetTickets_ConFiltros_RetornaPaginatedResponse()
            {
                var paginatedResp = new PaginatedResponse<TicketDTO> { Datos = new(), TotalRegistros = 0 };
                _ticketService.Setup(s => s.GetFilteredAsync(It.IsAny<TicketFiltroDTO>(), It.IsAny<int>())).ReturnsAsync(paginatedResp);
                ControllerTestHelper.SetupAuthenticatedUser(_controller, 1);

                var result = await _controller.GetTickets(new TicketFiltroDTO());

                result.Should().BeOfType<ObjectResult>();
                (result as ObjectResult)!.StatusCode.Should().Be(200);
            }

            [Fact]
            public async Task BuscarAvanzado_SinUsuario_Retorna401()
            {
                ControllerTestHelper.SetupUnauthenticatedUser(_controller);

                var result = await _controller.BuscarAvanzado(new TicketFiltroDTO());

                result.Should().BeOfType<UnauthorizedObjectResult>();
            }

            [Fact]
            public async Task GetTicket_TicketExistente_RetornaTicketDetail()
            {
                var ticket = new TicketDTO { Id_Tkt = 1, Contenido = "Test" };
                _ticketService.Setup(s => s.GetByIdAsync(1)).ReturnsAsync(ticket);
                ControllerTestHelper.SetupAuthenticatedUser(_controller, 1);

                var result = await _controller.GetTicket(1);

                result.Should().BeOfType<ObjectResult>();
                (result as ObjectResult)!.StatusCode.Should().Be(200);
            }

            [Fact]
            public async Task CreateTicket_DatosValidos_Retorna201()
            {
                var dto = new CreateUpdateTicketDTO { Contenido = "Test", Id_Prioridad = 1, Id_Departamento = 1 };
                _ticketService.Setup(s => s.CreateAsync(It.IsAny<CreateUpdateTicketDTO>(), It.IsAny<int>())).ReturnsAsync(1);
                _notificacionService.Setup(s => s.NotificarNuevoTicketAsync(It.IsAny<int>())).Returns(Task.CompletedTask);
                ControllerTestHelper.SetupAuthenticatedUser(_controller, 1);

                var result = await _controller.CreateTicket(dto);

                result.Should().BeOfType<ObjectResult>();
                (result as ObjectResult)!.StatusCode.Should().Be(201);
            }
        }

        // Nota: ReferencesController requiere CacheService que no se puede mockear fácilmente
        // Su cobertura se valida a través de la suite de integración
    }
}
