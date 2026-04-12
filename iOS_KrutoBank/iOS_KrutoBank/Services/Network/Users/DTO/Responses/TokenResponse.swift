import Foundation

// MARK: - DTO

struct TokenResponse: Decodable, Sendable {
    let token: String
}

// MARK: - Mapper

extension TokenResponse {
    func toDomain() -> Token {
        Token(accessToken: token)
    }
}
