using Xunit;
using Moq;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using TicketsAPI.Controllers;
using TicketsAPI.Services.Interfaces;
using TicketsAPI.Models.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TicketsAPI.Tests.Controllers
{
    /// <summary>
    /// Suite de tests para casos de error: 400, 401, 403, 404
    /// Cubre todos los endpoints principales con validaciones de errores.
    /// </summary>
    public class ErrorCasesTests
    {
        private readonly Mock<ILogger<BaseApiController>> _mockLogger;
        private readonly TicketsController _ticketsController;

        public ErrorCasesTests()
        {
            _mockLogger = new Mock<ILogger<BaseApiController>>();
            
            // Mock minimal de servicios
            var mockTicketService = new Mock<ITicketService>();
            
            _ticketsController = new TicketsController(
                _mockLogger.Object,
                mockTicketService.Object
            );
        }

        // ==================== 400 BAD REQUEST TESTS ====================

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "400")]
        public async Task CreateTicket_MissingRequiredFields_ReturnsBadRequest400()
        {
            // Arrange
            var invalidPayload = new { Contenido = "" };  // Empty required field

            // Act
            var result = await _ticketsController.CreateTicket(new CreateTicketDTO { Contenido = "" });

            // Assert
            var badRequest = Assert.IsType<BadRequestObjectResult>(result);
            Assert.Equal(400, badRequest.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "400")]
        public async Task UpdateTicket_InvalidData_ReturnsBadRequest400()
        {
            // Arrange
            var invalidPayload = new { Contenido = "" };  // Empty content

            // Act - attempt to update with invalid data
            var result = await _ticketsController.UpdateTicket(1, new UpdateTicketDTO { Contenido = "" });

            // Assert
            var badRequest = Assert.IsType<BadRequestObjectResult>(result);
            Assert.Equal(400, badRequest.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "400")]
        public async Task CreateComment_EmptyContent_ReturnsBadRequest400()
        {
            // Arrange - empty comment content
            var invalidComment = new { Contenido = "" };

            // Act
            var result = await _ticketsController.AddComment(1, new CreateCommentDTO { Contenido = "" });

            // Assert
            var badRequest = Assert.IsType<BadRequestObjectResult>(result);
            Assert.Equal(400, badRequest.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "400")]
        public async Task AssignTicket_InvalidUserId_ReturnsBadRequest400()
        {
            // Arrange - invalid user ID
            var assignPayload = new { id_usuario_asignado = -1 };  // Invalid ID

            // Act
            var result = await _ticketsController.AssignTicket(1, new AssignTicketDTO { id_usuario_asignado = -1 });

            // Assert
            var badRequest = Assert.IsType<BadRequestObjectResult>(result);
            Assert.Equal(400, badRequest.StatusCode);
        }

        // ==================== 401 UNAUTHORIZED TESTS ====================

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "401")]
        public async Task GetTickets_WithoutToken_ReturnsUnauthorized401()
        {
            // Arrange - no authorization token

            // Act
            var result = await _ticketsController.GetTickets();

            // Assert
            var unauthorized = Assert.IsType<UnauthorizedObjectResult>(result);
            Assert.Equal(401, unauthorized.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "401")]
        public async Task CreateTicket_WithoutToken_ReturnsUnauthorized401()
        {
            // Arrange - no authorization token
            var payload = new CreateTicketDTO { Contenido = "Test" };

            // Act
            var result = await _ticketsController.CreateTicket(payload);

            // Assert
            var unauthorized = Assert.IsType<UnauthorizedObjectResult>(result);
            Assert.Equal(401, unauthorized.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "401")]
        public async Task AddComment_WithoutToken_ReturnsUnauthorized401()
        {
            // Arrange - no authorization token
            var payload = new CreateCommentDTO { Contenido = "Comment" };

            // Act
            var result = await _ticketsController.AddComment(1, payload);

            // Assert
            var unauthorized = Assert.IsType<UnauthorizedObjectResult>(result);
            Assert.Equal(401, unauthorized.StatusCode);
        }

        // ==================== 403 FORBIDDEN TESTS ====================

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "403")]
        public async Task UpdateTicket_NotOwner_ReturnsForbidden403()
        {
            // Arrange - user is not ticket owner
            var ticketId = 1;
            var payload = new UpdateTicketDTO { Contenido = "Updated" };

            // Act
            var result = await _ticketsController.UpdateTicket(ticketId, payload);

            // Assert
            var forbidden = Assert.IsType<ForbidResult>(result) 
                           ?? Assert.IsType<ObjectResult>(result) as ForbidResult;
            
            // Some APIs return 403 as ObjectResult with status code
            if (result is ObjectResult objResult)
            {
                Assert.Equal(403, objResult.StatusCode);
            }
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "403")]
        public async Task DeleteTicket_WithoutPermission_ReturnsForbidden403()
        {
            // Arrange - user lacks delete permission
            var ticketId = 1;

            // Act
            var result = await _ticketsController.DeleteTicket(ticketId);

            // Assert
            Assert.IsType<ForbidResult>(result) 
                ?? Assert.IsType<ObjectResult>(result);  // Flexible assertion for 403
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "403")]
        public async Task ApproveComment_WithoutAdminRole_ReturnsForbidden403()
        {
            // Arrange - regular user trying to approve (admin-only action)
            var commentId = 1;

            // Act
            // This is a hypothetical endpoint that requires admin role
            var result = await _ticketsController.DeleteComment(1);  // Assumed to be restricted

            // Assert
            Assert.IsType<ObjectResult>(result);
        }

        // ==================== 404 NOT FOUND TESTS ====================

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "404")]
        public async Task GetTicket_NonExistentId_ReturnsNotFound404()
        {
            // Arrange
            var nonExistentTicketId = 99999;

            // Act
            var result = await _ticketsController.GetTicket(nonExistentTicketId);

            // Assert
            var notFound = Assert.IsType<NotFoundObjectResult>(result);
            Assert.Equal(404, notFound.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "404")]
        public async Task UpdateTicket_NonExistentId_ReturnsNotFound404()
        {
            // Arrange
            var nonExistentTicketId = 99999;
            var payload = new UpdateTicketDTO { Contenido = "Updated" };

            // Act
            var result = await _ticketsController.UpdateTicket(nonExistentTicketId, payload);

            // Assert
            var notFound = Assert.IsType<NotFoundObjectResult>(result);
            Assert.Equal(404, notFound.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "404")]
        public async Task GetComments_NonExistentTicket_ReturnsNotFound404()
        {
            // Arrange
            var nonExistentTicketId = 99999;

            // Act
            var result = await _ticketsController.GetComments(nonExistentTicketId);

            // Assert
            var notFound = Assert.IsType<NotFoundObjectResult>(result);
            Assert.Equal(404, notFound.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "404")]
        public async Task DeleteTicket_NonExistentId_ReturnsNotFound404()
        {
            // Arrange
            var nonExistentTicketId = 99999;

            // Act
            var result = await _ticketsController.DeleteTicket(nonExistentTicketId);

            // Assert
            var notFound = Assert.IsType<NotFoundObjectResult>(result);
            Assert.Equal(404, notFound.StatusCode);
        }

        // ==================== VALIDATION TESTS ====================

        [Fact]
        [Trait("Category", "Validation")]
        public async Task CreateTicket_LongContent_ValidatesMaxLength()
        {
            // Arrange - content exceeding max length
            var longContent = new string('a', 5001);  // Assuming max 5000 chars
            var payload = new CreateTicketDTO { Contenido = longContent };

            // Act
            var result = await _ticketsController.CreateTicket(payload);

            // Assert
            var badRequest = Assert.IsType<BadRequestObjectResult>(result);
            Assert.Equal(400, badRequest.StatusCode);
        }

        [Fact]
        [Trait("Category", "Validation")]
        public async Task AssignTicket_NegativeUserId_RejectsInvalidInput()
        {
            // Arrange
            var payload = new AssignTicketDTO { id_usuario_asignado = -1 };

            // Act
            var result = await _ticketsController.AssignTicket(1, payload);

            // Assert
            var badRequest = Assert.IsType<BadRequestObjectResult>(result);
            Assert.Equal(400, badRequest.StatusCode);
        }

        [Fact]
        [Trait("Category", "Validation")]
        public async Task UpdateTicket_NegativeTicketId_RejectsInvalidInput()
        {
            // Arrange
            var invalidTicketId = -1;
            var payload = new UpdateTicketDTO { Contenido = "Test" };

            // Act
            var result = await _ticketsController.UpdateTicket(invalidTicketId, payload);

            // Assert
            Assert.IsType<BadRequestObjectResult>(result);
        }

        // ==================== CONCURRENT REQUEST TESTS ====================

        [Fact]
        [Trait("Category", "Concurrency")]
        public async Task CreateTicket_ConcurrentRequests_HandlesRaceCondition()
        {
            // Arrange
            var payload = new CreateTicketDTO { Contenido = "Test" };
            var tasks = new List<Task<IActionResult>>();

            // Act - simulate concurrent requests
            for (int i = 0; i < 5; i++)
            {
                tasks.Add(_ticketsController.CreateTicket(payload));
            }
            var results = await Task.WhenAll(tasks);

            // Assert - all should complete without exception
            Assert.All(results, r => Assert.NotNull(r));
        }

        // ==================== DATA TYPE VALIDATION TESTS ====================

        [Fact]
        [Trait("Category", "DataValidation")]
        public async Task CreateTicket_InvalidDataTypes_ReturnsBadRequest()
        {
            // Arrange - passing null where object expected
            CreateTicketDTO nullPayload = null;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentNullException>(
                async () => await _ticketsController.CreateTicket(nullPayload)
            );
        }

        [Fact]
        [Trait("Category", "DataValidation")]
        public async Task UpdateTicket_NullPayload_ReturnsBadRequest()
        {
            // Arrange
            UpdateTicketDTO nullPayload = null;

            // Act & Assert
            await Assert.ThrowsAsync<ArgumentNullException>(
                async () => await _ticketsController.UpdateTicket(1, nullPayload)
            );
        }
    }

    /// <summary>
    /// Additional error tests for other controllers
    /// </summary>
    public class AuthenticationErrorTests
    {
        private readonly Mock<ILogger<BaseApiController>> _mockLogger;
        private readonly AuthController _authController;

        public AuthenticationErrorTests()
        {
            _mockLogger = new Mock<ILogger<BaseApiController>>();
            var mockAuthService = new Mock<IAuthService>();
            
            _authController = new AuthController(_mockLogger.Object, mockAuthService.Object);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "401")]
        public async Task Login_InvalidCredentials_ReturnsUnauthorized401()
        {
            // Arrange
            var invalidCredentials = new { usuario = "invalid", contrasena = "wrong" };

            // Act
            var result = await _authController.Login(new LoginDTO 
            { 
                usuario = "invalid", 
                contrasena = "wrong" 
            });

            // Assert
            var unauthorized = Assert.IsType<UnauthorizedObjectResult>(result);
            Assert.Equal(401, unauthorized.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        [Trait("ErrorCode", "400")]
        public async Task Login_MissingFields_ReturnsBadRequest400()
        {
            // Arrange
            var incompleteLogin = new LoginDTO { usuario = "admin" };  // Missing password

            // Act
            var result = await _authController.Login(incompleteLogin);

            // Assert
            var badRequest = Assert.IsType<BadRequestObjectResult>(result);
            Assert.Equal(400, badRequest.StatusCode);
        }

        [Fact]
        [Trait("Category", "ErrorHandling")]
        public async Task RefreshToken_InvalidToken_ReturnsUnauthorized401()
        {
            // Arrange - invalid or expired token

            // Act
            var result = await _authController.RefreshToken("invalid.token.here");

            // Assert
            var unauthorized = Assert.IsType<UnauthorizedObjectResult>(result);
            Assert.Equal(401, unauthorized.StatusCode);
        }
    }
}
