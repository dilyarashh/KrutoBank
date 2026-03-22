import Foundation

final class UsersRepository: UsersRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private var tokenStorage: TokenStorageProtocol

    init(
        networkService: NetworkServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }

    func getMyInfo() async throws -> UserProfile {
        let response = try await networkService.requestDecodable(GetMyInfoEndPoint(), as: UserResponse.self)
        return response.toDomain()
    }
}
