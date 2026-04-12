struct ChangePasswordRequest: Encodable, Sendable {
    let currentPassword: String
    let newPassword: String
}
