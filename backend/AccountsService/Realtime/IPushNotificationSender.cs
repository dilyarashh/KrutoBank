namespace AccountsService.Realtime;

public interface IPushNotificationSender
{
    Task SendAsync(IEnumerable<string> tokens, string title, string body, IReadOnlyDictionary<string, string> data, CancellationToken ct = default);
}
