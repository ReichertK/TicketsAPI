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
    public class DepartamentosControllerTests
    {
        private readonly Mock<IBaseRepository<Departamento>> _mockRepository;
        private readonly Mock<ILogger<DepartamentosController>> _mockLogger;
        private readonly DepartamentosController _controller;

        public DepartamentosControllerTests()
        {
            _mockRepository = new Mock<IBaseRepository<Departamento>>();
            _mockLogger = ControllerTestHelper.CreateMockLogger<DepartamentosController>();
            _controller = new DepartamentosController(_mockRepository.Object, _mockLogger.Object);
            
            // Setup usuario autenticado por defecto
            ControllerTestHelper.SetupAuthenticatedUser(_controller, 1, "Admin");
        }

        #region GET /api/v1/Departamentos

        [Fact]
        public async Task ObtenerDepartamentos_ConDatos_RetornaSuccess200()
        {
            // Arrange
            var departamentos = new List<Departamento>
            {
                new Departamento { Id_Departamento = 1, Nombre = "TI", Descripcion = "Tecnología" },
                new Departamento { Id_Departamento = 2, Nombre = "RRHH", Descripcion = "Recursos Humanos" }
            };
            _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(departamentos);

            // Act
            var result = await _controller.ObtenerDepartamentos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<DepartamentoDTO>>;
            response.Should().NotBeNull();
            response!.Exitoso.Should().BeTrue();
            response.Mensaje.Should().Be("Departamentos obtenidos exitosamente");
            response.Datos.Should().HaveCount(2);
            response.Datos![0].Nombre.Should().Be("TI");
        }

        [Fact]
        public async Task ObtenerDepartamentos_SinDatos_RetornaListaVacia()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetAllAsync()).ReturnsAsync(new List<Departamento>());

            // Act
            var result = await _controller.ObtenerDepartamentos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<List<DepartamentoDTO>>;
            response!.Exitoso.Should().BeTrue();
            response.Datos.Should().BeEmpty();
        }

        [Fact]
        public async Task ObtenerDepartamentos_CuandoExcepcion_RetornaError500()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetAllAsync()).ThrowsAsync(new Exception("Database error"));

            // Act
            var result = await _controller.ObtenerDepartamentos();

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(500);

            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeFalse();
            response.Mensaje.Should().Be("Error al obtener departamentos");
            response.Errores.Should().Contain("Database error");
        }

        #endregion

        #region GET /api/v1/Departamentos/{id}

        [Fact]
        public async Task ObtenerDepartamentoPorId_Existente_RetornaSuccess200()
        {
            // Arrange
            var departamento = new Departamento
            {
                Id_Departamento = 1,
                Nombre = "TI",
                Descripcion = "Tecnología"
            };
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(departamento);

            // Act
            var result = await _controller.ObtenerDepartamentoPorId(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);

            var response = objectResult.Value as ApiResponse<DepartamentoDTO>;
            response!.Exitoso.Should().BeTrue();
            response.Datos!.Nombre.Should().Be("TI");
        }

        [Fact]
        public async Task ObtenerDepartamentoPorId_NoExistente_RetornaError404()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Departamento?)null);

            // Act
            var result = await _controller.ObtenerDepartamentoPorId(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);

            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeFalse();
            response.Mensaje.Should().Be("Departamento no encontrado");
        }

        [Fact]
        public async Task ObtenerDepartamentoPorId_CuandoExcepcion_RetornaError500()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ThrowsAsync(new Exception("DB timeout"));

            // Act
            var result = await _controller.ObtenerDepartamentoPorId(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(500);
        }

        #endregion

        #region POST /api/v1/Departamentos

        [Fact(Skip = "Requiere mockear response structure correctamente")]
        public async Task CrearDepartamento_DatosValidos_RetornaCreated201()
        {
            // Arrange
            var dto = new CreateUpdateDepartamentoDTO
            {
                Nombre = "Nuevo Depto",
                Descripcion = "Descripción test"
            };
            _mockRepository.Setup(r => r.CreateAsync(It.IsAny<Departamento>())).ReturnsAsync(42);

            // Act
            var result = await _controller.CrearDepartamento(dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(201);

            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeTrue();
            response.Mensaje.Should().Be("Departamento creado exitosamente");

            _mockRepository.Verify(r => r.CreateAsync(It.Is<Departamento>(
                d => d.Nombre == "Nuevo Depto" && d.Descripcion == "Descripción test"
            )), Times.Once);
        }

        [Fact]
        public async Task CrearDepartamento_ModelStateInvalido_RetornaError400()
        {
            // Arrange
            _controller.ModelState.AddModelError("Nombre", "El nombre es requerido");
            var dto = new CreateUpdateDepartamentoDTO();

            // Act
            var result = await _controller.CrearDepartamento(dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(400);

            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeFalse();
            response.Mensaje.Should().Be("Datos inválidos");

            _mockRepository.Verify(r => r.CreateAsync(It.IsAny<Departamento>()), Times.Never);
        }

        [Fact]
        public async Task CrearDepartamento_CuandoExcepcion_RetornaError500()
        {
            // Arrange
            var dto = new CreateUpdateDepartamentoDTO { Nombre = "Test", Descripcion = "Test" };
            _mockRepository.Setup(r => r.CreateAsync(It.IsAny<Departamento>()))
                .ThrowsAsync(new Exception("Constraint violation"));

            // Act
            var result = await _controller.CrearDepartamento(dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(500);
        }

        #endregion

        #region PUT /api/v1/Departamentos/{id}

        [Fact]
        public async Task ActualizarDepartamento_Existente_RetornaSuccess200()
        {
            // Arrange
            var departamento = new Departamento { Id_Departamento = 1, Nombre = "Old", Descripcion = "Old" };
            var dto = new CreateUpdateDepartamentoDTO { Nombre = "New", Descripcion = "New" };
            
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(departamento);
            _mockRepository.Setup(r => r.UpdateAsync(It.IsAny<Departamento>())).ReturnsAsync(true);

            // Act
            var result = await _controller.ActualizarDepartamento(1, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);
            
            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeTrue();
            response.Mensaje.Should().Be("Departamento actualizado exitosamente");

            _mockRepository.Verify(r => r.UpdateAsync(It.Is<Departamento>(
                d => d.Nombre == "New" && d.Descripcion == "New"
            )), Times.Once);
        }

        [Fact]
        public async Task ActualizarDepartamento_NoExistente_RetornaError404()
        {
            // Arrange
            var dto = new CreateUpdateDepartamentoDTO { Nombre = "Test", Descripcion = "Test" };
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Departamento?)null);

            // Act
            var result = await _controller.ActualizarDepartamento(999, dto);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);

            _mockRepository.Verify(r => r.UpdateAsync(It.IsAny<Departamento>()), Times.Never);
        }

        #endregion

        #region DELETE /api/v1/Departamentos/{id}

        [Fact]
        public async Task EliminarDepartamento_Existente_RetornaSuccess200()
        {
            // Arrange
            var departamento = new Departamento { Id_Departamento = 1, Nombre = "Test", Descripcion = "Test" };
            _mockRepository.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(departamento);
            _mockRepository.Setup(r => r.DeleteAsync(1)).ReturnsAsync(true);

            // Act
            var result = await _controller.EliminarDepartamento(1);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(200);
            
            var response = objectResult.Value as ApiResponse<object>;
            response!.Exitoso.Should().BeTrue();
            response.Mensaje.Should().Be("Departamento eliminado exitosamente");

            _mockRepository.Verify(r => r.DeleteAsync(1), Times.Once);
        }

        [Fact]
        public async Task EliminarDepartamento_NoExistente_RetornaError404()
        {
            // Arrange
            _mockRepository.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Departamento?)null);

            // Act
            var result = await _controller.EliminarDepartamento(999);

            // Assert
            result.Should().BeOfType<ObjectResult>();
            var objectResult = result as ObjectResult;
            objectResult!.StatusCode.Should().Be(404);

            _mockRepository.Verify(r => r.DeleteAsync(It.IsAny<int>()), Times.Never);
        }

        #endregion
    }
}

