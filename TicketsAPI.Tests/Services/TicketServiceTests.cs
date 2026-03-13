using FluentAssertions;
using Moq;
using TicketsAPI.Config;
using TicketsAPI.Exceptions;
using TicketsAPI.Models.DTOs;
using TicketsAPI.Models.Entities;
using TicketsAPI.Repositories.Interfaces;
using TicketsAPI.Services.Implementations;
using TicketsAPI.Services.Interfaces;

namespace TicketsAPI.Tests.Services
{
    public class TicketServiceTests
    {
        private readonly Mock<ITicketRepository> _mockTicketRepo;
        private readonly Mock<IPrioridadRepository> _mockPrioridadRepo;
        private readonly Mock<IDepartamentoRepository> _mockDepartamentoRepo;
        private readonly Mock<IMotivoRepository> _mockMotivoRepo;
        private readonly Mock<IUsuarioRepository> _mockUsuarioRepo;
        private readonly Mock<IAuthService> _mockAuthService;
        private readonly TicketService _sut;

        public TicketServiceTests()
        {
            _mockTicketRepo = new Mock<ITicketRepository>();
            _mockPrioridadRepo = new Mock<IPrioridadRepository>();
            _mockDepartamentoRepo = new Mock<IDepartamentoRepository>();
            _mockMotivoRepo = new Mock<IMotivoRepository>();
            _mockUsuarioRepo = new Mock<IUsuarioRepository>();
            _mockAuthService = new Mock<IAuthService>();

            _sut = new TicketService(
                _mockTicketRepo.Object,
                _mockPrioridadRepo.Object,
                _mockDepartamentoRepo.Object,
                _mockMotivoRepo.Object,
                _mockUsuarioRepo.Object,
                _mockAuthService.Object);
        }

        #region CreateAsync

        [Fact]
        public async Task CreateAsync_DatosValidos_RetornaIdTicket()
        {
            // Arrange
            var dto = CrearTicketDTO();
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(1, "TKT_CREATE")).ReturnsAsync(true);
            _mockPrioridadRepo.Setup(r => r.ExistsAsync(1)).ReturnsAsync(true);
            _mockDepartamentoRepo.Setup(r => r.ExistsAsync(1)).ReturnsAsync(true);
            _mockUsuarioRepo.Setup(r => r.GetUsuarioContextoAsync(1))
                .ReturnsAsync((1, 1, 1));
            _mockTicketRepo.Setup(r => r.CreateAsync(It.IsAny<Ticket>())).ReturnsAsync(42);

            // Act
            var result = await _sut.CreateAsync(dto, idUsuarioCreador: 1);

            // Assert
            result.Should().Be(42);
            _mockTicketRepo.Verify(r => r.CreateAsync(It.Is<Ticket>(t =>
                t.Contenido == "La impresora no funciona" &&
                t.Id_Estado == TicketStates.Abierto &&
                t.Id_Usuario == 1
            )), Times.Once);
        }

        [Fact]
        public async Task CreateAsync_SinPermiso_LanzaUnauthorizedException()
        {
            // Arrange
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(99, "TKT_CREATE")).ReturnsAsync(false);

            // Act
            var act = () => _sut.CreateAsync(CrearTicketDTO(), idUsuarioCreador: 99);

