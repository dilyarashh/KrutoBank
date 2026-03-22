import Foundation

final class ExchangeRateService: ExchangeRateServiceProtocol {
    private var cachedRates: [String: Double] = [:]
    private var cacheBase: String = ""
    private var cacheDate: Date?
    private let cacheDuration: TimeInterval = 3600

    func rate(from: AccountCurrency, to: AccountCurrency) async throws -> Double {
        guard from != to else { return 1.0 }

        if let cached = cachedRates[to.rawValue],
           let date = cacheDate,
           Date().timeIntervalSince(date) < cacheDuration,
           cacheBase == from.rawValue {
            return cached
        }

        let url = APIConstants.exchangeRatesURL(base: from.rawValue)
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ExchangeRatesResponse.self, from: data)

        cachedRates = response.rates
        cacheBase = from.rawValue
        cacheDate = Date()

        return response.rates[to.rawValue] ?? 1.0
    }
}
