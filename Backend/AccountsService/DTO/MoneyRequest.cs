namespace AccountsService.DTO;

public class MoneyRequest
{
    public Guid AccountId { get; set; }
    public decimal Amount { get; set; }
}
