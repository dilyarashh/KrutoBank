struct UserAccountResponse: Decodable {
    let userId: String
    let accountId: String
    let accountName: String
    let balance: Double
    let isClosed: Bool
}
