struct TakeLoanRequest: Encodable {
    let userId: String
    let tariffName: String
    let amount: Double
}
