namespace AccountsService.DTO;

public class TransferRequest
{
    public Guid FromAccountId { get; set; }
    public string ToPhone { get; set; } = default!;
    public decimal Amount { get; set; }
}