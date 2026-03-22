import Foundation

struct TransferRequest: Encodable {
    let fromAccountId: String
    let toPhone: String
    let amount: Double
}
