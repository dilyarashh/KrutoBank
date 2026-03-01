import Foundation

struct CreditResponse: Decodable {
    let loanId: String
    let initialAmount: Double
    let remainingAmount: Double
    let tariffName: String?
    let interestRate: Double
    let createdAt: String
    let isActive: Bool

    var id: String { loanId }
    var paidAmount: Double {
        return initialAmount - remainingAmount
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

    var formattedInitialAmount: String {
        formatMoney(initialAmount)
    }

    var formattedRemainingAmount: String {
        formatMoney(remainingAmount)
    }

    var formattedPaidAmount: String {
        formatMoney(paidAmount)
    }

    var formattedInterestRate: String {
        return "\(Int(interestRate * 100))%"
    }

    private func formatMoney(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.2f", value)
    }
}
