protocol UsersRepositoryProtocol {
    func login(with phone: String, password: String) async throws
    func logout() async throws
    func getMyInfo() async throws -> UserResponse
}
