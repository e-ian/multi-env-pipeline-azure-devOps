using Microsoft.AspNetCore.Mvc;
using Xunit;
using Interswitch.Api.Controllers;
using Interswitch.Core.Models;

namespace Interswitch.Tests
{
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
            Assert.IsType<OkObjectResult>(result);
        }
    }
}
