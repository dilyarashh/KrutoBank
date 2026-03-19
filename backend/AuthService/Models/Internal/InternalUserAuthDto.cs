namespace AuthService.Models.Internal;

public class InternalUserAuthDto
{
    public Guid Id { get; set; }
    public required string Phone { get; set; }
    public required string HashPassword { get; set; }
    public required string Role { get; set; }
    public bool IsBlocked { get; set; }
}
