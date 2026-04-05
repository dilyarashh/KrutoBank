using System.Net;

namespace AuthService.Resilience;

public class ServiceCallResilienceHandler(
    string clientName,
    ServiceCallCircuitState circuitState,
    ILogger<ServiceCallResilienceHandler> logger) : DelegatingHandler
{
    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        if (circuitState.IsOpen(out var retryAfter))
        {
            throw new HttpRequestException(
                $"Circuit breaker is open for {clientName}. Retry after {Math.Ceiling(retryAfter.TotalSeconds)} seconds.");
        }

        var body = request.Content is null ? null : await request.Content.ReadAsByteArrayAsync(cancellationToken);
        var contentHeaders = request.Content?.Headers.ToList();

        for (var attempt = 1; attempt <= 3; attempt++)
        {
            using var clonedRequest = CloneRequest(request, body, contentHeaders);

            try
            {
                var response = await base.SendAsync(clonedRequest, cancellationToken);

                if (!IsTransientFailure(response))
                {
                    circuitState.RecordSuccess();
                    return response;
                }

                circuitState.RecordFailure();

                if (attempt == 3)
                {
                    return response;
                }

                response.Dispose();
                await DelayBeforeRetryAsync(attempt, cancellationToken);
            }
            catch (HttpRequestException ex) when (attempt < 3)
            {
                circuitState.RecordFailure();
                logger.LogWarning(ex, "Transient HTTP error when calling {ClientName}. Retry attempt {Attempt}.", clientName, attempt);
                await DelayBeforeRetryAsync(attempt, cancellationToken);
            }
            catch (TaskCanceledException ex) when (!cancellationToken.IsCancellationRequested && attempt < 3)
            {
                circuitState.RecordFailure();
                logger.LogWarning(ex, "Timeout when calling {ClientName}. Retry attempt {Attempt}.", clientName, attempt);
                await DelayBeforeRetryAsync(attempt, cancellationToken);
            }
            catch
            {
                circuitState.RecordFailure();
                throw;
            }
        }

        throw new InvalidOperationException("Retry loop exited unexpectedly.");
    }

    private static bool IsTransientFailure(HttpResponseMessage response)
    {
        return response.StatusCode == HttpStatusCode.RequestTimeout ||
               (int)response.StatusCode >= 500;
    }

    private static Task DelayBeforeRetryAsync(int attempt, CancellationToken cancellationToken)
    {
        var delay = TimeSpan.FromMilliseconds(200 * attempt);
        return Task.Delay(delay, cancellationToken);
    }

    private static HttpRequestMessage CloneRequest(
        HttpRequestMessage request,
        byte[]? body,
        List<KeyValuePair<string, IEnumerable<string>>>? contentHeaders)
    {
        var clone = new HttpRequestMessage(request.Method, request.RequestUri)
        {
            Version = request.Version,
            VersionPolicy = request.VersionPolicy
        };

        foreach (var header in request.Headers)
        {
            clone.Headers.TryAddWithoutValidation(header.Key, header.Value);
        }

        if (body is not null)
        {
            var content = new ByteArrayContent(body);
            if (contentHeaders is not null)
            {
                foreach (var header in contentHeaders)
                {
                    content.Headers.TryAddWithoutValidation(header.Key, header.Value);
                }
            }

            clone.Content = content;
        }

        foreach (var option in request.Options)
        {
            clone.Options.Set(new HttpRequestOptionsKey<object?>(option.Key), option.Value);
        }

        return clone;
    }
}
