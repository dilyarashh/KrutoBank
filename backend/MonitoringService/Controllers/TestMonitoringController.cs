using Microsoft.AspNetCore.Mvc;
using MonitoringService.Data;
using MonitoringService.Entities;

namespace MonitoringService.Controllers
{
    [ApiController]
    [Route("api/test-monitoring")]
    public class TestMonitoringController : ControllerBase
    {
        private readonly MonitoringDbContext _db;

        public TestMonitoringController(MonitoringDbContext db)
        {
            _db = db;
        }

        [HttpPost("seed")]
        public async Task<IActionResult> Seed()
        {
            var now = DateTime.UtcNow;

            var services = new[]
            {
                new
                {
                    Name = "UsersService",
                    Method = "GET",
                    Path = "/api/users/test",
                    BaseDuration = 120L,
                    ErrorEvery = 7
                },
                new
                {
                    Name = "AccountsService",
                    Method = "POST",
                    Path = "/api/accounts/test",
                    BaseDuration = 420L,
                    ErrorEvery = 4
                },
                new
                {
                    Name = "AuthService",
                    Method = "POST",
                    Path = "/account/login",
                    BaseDuration = 260L,
                    ErrorEvery = 3
                },
                new
                {
                    Name = "CreditsService",
                    Method = "GET",
                    Path = "/api/credits/test",
                    BaseDuration = 210L,
                    ErrorEvery = 5
                },
                new
                {
                    Name = "UserSettingsService",
                    Method = "GET",
                    Path = "/api/settings/test",
                    BaseDuration = 95L,
                    ErrorEvery = 8
                }
            };

            var requestLogs = new List<RequestLog>();
            var exceptionLogs = new List<ExceptionLog>();
            var traceSpans = new List<TraceSpan>();

            foreach (var service in services)
            {
                for (int i = 0; i < 20; i++)
                {
                    var createdAt = now.AddMinutes(-(20 - i));
                    var isError = i % service.ErrorEvery == 0;

                    var duration = service.BaseDuration + (i * 17) + Random.Shared.Next(10, 80);

                    if (isError)
                    {
                        duration += Random.Shared.Next(120, 260);
                    }

                    var traceId = $"{service.Name}-trace-{Guid.NewGuid():N}";
                    var spanId = $"{service.Name}-span-{Guid.NewGuid():N}".Substring(0, 24);

                    var statusCode = isError
                        ? (service.Name == "AuthService" ? 401 : 500)
                        : 200;

                    requestLogs.Add(new RequestLog
                    {
                        ServiceName = service.Name,
                        Method = service.Method,
                        Path = service.Path,
                        StatusCode = statusCode,
                        DurationMs = duration,
                        TraceId = traceId,
                        SpanId = spanId,
                        IsError = isError,
                        CreatedAt = createdAt
                    });

                    traceSpans.Add(new TraceSpan
                    {
                        ServiceName = service.Name,
                        TraceId = traceId,
                        SpanId = spanId,
                        ParentSpanId = null,
                        OperationName = $"HTTP {service.Method} {service.Path}",
                        StartedAt = createdAt.AddMilliseconds(-duration),
                        EndedAt = createdAt,
                        DurationMs = duration,
                        Status = isError ? "Error" : "Ok"
                    });

                    if (isError)
                    {
                        exceptionLogs.Add(new ExceptionLog
                        {
                            ServiceName = service.Name,
                            Method = service.Method,
                            Path = service.Path,
                            TraceId = traceId,
                            SpanId = spanId,
                            Message = service.Name switch
                            {
                                "AuthService" => "Invalid credentials",
                                "AccountsService" => "Balance operation failed",
                                "CreditsService" => "Credit calculation failed",
                                "UsersService" => "User lookup failed",
                                "UserSettingsService" => "Settings loading failed",
                                _ => "Unknown service error"
                            },
                            StackTrace = $"at {service.Name}.TestMethod()",
                            CreatedAt = createdAt
                        });
                    }
                }
            }

            _db.RequestLogs.AddRange(requestLogs);
            _db.ExceptionLogs.AddRange(exceptionLogs);
            _db.TraceSpans.AddRange(traceSpans);

            await _db.SaveChangesAsync();

            return Ok(new
            {
                message = "Test monitoring data inserted successfully",
                requestLogs = requestLogs.Count,
                exceptionLogs = exceptionLogs.Count,
                traceSpans = traceSpans.Count
            });
        }
    }
}