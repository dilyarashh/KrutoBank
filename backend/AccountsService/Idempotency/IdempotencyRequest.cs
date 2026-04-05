namespace AccountsService.Idempotency;

public class IdempotencyRequest
{
    public Guid Id { get; set; }
    public required string Key { get; set; }
    public required string UserScope { get; set; }
    public required string Method { get; set; }
    public required string RequestPath { get; set; }
    public required string QueryString { get; set; }
    public required string RequestHash { get; set; }
    public required string State { get; set; }
    public int? ResponseStatusCode { get; set; }
    public string? ResponseContentType { get; set; }
    public string ResponseBody { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}
