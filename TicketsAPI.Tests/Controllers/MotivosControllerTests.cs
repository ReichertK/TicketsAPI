using FluentAssertions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using TicketsAPI.Controllers;
using TicketsAPI.Models;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Tests.Helpers;

namespace TicketsAPI.Tests.Controllers
{
    public class MotivosControllerTests
    {
        private readonly Mock<IBaseRepository<Motivo>> _mockRepository;
        private readonly Mock<ILogger<MotivosController>> _mockLogger;
        private readonly MotivosController _controller;

        public MotivosControllerTests()
        {
            _mockRepository = new Mock<IBaseRepository<Motivo>>();
            _mockLogger = ControllerTestHelper.CreateMockLogger<MotivosController>();
            _controller = new MotivosController(_mockRepository.Object, _mockLogger.Object);
            
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 1, "Admin");
        }

        #region GET /api/v1/Motivos

        [Fact]
        public async Task ObtenerMotivos_ConDatos_RetornaSuccess200()
        {
            // Arrange
            var motivos = new List<Motivo>
            {
                new Motivo { Id_Motivo = 1, Nombre = "Bug", Categoria = "Incidencia" },
                new Motivo { Id_Motivo = 2, Nombre = "Feature", Categoria = "Mejora" }
            };
            _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(motivos);

            // Act
            var result = await _controller.ObtenerMotivos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<MotivoDTO>>;
            response!.Exitoso.Should().BeTrue();
            response.Datos.Should().HaveCount(2);
            response.Datos![0].Nombre.Should().Be("Bug");
        }

        [Fact]
        public async Task ObtenerMotivos_SinDatos_RetornaListaVacia()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(new List<Motivo>());

            // Act
            var result = await _controller.ObtenerMotivos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<MotivoDTO>>;
            response!.Exitoso.Should().BeTrue();
            response.Datos.Should().BeEmpty();
        }

        [Fact]
        public async Task ObtenerMotivos_CuandoExcepcion_RetornaError500()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetAllAsync()).ThrowsAsync(new Exception("Database error"));

            // Act
            var result = await _controller.ObtenerMotivos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(500);
        }

        #endregion

        #region GET /api/v1/Motivos/{id}

        [Fact]
        public async Task ObtenerMotivoPorId_Existente_RetornaSuccess200()
        {
            // Arrange
            var motivo = new Motivo { Id_Motivo = 1, Nombre = "Bug", Categoria = "Incidencia" };
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(motivo);

            // Act
            var result = await _controller.ObtenerMotivoPorId(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<MotivoDTO>;
            response!.Exitoso.Should().BeTrue();
            response.Datos!.Nombre.Should().Be("Bug");
        }

        [Fact]
        public async Task ObtenerMotivoPorId_NoExistente_RetornaError404()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Motivo?)null);

            // Act
            var result = await _controller.ObtenerMotivoPorId(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);
        }

        #endregion

        #region POST /api/v1/Motivos

        [Fact]
        public async Task CrearMotivo_DatosValidos_RetornaCreated201()
        {
            // Arrange
            var dto = new CreateUpdateMotivoDTO { Nombre = "Nuevo Motivo", Categoria = "Test" };
            _mockRepository.Setup(r => r.CreateAsync(It.IsAny<Motivo>())).ReturnsAsync(42);

            // Act
            var result = await _controller.CrearMotivo(dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(201);

            _mockRepository.Verify(r => r.CreateAsync(It.Is<Motivo>(
                m => m.Nombre == "Nuevo Motivo" && m.Categoria == "Test"
            )), Times.Once);
        }

        [Fact]
        public async Task CrearMotivo_ModelStateInvalido_RetornaError400()
        {
            // Arrange
            _controller.ModelState.AddModelError("Nombre", "Requerido");
            var dto = new CreateUpdateMotivoDTO();

            // Act
            var result = await _controller.CrearMotivo(dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(400);

            _mockRepository.Verify(r => r.CreateAsync(It.IsAny<Motivo>()), Times.Never);
        }

        #endregion

        #region PUT /api/v1/Motivos/{id}

        [Fact]
        public async Task ActualizarMotivo_Existente_RetornaSuccess200()
        {
            // Arrange
            var motivo = new Motivo { Id_Motivo = 1, Nombre = "Old", Categoria = "Old" };
            var dto = new CreateUpdateMotivoDTO { Nombre = "New", Categoria = "New" };
            
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(motivo);
            _mockRepository.Setup(r => r.UpdateAsync(It.IsAny<Motivo>())).ReturnsAsync(true);

            // Act
            var result = await _controller.ActualizarMotivo(1, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            _mockRepository.Verify(r => r.UpdateAsync(It.Is<Motivo>(
                m => m.Nombre == "New" && m.Categoria == "New"
            )), Times.Once);
        }

        [Fact]
        public async Task ActualizarMotivo_NoExistente_RetornaError404()
        {
            // Arrange
            var dto = new CreateUpdateMotivoDTO { Nombre = "Test", Categoria = "Test" };
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Motivo?)null);

            // Act
            var result = await _controller.ActualizarMotivo(999, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);

            _mockRepository.Verify(r => r.UpdateAsync(It.IsAny<Motivo>()), Times.Never);
        }

        #endregion

        #region DELETE /api/v1/Motivos/{id}

        [Fact]
        public async Task EliminarMotivo_Existente_RetornaSuccess200()
        {
            // Arrange
            var motivo = new Motivo { Id_Motivo = 1, Nombre = "Test", Categoria = "Test" };
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(motivo);
            _mockRepository.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);

            // Act
            var result = await _controller.EliminarMotivo(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            _mockRepository.Verify(r => r.DeleteAsync(1), Times.Once);
        }

        [Fact]
        public async Task EliminarMotivo_NoExistente_RetornaError404()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Motivo?)null);

            // Act
            var result = await _controller.EliminarMotivo(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);

            _mockRepository.Verify(r => r.DeleteAsync(It.IsAny<int>()), Times.Never);
        }

        #endregion
    }
}
