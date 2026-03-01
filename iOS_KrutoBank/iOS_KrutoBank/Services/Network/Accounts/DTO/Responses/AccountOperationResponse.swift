import Foundation

struct AccountOperationResponse: Decodable, Identifiable {
    let createdAt: String
    let type: OperationType
    let amount: Double

    var id: String { createdAt }
}

extension AccountOperationResponse {
    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: createdAt) else {
            return createdAt
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .short
        outputFormatter.timeStyle = .short
        outputFormatter.locale = Locale(identifier: "ru_RU")

        return outputFormatter.string(from: date)
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = amount.rounded() == amount ? 0 : 2

        let formattedNumber = formatter.string(from: NSNumber(value: amount)) ?? String(amount)

        switch type {
        case .deposit:
            return "+\(formattedNumber) ₽"
        case .withdraw:
            return "-\(formattedNumber) ₽"
        }
    }
}
