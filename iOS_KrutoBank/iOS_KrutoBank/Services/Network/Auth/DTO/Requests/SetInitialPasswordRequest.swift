struct SetInitialPasswordRequest: Encodable {
    let userId: String
    let newPassword: String
}
