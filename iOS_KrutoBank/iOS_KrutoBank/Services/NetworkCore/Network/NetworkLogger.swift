import Foundation

enum NetworkLogger {
    static func logRequest(_ request: URLRequest, attempt: Int, traceID: String) {
        print(separator)
        print("🚀 [Request][Attempt \(attempt)][TraceID: \(traceID)] \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "NO URL")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📝 [Headers]: \(headers)")
        }

        if let body = request.httpBody, !body.isEmpty {
            print("📦 [Body]: \(prettyBody(from: body))")
        }
    }

    static func logResponse(data: Data, response: HTTPURLResponse, traceID: String) {
        print("📥 [Response][TraceID: \(traceID)] Status: \(response.statusCode)")

        if !data.isEmpty {
            print("📄 [Data]: \(prettyBody(from: data))")
        }

        print(separator)
    }

    static func logNetworkError(_ error: NetworkError) {
        print("❌ [NetworkError]: \(error)")
    }

    static func logError(_ error: Error) {
        print("❌ [Error]: \(error)")
    }

    static func logRetry(attempt: Int, maxAttempts: Int, delay: TimeInterval) {
        print("🔁 [Retry] attempt \(attempt + 1)/\(maxAttempts) in \(String(format: "%.2f", delay)) sec")
    }

    static func logResponseTime(_ duration: TimeInterval, url: String, statusCode: Int) {
        let ms = Int(duration * 1000)
        let icon = ms < 500 ? "🟢" : ms < 1500 ? "🟡" : "🔴"
        print("\(icon) [ResponseTime] \(ms)ms | \(statusCode) | \(url)")
    }

    static func logErrorRate(_ rate: Double, total: Int) {
        let percent = Int(rate * 100)
        let icon = percent < 30 ? "✅" : percent < 70 ? "⚠️" : "🚨"
        print("\(icon) [ErrorRate] \(percent)% (last \(total) requests)")
    }

    static func log(_ message: String) {
        print("📋 [Log]: \(message)")
    }
}

// MARK: - Private
private extension NetworkLogger {
    static var separator: String {
        "--------------------------------------------------"
    }

    static func prettyBody(from data: Data) -> String {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }

        return String(data: data, encoding: .utf8) ?? "Unable to print body"
    }
}
