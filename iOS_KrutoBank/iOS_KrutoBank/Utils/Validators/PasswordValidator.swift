import Foundation

struct PasswordValidator: TextInputValidator {
    func validate(_ text: String) -> TextInputValidationResult {
        let password = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let hasMinLength = password.count >= 6

        let isValid = hasMinLength

        return .init(
            isValid: isValid,
            error: AppStrings.Login.passwordError
        )
    }
}
