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

    func getMyInfo() async throws -> UserResponse {
        let endPoint = GetMyInfoEndPoint()
        return try await networkService.requestDecodable(endPoint, as: UserResponse.self)
    }
}
