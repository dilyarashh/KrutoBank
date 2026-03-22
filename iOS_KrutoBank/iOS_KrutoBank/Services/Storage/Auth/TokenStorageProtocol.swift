protocol TokenStorageProtocol: AnyObject {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }

    func clear()
}
