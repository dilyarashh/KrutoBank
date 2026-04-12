enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

extension HTTPMethod {
    var isMutation: Bool {
        switch self {
        case .post, .put, .patch, .delete:
            return true
        case .get:
            return false
        }
    }
}
