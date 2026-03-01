import SwiftUI

enum OperationType: String, Decodable {
    case deposit = "Deposit"
    case withdraw = "Withdraw"

    var displayName: String {
        switch self {
        case .deposit:
            return "Пополнение"
        case .withdraw:
            return "Списание"
        }
    }

    var iconName: String {
        switch self {
        case .deposit:
            return "arrow.down.circle.fill"
        case .withdraw:
            return "arrow.up.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .deposit:
            return Color.AppColor.textSuccess
        case .withdraw:
            return Color.AppColor.textError
        }
    }
}
