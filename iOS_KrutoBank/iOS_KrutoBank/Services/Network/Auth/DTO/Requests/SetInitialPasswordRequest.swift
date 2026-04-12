struct SetInitialPasswordRequest: Encodable, Sendable {
    let userId: String
    let newPassword: String
}
