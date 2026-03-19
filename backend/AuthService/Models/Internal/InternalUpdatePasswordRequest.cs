namespace AuthService.Models.Internal;

public class InternalUpdatePasswordRequest
{
    public required string PasswordHash { get; set; }
}
