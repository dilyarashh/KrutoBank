struct TakeLoanRequest: Encodable, Sendable {
    let userId: String
    let tariffName: String
    let amount: Double
    let accountId: String
}
