@MainActor enum DI {
    static var container: AppDependency = AppDependency.build()
}

@MainActor
struct AppDependency {
    let tokenStorage: TokenStorageProtocol
    let authorizationProvider: AuthorizationProvidingProtocol
    let sessionService: SessionServiceProtocol
    let networkService: NetworkServiceProtocol
    let usersRepository: UsersRepositoryProtocol
    let accountsRepository: AccountsRepositoryProtocol
    let creditsRepository: CreditsRepositoryProtocol

    static func build() -> AppDependency {
        let tokenStorage = KeychainTokenStorage()
        let authorizationProvider = AuthorizationProvider(tokenStorage: tokenStorage)
        let sessionService = SessionService(
            tokenStorage: tokenStorage
        )
        let networkService = NetworkService(
            networkTransport: HTTPClient(authorizationProvider: authorizationProvider),
            sessionService: sessionService
        )
        let usersRepository = UsersRepository(
            networkService: networkService,
            tokenStorage: tokenStorage
        )
        let accountsRepository = AccountsRepository(
            networkService: networkService
        )
        let creditsRepository = CreditsRepository(
            networkService: networkService
        )

        return AppDependency(
            tokenStorage: tokenStorage,
            authorizationProvider: authorizationProvider,
            sessionService: sessionService,
            networkService: networkService,
            usersRepository: usersRepository,
            accountsRepository: accountsRepository,
            creditsRepository: creditsRepository
        )
    }
}
