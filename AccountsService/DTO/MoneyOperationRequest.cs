namespace AccountsService.DTO;

public class MoneyOperationRequest
{
    public Guid AccountId { get; set; }
    public decimal Amount { get; set; }
}
