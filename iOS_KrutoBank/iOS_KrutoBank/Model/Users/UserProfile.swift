import Foundation

// MARK: - Domain Model

struct UserProfile {
    let id: String
    let firstName: String
    let lastName: String
    let middleName: String?
    let phone: String?
    let email: String?
    let birthday: String?
    let role: Role
    let isBlocked: Bool

    var fullName: String {
        [lastName, firstName, middleName]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    enum Role {
        case client
        case employee

        var title: String {
            switch self {
            case .client:
                return AppStrings.Profile.roleClient
            case .employee:
                return AppStrings.Profile.roleEmployee
            }
        }
    }
}
