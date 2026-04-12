import Foundation

// MARK: - State

enum CircuitBreakerState {
    case closed
    case open(until: Date)
    case halfOpen
}

// MARK: - CircuitBreaker

final class CircuitBreaker {

    // MARK: - Config
    private let failureThreshold: Double
    private let windowSize: Int
    private let resetTimeout: TimeInterval

    // MARK: - State
    private(set) var state: CircuitBreakerState = .closed
    private var results: [Bool] = []
    private let lock = NSLock()

    // MARK: - Shared instance
    static let shared = CircuitBreaker()

    // MARK: - Init
    init(
        failureThreshold: Double = 0.7,
        windowSize: Int = 10,
        resetTimeout: TimeInterval = 30
    ) {
        self.failureThreshold = failureThreshold
        self.windowSize = windowSize
        self.resetTimeout = resetTimeout
    }

    // MARK: - Public

    func canMakeRequest() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        switch state {
        case .closed, .halfOpen:
            return true
        case .open(let until):
            if Date() >= until {
                state = .halfOpen
                NetworkLogger.log("🔌 [CircuitBreaker] → HALF-OPEN (пробный запрос)")
                return true
            }
            NetworkLogger.log("🚫 [CircuitBreaker] OPEN — запрос заблокирован")
            return false
        }
    }

    func recordSuccess() {
        lock.lock()
        defer { lock.unlock() }

        results.append(true)
        trimWindow()

        if case .halfOpen = state {
            state = .closed
            results.removeAll()
            NetworkLogger.log("✅ [CircuitBreaker] → CLOSED (сервис восстановлен)")
        }
    }

    func recordFailure() {
        lock.lock()
        defer { lock.unlock() }

        results.append(false)
        trimWindow()

        let errorRate = calculateErrorRate()
        let failCount = results.filter { !$0 }.count
        NetworkLogger.log("📊 [CircuitBreaker] ошибок: \(Int(errorRate * 100))% (\(failCount)/\(results.count))")

        guard case .closed = state else { return }

        if errorRate > failureThreshold {
            let until = Date().addingTimeInterval(resetTimeout)
            state = .open(until: until)
            NetworkLogger.log("🚨 [CircuitBreaker] → OPEN (\(Int(errorRate * 100))% ошибок > \(Int(failureThreshold * 100))%, пауза \(Int(resetTimeout))с)")
        }
    }

    var currentErrorRate: Double {
        lock.lock()
        defer { lock.unlock() }
        return calculateErrorRate()
    }

    var totalCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return results.count
    }

    var isOpen: Bool {
        lock.lock()
        defer { lock.unlock() }
        if case .open(let until) = state, Date() < until {
            return true
        }
        return false
    }

    // MARK: - Private

    private func trimWindow() {
        if results.count > windowSize {
            results.removeFirst(results.count - windowSize)
        }
    }

    private func calculateErrorRate() -> Double {
        guard !results.isEmpty else { return 0 }
        let failures = results.filter { !$0 }.count
        return Double(failures) / Double(results.count)
    }
}
