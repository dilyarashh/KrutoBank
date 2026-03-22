import Foundation

// MARK: - Exchange Rate Response (from open API)
struct ExchangeRatesResponse: Decodable {
    let base: String
    let rates: [String: Double]
}

// MARK: - Protocol
protocol ExchangeRateServiceProtocol {
    /// Returns conversion rate: how many `toCurrency` units per 1 `fromCurrency`
    func rate(from: Currency, to: Currency) async throws -> Double
}

// MARK: - Implementation
final class ExchangeRateService: ExchangeRateServiceProtocol {
    private var cachedRates: [String: Double] = [:]
    private var cacheBase: String = ""
    private var cacheDate: Date?
    private let cacheDuration: TimeInterval = 3600 // 1 hour

    func rate(from: Currency, to: Currency) async throws -> Double {
        guard from != to else { return 1.0 }

        if let cached = cachedRates[to.rawValue],
           let date = cacheDate,
           Date().timeIntervalSince(date) < cacheDuration,
           cacheBase == from.rawValue {
            return cached
        }

        let url = URL(string: "https://api.exchangerate-api.com/v4/latest/\(from.rawValue)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)

        cachedRates = response.rates
        cacheBase = from.rawValue
        cacheDate = Date()

        return response.rates[to.rawValue] ?? 1.0
    }
}
