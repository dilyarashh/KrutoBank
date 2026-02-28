namespace AccountsService.Entities;

public class Account
{
    public Guid Id { get; set; }
    public required string Name { get; set; }
    public decimal Balance { get; set; }
    public required DateTime OpenedAt { get; set; }
    public bool IsClosed { get; set; }
    public DateTime? ClosedAt { get; set; }
    public ICollection<AccountOperation> Operations { get; set; } = new List<AccountOperation>();
}
