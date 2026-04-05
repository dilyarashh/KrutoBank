namespace UserSettingsService.Errors.Exceptions;

using UserSettingsService.Errors;

public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public ExceptionMiddleware(
        RequestDelegate next,
        ILogger<ExceptionMiddleware> logger,
        IHttpClientFactory httpClientFactory,
        IConfiguration configuration)
    {
        _next = next;
        _logger = logger;
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, ex.Message);

            await SendExceptionToMonitoringAsync(context, ex);
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task SendExceptionToMonitoringAsync(HttpContext context, Exception ex)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("Monitoring");

            await client.PostAsJsonAsync("/api/monitoring/exceptions", new
            {
                ServiceName = _configuration["Monitoring:ServiceName"] ?? "UserSettingsService",
                Method = context.Request.Method,
                Path = context.Request.Path.ToString(),
                TraceId = context.Items["TraceId"]?.ToString(),
                SpanId = context.Items["SpanId"]?.ToString(),
                Message = ex.Message,
                StackTrace = ex.StackTrace,
                CreatedAt = DateTime.UtcNow
            });
        }
        catch (Exception monitoringEx)
        {
            _logger.LogWarning(monitoringEx, "Не удалось отправить exception в MonitoringService");
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var response = exception switch
        {
            NotFoundException => CreateResponse(404, exception.Message),
            ForbiddenException => CreateResponse(403, exception.Message),
            UnauthorizedException => CreateResponse(401, exception.Message),
            BadRequestException => CreateResponse(400, exception.Message),
            ValidationException validationEx => new ErrorResponse
            {
                Title = "Validation failed",
                Status = 400,
                Errors = validationEx.Errors
            },
            _ => CreateResponse(500, "Internal server error")
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = response.Status;

        return context.Response.WriteAsJsonAsync(response);
    }

    private static ErrorResponse CreateResponse(int status, string message)
        => new()
        {
            Title = message,
            Status = status
        };
}
