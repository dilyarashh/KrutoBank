import Foundation

final class HTTPClient: NetworkTransport {
    private let session: URLSession
    private let authorizationProvider: AuthorizationProvidingProtocol
    private let retryPolicy: RetryPolicy
    private let circuitBreaker: CircuitBreaker

    init(
        session: URLSession = .shared,
        authorizationProvider: AuthorizationProvidingProtocol,
        retryPolicy: RetryPolicy = .default,
        circuitBreaker: CircuitBreaker = .shared
    ) {
        self.session = session
        self.authorizationProvider = authorizationProvider
        self.retryPolicy = retryPolicy
        self.circuitBreaker = circuitBreaker
    }

    func send(_ endpoint: EndPoint) async throws -> Data {
        var request = try URLRequestBuilder.build(from: endpoint)

        request = await authorizationProvider.addAuthorization(
            to: request,
            requirement: endpoint.authorization
        )

        if endpoint.requiresIdempotencyKey {
            let key = endpoint.idempotencyKey ?? UUID().uuidString
            request.setValue(key, forHTTPHeaderField: HTTPHeader.idempotencyKey)
        }

        let traceID = UUID().uuidString
        request.setValue(traceID, forHTTPHeaderField: HTTPHeader.traceID)

        return try await performWithRetry(request, traceID: traceID)
    }

    func sendDecodable<T: Decodable & Sendable>(_ endpoint: EndPoint, as: T.Type) async throws -> T {
        let data = try await send(endpoint)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

// MARK: - Private
private extension HTTPClient {
    func performWithRetry(_ request: URLRequest, traceID: String) async throws -> Data {
        var lastError: Error?

        for attempt in 1...retryPolicy.maxAttempts {
            guard circuitBreaker.canMakeRequest() else {
                throw NetworkError.circuitBreakerOpen
            }

            do {
                NetworkLogger.logRequest(request, attempt: attempt, traceID: traceID)

                let startTime = Date()
                let (data, response) = try await session.data(for: request)
                let duration = Date().timeIntervalSince(startTime)

                guard let http = response as? HTTPURLResponse else {
                    circuitBreaker.recordFailure()
                    NetworkLogger.logErrorRate(circuitBreaker.currentErrorRate, total: circuitBreaker.totalCount)
                    throw NetworkError.noResponse
                }

                NetworkLogger.logResponse(data: data, response: http, traceID: traceID)
                NetworkLogger.logResponseTime(duration, url: request.url?.absoluteString ?? "", statusCode: http.statusCode)

                if HTTPStatusCode.isSuccess(http.statusCode) {
                    circuitBreaker.recordSuccess()
                    NetworkLogger.logErrorRate(circuitBreaker.currentErrorRate, total: circuitBreaker.totalCount)
                    return data
                }

                if http.statusCode == HTTPStatusCode.unauthorized.rawValue {
                    throw NetworkError.unauthorized
                }

                let message = String(data: data, encoding: .utf8)

                if shouldRetry(statusCode: http.statusCode, request: request, attempt: attempt) {
                    circuitBreaker.recordFailure()
                    NetworkLogger.logErrorRate(circuitBreaker.currentErrorRate, total: circuitBreaker.totalCount)
                    lastError = NetworkError.serverError(code: http.statusCode, message: message)

                    let delay = retryPolicy.timeInterval(for: attempt)
                    NetworkLogger.logRetry(attempt: attempt, maxAttempts: retryPolicy.maxAttempts, delay: delay)

                    try await sleepBeforeNextAttempt(attempt: attempt)
                    continue
                }

                circuitBreaker.recordFailure()
                NetworkLogger.logErrorRate(circuitBreaker.currentErrorRate, total: circuitBreaker.totalCount)
                throw NetworkError.serverError(code: http.statusCode, message: message)

            } catch let error as NetworkError {
                if shouldRetry(networkError: error, request: request, attempt: attempt) {
                    circuitBreaker.recordFailure()
                    lastError = error

                    let delay = retryPolicy.timeInterval(for: attempt)
                    NetworkLogger.logRetry(attempt: attempt, maxAttempts: retryPolicy.maxAttempts, delay: delay)

                    try await sleepBeforeNextAttempt(attempt: attempt)
                    continue
                }

                NetworkLogger.logNetworkError(error)
                throw error
            } catch {
                let wrapped = NetworkError.transportError(underlying: error)

                if shouldRetry(networkError: wrapped, request: request, attempt: attempt) {
                    circuitBreaker.recordFailure()
                    lastError = wrapped

                    let delay = retryPolicy.timeInterval(for: attempt)
                    NetworkLogger.logRetry(attempt: attempt, maxAttempts: retryPolicy.maxAttempts, delay: delay)

                    try await sleepBeforeNextAttempt(attempt: attempt)
                    continue
                }

                NetworkLogger.logError(error)
                throw wrapped
            }
        }

        throw lastError ?? NetworkError.noResponse
    }

    func shouldRetry(statusCode: Int, request: URLRequest, attempt: Int) -> Bool {
        guard attempt < retryPolicy.maxAttempts else { return false }
        guard isRetrySafe(request) else { return false }
        return retryPolicy.retryableStatusCodes.contains(statusCode)
    }

    func shouldRetry(networkError: NetworkError, request: URLRequest, attempt: Int) -> Bool {
        guard attempt < retryPolicy.maxAttempts else { return false }
        guard isRetrySafe(request) else { return false }

        switch networkError {
        case .transportError, .noResponse:
            return true
        default:
            return false
        }
    }

    func isRetrySafe(_ request: URLRequest) -> Bool {
        guard let method = request.httpMethod?.uppercased() else { return false }

        if method == "GET" {
            return true
        }

        return request.value(forHTTPHeaderField: HTTPHeader.idempotencyKey) != nil
    }

    func sleepBeforeNextAttempt(attempt: Int) async throws {
        let delay = retryPolicy.delay(for: attempt)
        try await Task.sleep(nanoseconds: delay)
    }
}
