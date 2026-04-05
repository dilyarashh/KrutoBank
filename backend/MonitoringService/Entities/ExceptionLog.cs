namespace MonitoringService.Entities
{
    public class ExceptionLog
    {
        public Guid Id { get; set; }
        public string ServiceName { get; set; } = null!;
        public string Method { get; set; } = null!;
        public string Path { get; set; } = null!;
        public string TraceId { get; set; } = null!;
        public string SpanId { get; set; } = null!;
        public string Message { get; set; } = null!;
        public string? StackTrace { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
