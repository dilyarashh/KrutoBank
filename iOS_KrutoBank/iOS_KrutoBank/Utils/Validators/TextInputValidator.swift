import SwiftUI

protocol TextInputValidator {
    func validate(_ text: String) -> TextInputValidationResult
}

struct TextInputValidationResult {
    let isValid: Bool
    let error: String
}
