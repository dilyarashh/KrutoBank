using AccountsService.Entities.Enums;

namespace AccountsService.DTO;

public class RegisterPushSubscriptionRequest
{
    public PushPlatform Platform { get; set; }
    public PushAudience Audience { get; set; }
    public required string Token { get; set; }
}
