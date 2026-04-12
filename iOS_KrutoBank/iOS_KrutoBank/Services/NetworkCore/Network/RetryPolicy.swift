import Foundation

struct RetryPolicy {
    let maxAttempts: Int
    let baseDelay: TimeInterval
    let retryableStatusCodes: Set<Int>

    static let `default` = RetryPolicy(
        maxAttempts: 5,
        baseDelay: 0.5,
        retryableStatusCodes: [408, 425, 429, 500, 502, 503, 504]
    )

    func delay(for attempt: Int) -> UInt64 {
        UInt64(timeInterval(for: attempt) * 1_000_000_000)
    }

    func timeInterval(for attempt: Int) -> TimeInterval {
        baseDelay * pow(2.0, Double(attempt - 1))
    }
}
