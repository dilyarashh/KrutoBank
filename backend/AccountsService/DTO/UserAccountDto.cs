namespace AccountsService.DTO;

public class UserAccountDto
{
    public Guid UserId { get; set; }

    public Guid AccountId { get; set; }
    public string AccountName { get; set; } = null!;
    public decimal Balance { get; set; }
    public bool IsClosed { get; set; }
}