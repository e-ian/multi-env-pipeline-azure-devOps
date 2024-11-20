// src/Interswitch.Api/Controllers/HealthController.cs
using Microsoft.AspNetCore.Mvc;

namespace Interswitch.Api.Controllers;

[ApiController]
[Route("[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new { status = "healthy", timestamp = DateTime.UtcNow });
    }
}