import Foundation
import SwiftUI

struct LoanOperationResponse: Decodable, Identifiable {
    let operationId: String
    let amount: Double
    let operationDate: String
    let operationType: String?

    var id: String { operationId }

    var typeDisplayName: String {
        operationType ?? "Неизвестно"
    }

    var iconName: String {
        "doc.text.magnifyingglass"
    }

    var iconColor: Color {
        Color.AppColor.primaryPink
    }

    var formattedAmount: String {
        "\(formatMoney(amount)) ₽"
    }

    var formattedDate: String {
        formatDate(operationDate)
    }

    var formattedDateTime: String {
        formatDateTime(operationDate)
    }

    private func formatMoney(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }

    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateString) else {
            return dateString
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .none
        outputFormatter.locale = Locale(identifier: "ru_RU")

        return outputFormatter.string(from: date)
    }

    private func formatDateTime(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateString) else {
            return dateString
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .short
        outputFormatter.timeStyle = .short
        outputFormatter.locale = Locale(identifier: "ru_RU")

        return outputFormatter.string(from: date)
    }
}
