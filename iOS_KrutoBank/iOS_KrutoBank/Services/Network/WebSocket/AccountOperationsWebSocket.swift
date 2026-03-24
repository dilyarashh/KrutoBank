import Foundation

// MARK: - Protocol
protocol AccountOperationsWebSocketProtocol: AnyObject {
    var onInvalidate: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    var isConnected: Bool { get }

    func connect(accountId: String)
    func disconnect()
}

// MARK: - WebSocket message from server
private struct WSMessage: Decodable {
    let type: String
}

// MARK: - Implementation
final class AccountOperationsWebSocket: NSObject, AccountOperationsWebSocketProtocol {
    var onInvalidate: (() -> Void)?
    var onError: ((Error) -> Void)?

    private(set) var isConnected: Bool = false

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var currentAccountId: String?
    private let tokenStorage: TokenStorageProtocol

    init(tokenStorage: TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
        super.init()
    }

    func connect(accountId: String) {
        disconnect()
        currentAccountId = accountId

        var wsURL = APIConstants.accountOperationsWebSocket(accountId: accountId)

        if let token = tokenStorage.accessToken {
            var components = URLComponents(url: wsURL, resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "access_token", value: token)]
            wsURL = components.url ?? wsURL
        }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        self.urlSession = session
        let task = session.webSocketTask(with: wsURL)
        self.webSocketTask = task
        task.resume()
        isConnected = true
        receiveNext()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession = nil
        isConnected = false
        currentAccountId = nil
    }

    // MARK: - Receive loop
    private func receiveNext() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                self.isConnected = false
                self.onError?(error)
            case .success(let message):
                self.handleMessage(message)
                self.receiveNext()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8),
                  let wsMessage = try? JSONDecoder().decode(WSMessage.self, from: data) else {
                // Unknown message format — treat as invalidation signal
                onInvalidate?()
                return
            }
            if wsMessage.type == "invalidate" {
                onInvalidate?()
            }
        case .data(let data):
            if let wsMessage = try? JSONDecoder().decode(WSMessage.self, from: data),
               wsMessage.type == "invalidate" {
                onInvalidate?()
            }
        @unknown default:
            break
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension AccountOperationsWebSocket: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        isConnected = true
    }

    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        isConnected = false
    }
}
