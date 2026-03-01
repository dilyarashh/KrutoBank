import SwiftUI

struct TextInput: View {
    enum InputType {
        case text
        case password
    }

    @Binding private var text: String

    private let placeholder: String
    private let title: String?
    private let type: InputType
    private let validator: TextInputValidator?
    private let formatter: TextInputFormatter?
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?

    @State private var errorText: String?
    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        placeholder: String,
        title: String? = nil,
        type: InputType = .text,
        validator: TextInputValidator? = nil,
        formatter: TextInputFormatter? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.title = title
        self.type = type
        self.validator = validator
        self.formatter = formatter
        self.keyboardType = keyboardType
        self.textContentType = textContentType
    }

    private var borderColor: Color {
        if errorText != nil { return .AppColor.textError }
        return isFocused ? .AppColor.primaryPink : .AppColor.primaryLight.opacity(0.6)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title {
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.AppColor.textSecondary)
                    .padding(.horizontal, 8)
            }

            inputField
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color.AppColor.primaryWhite)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(borderColor, lineWidth: isFocused ? 1.5 : 1)
                }

            if let errorText {
                Text(errorText.localization)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.AppColor.textError)
                    .padding(.horizontal, 8)
            }
        }
        .onChange(of: text) { newValue in
            if let formatter {
                let formattedText = formatter.format(newValue)
                if formattedText != newValue {
                    text = formattedText
                }
            }
            errorText = nil
        }
        .onChange(of: isFocused) { focused in
            guard !focused, let validator else { return }
            let result = validator.validate(text)
            errorText = result.isValid ? nil : result.error
        }
    }

    @ViewBuilder
    private var inputField: some View {
        switch type {
        case .text:
            TextField(placeholder.localization, text: $text)
                .focused($isFocused)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

        case .password:
            SecureField(placeholder.localization, text: $text)
                .focused($isFocused)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
    }
}
