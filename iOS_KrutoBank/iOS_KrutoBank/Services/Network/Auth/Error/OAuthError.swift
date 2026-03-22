import Foundation

enum OAuthError: LocalizedError {
    case userCancelled
    case authSessionFailed(Error)
    case missingCallbackURL
    case invalidCallbackURL
    case missingAuthCode
    case tokenExchangeFailed
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .userCancelled:             
            return "Вход отменён"
        case .authSessionFailed(let e):   
            return "Ошибка аутентификации: \(e.localizedDescription)"
        case .missingCallbackURL:        
            return "Не получен callback URL"
        case .invalidCallbackURL:        
            return "Некорректный callback URL"
        case .missingAuthCode:           
            return "Отсутствует код авторизации"
        case .tokenExchangeFailed:        
            return "Не удалось обменять код на токены"
        case .serverError(let msg):      
            return "Ошибка сервера: \(msg)"
        }
    }
}
