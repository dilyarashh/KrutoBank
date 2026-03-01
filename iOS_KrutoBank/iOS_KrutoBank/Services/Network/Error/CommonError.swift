import Foundation
import SwiftUI

enum CommonError: Error, Equatable {
    case sessionExpired
    case serverUnavailable
    case parsingFailed
    case networkUnavailable
    case timeout
    case unknown
}

extension CommonError {
    static func map(_ error: Error) -> CommonError {
        if let common = error as? CommonError { return common }

        guard let networkError = error as? NetworkError else { return .unknown }

        switch networkError {
        case .unauthorized:
            return .sessionExpired

        case .noResponse:
            return .serverUnavailable

        case .decodingFailed:
            return .parsingFailed

        case .transportError(let underlying):
            if let urlError = underlying as? URLError, urlError.code == .timedOut {
                return .timeout
            }
            return .networkUnavailable

        default:
            return .unknown
        }
    }

    var errorMessage: String {
        switch self {
        case .networkUnavailable:
            return AppStrings.Errors.networkUnavailable
        case .timeout:
            return AppStrings.Errors.timeout
        case .serverUnavailable:
            return AppStrings.Errors.serverUnavailable
        case .parsingFailed:
            return AppStrings.Errors.parsingFailed
        case .sessionExpired:
            return AppStrings.Login.sessionExpired
        case .unknown:
            return AppStrings.Errors.unknown
        }
    }
}
