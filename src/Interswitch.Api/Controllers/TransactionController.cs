// src/Interswitch.Api/Controllers/TransactionController.cs
using Microsoft.AspNetCore.Mvc;

namespace Interswitch.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class TransactionController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> ProcessTransaction([FromBody] TransactionRequest request)
    {
        // Placeholder for actual transaction processing
        await Task.Delay(100); // Simulate processing
        return Ok(new { 
            transactionId = Guid.NewGuid(),
            status = "processed",
            timestamp = DateTime.UtcNow
        });
    }
}
