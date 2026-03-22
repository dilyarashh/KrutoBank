import Foundation

struct TransferRequest: Encodable {
    let fromAccountId: String
    let toAccountId: String
    let amount: Double
    let currency: String
}
