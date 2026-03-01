import Foundation

final class KeychainTokenStorage: TokenStorageProtocol {
    private let store: KeyValueStoreProtocol

    init(
        service: String = KeychainConstants.tokenService,
        accessGroup: String? = nil,
        accessibility: CFString = kSecAttrAccessibleAfterFirstUnlock
    ) {
        self.store = KeychainStoreFactory.make(
            service: service,
            accessGroup: accessGroup,
            accessibility: accessibility
        )
    }

    var accessToken: String? {
        get {
            if let data = try? store.get(for: KeychainConstants.accessToken) {
                return String(data: data, encoding: .utf8)
            }
            else {
                return nil
            }
        }
        set {
            if let value = newValue {
                try? store.set(Data(value.utf8), for: KeychainConstants.accessToken)
            }
            else {
                try? store.delete(for: KeychainConstants.accessToken)
            }
        }
    }

    func clear() {
        try? store.delete(for: KeychainConstants.accessToken)
    }
}
