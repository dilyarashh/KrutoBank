struct ExchangeRatesResponse: Decodable {
    let base: String
    let rates: [String: Double]
}
