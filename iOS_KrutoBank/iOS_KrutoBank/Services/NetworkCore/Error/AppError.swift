import Foundation

// MARK: - AppError — unified error hierarchy
enum AppError: LocalizedError {
    // Network layer
    case networkUnavailable
    case timeout
    case serverUnavailable
    case unauthorized
    case forbidden
    case serverError(code: Int, message: String?)
    case decodingFailed
    // Business logic
    case insufficientFunds
    case accountClosed
    case creditLimitExceeded
    // App-level
    case unknown(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:    return "Нет соединения с сетью"
        case .timeout:               return "Превышено время ожидания"
        case .serverUnavailable:     return "Сервер недоступен"
        case .unauthorized:          return "Сессия истекла. Войдите снова"
        case .forbidden:             return "Нет доступа к этому ресурсу"
        case .serverError(_, let m): return m ?? "Ошибка сервера"
        case .decodingFailed:        return "Ошибка обработки данных"
        case .insufficientFunds:     return "Недостаточно средств"
        case .accountClosed:         return "Счёт закрыт"
        case .creditLimitExceeded:   return "Кредитный лимит исчерпан"
        case .unknown(let e):        return e.localizedDescription
        }
    }

    var isFatal: Bool {
        switch self {
        case .unauthorized:
            return true
        default:
            return false
        }
    }

    // MARK: - Convert from NetworkError
    static func from(_ networkError: NetworkError) -> AppError {
        switch networkError {
        case .unauthorized:
            return .unauthorized
        case .noResponse:
            return .serverUnavailable
        case .decodingFailed:
            return .decodingFailed
        case .serverError(let code, let m):
            switch code {
            case 403:
                return .forbidden
            case 422:
                return .insufficientFunds
            default:
                return .serverError(code: code, message: m)
            }
        case .circuitBreakerOpen:
            return .serverUnavailable
        case .transportError:
            return .networkUnavailable
        case .invalidURL, .encodingFailed:
            return .unknown(underlying: networkError)
        }
    }

    // MARK: - Convert from any Error
    static func from(_ error: Error) -> AppError {
        if let appErr = error as? AppError { return appErr }
        if let netErr = error as? NetworkError { return .from(netErr) }
        return .unknown(underlying: error)
    }
}
