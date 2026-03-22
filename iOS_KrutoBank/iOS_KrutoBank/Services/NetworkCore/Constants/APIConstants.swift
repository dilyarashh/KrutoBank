import Foundation

enum APIConstants {
    // MARK: - Base URLs
    static let authServiceBaseURL        = URL(string: "http://localhost:5270")!
    static let usersServiceBaseURL       = URL(string: "http://localhost:5260")!
    static let accountsServiceBaseURL    = URL(string: "http://localhost:5251")!
    static let creditsServiceBaseURL     = URL(string: "http://localhost:5173")!
    static let appSettingsServiceBaseURL = URL(string: "http://localhost:5165")!

    // MARK: - WebSocket
    static func accountOperationsWebSocket(accountId: String) -> URL {
        URL(string: "ws://localhost:5251/ws/accounts/\(accountId)/operations")!
    }

    // MARK: - Users
    enum Users {
        static let myself = "/api/users/myself"
    }

    // MARK: - Accounts
    enum Accounts {
        static let open = "/api/accounts"
        static let close = "/api/accounts"
        static let deposit = "/api/accounts/deposit"
        static let withdraw = "/api/accounts/withdraw"
        static let transfer = "/api/accounts/transfer"
        static let myAccounts = "/api/accounts/my-accounts"
        static func myOperations(accountId: String) -> String {
            "/api/accounts/\(accountId)/my-operations"
        }
        static func myAccount(accountId: String) -> String {
            "/api/accounts/\(accountId)/my-account"
        }
    }

    // MARK: - Credits
    enum Credits {
        static let tariffs = "/api/Credits/tariffs"
        static let takeLoan = "/api/Credits/loans/take"
        static let repayLoan = "/api/Credits/loans/repay"
        static func userLoans(userId: String) -> String {
            "/api/Credits/users/\(userId)/loans"
        }
        static func loanOperations(userId: String, loanId: String) -> String {
            "/api/Credits/users/\(userId)/loans/\(loanId)/operations"
        }
        static func overduePayments(userId: String) -> String {
            "/api/Credits/users/\(userId)/overdue"
        }
        static func creditRating(userId: String) -> String {
            "/api/Credits/users/\(userId)/rating"
        }
    }

    // MARK: - App Settings
    enum AppSettings {
        static let settings = "/api/settings/me"
        static let theme = "/api/settings/theme"
        static let hiddenAccounts = "/api/settings/hidden-accounts"
    }

    // MARK: - Exchange Rates
    static func exchangeRatesURL(base: String) -> URL {
        URL(string: "https://api.exchangerate-api.com/v4/latest/\(base)")!
    }
}
