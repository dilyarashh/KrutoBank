import Foundation

typealias Parameters = [String: Any]

enum HTTPTask {
    case request
    case requestBody(Encodable)
    case requestUrlParameters(Parameters)
    case requestFormUrlEncoded(Parameters)
    case requestMultipart(Parameters)
}
