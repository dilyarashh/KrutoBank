import Foundation

enum APIConstants {
    // MARK: - Base URLs
    static let usersServiceBaseURL = URL(string: "http://localhost:5260")!
    static let accountsServiceBaseURL = URL(string: "http://localhost:5251")!
    static let creditsServiceBaseURL = URL(string: "http://localhost:5173")!

    // MARK: - Users
    enum Users {
        static let login = "/api/auth/login"
        static let logout = "/api/auth/logout"
        static let myself = "/api/users/myself"
    }

    // MARK: - Accounts
    enum Accounts {
        static let open = "/api/accounts"
        static let close = "/api/accounts"
        static let deposit = "/api/accounts/deposit"
        static let withdraw = "/api/accounts/withdraw"
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
    }
}
