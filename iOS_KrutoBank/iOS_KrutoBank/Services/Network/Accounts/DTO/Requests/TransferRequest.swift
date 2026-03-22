import Foundation

struct TransferRequest: Encodable {
    let fromAccountId: String
    let string: String
    let amount: Double
    let currency: String
}
