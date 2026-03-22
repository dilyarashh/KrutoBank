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

    var paidAmount: Double { initialAmount - remainingAmount }

    var progress: Double {
        guard initialAmount > 0 else { return 0 }
        return paidAmount / initialAmount
    }

    var status: String {
        if remainingAmount <= 0 {
            return "Закрыт"
        }
        else if isActive {
            return "Активный"
        }
        else {
            return "Неактивный"
        }
    }

    var formattedInitialAmount: String {
        CurrencyFormatter.formatMoney(initialAmount)
    }
    var formattedRemainingAmount: String {
        CurrencyFormatter.formatMoney(remainingAmount)
    }
    var formattedPaidAmount: String {
        CurrencyFormatter.formatMoney(paidAmount)
    }
    var formattedInterestRate: String {
        "\(Int(interestRate * 100))%"
    }
}
