namespace AuthService.Resilience;

public class ServiceCallCircuitState
{
    private readonly object _sync = new();
    private readonly Queue<(DateTime TimestampUtc, bool Failed)> _events = new();
    private DateTime? _openUntilUtc;

    public bool IsOpen(out TimeSpan retryAfter)
    {
        lock (_sync)
        {
            Cleanup();

            if (_openUntilUtc.HasValue && _openUntilUtc.Value > DateTime.UtcNow)
            {
                retryAfter = _openUntilUtc.Value - DateTime.UtcNow;
                return true;
            }

            _openUntilUtc = null;
            retryAfter = TimeSpan.Zero;
            return false;
        }
    }

    public void RecordSuccess() => Record(false);

    public void RecordFailure() => Record(true);

    private void Record(bool failed)
    {
        lock (_sync)
        {
            _events.Enqueue((DateTime.UtcNow, failed));
            Cleanup();

            if (_events.Count < 10)
            {
                return;
            }

            var failures = _events.Count(x => x.Failed);
            var ratio = failures / (double)_events.Count;

            if (ratio > 0.7d)
            {
                _openUntilUtc = DateTime.UtcNow.AddSeconds(30);
            }
        }
    }

    private void Cleanup()
    {
        var threshold = DateTime.UtcNow.AddMinutes(-1);

        while (_events.Count > 0 && _events.Peek().TimestampUtc < threshold)
        {
            _events.Dequeue();
        }
    }
}
