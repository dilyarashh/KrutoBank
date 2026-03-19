namespace UsersService.DTOs.Internal;

public class InternalUpdatePasswordRequest
{
    public required string PasswordHash { get; set; }
}
