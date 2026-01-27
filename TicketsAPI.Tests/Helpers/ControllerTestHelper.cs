using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Moq;
using TicketsAPI.Controllers;

namespace TicketsAPI.Tests.Helpers
{
    /// <summary>
    /// Helper class para crear contextos de usuario autenticado en tests
    /// </summary>
    public static class ControllerTestHelper
    {
        /// <summary>
        /// Configura un controller con usuario autenticado
        /// </summary>
        public static void SetupAuthenticatedUser(
            ControllerBase controller, 
            int userId, 
            string? role = null)
        {
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
                new Claim("sub", userId.ToString())
            };

            if (!string.IsNullOrEmpty(role))
            {
                claims.Add(new Claim("role", role));
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var identity = new ClaimsIdentity(claims, "TestAuth");
            var claimsPrincipal = new ClaimsPrincipal(identity);

            controller.ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext
                {
                    User = claimsPrincipal
                }
            };
        }

        /// <summary>
        /// Configura un controller sin usuario autenticado
        /// </summary>
        public static void SetupUnauthenticatedUser(ControllerBase controller)
        {
            controller.ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext
                {
                    User = new ClaimsPrincipal(new ClaimsIdentity())
                }
            };
        }

        /// <summary>
        /// Crea un mock de ILogger genérico
        /// </summary>
        public static Mock<ILogger<T>> CreateMockLogger<T>()
        {
            return new Mock<ILogger<T>>();
        }

        /// <summary>
        /// Verifica que se haya llamado al logger con error
        /// </summary>
        public static void VerifyLogError<T>(Mock<ILogger<T>> mockLogger)
        {
            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Error,
                    It.IsAny<EventId>(),
                    It.Is<It.IsAnyType>((v, t) => true),
                    It.IsAny<Exception>(),
                    It.Is<Func<It.IsAnyType, Exception?, string>>((v, t) => true)),
                Times.AtLeastOnce);
        }

        /// <summary>
        /// Verifica que se haya llamado al logger con warning
        /// </summary>
        public static void VerifyLogWarning<T>(Mock<ILogger<T>> mockLogger)
        {
            mockLogger.Verify(
                x => x.Log(
                    LogLevel.Warning,
                    It.IsAny<EventId>(),
                    It.Is<It.IsAnyType>((v, t) => true),
                    It.IsAny<Exception>(),
                    It.Is<Func<It.IsAnyType, Exception?, string>>((v, t) => true)),
                Times.AtLeastOnce);
        }
    }
}
