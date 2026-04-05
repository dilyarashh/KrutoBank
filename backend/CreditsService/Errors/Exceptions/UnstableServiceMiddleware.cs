namespace AccountsService.Errors.Exceptions;

public class UnstableServiceMiddleware(RequestDelegate next, ILogger<UnstableServiceMiddleware> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value?.ToLowerInvariant() ?? string.Empty;

        if (path.StartsWith("/metrics") ||
            path.StartsWith("/swagger") ||
            path.StartsWith("/hangfire"))
        {
            await next(context);
            return;
        }

        var failureProbability = DateTime.Now.Minute % 2 == 0 ? 0.7 : 0.3;

        if (Random.Shared.NextDouble() < failureProbability)
        {
            logger.LogWarning(
                "Simulated instability triggered for {Method} {Path}. Failure probability: {FailureProbability:P0}",
                context.Request.Method,
                context.Request.Path,
                failureProbability);

            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            context.Response.ContentType = "application/json";

            await context.Response.WriteAsJsonAsync(new
            {
                title = "Simulated internal server error",
                status = StatusCodes.Status500InternalServerError
            });

            return;
        }

        await next(context);
    }
}
