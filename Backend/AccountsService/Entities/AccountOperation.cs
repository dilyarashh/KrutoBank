using AccountsService.Entities.Enums;

namespace AccountsService.Entities;

public class AccountOperation
{
    public Guid Id { get; set; }
    public Guid AccountId { get; set; }
    public DateTime CreatedAt { get; set; }
    public required OperationType Type { get; set; } 
    public decimal Amount { get; set; }
    public Account Account { get; set; } = null!;
}
