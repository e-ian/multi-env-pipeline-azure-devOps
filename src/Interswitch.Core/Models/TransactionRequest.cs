// src/Interswitch.Api/Models/TransactionRequest.cs
namespace Interswitch.Core.Models;

public class TransactionRequest
{
    public string MerchantId { get; set; } = "";
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "NGN";
    public string Reference { get; set; } = "";
}
