import Foundation

struct Credit: Identifiable {
    let loanId: String
    let initialAmount: Double
    let remainingAmount: Double
    let tariffName: String?
    let interestRate: Double
    let createdAt: String
    let isActive: Bool

    var id: String { loanId }

    var paidAmount: Double {
        initialAmount - remainingAmount
    }

    var progress: Double {
        guard initialAmount > 0 else { return 0 }
        return paidAmount / initialAmount
    }

    var status: String {
        if remainingAmount <= 0 {
            return "Закрыт"
        } else if isActive {
            return "Активный"
        } else {
            return "Неактивный"
        }
    }

    var formattedInitialAmount: String { formatMoney(initialAmount) }
    var formattedRemainingAmount: String { formatMoney(remainingAmount) }
    var formattedPaidAmount: String { formatMoney(paidAmount) }

    var formattedInterestRate: String {
        "\(Int(interestRate * 100))%"
    }

    private func formatMoney(_ value: Double) -> String {
        value.rounded() == value
            ? String(Int(value))
            : String(format: "%.2f", value)
    }
}
