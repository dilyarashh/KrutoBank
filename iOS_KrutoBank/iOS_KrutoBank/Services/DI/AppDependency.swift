@MainActor enum DI {
    static var container: AppDependency = AppDependency.build()
}

@MainActor
struct AppDependency {
    let tokenStorage: TokenStorageProtocol
    let authorizationProvider: AuthorizationProvidingProtocol
    let sessionService: SessionServiceProtocol
    let networkService: NetworkServiceProtocol
    let oauthService: OAuthServiceProtocol
    let usersRepository: UsersRepositoryProtocol
    let accountsRepository: AccountsRepositoryProtocol
    let creditsRepository: CreditsRepositoryProtocol
    let appSettingsRepository: AppSettingsRepositoryProtocol
    let exchangeRateService: ExchangeRateServiceProtocol
    let accountOperationsWebSocket: AccountOperationsWebSocketProtocol

    static func build() -> AppDependency {
        let tokenStorage = KeychainTokenStorage()
        let oauthService = OAuthService()
        let authorizationProvider = AuthorizationProvider(
            tokenStorage: tokenStorage,
            oauthService: oauthService
        )
        let sessionService = SessionService(tokenStorage: tokenStorage)
        let networkService = NetworkService(
            networkTransport: HTTPClient(authorizationProvider: authorizationProvider),
            sessionService: sessionService
        )
        let usersRepository = UsersRepository(
            networkService: networkService,
            tokenStorage: tokenStorage
        )
        let accountsRepository = AccountsRepository(networkService: networkService)
        let creditsRepository = CreditsRepository(networkService: networkService)
        let appSettingsRepository = AppSettingsRepository(networkService: networkService)
        let exchangeRateService = ExchangeRateService()
        let accountOperationsWebSocket = AccountOperationsWebSocket(tokenStorage: tokenStorage)

        return AppDependency(
            tokenStorage: tokenStorage,
            authorizationProvider: authorizationProvider,
            sessionService: sessionService,
            networkService: networkService,
            oauthService: oauthService,
            usersRepository: usersRepository,
            accountsRepository: accountsRepository,
            creditsRepository: creditsRepository,
            appSettingsRepository: appSettingsRepository,
            exchangeRateService: exchangeRateService,
            accountOperationsWebSocket: accountOperationsWebSocket
        )
    }
}
