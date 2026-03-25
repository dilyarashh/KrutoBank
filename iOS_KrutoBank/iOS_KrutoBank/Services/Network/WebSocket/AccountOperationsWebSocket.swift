import Foundation
import SignalRClient

// MARK: - Protocol

protocol AccountOperationsWebSocketProtocol: AnyObject {
    var onInvalidate: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    var isConnected: Bool { get }

    func connect(accountId: String)
    func disconnect()
}

// MARK: - Implementation

final class AccountOperationsWebSocket: AccountOperationsWebSocketProtocol {

    // MARK: - Public

    var onInvalidate: (() -> Void)?
    var onError: ((Error) -> Void)?

    private(set) var isConnected: Bool = false

    // MARK: - Private properties

    private let tokenStorage: TokenStorageProtocol
    private var connection: HubConnection?
    private var currentAccountId: String?

    // MARK: - Init

    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }

    // MARK: - Public methods

    func connect(accountId: String) {
        disconnect()
        currentAccountId = accountId

        guard let token = tokenStorage.accessToken, !token.isEmpty else {
            onError?(SignalRError.missingAccessToken)
            return
        }

        let hubURL = APIConstants.accountOperationsHubURL(accessToken: token)

        let connection = HubConnectionBuilder()
            .withUrl(url: hubURL.absoluteString)
            .withAutomaticReconnect()
            .build()

        registerHandlers(on: connection)

        // MARK: - Connection lifecycle

        connection.onReconnecting { [weak self] (error: Error?) in
            self?.isConnected = false
            if let error {
                self?.onError?(error)
            }
        }

        connection.onReconnected { [weak self] in
            guard let self else { return }
            self.isConnected = true

            if let accountId = self.currentAccountId {
                Task {
                    do {
                        try await connection.invoke(method: "SubscribeAccount", arguments: accountId)
                    } catch {
                        self.onError?(error)
                    }
                }
            }
        }

        connection.onClosed { [weak self] (error: Error?) in
            self?.isConnected = false
            if let error {
                self?.onError?(error)
            }
        }

        self.connection = connection

        // MARK: - Start connection

        Task {
            do {
                try await connection.start()
                isConnected = true
                try await connection.invoke(method: "SubscribeAccount", arguments: accountId)
            } catch {
                isConnected = false
                onError?(error)
            }
        }
    }

    func disconnect() {
        let accountId = currentAccountId
        let connection = connection

        currentAccountId = nil
        isConnected = false
        self.connection = nil

        guard let connection else { return }

        Task {
            do {
                if let accountId {
                    try? await connection.invoke(method: "UnsubscribeAccount", arguments: accountId)
                }
                try await connection.stop()
            } catch {
                onError?(error)
            }
        }
    }

    // MARK: - Handlers

    private func registerHandlers(on connection: HubConnection) {
        Task {
            await connection.on("OperationsSnapshot") { [weak self] (_: String, _: [OperationDTO]) in
                self?.onInvalidate?()
            }
        }
    }
}

// MARK: - DTO

private struct OperationDTO: Decodable {
    let createdAt: String
    let type: String
    let amount: Double
}

// MARK: - Errors

enum SignalRError: LocalizedError {
    case missingAccessToken

    var errorDescription: String? {
        switch self {
        case .missingAccessToken:
            return "Нет access token для SignalR-подключения"
        }
    }
}
