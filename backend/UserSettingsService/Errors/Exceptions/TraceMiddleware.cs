using System.Diagnostics;

namespace UserSettingsService.Errors.Exceptions
{
    public class TraceMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly IConfiguration _configuration;

        public TraceMiddleware(RequestDelegate next, IConfiguration configuration)
        {
            _next = next;
            _configuration = configuration;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var serviceName = _configuration["Monitoring:ServiceName"] ?? "UnknownService";

            using var activity = new Activity($"{serviceName}.request");

            activity.SetIdFormat(ActivityIdFormat.W3C);
            activity.Start();

            activity.SetTag("service.name", serviceName);
            activity.SetTag("http.method", context.Request.Method);
            activity.SetTag("http.path", context.Request.Path.ToString());

            context.Items["TraceId"] = activity.TraceId.ToString();
            context.Items["SpanId"] = activity.SpanId.ToString();

            try
            {
                await _next(context);
                activity.SetTag("http.status_code", context.Response.StatusCode);
            }
            catch (Exception ex)
            {
                activity.SetTag("exception.message", ex.Message);
                activity.SetTag("exception.type", ex.GetType().FullName);
                throw;
            }
            finally
            {
                activity.Stop();
            }
        }
    }
}
