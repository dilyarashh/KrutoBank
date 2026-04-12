import Foundation

struct TransferRequest: Encodable, Sendable {
    let fromAccountId: String
    let toPhone: String
    let amount: Double
}
