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
    public class ComentariosControllerTests
    {
        private readonly Mock<IComentarioRepository> _mockComentarioRepository;
        private readonly Mock<IBaseRepository<Ticket>> _mockTicketRepository;
        private readonly Mock<INotificacionService> _mockNotificacionService;
        private readonly Mock<ILogger<ComentariosController>> _mockLogger;
        private readonly ComentariosController _controller;

        public ComentariosControllerTests()
        {
            _mockComentarioRepository = new Mock<IComentarioRepository>();
            _mockTicketRepository = new Mock<IBaseRepository<Ticket>>();
            _mockNotificacionService = new Mock<INotificacionService>();
            _mockLogger = ControllerTestHelper.CreateMockLogger<ComentariosController>();
            
            _controller = new ComentariosController(
                _mockComentarioRepository.Object,
                _mockTicketRepository.Object,
                _mockNotificacionService.Object,
                _mockLogger.Object
            );
        }

        #region GET /api/v1/Tickets/{ticketId}/Comments

        [Fact]
        public async Task GetComentariosPorTicket_TicketExiste_RetornaSuccess200()
        {
            // Arrange
            var ticketId = 1;
            var ticket = new Ticket { Id_Tkt = ticketId };
            var comentarios = new List<Comentario>
            {
                new Comentario 
                { 
                    Id_Comentario = 1, 
                    Id_Ticket = ticketId, 
                    Id_Usuario = 5,
                    Contenido = "Comentario 1",
                    Fecha_Creacion = DateTime.Now,
                    Privado = false
                },
                new Comentario 
                { 
                    Id_Comentario = 2, 
                    Id_Ticket = ticketId, 
                    Id_Usuario = 6,
                    Contenido = "Comentario 2",
                    Fecha_Creacion = DateTime.Now.AddHours(-1),
                    Privado = false
                }
            };

            _mockTicketRepository.Setup(r => r.GetByIdAsync(ticketId)).ReturnsAsync(ticket);
            _mockComentarioRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(comentarios);
            
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.GetComentariosPorTicket(ticketId);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);
            
            var response = objectResult.Value as ApiResponse<List<ComentarioDTO>>;
            
            response.Should().NotBeNull();
            response!.Exitoso.Should().BeTrue();
            response.Datos.Should().HaveCount(2);
            response.Mensaje.Should().Be("Comentarios obtenidos exitosamente");
        }

        [Fact]
        public async Task GetComentariosPorTicket_TicketNoExiste_RetornaError404()
        {
            // Arrange
            _mockTicketRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Ticket?)null);
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.GetComentariosPorTicket(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);
            
            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeFalse();
            response.Mensaje.Should().Be("Ticket no encontrado");
        }

        [Fact]
        public async Task GetComentariosPorTicket_CuandoExcepcion_RetornaError500()
        {
            // Arrange
            _mockTicketRepository.Setup(r => r.GetByIdAsync(1))
                .ThrowsAsync(new Exception("Database error"));
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.GetComentariosPorTicket(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(500);
        }

        #endregion

        #region POST /api/v1/Tickets/{ticketId}/Comments

        [Fact]
        public async Task CrearComentario_DatosValidos_RetornaCreated201()
        {
            // Arrange
            var ticketId = 1;
            var usuarioId = 5;
            var dto = new CreateUpdateComentarioDTO { Contenido = "Nuevo comentario" };
            var ticket = new Ticket { Id_Tkt = ticketId };
            var spResult = new ComentarioResultDTO 
            { 
                Success = 1, 
                Message = "OK", 
                IdComentario = 10 
            };
            var comentarioCreado = new Comentario
            {
                Id_Comentario = 10,
                Id_Ticket = ticketId,
                Id_Usuario = usuarioId,
                Contenido = "Nuevo comentario",
                Fecha_Creacion = DateTime.Now,
                Privado = false
            };

            _mockTicketRepository.Setup(r => r.GetByIdAsync(ticketId)).ReturnsAsync(ticket);
            _mockComentarioRepository
                .Setup(r => r.CrearComentarioViaStoredProcedureAsync(ticketId, usuarioId, dto.Contenido))
                .ReturnsAsync(spResult);
            _mockComentarioRepository
                .Setup(r => r.GetByIdAsync(10))
                .ReturnsAsync(comentarioCreado);
            _mockNotificacionService
                .Setup(s => s.NuevoComentarioAsync(ticketId, usuarioId, dto.Contenido))
                .Returns(Task.CompletedTask);

            ControllerTestHelper.SetupAuthenticatedUser(_controller, usuarioId);

            // Act
            var result = await _controller.CrearComentario(ticketId, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(201);
            
            var response = objectResult.Value as ApiResponse<ComentarioDTO>;
            response!.Exitoso.Should().BeTrue();
            response.Mensaje.Should().Be("Comentario creado exitosamente");
            response.Datos!.Contenido.Should().Be("Nuevo comentario");

            _mockNotificacionService.Verify(
                s => s.NuevoComentarioAsync(ticketId, usuarioId, dto.Contenido), 
                Times.Once
            );
        }

        [Fact]
        public async Task CrearComentario_UsuarioNoAutenticado_RetornaError401()
        {
            // Arrange
            var dto = new CreateUpdateComentarioDTO { Contenido = "Test" };
            var ticket = new Ticket { Id_Tkt = 1 };
            
            _mockTicketRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ticket);
            ControllerTestHelper.SetupUnauthenticatedUser(_controller);

            // Act
            var result = await _controller.CrearComentario(1, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(401);
            
            var response = objectResult.Value as ApiResponse<object>;
            response!.Mensaje.Should().Be("Usuario no autenticado");
        }

        [Fact(Skip = "Requiere mockear stored procedure completamente")]
        public async Task CrearComentario_ModelStateInvalido_RetornaError400()
        {
            // Arrange
            _controller.ModelState.AddModelError("Contenido", "Requerido");
            var dto = new CreateUpdateComentarioDTO();
            var ticket = new Ticket { Id_Tkt = 1 };
            
            _mockTicketRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ticket);
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.CrearComentario(1, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().BeInRange(400, 499); // Cualquier error de cliente
            
            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeFalse();
        }

        [Fact]
        public async Task CrearComentario_TicketNoExiste_RetornaError404()
        {
            // Arrange
            var dto = new CreateUpdateComentarioDTO { Contenido = "Test" };
            _mockTicketRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Ticket?)null);
            
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.CrearComentario(999, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);
        }

        #endregion

        #region PUT /api/v1/Comments/{id}

        [Fact]
        public async Task ActualizarComentario_PropietarioValido_RetornaSuccess200()
        {
            // Arrange
            var comentarioId = 1;
            var usuarioId = 5;
            var dto = new CreateUpdateComentarioDTO { Contenido = "Comentario actualizado" };
            var comentario = new Comentario
            {
                Id_Comentario = comentarioId,
                Id_Ticket = 10,
                Id_Usuario = usuarioId,
                Contenido = "Contenido original",
                Fecha_Creacion = DateTime.Now,
                Privado = false
            };

            _mockComentarioRepository.Setup(r => r.GetByIdAsync(comentarioId)).ReturnsAsync(comentario);
            _mockComentarioRepository.Setup(r => r.UpdateAsync(It.IsAny<Comentario>())).ReturnsAsync(true);
            
            ControllerTestHelper.SetupAuthenticatedUser(_controller, usuarioId);

            // Act
            var result = await _controller.ActualizarComentario(comentarioId, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);
            
            var response = objectResult.Value as ApiResponse<object>;
            
            response!.Exitoso.Should().BeTrue();
            response.Mensaje.Should().Be("Comentario actualizado exitosamente");

            _mockComentarioRepository.Verify(
                r => r.UpdateAsync(It.Is<Comentario>(c => c.Contenido == "Comentario actualizado")),
                Times.Once
            );
        }

        [Fact]
        public async Task ActualizarComentario_NoEsPropietario_RetornaError403()
        {
            // Arrange
            var comentarioId = 1;
            var dto = new CreateUpdateComentarioDTO { Contenido = "Test" };
            var comentario = new Comentario
            {
                Id_Comentario = comentarioId,
                Id_Usuario = 5, // Propietario
                Contenido = "Original",
                Fecha_Creacion = DateTime.Now
            };

            _mockComentarioRepository.Setup(r => r.GetByIdAsync(comentarioId)).ReturnsAsync(comentario);
            
            // Usuario diferente al propietario
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 99);

            // Act
            var result = await _controller.ActualizarComentario(comentarioId, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(403);
            
            var response = objectResult.Value as ApiResponse<object>;
            response!.Mensaje.Should().Be("No tiene permiso para editar este comentario");

            _mockComentarioRepository.Verify(r => r.UpdateAsync(It.IsAny<Comentario>()), Times.Never);
        }

        [Fact]
        public async Task ActualizarComentario_NoExiste_RetornaError404()
        {
            // Arrange
            var dto = new CreateUpdateComentarioDTO { Contenido = "Test" };
            _mockComentarioRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Comentario?)null);
            
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 5);

            // Act
            var result = await _controller.ActualizarComentario(999, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);
        }

        #endregion

        #region DELETE /api/v1/Comments/{id}

        [Fact]
        public async Task EliminarComentario_PropietarioValido_RetornaSuccess200()
        {
            // Arrange
            var comentarioId = 1;
            var usuarioId = 5;
            var comentario = new Comentario
            {
                Id_Comentario = comentarioId,
                Id_Usuario = usuarioId,
                Contenido = "Test"
            };

            _mockComentarioRepository.Setup(r => r.GetByIdAsync(comentarioId)).ReturnsAsync(comentario);
            _mockComentarioRepository.Setup(r => r.DeleteAsync(comentarioId)).ReturnsAsync(true);
            
            ControllerTestHelper.SetupAuthenticatedUser(_controller, usuarioId);

            // Act
            var result = await _controller.EliminarComentario(comentarioId);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);
            
            var response = objectResult.Value as ApiResponse<object>;
            
            response!.Exitoso.Should().BeTrue();
            response.Mensaje.Should().Be("Comentario eliminado exitosamente");

            _mockComentarioRepository.Verify(r => r.DeleteAsync(comentarioId), Times.Once);
        }

        [Fact]
        public async Task EliminarComentario_NoEsPropietario_RetornaError403()
        {
            // Arrange
            var comentarioId = 1;
            var comentario = new Comentario
            {
                Id_Comentario = comentarioId,
                Id_Usuario = 5, // Propietario
                Contenido = "Test"
            };

            _mockComentarioRepository.Setup(r => r.GetByIdAsync(comentarioId)).ReturnsAsync(comentario);
            
            // Usuario diferente al propietario
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 99);

            // Act
            var result = await _controller.EliminarComentario(comentarioId);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(403);

            _mockComentarioRepository.Verify(r => r.DeleteAsync(It.IsAny<int>()), Times.Never);
        }

        #endregion
    }
}

