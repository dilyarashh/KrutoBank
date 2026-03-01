import Foundation

private extension Constants {
    static let phoneLength = 11
}

struct PhoneValidator: TextInputValidator {
    func validate(_ text: String) -> TextInputValidationResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let digitsOnlyText = trimmedText.filter { $0.isNumber }

        let isValid = digitsOnlyText.count == Constants.phoneLength

        return .init(
            isValid: isValid,
            error: AppStrings.Login.phoneNumberError
        )
    }
}
