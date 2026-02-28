namespace AccountsService.Entities;

public class UserAccount
{
    public Guid UserId { get; set; }
    public Guid AccountId { get; set; }
    
    public Account Account { get; set; } = null!;
}
