using Microsoft.AspNetCore.Mvc;
using MonitoringService.Data;
using Microsoft.EntityFrameworkCore;

namespace MonitoringService.Controllers
{
    [ApiController]
    [Route("api/dashboard")]
    public class MonitoringDashboardController : ControllerBase
    {
        private readonly MonitoringDbContext _dbContext;

        public MonitoringDashboardController(MonitoringDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet("rps")]
        public async Task<IActionResult> GetRps()
        {
            var from = DateTime.UtcNow.AddMinutes(-30);

            var data = await _dbContext.RequestLogs
                .Where(x => x.CreatedAt >= from)
                .GroupBy(x => x.ServiceName)
                .Select(g => new
                {
                    Service = g.Key,
                    Count = g.Count(),
                    Rps = g.Count() / 1800.0
                })
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("errors-percent")]
        public async Task<IActionResult> GetErrorPercent()
        {
            var from = DateTime.UtcNow.AddMinutes(-30);

            var data = await _dbContext.RequestLogs
                .Where(x => x.CreatedAt >= from)
                .GroupBy(x => x.ServiceName)
                .Select(g => new
                {
                    Service = g.Key,
                    Total = g.Count(),
                    Errors = g.Count(x => x.IsError),
                    ErrorPercent = g.Count() == 0 ? 0 : g.Count(x => x.IsError) * 100.0 / g.Count()
                })
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("avg-response")]
        public async Task<IActionResult> GetAverageResponse()
        {
            var from = DateTime.UtcNow.AddMinutes(-30);

            var data = await _dbContext.RequestLogs
                .Where(x => x.CreatedAt >= from)
                .GroupBy(x => x.ServiceName)
                .Select(g => new
                {
                    Service = g.Key,
                    AvgDurationMs = g.Average(x => x.DurationMs)
                })
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("exceptions")]
        public async Task<IActionResult> GetExceptions()
        {
            var data = await _dbContext.ExceptionLogs
                .OrderByDescending(x => x.CreatedAt)
                .Take(100)
                .ToListAsync();

            return Ok(data);
        }

        [HttpGet("traces/{traceId}")]
        public async Task<IActionResult> GetTrace(string traceId)
        {
            var data = await _dbContext.TraceSpans
                .Where(x => x.TraceId == traceId)
                .OrderBy(x => x.StartedAt)
                .ToListAsync();

            return Ok(data);
        }
    }
}
