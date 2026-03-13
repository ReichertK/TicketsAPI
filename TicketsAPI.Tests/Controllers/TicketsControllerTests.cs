using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
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
    public class TicketsControllerTests
    {
        private readonly Mock<ITicketService> _ticketService = new();
        private readonly Mock<IEstadoService> _estadoService = new();
        private readonly Mock<INotificacionService> _notificacionService = new();
        private readonly Mock<ITicketRepository> _ticketRepository = new();
        private readonly Mock<IExportService> _exportService = new();
        private readonly Mock<INotificacionLecturaRepository> _notificacionLecturaRepo = new();
        private readonly Mock<IAuthService> _authService = new();
        private readonly Mock<ILogger<TicketsController>> _logger = ControllerTestHelper.CreateMockLogger<TicketsController>();
        private readonly TicketsController _controller;

        public TicketsControllerTests()
        {
            _controller = new TicketsController(
                _logger.Object,
                _ticketService.Object,
                _estadoService.Object,
                _notificacionService.Object,
                _ticketRepository.Object,
                _exportService.Object,
                _notificacionLecturaRepo.Object,
                _authService.Object);
        }

        [Fact]
        public async Task BuscarAvanzado_SinUsuario_Retorna401()
        {
            // Arrange
            ControllerTestHelper.SetupUnauthenticatedUser(_controller);

            // Act
            var result = await _controller.BuscarAvanzado(new TicketFiltroDTO());

            // Assert
            result.Should().BeOfType<UnauthorizedObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(401);
        }

        [Fact]
        public async Task BuscarAvanzado_UsuarioAutenticado_PoneIdUsuarioEnFiltro()
        {
            // Arrange
            var userId = 42;
            var filtroEntrada = new TicketFiltroDTO { Busqueda = "test" };
            var paginated = new PaginatedResponse<TicketDTO>
            {
                Datos = new List<TicketDTO>(),
                TotalRegistros = 0,
                TotalPaginas = 0,
                PaginaActual = 1,
                TamañoPagina = 10
            };

            _ticketService
                .Setup(s => s.GetFilteredAsync(It.IsAny<TicketFiltroDTO>(), It.IsAny<int>()))
                .ReturnsAsync(paginated);

            ControllerTestHelper.SetupAuthenticatedUser(_controller, userId);

            // Act
            var result = await _controller.BuscarAvanzado(filtroEntrada);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);
            _ticketService.Verify(s => s.GetFilteredAsync(It.IsAny<TicketFiltroDTO>(), userId), Times.Once);
        }
    }
}
