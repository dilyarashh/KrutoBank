import SwiftUI

struct UserResponse: Decodable {
    let id: String
    let firstName: String
    let lastName: String
    let middleName: String?
    let phone: String?
    let email: String?
    let birthday: String?
    let role: UserRole
    let isBlocked: Bool
}

enum UserRole: String, Decodable {
    case client = "Client"
    case employee = "Employee"

    var title: String {
        switch self {
        case .client:
            return AppStrings.Profile.roleClient
        case .employee:
            return AppStrings.Profile.roleEmployee
        }
    }
}
