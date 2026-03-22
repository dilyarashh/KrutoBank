import Foundation

// MARK: - DTO

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
}

// MARK: - Mapper

extension UserResponse {
    func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            middleName: middleName,
            phone: phone,
            email: email,
            birthday: birthday,
            role: role.toDomain(),
            isBlocked: isBlocked
        )
    }
}

private extension UserRole {
    func toDomain() -> UserProfile.Role {
        switch self {
        case .client:
            return .client
        case .employee:
            return .employee
        }
    }
}
