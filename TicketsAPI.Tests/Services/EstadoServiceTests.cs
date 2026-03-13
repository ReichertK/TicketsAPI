using FluentAssertions;
using Moq;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Implementations;

namespace TicketsAPI.Tests.Services
{
    public class EstadoServiceTests
    {
        private readonly Mock<IEstadoRepository> _mockEstadoRepo;
        private readonly Mock<IPoliticaTransicionRepository> _mockPoliticaRepo;
        private readonly EstadoService _sut;

        public EstadoServiceTests()
        {
            _mockEstadoRepo = new Mock<IEstadoRepository>();
            _mockPoliticaRepo = new Mock<IPoliticaTransicionRepository>();
            _sut = new EstadoService(_mockEstadoRepo.Object, _mockPoliticaRepo.Object);
        }

        #region GetAllAsync

        [Fact]
        public async Task GetAllAsync_RetornaEstadosMapeados()
        {
            // Arrange
            _mockEstadoRepo.Setup(r => r.GetAllActiveAsync()).ReturnsAsync(new List<Estado>
            {
                new() { Id_Estado = 1, Nombre_Estado = "Abierto", Color = "#28a745", Orden = 1, Activo = true },
                new() { Id_Estado = 2, Nombre_Estado = "En Proceso", Color = "#007bff", Orden = 2, Activo = true },
            });

            // Act
            var result = await _sut.GetAllAsync();

            // Assert
            result.Should().HaveCount(2);
            result[0].Nombre_Estado.Should().Be("Abierto");
            result[1].Color.Should().Be("#007bff");
        }

        #endregion

        #region GetByIdAsync

        [Fact]
        public async Task GetByIdAsync_EstadoExiste_RetornaDTO()
        {
            // Arrange
            _mockEstadoRepo.Setup(r => r.GetByIdAsync(3)).ReturnsAsync(
                new Estado { Id_Estado = 3, Nombre_Estado = "Cerrado", Color = "#dc3545", Orden = 3, Activo = true });

            // Act
            var result = await _sut.GetByIdAsync(3);

            // Assert
            result.Should().NotBeNull();
            result!.Nombre_Estado.Should().Be("Cerrado");
        }

        [Fact]
        public async Task GetByIdAsync_NoExiste_RetornaNull()
        {
            _mockEstadoRepo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Estado?)null);

            var result = await _sut.GetByIdAsync(999);

            result.Should().BeNull();
        }

        #endregion

        #region ValidarTransicionAsync — State Machine

        [Theory]
        [InlineData(1, 2, 10, true)]   // Abierto → En Proceso (Admin) ✓
        [InlineData(2, 3, 1, true)]    // En Proceso → Cerrado (Supervisor) ✓
        [InlineData(3, 7, 10, true)]   // Cerrado → Reabierto (Admin) ✓
        [InlineData(1, 3, 3, false)]   // Abierto → Cerrado (Operador) ✗ (must go through En Proceso)
        [InlineData(6, 1, 10, false)]  // Resuelto → Abierto ✗ (invalid transition)
        public async Task ValidarTransicion_ReglasDeEstado(int from, int to, int rol, bool expected)
        {
            // Arrange
            if (expected)
            {
                _mockPoliticaRepo.Setup(p => p.GetTransicionAsync(from, to, rol))
                    .ReturnsAsync(new PoliticaTransicion { Permitida = true });
            }
            else
            {
                _mockPoliticaRepo.Setup(p => p.GetTransicionAsync(from, to, rol))
                    .ReturnsAsync((PoliticaTransicion?)null);
            }

            // Act
            var result = await _sut.ValidarTransicionAsync(from, to, rol);

            // Assert
            result.Should().Be(expected);
        }

        [Fact]
        public async Task ValidarTransicion_PolicyExistePeroDenegada_RetornaFalse()
        {
            // Arrange — rule exists but Permitida = false
            _mockPoliticaRepo.Setup(p => p.GetTransicionAsync(1, 6, 3))
                .ReturnsAsync(new PoliticaTransicion { Permitida = false });

            // Act
            var result = await _sut.ValidarTransicionAsync(1, 6, 3);

            // Assert
            result.Should().BeFalse();
        }

        #endregion

        #region GetTransicionesPermitidas

        [Fact]
        public async Task GetTransicionesPermitidas_RetornaTransicionesMapeadas()
        {
            // Arrange — From "Abierto" (1), Supervisor (1) can go to "En Proceso" (2)
            _mockPoliticaRepo.Setup(p => p.GetPosiblesTransicionesAsync(1, 1))
                .ReturnsAsync(new List<PoliticaTransicion>
                {
                    new()
                    {
                        Id_Estado_Destino = 2,
                        Permiso_Requerido = "TKT_ASSIGN",
                        Requiere_Propietario = false,
                        Requiere_Aprobacion = false,
                        EstadoDestino = new Estado { Nombre_Estado = "En Proceso", Color = "#007bff" }
                    }
                });

            // Act
            var result = await _sut.GetTransicionesPermitidas(1, 1);

            // Assert
            result.Should().HaveCount(1);
            result[0].Id_Estado_Destino.Should().Be(2);
            result[0].Nombre_Estado.Should().Be("En Proceso");
            result[0].Permiso_Requerido.Should().Be("TKT_ASSIGN");
        }

        [Fact]
        public async Task GetTransicionesPermitidas_EstadoFinal_RetornaListaVacia()
        {
            // Arrange — "Resuelto" (6) with no further transitions for Operador
            _mockPoliticaRepo.Setup(p => p.GetPosiblesTransicionesAsync(6, 3))
                .ReturnsAsync(new List<PoliticaTransicion>());

            // Act
            var result = await _sut.GetTransicionesPermitidas(6, 3);

            // Assert
            result.Should().BeEmpty();
        }

        #endregion
    }
}
