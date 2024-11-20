// src/Interswitch.Tests/HealthControllerTests.cs
using Microsoft.AspNetCore.Mvc;
using Xunit;
using Interswitch.Api.Controllers;

namespace Interswitch.Tests;

public class HealthControllerTests
{
    private readonly HealthController _controller;

    public HealthControllerTests()
    {
        _controller = new HealthController();
    }

    [Fact]
    public void Get_ReturnsOkResult()
    {
        // Act
        var result = _controller.Get();

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var value = Assert.IsType<dynamic>(okResult.Value);
        Assert.Equal("healthy", value.status);
    }
}
