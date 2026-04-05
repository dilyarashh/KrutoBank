using Microsoft.AspNetCore.Mvc;
using MonitoringService.Data;
using MonitoringService.DTO;
using MonitoringService.Entities;
using Microsoft.EntityFrameworkCore;

namespace MonitoringService.Controllers
{
    [ApiController]
    [Route("api/monitoring")]
    public class MonitoringIngestController : ControllerBase
    {
        private readonly MonitoringDbContext _dbContext;

        public MonitoringIngestController(MonitoringDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpPost("requests")]
        public async Task<IActionResult> SaveRequest([FromBody] RequestLogDto dto)
        {
            var entity = new RequestLog
            {
                Id = Guid.NewGuid(),
                ServiceName = dto.ServiceName,
                Method = dto.Method,
                Path = dto.Path,
                StatusCode = dto.StatusCode,
                DurationMs = dto.DurationMs,
                TraceId = dto.TraceId,
                SpanId = dto.SpanId,
                IsError = dto.IsError,
                CreatedAt = dto.CreatedAt
            };

            _dbContext.RequestLogs.Add(entity);
            await _dbContext.SaveChangesAsync();

            return Ok();
        }

        [HttpPost("exceptions")]
        public async Task<IActionResult> SaveException([FromBody] ExceptionLogDto dto)
        {
            var entity = new ExceptionLog
            {
                Id = Guid.NewGuid(),
                ServiceName = dto.ServiceName,
                Method = dto.Method,
                Path = dto.Path,
                TraceId = dto.TraceId,
                SpanId = dto.SpanId,
                Message = dto.Message,
                StackTrace = dto.StackTrace,
                CreatedAt = dto.CreatedAt
            };

            _dbContext.ExceptionLogs.Add(entity);
            await _dbContext.SaveChangesAsync();

            return Ok();
        }

        [HttpPost("traces")]
        public async Task<IActionResult> SaveTrace([FromBody] TraceSpanDto dto)
        {
            var entity = new TraceSpan
            {
                Id = Guid.NewGuid(),
                ServiceName = dto.ServiceName,
                TraceId = dto.TraceId,
                SpanId = dto.SpanId,
                ParentSpanId = dto.ParentSpanId,
                OperationName = dto.OperationName,
                StartedAt = dto.StartedAt,
                EndedAt = dto.EndedAt,
                DurationMs = dto.DurationMs,
                Status = dto.Status
            };

            _dbContext.TraceSpans.Add(entity);
            await _dbContext.SaveChangesAsync();

            return Ok();
        }
    }
}
