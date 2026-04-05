namespace MonitoringService.Entities
{
    public class RequestLog
    {
        public Guid Id { get; set; }
        public string ServiceName { get; set; } = null!;
        public string Method { get; set; } = null!;
        public string Path { get; set; } = null!;
        public int StatusCode { get; set; }
        public long DurationMs { get; set; }
        public string TraceId { get; set; } = null!;
        public string SpanId { get; set; } = null!;
        public bool IsError { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
