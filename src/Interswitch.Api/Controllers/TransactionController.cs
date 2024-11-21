// src/Interswitch.Api/Controllers/TransactionController.cs
using Microsoft.AspNetCore.Mvc;
using Interswitch.Core.Models;

namespace Interswitch.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class TransactionController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> ProcessTransaction(TransactionRequest request)
    {
        var response = new 
        {
            transactionId = Guid.NewGuid(),
            status = "processed"
        };
        return Ok(response);
    }
}
