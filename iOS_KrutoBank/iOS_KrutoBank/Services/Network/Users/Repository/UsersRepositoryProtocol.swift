import Foundation

protocol UsersRepositoryProtocol {
    func getMyInfo() async throws -> UserProfile
}
