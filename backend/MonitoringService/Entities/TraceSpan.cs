namespace MonitoringService.Entities
{
    public class TraceSpan
    {
        public Guid Id { get; set; }
        public string ServiceName { get; set; } = null!;
        public string TraceId { get; set; } = null!;
        public string SpanId { get; set; } = null!;
        public string? ParentSpanId { get; set; }
        public string OperationName { get; set; } = null!;
        public DateTime StartedAt { get; set; }
        public DateTime EndedAt { get; set; }
        public long DurationMs { get; set; }
        public string Status { get; set; } = null!;
    }
}
