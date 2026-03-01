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

    func login(with phone: String, password: String) async throws {
        let dto = LoginRequest(phone: phone, password: password)
        let endPoint = LoginEndPoint(body: dto)

        let response = try await networkService.requestDecodable(endPoint, as: TokenResponse.self)
        tokenStorage.accessToken = response.token
    }

    func logout() async throws {
        let endPoint = LogoutEndPoint()
        try await networkService.request(endPoint)
        tokenStorage.accessToken = nil
    }

    func getMyInfo() async throws -> UserResponse {
        let endPoint = GetMyInfoEndPoint()
        return try await networkService.requestDecodable(endPoint, as: UserResponse.self)
    }
}
