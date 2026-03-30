using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;

namespace AccountsService.Realtime;

public class FirebasePushNotificationSender : IPushNotificationSender
{
    private readonly ILogger<FirebasePushNotificationSender> _logger;
    private readonly FirebaseMessaging? _messaging;

    public FirebasePushNotificationSender(
        IConfiguration configuration,
        IHostEnvironment environment,
        ILogger<FirebasePushNotificationSender> logger)
    {
        _logger = logger;

        var configuredPath = configuration["Firebase:CredentialsPath"];
        if (string.IsNullOrWhiteSpace(configuredPath))
        {
            _logger.LogWarning("Firebase credentials are not configured. Push notifications are disabled.");
            return;
        }

        var credentialsPath = Path.IsPathRooted(configuredPath)
            ? configuredPath
            : Path.GetFullPath(Path.Combine(environment.ContentRootPath, configuredPath));

        if (!File.Exists(credentialsPath))
        {
            _logger.LogWarning(
                "Firebase credentials file was not found at '{CredentialsPath}'. Push notifications are disabled.",
                credentialsPath);
            return;
        }

        var app = FirebaseApp.DefaultInstance ?? FirebaseApp.Create(new AppOptions
        {
            Credential = GoogleCredential.FromFile(credentialsPath)
        });

        _messaging = FirebaseMessaging.GetMessaging(app);
    }

    public async Task SendAsync(
        IEnumerable<string> tokens,
        string title,
        string body,
        IReadOnlyDictionary<string, string> data,
        CancellationToken ct = default)
    {
        if (_messaging is null)
        {
            return;
        }

        var distinctTokens = tokens
            .Where(static x => !string.IsNullOrWhiteSpace(x))
            .Distinct(StringComparer.Ordinal)
            .ToList();

        if (distinctTokens.Count == 0)
        {
            return;
        }

        var message = new MulticastMessage
        {
            Tokens = distinctTokens,
            Notification = new Notification
            {
                Title = title,
                Body = body
            },
            Data = new Dictionary<string, string>(data)
        };

        var result = await _messaging.SendEachForMulticastAsync(message, ct);
        if (result.FailureCount > 0)
        {
            _logger.LogWarning("Firebase push send completed with {FailureCount} failures from {TokenCount} tokens.",
                result.FailureCount,
                distinctTokens.Count);
        }
    }
}
