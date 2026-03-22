import SwiftUI

enum OperationType: String, Decodable {
    case deposit = "Deposit"
    case withdraw = "Withdraw"
    case transfer = "Transfer"

    var displayName: String {
        switch self {
        case .deposit:  return "Пополнение"
        case .withdraw: return "Списание"
        case .transfer: return "Перевод"
        }
    }

    var iconName: String {
        switch self {
        case .deposit:  return "arrow.down.circle.fill"
        case .withdraw: return "arrow.up.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .deposit:  return Color.AppColor.textSuccess
        case .withdraw: return Color.AppColor.textError
        case .transfer: return Color.AppColor.primaryPink
        }
    }
}
