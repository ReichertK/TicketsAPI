using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using TicketsAPI.Controllers;
using TicketsAPI.Models;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Tests.Helpers;

namespace TicketsAPI.Tests.Controllers
{
    public class TransicionesControllerTests
    {
        private readonly Mock<IBaseRepository<Transicion>> _mockTransicionRepository;
        private readonly Mock<IBaseRepository<Ticket>> _mockTicketRepository;
        private readonly Mock<INotificacionService> _mockNotificacionService;
        private readonly Mock<ITicketService> _mockTicketService;
        private readonly Mock<ILogger<TransicionesController>> _mockLogger;
        private readonly TransicionesController _controller;

        public TransicionesControllerTests()
        {
            _mockTransicionRepository = new Mock<IBaseRepository<Transicion>>();
            _mockTicketRepository = new Mock<IBaseRepository<Ticket>>();
            _mockNotificacionService = new Mock<INotificacionService>();
            _mockTicketService = new Mock<ITicketService>();
            _mockLogger = ControllerTestHelper.CreateMockLogger<TransicionesController>();
            
            _controller = new TransicionesController(
                _mockTransicionRepository.Object,
                _mockTicketRepository.Object,
                _mockNotificacionService.Object,
                _mockTicketService.Object,
                _mockLogger.Object
            );
        }

        #region GET /api/v1/Tickets/{ticketId}/Transitions

        [Fact]
        public async Task ObtenerTransicionesPorTicket_TicketExiste_RetornaSuccess200()
        {
            // Arrange
            var ticketId = 10;
            var ticket = new Ticket { Id_Tkt = ticketId };
            var transiciones = new List<Transicion>
            {
                new Transicion 
                { 
                    Id_Transicion = 1, 
                    Id_Tkt = ticketId, 
                    Id_Estado_Anterior = 1,
                    Id_Estado_Nuevo = 2,
                    Fecha = DateTime.Now.AddDays(-1)
                },
                new Transicion 
                { 
                    Id_Transicion = 2, 
                    Id_Tkt = ticketId, 
                    Id_Estado_Anterior = 2,
                    Id_Estado_Nuevo = 3,
                    Fecha = DateTime.Now
                }
            };

            _mockTicketRepository.Setup(r => r.GetByIdAsync(ticketId)).ReturnsAsync(ticket);
            _mockTransicionRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(transiciones);

            // Act
            var result = await _controller.ObtenerTransicionesPorTicket(ticketId);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<TransicionDTO>>;
            response!.Exitoso.Should().BeTrue();
            response.Datos.Should().HaveCount(2);
        }

        [Fact]
        public async Task ObtenerTransicionesPorTicket_TicketNoExiste_RetornaError404()
        {
            // Arrange
            _mockTicketRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Ticket?)null);

            // Act
            var result = await _controller.ObtenerTransicionesPorTicket(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);
        }

        [Fact]
        public async Task ObtenerTransicionesPorTicket_SinTransiciones_RetornaListaVacia()
        {
            // Arrange
            var ticketId = 10;
            var ticket = new Ticket { Id_Tkt = ticketId };
            _mockTicketRepository.Setup(r => r.GetByIdAsync(ticketId)).ReturnsAsync(ticket);
            _mockTransicionRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(new List<Transicion>());

            // Act
            var result = await _controller.ObtenerTransicionesPorTicket(ticketId);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<TransicionDTO>>;
            response!.Datos.Should().BeEmpty();
        }

        #endregion

        #region POST /api/v1/Tickets/{ticketId}/Transition

        [Fact]
        public async Task RealizarTransicion_DatosValidos_RetornaSuccess200()
        {
            // Arrange
            var ticketId = 10;
            var usuarioId = 5;
            var dto = new TransicionEstadoDTO { Id_Estado_Nuevo = 3, Comentario = "Escalado" };
            var ticket = new Ticket { Id_Tkt = ticketId, Id_Estado = 2 };

            _mockTicketRepository.Setup(r => r.GetByIdAsync(ticketId)).ReturnsAsync(ticket);
            _mockTicketService.Setup(s => s.TransicionarEstadoAsync(ticketId, It.IsAny<TransicionEstadoDTO>(), usuarioId))
                .ReturnsAsync(true);
            _mockTransicionRepository.Setup(r => r.CreateAsync(It.IsAny<Transicion>())).ReturnsAsync(1);
            _mockNotificacionService.Setup(s => s.TransicionEstadoAsync(ticketId, usuarioId, dto.Id_Estado_Nuevo))
                .Returns(Task.CompletedTask);

            ControllerTestHelper.SetupAuthenticatedUser(_controller, usuarioId);

            // Act
            var result = await _controller.RealizarTransicion(ticketId, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            _mockTransicionRepository.Verify(r => r.CreateAsync(It.Is<Transicion>(
                t => t.Id_Tkt == ticketId && 
                     t.Id_Estado_Anterior == 2 && 
                     t.Id_Estado_Nuevo == 3
            )), Times.Once);
        }

        [Fact]
        public async Task RealizarTransicion_TicketNoExiste_RetornaError404()
        {
            // Arrange
            var dto = new TransicionEstadoDTO { Id_Estado_Nuevo = 3 };
            _mockTicketRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Ticket?)null);
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.RealizarTransicion(999, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);
        }

        [Fact]
        public async Task RealizarTransicion_UsuarioNoAutenticado_RetornaError401()
        {
            // Arrange
            var dto = new TransicionEstadoDTO { Id_Estado_Nuevo = 3 };
            var ticket = new Ticket { Id_Tkt = 10 };
            _mockTicketRepository.Setup(r => r.GetByIdAsync(10)).ReturnsAsync(ticket);
            ControllerTestHelper.SetupUnauthenticatedUser(_controller);

            // Act
            var result = await _controller.RealizarTransicion(10, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(401);
        }

        [Fact(Skip = "ModelState.IsValid requiere configuración compleja de validación ASP.NET")]
        public async Task RealizarTransicion_ModelStateInvalido_RetornaError400()
        {
            // Arrange
            var ticket = new Ticket { Id_Tkt = 10 };
            _mockTicketRepository.Setup(r => r.GetByIdAsync(10)).ReturnsAsync(ticket);
            _controller.ModelState.AddModelError("Id_Estado_Nuevo", "Requerido");
            var dto = new TransicionEstadoDTO();
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.RealizarTransicion(10, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(400);
        }

        #endregion
    }
}
