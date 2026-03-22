import Foundation

struct OverduePaymentResponse: Decodable, Identifiable {
    let loanId: String
    let dueDate: String
    let amount: Double
    let tariffName: String?

    var id: String { "\(loanId)-\(dueDate)" }

    var formattedDate: String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = iso.date(from: dueDate) else { return dueDate }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.locale = Locale(identifier: "ru_RU")
        return fmt.string(from: date)
    }
}
