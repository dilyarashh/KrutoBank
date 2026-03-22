struct Tariff: Identifiable {
    let id: String
    let name: String
    let interestRate: Double

    var formattedInterestRate: String {
        "\(Int(interestRate * 100))%"
    }
}
