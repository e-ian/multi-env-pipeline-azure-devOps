using Microsoft.AspNetCore.Mvc;
using Xunit;
using Interswitch.Api.Controllers;

namespace Interswitch.Tests
{
    public class HealthControllerTests
    {
        [Fact]
        public void Get_ReturnsOkResult()
        {
            // Arrange
            var controller = new HealthController();

            // Act
            var result = controller.Get();

            // Assert
            Assert.IsType<OkObjectResult>(result);
        }
    }
}
