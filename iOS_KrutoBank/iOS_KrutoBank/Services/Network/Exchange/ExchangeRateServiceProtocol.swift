protocol ExchangeRateServiceProtocol {
    func rate(from: AccountCurrency, to: AccountCurrency) async throws -> Double
}
