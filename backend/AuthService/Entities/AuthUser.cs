namespace AuthService.Entities;

public class AuthUser
{
    public Guid Id { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
    public required string MiddleName { get; set; }
    public required string Phone { get; set; }
    public string? Email { get; set; }
    public DateOnly Birthday { get; set; }
    public required string HashPassword { get; set; }
    public UserRole Role { get; set; }
    public bool IsBlocked { get; set; }
    public DateTime Created { get; set; }
    public DateTime? Updated { get; set; }
}
