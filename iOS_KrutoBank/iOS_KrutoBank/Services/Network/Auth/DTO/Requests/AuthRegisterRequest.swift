struct AuthRegisterRequest: Encodable {
    let firstName: String
    let lastName: String
    let middleName: String
    let phone: String
    let email: String
    let birthday: String
    let password: String
    let role: Int
}