            // Assert
            await act.Should().ThrowAsync<UnauthorizedException>()
                .WithMessage("*permisos*crear*");
        }

        [Fact]
        public async Task CreateAsync_PrioridadInvalida_LanzaValidationException()
        {
            // Arrange
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(1, "TKT_CREATE")).ReturnsAsync(true);
            _mockPrioridadRepo.Setup(r => r.ExistsAsync(999)).ReturnsAsync(false);

            var dto = CrearTicketDTO();
            dto.Id_Prioridad = 999;

            // Act
            var act = () => _sut.CreateAsync(dto, 1);

            // Assert
            await act.Should().ThrowAsync<ValidationException>()
                .WithMessage("*prioridad*999*no existe*");
        }

        [Fact]
        public async Task CreateAsync_DepartamentoInvalido_LanzaValidationException()
        {
            // Arrange
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(1, "TKT_CREATE")).ReturnsAsync(true);
            _mockPrioridadRepo.Setup(r => r.ExistsAsync(1)).ReturnsAsync(true);
            _mockDepartamentoRepo.Setup(r => r.ExistsAsync(999)).ReturnsAsync(false);

            var dto = CrearTicketDTO();
            dto.Id_Departamento = 999;

            // Act
            var act = () => _sut.CreateAsync(dto, 1);

            // Assert
            await act.Should().ThrowAsync<ValidationException>()
                .WithMessage("*departamento*999*no existe*");
        }

        [Fact]
        public async Task CreateAsync_SinContextoUsuario_LanzaValidationException()
        {
            // Arrange
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(1, "TKT_CREATE")).ReturnsAsync(true);
            _mockPrioridadRepo.Setup(r => r.ExistsAsync(1)).ReturnsAsync(true);
            _mockDepartamentoRepo.Setup(r => r.ExistsAsync(1)).ReturnsAsync(true);
            _mockUsuarioRepo.Setup(r => r.GetUsuarioContextoAsync(1))
                .ReturnsAsync(((int, int, int)?)null);

            // Act
            var act = () => _sut.CreateAsync(CrearTicketDTO(), 1);

            // Assert
            await act.Should().ThrowAsync<ValidationException>()
                .WithMessage("*contexto*");
        }

        #endregion

        #region UpdateAsync

        [Fact]
        public async Task UpdateAsync_TicketCerrado_NoAdmin_LanzaValidationException()
        {
            // Arrange
            var ticket = CrearTicketEntity(id: 1, estado: TicketStates.Cerrado);
            _mockTicketRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ticket);
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(3, "TKT_EDIT_ANY")).ReturnsAsync(false);

            // Act
            var act = () => _sut.UpdateAsync(1, CrearTicketDTO(), idUsuarioActual: 3);

            // Assert
            await act.Should().ThrowAsync<ValidationException>()
                .WithMessage("*Cerrado*Administrador*");
        }

        [Fact]
        public async Task UpdateAsync_TicketNoExiste_LanzaNotFoundException()
        {
            // Arrange
            _mockTicketRepo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Ticket?)null);

            // Act
            var act = () => _sut.UpdateAsync(999, CrearTicketDTO(), 1);

            // Assert
            await act.Should().ThrowAsync<NotFoundException>()
                .WithMessage("*999*no existe*");
        }

        [Fact]
        public async Task UpdateAsync_OperadorSoloEditaSusPropios()
        {
            // Arrange — ticket creado por user 2, asignado a user 2, operador = user 3
            var ticket = CrearTicketEntity(id: 1, estado: TicketStates.Abierto, creador: 2, asignado: 2);
            _mockTicketRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ticket);
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(3, "TKT_EDIT_ANY")).ReturnsAsync(false);
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(3, "TKT_EDIT_ASSIGNED")).ReturnsAsync(true);

            // Act
            var act = () => _sut.UpdateAsync(1, CrearTicketDTO(), idUsuarioActual: 3);

            // Assert
            await act.Should().ThrowAsync<UnauthorizedException>()
                .WithMessage("*creados por ti o asignados*");
        }

        #endregion

        #region CloseAsync

        [Fact]
        public async Task CloseAsync_TicketExistente_DelegaAlSP()
        {
            // Arrange
            var ticket = CrearTicketEntity(id: 5, estado: TicketStates.EnProceso);
            _mockTicketRepo.Setup(r => r.GetByIdAsync(5)).ReturnsAsync(ticket);
            _mockTicketRepo.Setup(r => r.TransicionarEstadoViaStoredProcedureAsync(
                5, TicketStates.Cerrado, 1, It.IsAny<string>(), null, null, null, false))
                .ReturnsAsync(new TransicionResultDTO { Success = 1 });

            // Act
            var result = await _sut.CloseAsync(5, idUsuario: 1, "Resuelto por teléfono");

            // Assert
            result.Should().BeTrue();
        }

        [Fact]
        public async Task CloseAsync_TicketNoExiste_LanzaNotFoundException()
        {
            // Arrange
            _mockTicketRepo.Setup(r => r.GetByIdAsync(999)).ReturnsAsync((Ticket?)null);

            // Act
            var act = () => _sut.CloseAsync(999, 1);

            // Assert
            await act.Should().ThrowAsync<NotFoundException>();
        }

        #endregion

        #region GetFilteredAsync — Vista routing

        [Fact]
        public async Task GetFilteredAsync_VistaMisTickets_UsaSPDedicado()
        {
            // Arrange
            var filtro = new TicketFiltroDTO { Vista = "mis-tickets" };
            var expected = new PaginatedResponse<TicketDTO> { TotalRegistros = 5 };
            _mockTicketRepo.Setup(r => r.GetMisTicketsAsync(1, filtro)).ReturnsAsync(expected);

            // Act
            var result = await _sut.GetFilteredAsync(filtro, 1);

            // Assert
            result.TotalRegistros.Should().Be(5);
            _mockTicketRepo.Verify(r => r.GetMisTicketsAsync(1, filtro), Times.Once);
        }

        [Fact]
        public async Task GetFilteredAsync_VistaTodos_UsaSPDedicado()
        {
            // Arrange
            var filtro = new TicketFiltroDTO { Vista = "todos" };
            var expected = new PaginatedResponse<TicketDTO> { TotalRegistros = 100 };
            _mockTicketRepo.Setup(r => r.GetTodosTicketsAsync(1, filtro)).ReturnsAsync(expected);

            // Act
            var result = await _sut.GetFilteredAsync(filtro, 1);

            // Assert
            result.TotalRegistros.Should().Be(100);
        }

        [Fact]
        public async Task GetFilteredAsync_SinVista_SinPermisoListAll_FiltraPorUsuario()
        {
            // Arrange
            var filtro = new TicketFiltroDTO { Vista = null };
            _mockAuthService.Setup(a => a.ValidarPermisoAsync(3, "TKT_LIST_ALL")).ReturnsAsync(false);
            _mockTicketRepo.Setup(r => r.GetFilteredAdvancedAsync(It.IsAny<TicketFiltroDTO>()))
                .ReturnsAsync(new PaginatedResponse<TicketDTO>());

            // Act
            await _sut.GetFilteredAsync(filtro, 3);

            // Assert — verify that VistaUsuarioId was set
            _mockTicketRepo.Verify(r => r.GetFilteredAdvancedAsync(
                It.Is<TicketFiltroDTO>(f => f.VistaUsuarioId == 3)), Times.Once);
        }

        #endregion

        #region AsignarAsync

        [Fact]
        public async Task AsignarAsync_UsuarioNoExiste_LanzaValidationException()
        {
            // Arrange
            var ticket = CrearTicketEntity(id: 1, estado: TicketStates.Abierto);
            _mockTicketRepo.Setup(r => r.GetByIdAsync(1)).ReturnsAsync(ticket);
            _mockUsuarioRepo.Setup(r => r.ExistsAsync(999)).ReturnsAsync(false);

            // Act
            var act = () => _sut.AsignarAsync(1, idUsuarioAsignado: 999, idUsuarioActor: 1, null);

            // Assert
            await act.Should().ThrowAsync<ValidationException>()
                .WithMessage("*usuario*999*no existe*");
        }

        #endregion

        #region Helpers

        private static CreateUpdateTicketDTO CrearTicketDTO() => new()
        {
            Contenido = "La impresora no funciona",
            Id_Prioridad = 1,
            Id_Departamento = 1
        };

        private static Ticket CrearTicketEntity(int id, int estado, int creador = 1, int? asignado = null) => new()
        {
            Id_Tkt = id,
            Id_Estado = estado,
            Id_Usuario = creador,
            Id_Usuario_Asignado = asignado,
            Id_Empresa = 1,
            Id_Perfil = 1,
            Id_Sucursal = 1,
            Contenido = "Ticket de prueba",
            Habilitado = 1
        };

        #endregion
    }
}
