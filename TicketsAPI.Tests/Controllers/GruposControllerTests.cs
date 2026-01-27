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
    public class GruposControllerTests
    {
        private readonly Mock<IBaseRepository<Grupo>> _mockRepository;
        private readonly Mock<ILogger<GruposController>> _mockLogger;
        private readonly GruposController _controller;

        public GruposControllerTests()
        {
            _mockRepository = new Mock<IBaseRepository<Grupo>>();
            _mockLogger = ControllerTestHelper.CreateMockLogger<GruposController>();
            _controller = new GruposController(_mockRepository.Object, _mockLogger.Object);
            
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 1, "Admin");
        }

        #region GET /api/v1/Grupos

        [Fact]
        public async Task ObtenerGrupos_ConDatos_RetornaSuccess200()
        {
            // Arrange
            var grupos = new List<Grupo>
            {
                new Grupo { Id_Grupo = 1, Tipo_Grupo = "Soporte" },
                new Grupo { Id_Grupo = 2, Tipo_Grupo = "Desarrollo" }
            };
            _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(grupos);

            // Act
            var result = await _controller.ObtenerGrupos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<GrupoDTO>>;
            response!.Exitoso.Should().BeTrue();
            response.Datos.Should().HaveCount(2);
            response.Datos![0].Tipo_Grupo.Should().Be("Soporte");
        }

        [Fact]
        public async Task ObtenerGrupos_SinDatos_RetornaListaVacia()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(new List<Grupo>());

            // Act
            var result = await _controller.ObtenerGrupos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<GrupoDTO>>;
            response!.Exitoso.Should().BeTrue();
            response.Datos.Should().BeEmpty();
        }

        [Fact]
        public async Task ObtenerGrupos_CuandoExcepcion_RetornaError500()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetAllAsync()).ThrowsAsync(new Exception("Database error"));

            // Act
            var result = await _controller.ObtenerGrupos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(500);
        }

        #endregion

        #region GET /api/v1/Grupos/{id}

        [Fact]
        public async Task ObtenerGrupoPorId_Existente_RetornaSuccess200()
        {
            // Arrange
            var grupo = new Grupo { Id_Grupo = 1, Tipo_Grupo = "Soporte" };
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(grupo);

            // Act
            var result = await _controller.ObtenerGrupoPorId(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<GrupoDTO>;
            response!.Exitoso.Should().BeTrue();
            response.Datos!.Tipo_Grupo.Should().Be("Soporte");
        }

        [Fact]
        public async Task ObtenerGrupoPorId_NoExistente_RetornaError404()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Grupo?)null);

            // Act
            var result = await _controller.ObtenerGrupoPorId(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);
        }

        #endregion

        #region POST /api/v1/Grupos

        [Fact]
        public async Task CrearGrupo_DatosValidos_RetornaCreated201()
        {
            // Arrange
            var dto = new GrupoDTO { Tipo_Grupo = "Nuevo Grupo" };
            _mockRepository.Setup(r => r.CreateAsync(It.IsAny<Grupo>())).ReturnsAsync(42);

            // Act
            var result = await _controller.CrearGrupo(dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(201);

            _mockRepository.Verify(r => r.CreateAsync(It.Is<Grupo>(
                g => g.Tipo_Grupo == "Nuevo Grupo"
            )), Times.Once);
        }

        [Fact]
        public async Task CrearGrupo_ModelStateInvalido_RetornaError400()
        {
            // Arrange
            _controller.ModelState.AddModelError("Tipo_Grupo", "Requerido");
            var dto = new GrupoDTO();

            // Act
            var result = await _controller.CrearGrupo(dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(400);

            _mockRepository.Verify(r => r.CreateAsync(It.IsAny<Grupo>()), Times.Never);
        }

        #endregion

        #region PUT /api/v1/Grupos/{id}

        [Fact]
        public async Task ActualizarGrupo_Existente_RetornaSuccess200()
        {
            // Arrange
            var grupo = new Grupo { Id_Grupo = 1, Tipo_Grupo = "Old" };
            var dto = new GrupoDTO { Tipo_Grupo = "New" };
            
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(grupo);
            _mockRepository.Setup(r => r.UpdateAsync(It.IsAny<Grupo>())).ReturnsAsync(true);

            // Act
            var result = await _controller.ActualizarGrupo(1, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            _mockRepository.Verify(r => r.UpdateAsync(It.Is<Grupo>(
                g => g.Tipo_Grupo == "New"
            )), Times.Once);
        }

        [Fact]
        public async Task ActualizarGrupo_NoExistente_RetornaError404()
        {
            // Arrange
            var dto = new GrupoDTO { Tipo_Grupo = "Test" };
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Grupo?)null);

            // Act
            var result = await _controller.ActualizarGrupo(999, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);

            _mockRepository.Verify(r => r.UpdateAsync(It.IsAny<Grupo>()), Times.Never);
        }

        #endregion

        #region DELETE /api/v1/Grupos/{id}

        [Fact]
        public async Task EliminarGrupo_Existente_RetornaSuccess200()
        {
            // Arrange
            var grupo = new Grupo { Id_Grupo = 1, Tipo_Grupo = "Test" };
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(grupo);
            _mockRepository.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);

            // Act
            var result = await _controller.EliminarGrupo(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            _mockRepository.Verify(r => r.DeleteAsync(1), Times.Once);
        }

        [Fact]
        public async Task EliminarGrupo_NoExistente_RetornaError404()
        {
            // Arrange
            _mockRepository.Setup(r => r.DeleteAsync(999)).ReturnsAsync(false);

            // Act
            var result = await _controller.EliminarGrupo(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);

            _mockRepository.Verify(r => r.DeleteAsync(999), Times.Once);
        }

        #endregion
    }
}
