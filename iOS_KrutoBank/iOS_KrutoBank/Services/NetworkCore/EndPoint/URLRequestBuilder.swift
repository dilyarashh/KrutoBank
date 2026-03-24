import Foundation

enum URLRequestBuilder {
    static func build(from endpoint: EndPoint) throws -> URLRequest {
        let safePath =
            endpoint.path.hasPrefix("/")
            ? String(endpoint.path.dropFirst())
            : endpoint.path

        let url = endpoint.baseURL.appendingPathComponent(safePath)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if request.value(forHTTPHeaderField: HTTPHeader.accept) == nil {
            request.setValue(HTTPHeaderValue.json, forHTTPHeaderField: HTTPHeader.accept)
        }

        switch endpoint.task {
        case .request:
            break

        case .requestBody(let data):
            do {
                request.httpBody = try JSONEncoder().encode(data)

                if request.value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
                    request.setValue(
                        HTTPHeaderValue.json,
                        forHTTPHeaderField: HTTPHeader.contentType
                    )
                }

                if request.value(forHTTPHeaderField: HTTPHeader.accept) == nil {
                    request.setValue(HTTPHeaderValue.json, forHTTPHeaderField: HTTPHeader.accept)
                }
            }
            catch is EncodingError {
                throw NetworkError.encodingFailed
            }
            catch {
                throw NetworkError.transportError(underlying: error)
            }

        case .requestUrlParameters(let parameters):
            request.url = try addQuery(parameters, to: request.url)

        case .requestFormUrlEncoded(let parameters):
            if request.value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: HTTPHeader.contentType)
            }
            let bodyString = parameters.map { k, v in
                "\(k)=\(String(describing: v).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)

        case .requestMultipart(let parameters):
            let boundary = "Boundary-\(UUID().uuidString)"
            if request.value(forHTTPHeaderField: HTTPHeader.contentType) == nil {
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: HTTPHeader.contentType)
            }
            var body = Data()
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(String(describing: value))\r\n".data(using: .utf8)!)
            }
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
        }

        return request
    }
}

// MARK: - Helpers
private extension URLRequestBuilder {
    static func addQuery(_ parameters: Parameters, to url: URL?) throws -> URL {
        guard let url else {
            throw NetworkError.invalidURL
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        var items = components.queryItems ?? []

        for (key, value) in parameters {
            let string = String(describing: value)
            items.append(URLQueryItem(name: key, value: string))
        }

        components.queryItems = items

        guard let newURL = components.url else {
            throw NetworkError.invalidURL
        }

        return newURL
    }
}
