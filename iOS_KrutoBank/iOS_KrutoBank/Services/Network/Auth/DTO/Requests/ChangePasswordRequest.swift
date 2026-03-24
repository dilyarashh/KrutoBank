struct ChangePasswordRequest: Encodable {
    let currentPassword: String
    let newPassword: String
}
