using AccountsService.Entities.Enums;

namespace AccountsService.Entities;

public class PushSubscription
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public PushPlatform Platform { get; set; }
    public PushAudience Audience { get; set; }
    public required string Token { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
