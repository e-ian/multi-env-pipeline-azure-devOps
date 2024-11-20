// src/Interswitch.Tests/TransactionControllerTests.cs
using Microsoft.AspNetCore.Mvc;
using Xunit;
using Interswitch.Api.Controllers;
using Interswitch.Api.Models;

namespace Interswitch.Tests;

public class TransactionControllerTests
{
    private readonly TransactionController _controller;

    public TransactionControllerTests()
    {
        _controller = new TransactionController();
    }

    [Fact]
    public async Task ProcessTransaction_ValidRequest_ReturnsOkResult()
    {
        // Arrange
        var request = new TransactionRequest
        {
            MerchantId = "TEST001",
            Amount = 1000.00m,
            Currency = "NGN",
            Reference = "REF123"
        };

        // Act
        var result = await _controller.ProcessTransaction(request);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result);
        var value = Assert.IsType<dynamic>(okResult.Value);
        Assert.NotNull(value.transactionId);
        Assert.Equal("processed", value.status);
    }
}
