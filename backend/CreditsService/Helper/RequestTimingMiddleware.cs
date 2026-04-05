using System.Diagnostics;

namespace CreditsService.Helper
{
    public class RequestTimingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<RequestTimingMiddleware> _logger;

        public RequestTimingMiddleware(
            RequestDelegate next,
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            ILogger<RequestTimingMiddleware> logger)
        {
            _next = next;
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            if (context.Request.Path.StartsWithSegments("/swagger"))
            {
                await _next(context);
                return;
            }

            var stopwatch = Stopwatch.StartNew();

            await _next(context);

            stopwatch.Stop();

            var serviceName = _configuration["Monitoring:ServiceName"] ?? "UnknownService";
            var traceId = context.Items["TraceId"]?.ToString();
            var spanId = context.Items["SpanId"]?.ToString();

            var payload = new
            {
                ServiceName = serviceName,
                Method = context.Request.Method,
                Path = context.Request.Path.ToString(),
                StatusCode = context.Response.StatusCode,
                DurationMs = stopwatch.ElapsedMilliseconds,
                TraceId = traceId,
                SpanId = spanId,
                CreatedAt = DateTime.UtcNow
            };

            try
            {
                var client = _httpClientFactory.CreateClient("Monitoring");
                await client.PostAsJsonAsync("/api/monitoring/requests", payload);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Не удалось отправить request log в MonitoringService");
            }
        }
    }
}
